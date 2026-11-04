{ hostname, ... }:
let
  shared = builtins.readFile ./config.kdl;
  outputs = builtins.readFile ./outputs-${hostname}.kdl;
in
{
  xdg.configFile."niri/config.kdl".text = shared + "\n" + outputs;
}
