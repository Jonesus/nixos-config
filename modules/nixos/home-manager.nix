{ inputs, user, config, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
    extraSpecialArgs = {
      inherit inputs user;
      hostname = config.networking.hostName;
    };
    users.${user} = import ../../home;
  };
}
