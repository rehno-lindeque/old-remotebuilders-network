{ pkgs ? import <nixpkgs> {}
, aarch64Pkgs ? import ./nix {}
, stateFilePath ? (builtins.getEnv "PWD" + "/secrets/localstate.nixops")
, secretsEnvPath ? (builtins.getEnv "PWD" + "/secrets/.ec2-env")
}:

let
  remoteBuildersNetwork = pkgs.callPackage ./. { inherit aarch64Pkgs stateFilePath secretsEnvPath; };
in
pkgs.stdenv.mkDerivation
  {
    name = "remotebuilders-network-provisioning-environment";
    version = "0.0.0";
    buildInputs =
      with pkgs;
      [
        direnv
        git-crypt
        nixops
        remoteBuildersNetwork
      ];
    shellHook =
      let
        nc="\\e[0m"; # No Color
        white="\\e[1;37m";
        black="\\e[0;30m";
        blue="\\e[0;34m";
        light_blue="\\e[1;34m";
        green="\\e[0;32m";
        light_green="\\e[1;32m";
        cyan="\\e[0;36m";
        light_cyan="\\e[1;36m";
        red="\\e[0;31m";
        light_red="\\e[1;31m";
        purple="\\e[0;35m";
        light_purple="\\e[1;35m";
        brown="\\e[0;33m";
        yellow="\\e[1;33m";
        grey="\\e[0;30m";
        light_grey="\\e[0;37m";
      in
        ''
        echo ""
        printf "${white}"
        echo "------------------------------------------------"
        echo "Remote builders network provisioning environment"
        echo "------------------------------------------------"
        printf "${nc}"
        ${remoteBuildersNetwork}/bin/remotebuilders-help

        # Hook up direnv
        if [ -n "$BASH_VERSION" ]; then
          eval "$(direnv hook bash)"
        elif [ -n "$ZSH_VERSION" ]; then 
          eval "$(direnv hook zsh)"
        else
          echo "Unknown shell"
        fi

        # Use localstate.nixops file in this directory
        export NIXOPS_STATE=${stateFilePath}

        # set default deployment name
        export NIXOPS_DEPLOYMENT=remotebuilders
        '';
  }


