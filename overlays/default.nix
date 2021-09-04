self: super: {
  # Custom packages. Will be made available on all machines and used where
  # needed.
  larbs_scripts = super.pkgs.callPackage ../packages/larbs_scripts { };
  fabric-server = super.pkgs.callPackage ../packages/fabric-server { };
  overviewer = super.pkgs.callPackage ../packages/overviewer {
    # buildPythonApplication = super.python.pkgs.buildPythonApplication;
    # setuptools = super.python.pkgs.setuptools;
    wrapPython = super.python3.pkgs.wrapPython;
    makeWrapper = super.makeWrapper;
  };
  wrapOBS = super.pkgs.callPackage ../packages/ndi/obs-wrapper.nix { };
  ndi = super.pkgs.callPackage ../packages/ndi { };
  obs-ndi = super.ndi.overrideAttrs (old: {
    buildInputs = [ self.unstable.obs-studio super.qtbase self.ndi ];
  });
  obs = (self.wrapOBS {
    plugins = with self.unstable.obs-studio-plugins; [
      super.obs-ndi
      obs-websocket
      obs-move-transition
    ];
  });

  # override with newer version from nixpkgs-unstable
  # tautulli = self.unstable.tautulli;

  # override with newer version from nixpkgs-unstable (home-manager related)
  discord = self.unstable.discord;
  neovim-unwrapped = self.unstable.neovim-unwrapped;
  obs-studio = self.unstable.obs-studio;
  signal-desktop = self.unstable.signal-desktop;
  spotify = self.unstable.spotify;
  vscode = self.unstable.vscode;
  youtube-dl = self.unstable.youtube-dl;
  zoom-us = self.unstable.zoom-us;

  # suckless packages
  dwm = (super.dwm.overrideAttrs (oldAttrs: rec {
    src = super.pkgs.fetchFromGitHub {
      owner = "luksab";
      repo = "dwm";
      rev = "4480b7c422d3dd5e315289d35e203871eb4476b2";
      sha256 = "sha256-PIDPTFLPNCTHQGz6HKYxbF9U9Aa9vnTRgMXyCwUqg7w=";
      name = "dwm";
    };
  }));

  dwmblocks = (super.dwmblocks.overrideAttrs (oldAttrs: rec {
    src = super.pkgs.fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "dwmblocks";
      rev = "66f31c307adbdcc2505239260ecda24a49eea7af";
      sha256 = "sha256-j3wCRyl1+0D2XcdqhE5Zgf53bEXhcaU4dvdyYG9LZ2g=";
    };
    patches = [ ../packages/suckless/dwmblocks.patch ];
  }));

  dmenu = (super.dmenu.overrideAttrs (oldAttrs: rec {
    src = super.pkgs.fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "dmenu";
      rev = "3a6bc67fbd6df190b002d33f600a6465cad9cfb8";
      sha256 = "sha256-qwOcJqYGMftFwayfYA3XM0xaOo6ALV4gu1HpFRapbFg=";
    };
  }));

  st = (super.st.overrideAttrs (oldAttrs: rec {
    buildInputs = oldAttrs.buildInputs
      ++ [ super.pkgs.git super.pkgs.harfbuzz ];
    src = super.pkgs.fetchFromGitHub {
      owner = "LukeSmithxyz";
      repo = "st";
      rev = "e053bd6036331cc7d14f155614aebc20f5371d3a";
      sha256 = "sha256-WwjuNxWoeR/ppJxJgqD20kzrn1kIfgDarkTOedX/W4k=";
      name = "st";
    };
    patches = [ ../packages/suckless/st.patch ];
    fetchSubmodules = true;
  }));
}
