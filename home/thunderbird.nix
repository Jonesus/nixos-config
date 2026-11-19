_:
let
  realName = "Joonas Palosuo";
  # pilke.app mail is hosted at Migadu (IMAP/SMTP hosts come from the flavor;
  # the login is the full address). Passwords are entered once in Thunderbird.
  migadu = address: {
    inherit address realName;
    flavor = "migadu.com";
    thunderbird.enable = true;
  };
in
{
  programs.thunderbird = {
    enable = true;
    profiles.default = {
      isDefault = true;
      accountsOrder = [
        "cellbytes"
        "pilke"
        "pilke-contact"
        "pilke-turvallisuus"
      ];
    };
  };

  accounts.email.accounts = {
    # Microsoft 365: the flavor sets the hosts and OAuth2, so Thunderbird
    # opens a Microsoft sign-in window on first use instead of asking for a
    # password.
    cellbytes = {
      primary = true;
      address = "joonas@cellbytes.io";
      inherit realName;
      flavor = "outlook.office365.com";
      thunderbird.enable = true;
    };

    pilke = migadu "joonas@pilke.app";
    pilke-contact = migadu "contact@pilke.app";
    pilke-turvallisuus = migadu "turvallisuus@pilke.app";
  };
}
