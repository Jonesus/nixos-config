#!/usr/bin/env bash
# Update the flake's inputs, but only to versions at least DAYS old (default 7):
# a cooldown like npm's/pip's minimum release age.
#
#   scripts/update-flake-aged.sh [DAYS]
#
# - nixpkgs: the newest nixos-unstable channel release published before the
#   cutoff (channel releases are the commits Hydra built and tested; picking a
#   commit by date could land on one that never was).
# - noctalia: the newest commit before the cutoff whose package is in
#   noctalia.cachix.org, so it never needs a local compile.
# - other GitHub inputs: the newest commit on their branch before the cutoff.
#
# Inputs never move backwards. Pins are written with --override-input, which
# keeps the flake.nix source in flake.lock, so a later plain `nix flake lock`
# or `nh os switch` keeps them. Prints a Markdown summary on stdout.
# Set GITHUB_TOKEN to avoid GitHub API rate limits.
set -euo pipefail

days=${1:-7}
cd "$(dirname "$0")/.."

cutoff=$(date -u -d "-$days days" +%s)
cutoff_iso=$(date -u -d "@$cutoff" +%Y-%m-%dT%H:%M:%SZ)
system=x86_64-linux

gh_api() {
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    -H "Accept: application/vnd.github+json" "https://api.github.com/$1"
}

# Newest release of a nixos channel published before the cutoff, as "rev epoch".
channel_rev() {
  local url path name prefix token="" page best="" best_t=0 key t rev
  url=$(curl -fsSI "https://channels.nixos.org/$1" | tr -d '\r' |
    awk 'tolower($1)=="location:"{print $2}')
  path=${url#https://releases.nixos.org/}
  name=${path##*/}
  path=${path%/*}
  if [[ $name == *pre* ]]; then prefix=${name%%pre*}pre; else prefix=${name%.*.*}.; fi
  while :; do
    page=$(curl -fsSL "https://nix-releases.s3.amazonaws.com/?list-type=2&prefix=$path/$prefix${token:+&continuation-token=$(jq -rn --arg t "$token" '$t|@uri')}")
    while read -r key t; do
      t=$(date -u -d "$t" +%s)
      if ((t <= cutoff && t > best_t)); then best=${key%/git-revision} best_t=$t; fi
    done < <(grep -o '<Key>[^<]*/git-revision</Key><LastModified>[^<]*' <<<"$page" |
      sed -E 's#<Key>([^<]*)</Key><LastModified>#\1 #')
    token=$(grep -o '<NextContinuationToken>[^<]*' <<<"$page" | sed 's/.*>//' || true)
    [[ -n $token ]] || break
  done
  # The current series may not reach back to the cutoff right after a
  # version bump; then leave nixpkgs where it is.
  [[ -n $best ]] || return 0
  # Releases are picked by publish time, but report the commit's own time:
  # that's what flake.lock's lastModified holds and gets compared against.
  rev=$(curl -fsSL "https://releases.nixos.org/$best/git-revision")
  echo "$rev $(date -u -d "$(gh_api "repos/NixOS/nixpkgs/commits/$rev" | jq -r .commit.committer.date)" +%s)"
}

# Newest commit on a branch before the cutoff, as "rev epoch". With a cache
# URL, the newest one whose default package is in that binary cache.
github_rev() {
  local owner=$1 repo=$2 ref=$3 cache=${4:-} rev t out
  while read -r rev t; do
    if [[ -n $cache ]]; then
      out=$(nix eval --raw "github:$owner/$repo/$rev#packages.$system.default.outPath" 2>/dev/null) || continue
      out=${out#/nix/store/}
      curl -fsS -o /dev/null "$cache/${out%%-*}.narinfo" 2>/dev/null || continue
    fi
    echo "$rev $(date -u -d "$t" +%s)"
    return 0
  done < <(gh_api "repos/$owner/$repo/commits?per_page=30&until=$cutoff_iso${ref:+&sha=$ref}" |
    jq -r '.[] | "\(.sha) \(.commit.committer.date)"')
}

declare -A cache=([noctalia]=https://noctalia.cachix.org)

overrides=()
rows=()
for input in $(jq -r '.nodes.root.inputs | keys[]' flake.lock); do
  node=$(jq -r --arg i "$input" '.nodes.root.inputs[$i]' flake.lock)
  read -r type owner repo ref old old_t < <(jq -r --arg n "$node" '.nodes[$n] |
    [.original.type, .original.owner, .original.repo, (.original.ref // ""),
     .locked.rev, .locked.lastModified] | map(if . == "" then "-" else tostring end) | join(" ")' flake.lock)
  [[ $ref == - ]] && ref=""
  if [[ $type != github ]]; then
    echo "skipping $input: $type inputs aren't handled" >&2
    continue
  fi

  if [[ $owner/$repo == NixOS/nixpkgs && $ref == nixos-* ]]; then
    new=$(channel_rev "$ref")
  else
    new=$(github_rev "$owner" "$repo" "$ref" "${cache[$input]:-}")
  fi
  if [[ -z $new ]]; then
    echo "skipping $input: no suitable version older than $days days" >&2
    continue
  fi
  read -r rev t <<<"$new"
  if [[ $rev == "$old" ]] || ((t <= old_t)); then continue; fi

  overrides+=(--override-input "$input" "github:$owner/$repo/$rev")
  rows+=("| $input | $(date -u -d "@$old_t" +%F) | $(date -u -d "@$t" +%F) | [${old:0:7}…${rev:0:7}](https://github.com/$owner/$repo/compare/$old...$rev) |")
done

if ((${#overrides[@]} == 0)); then
  echo "Nothing to update: every input is already at its newest version older than $days days." >&2
  exit 0
fi

nix flake lock "${overrides[@]}" >&2

echo "Flake inputs updated to their newest versions from at least $days days ago (cutoff ${cutoff_iso%T*})."
echo
echo "| Input | From | To | Changes |"
echo "|---|---|---|---|"
printf '%s\n' "${rows[@]}"
