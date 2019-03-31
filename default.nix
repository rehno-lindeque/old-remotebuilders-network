{ lib, linkFarm, writeShellScriptBin, nixops, nix
, aarch64Pkgs ? import ./nix {}
, sshKeyPath ? "/home/me/.ssh/id_accesspoint"
, stateFilePath  # Path to a .nixops file that contains nix state
, secretsEnvPath # Path to a shell file that exports EC2_ACCESS_KEY and EC2_SECRET_KEY
}:

let
  networkScripts = lib.fix (self:
    lib.mapAttrs writeShellScriptBin {
      remotebuilders-help = ''
        echo "USAGE:"
        echo ""
        echo "remotebuilders-help"
        echo "remotebuilders-ops"
        echo "aarch64-ip"
        echo "aarch64-up"
        echo "aarch64-down"
        echo "aarch64-ssh"
        echo "aarch64-copy"
        echo "aarch64-realise"
        echo "aarch64-realise-bg"
        echo "aarch64-copy-id"
        echo ""
        '';
      remotebuilders-ops = ''
        if [[ -f ${secretsEnvPath} ]]; then
          echo "using secrets in ${secretsEnvPath}"
          source ${secretsEnvPath}
        else
          echo "secrets path ${secretsEnvPath} does not exist"
        fi
        echo "${nixops}/bin/nixops $1 -s ${stateFilePath} -d remotebuilders ''${@:2}"
        ${nixops}/bin/nixops $1 -s ${stateFilePath} -d remotebuilders ''${@:2}
        '';
      aarch64-ip = ''
        ${self.remotebuilders-ops}/bin/remotebuilders-ops info --plain 2>/dev/null \
          | grep remotebuilder-aarch64 \
          | grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' \
          | head -1 \
          | tr -d '\n'
        '';
      aarch64-up = ''
        ${self.remotebuilders-ops}/bin/remotebuilders-ops deploy -Inixpkgs=${aarch64Pkgs.path} --include remotebuilder-aarch64
        # pull down host key ..
        '';
      aarch64-down = ''
        ${self.remotebuilders-ops}/bin/remotebuilders-ops destroy --include remotebuilder-aarch64
        '';
      aarch64-ssh = ''
        ${self.remotebuilders-ops}/bin/remotebuilders-ops ssh remotebuilder-aarch64
        '';
      aarch64-copy = ''
        ${nix}/bin/nix copy --to "ssh://root@$(${self.aarch64-ip}/bin/aarch64-ip)?ssh-key=${sshKeyPath}" $@
        '';
      aarch64-realise = ''
        ${nix}/bin/nix copy --to "ssh://root@$(${self.aarch64-ip}/bin/aarch64-ip)?ssh-key=${sshKeyPath}" $@
        ${self.remotebuilders-ops}/bin/remotebuilders-ops ssh remotebuilder-aarch64 "nix-store --realise $@"
        '';
      aarch64-realise-bg = ''
        ${nix}/bin/nix copy --to "ssh://root@$(${self.aarch64-ip}/bin/aarch64-ip)?ssh-key=${sshKeyPath}" $@
        ${self.remotebuilders-ops}/bin/remotebuilders-ops ssh remotebuilder-aarch64 "rm nohup.out ; nohup nix-store --realise $@ &"
        ${self.remotebuilders-ops}/bin/remotebuilders-ops ssh remotebuilder-aarch64 "tail -f nohup.out"
        '';
      # TODO: export key using nixops export for $1 in the below script
      aarch64-copy-id = ''
        ssh-copy-id root@$(${self.aarch64-ip}/bin/aarch64-ip) -i ${sshKeyPath}.pub -o "IdentityFile $1" ''${@:2}
      '';
    });
in
  linkFarm "remotebuilders-network"
    (lib.attrValues
      (lib.mapAttrs (name: path: { name = "bin/${name}"; path = "${path}/bin/${name}"; }) networkScripts))

