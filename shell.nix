# { pkgs ? import <nixpkgs> {}
# { pkgs ? import ./nix { localSystem.system = "x86_64-linux"; crossSystem.system = "aarch64-linux"; }
{ pkgs ? import ./nix { }
}:

pkgs.stdenv.mkDerivation
  {
    name = "remotebuilders-network-provisioning-environment";
    version = "0.0.0";
    buildInputs =
      # Nix shell dependencies
      with pkgs;
      [
        direnv
        git-crypt
        # nix
        nixops
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
        echo "Shorthands:"
        echo ""
        echo "aarch64-ip"
        echo "aarch64-up"
        echo "aarch64-down"
        echo "aarch64-ssh"
        echo "aarch64-copy"
        echo "aarch64-realise"
        echo "aarch64-realise-bg"

        echo ""

        # Hook up direnv
        if [ -n "$BASH_VERSION" ]; then
          eval "$(direnv hook bash)"
        elif [ -n "$ZSH_VERSION" ]; then 
          eval "$(direnv hook zsh)"
        else
          echo "Unknown shell"
        fi

        aarch64-ip(){
          nixops info --plain 2>/dev/null | grep remotebuilder-aarch64 | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' | head -1 | tr -d '\n' 
        }

        aarch64-up(){
          nixops deploy --include remotebuilder-aarch64
          # pull down host key 
        }

        aarch64-down(){
          nixops destroy --include remotebuilder-aarch64
        }
        aarch64-ssh(){
          nixops ssh remotebuilder-aarch64
        }
        aarch64-copy(){
          nix copy --to "ssh://root@$(aarch64-ip)?ssh-key=/home/me/.ssh/id_accesspoint" $@
        }
        aarch64-realise(){
          nix copy --to "ssh://root@$(aarch64-ip)?ssh-key=/home/me/.ssh/id_accesspoint" $@
          nixops ssh remotebuilder-aarch64 "nix-store --realise $@"
        }
        aarch64-realise-bg(){
          nix copy --to "ssh://root@$(aarch64-ip)?ssh-key=/home/me/.ssh/id_accesspoint" $@
          nixops ssh remotebuilder-aarch64 "rm nohup.out ; nohup nix-store --realise $@ &"
          nixops ssh remotebuilder-aarch64 "tail -f nohup.out"
        }

        # Use localstate.nixops file in this directory
        export NIXOPS_STATE=$(pwd)/secrets/localstate.nixops

        # set default deployment name
        export NIXOPS_DEPLOYMENT=remotebuilders

        # load secrets into the shell environment
        if [[ -f ./secrets/.my-envrc ]]; then
          source ./secrets/.my-envrc
        fi

        # Use a specific (unstable) channel for deploying nixpkgs
        # NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos-unstable/nixpkgs:$NIX_PATH
        # NIX_PATH=nixpkgs=${pkgs.src}:$NIX_PATH
        # NIX_PATH=nixpkgs=${pkgs.path}
        '';
  }


