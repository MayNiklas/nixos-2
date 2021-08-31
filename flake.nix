{
  description = "My main system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-21.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # mayniklas.url = "github:mayniklas/nixos";
    # mayniklas.inputs.nixpkgs.follows = "nixpkgs";
    # mayniklas.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    # mayniklas.inputs.home-manager.follows = "home-manager";
  };

  outputs = { self, ... }@inputs:
    with inputs;
    let

      # Function to create defult (common) system config options
      defFlakeSystem = systemArch: baseCfg:
        nixpkgs.lib.nixosSystem {
          system = "${systemArch}";
          modules = [
            # Add home-manager option to all configs
            ({ ... }: {
              imports = builtins.attrValues self.nixosModules
                #++ [ mayniklas.nixosModules.xserver ]
                ++ [
                  {
                    # Set the $NIX_PATH entry for nixpkgs. This is necessary in
                    # this setup with flakes, otherwise commands like `nix-shell
                    # -p pkgs.htop` will keep using an old version of nixpkgs.
                    # With this entry in $NIX_PATH it is possible (and
                    # recommended) to remove the `nixos` channel for both users
                    # and root e.g. `nix-channel --remove nixos`. `nix-channel
                    # --list` should be empty for all users afterwards
                    nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
                    nixpkgs.overlays = [ self.overlay self.overlay-unstable ];
                  }
                  baseCfg
                  home-manager.nixosModules.home-manager
                  # DONT set useGlobalPackages! It's not necessary in newer
                  # home-manager versions and does not work with configs using
                  # `nixpkgs.config`
                  { home-manager.useUserPackages = true; }
                ];
              # Let 'nixos-version --json' know the Git revision of this flake.
              system.configurationRevision =
                nixpkgs.lib.mkIf (self ? rev) self.rev;
              nix.registry.nixpkgs.flake = nixpkgs;
            })
          ];
        };

    in {

      # Expose overlay to flake outputs, to allow using it from other flakes.
      overlay = final: prev: (import ./overlays) final prev;

      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs (map (x: {
        name = x;
        value = import (./modules + "/${x}");
      }) (builtins.attrNames (builtins.readDir ./modules)));

      # Each subdirectory in ./machins is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = {

        laptop = defFlakeSystem "x86_64-linux" {
          imports = [
            # Machine specific config
            (import (./machines/laptop/configuration.nix) { inherit self; })
          ];
        };

        arm = defFlakeSystem "aarch64-linux" {
          imports = [
            # Machine specific config
            (import (./machines/arm/configuration.nix) { inherit self; })
          ];
        };

        pi4b = defFlakeSystem "aarch64-linux" {
          imports = [
            # Machine specific config
            (import (./machines/pi4b/configuration.nix) { inherit self; })
          ];
        };

        majaArm = defFlakeSystem "aarch64-linux" {
          imports = [
            # Machine specific config
            (import (./machines/majaArm/configuration.nix) { inherit self; })
          ];
        };

      };
    } //

    # (flake-utils.lib.eachSystem [ "aarch64-linux" "i686-linux" "x86_64-linux" ])
    (flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ]) (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
          config = {
            allowUnsupportedSystem = true;
            allowUnfree = true;
          };
        };
      in rec {

        packages = flake-utils.lib.flattenTree {
          larbs_scripts = pkgs.larbs_scripts;
          #   anki-bin = pkgs.anki-bin;
          #   darknet = pkgs.darknet;
          #   plex = pkgs.plex;
          #   plexRaw = pkgs.plexRaw;
          #   tautulli = pkgs.tautulli;
        };

        apps = {
          # Allow custom packages to be run using `nix run`
          #   anki-bin = flake-utils.lib.mkApp { drv = packages.anki-bin; };
          #   darknet = flake-utils.lib.mkApp { drv = packages.darknet; };
          #   plex = flake-utils.lib.mkApp { drv = packages.plex; };
          #   plexRaw = flake-utils.lib.mkApp { drv = packages.plexRaw; };
          #   tautulli = flake-utils.lib.mkApp { drv = packages.tautulli; };
        };
      });
}
