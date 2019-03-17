{ pkgs
, resources
, lib
, ...
}:

{
  # networking.firewall = {
  #   allowedTCPPorts = [ 22 ];
  # };

  # nix.sshServe = {
  #   enable = true;
  #   keys = [ ];
  #     ((k: "${lib.traceVal k}") resources.sshKeyPairs.build-slave-keypair.publicKey)
  # };

  # users.users = {
  #   build-slave = {
  #     # group = "users";
  #     description = "User for participating in distributed builds";
  #     extraGroups = [];
  #     # openssh.authorizedKeys.keys = [ resources.sshKeyPairs."build-coordinator".publicKey ];
  #     # openssh.authorizedKeys.keyFiles = [ ../secrets/id_ml_build_coordinator.pub ];
  #     shell = pkgs.bashInteractive;
  #   };
  # };
  # nix.trustedUsers = [ "build-slave" ]; # also root? https://nixos.org/nixos/options.html#nix.trustedusers
}
