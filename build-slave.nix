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

  users.extraUsers.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4l3exfk44/NHAO2vDgtKuF9eDiSoWR+VOWhB6ZbLtR72MX05TTirQT11cXCEBdVl6/hS1Xca0DTuk9Zth/yfTvCiyWr9s+5MvHZp0pptqfz/Hzb3lnl/HA8ctfo3uZ6aiL8oL0xo8kHo79g8Z5nIhFGh/XEUpj7ARG/VSRBNVtlPSpHoBFoyDsPs58BhKyIRWR+A6SGbSGOuaxj6ynlcyv7FUG9Gq9HLVK32yUafBrthUVpX2BSUNoh2cDZlxbn0k2NKdfc2APYHa+V289OHKdfoMjA3xCacbpAMudv09NWT/X7RoRZ8yHuMJTqUi7OFTddY3XPKyRFm7GE9Pt35+pvuJfGKpP5GYXVhAUuohxMO0xD3gNdnGzzcMJGRtH14kFGE5rhQHkIiWQeEae9p81u5d3wn7CvGrjOPSJPeBq+CmdmyRGerIVG2QbYkTXvz5Bp7fRH/KTrjIrZAMCgqcZhezaDjke4s4AFEnm017U1FBolAEyiN5BrHX/cfI1RLWUW7hX5QZi4zDuZoCe8D4aMQv65Bie5Ymz/MVN/97CKvO2P3L1cCC9313BkeDAgSy3N2jwZO5Bo9symApOY+P0XvoKAMKooQjYP0mKYequsmys5Qrkgm4xffBmy/PmVQlJYiBU6EjrI+8ElVz89UvSD/kPvLnYEf70OOYs3X+3w== remote-build-for-access-point"
  ];
}
