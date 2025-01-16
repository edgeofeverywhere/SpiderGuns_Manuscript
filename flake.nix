{
  description = "CI Flake for Spiders + Guns Manuscript";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        rPackages = with pkgs.rPackages; [
          tidyverse
          paletteer
          lme4
          afex
          svglite
          kableExtra
          knitr
          gridExtra
          bayesplot
          brms
          emmeans
          RColorBrewer
          systemfonts
          splithalf
          ggthemes
          osfr
          webshot2
          magick
        ];

        # Create R wrapper with packages
        customR = pkgs.rWrapper.override {
          packages = rPackages;
        };

        # create site-library env with all R packages - for quarto to build with
        rLibrary = pkgs.buildEnv {
          name = "r-library";
          paths = rPackages;
        };

        buildInputs = with pkgs; [
          customR
          quarto
          texlive.combined.scheme-full
          fontconfig
          harfbuzz
          fribidi
          ubuntu_font_family
          lmodern
          chromium
          librsvg
          biber
        ];

      in {
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          
          shellHook = ''
            export R_LIBS_SITE="${rLibrary}/library"
            export R_LIBS_USER="$PWD/.R/library"
            mkdir -p $R_LIBS_USER
            export FONTCONFIG_PATH="${pkgs.fontconfig.out}/etc/fonts"
            export XDG_CACHE_HOME="$PWD/.cache"
            export QUARTO_CACHE_HOME="$PWD/.cache/quarto"
            mkdir -p $QUARTO_CACHE_HOME
          '';
        };

        packages.default = pkgs.stdenv.mkDerivation {
          name = "quarto-builder";
          src = ./.;
          inherit buildInputs;
          dontStrip = true;

          buildPhase = ''
            export FONTCONFIG_PATH="${pkgs.fontconfig.out}/etc/fonts"
            export R_LIBS_SITE="${rLibrary}/library"
            export R_LIBS_USER="$TMPDIR/R/library"
            export XDG_CACHE_HOME="$TMPDIR/.cache"
            export QUARTO_CACHE_HOME="$TMPDIR/.cache/quarto"
            export HOME="$TMPDIR"
            export NODE_OPTIONS="--stack-size=274877906944"
            export QUARTO_VERBOSE=true
            
            mkdir -p $R_LIBS_USER $QUARTO_CACHE_HOME
            
            quarto render SG-Analysis.qmd --to pdf
            quarto render SG-Analysis.qmd --to html
            
            tar czf sg-analysis-files.tar.gz SG-Analysis_files/
          '';

          installPhase = ''
            mkdir -p $out
            cp -p SG-Analysis.pdf $out/
            cp -p SG-Analysis.html $out/
            if [ -f SG-Analysis.tex ]; then
              cp -p SG-Analysis.tex $out/
            fi
            cp -p sg-analysis-files.tar.gz $out/
          '';
        };
      }
    );
}