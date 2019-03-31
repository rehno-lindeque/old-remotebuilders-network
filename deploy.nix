# Deployment instructions

# $ nixops create deploy.nix
#

{ buildSlaves ? 1
# , instanceSize ? "large"
}:

let
  networkName = "remotebuilders";
  region = "us-east-1";
  zone = "us-east-1b";

  resources =
    import ./ec2-resources.nix { inherit networkName region zone; };
    # // {
    #   sshKeyPairs."build-coordinator" = {};
    # };

  ec2BuildSlave = systemImport: name: { resources, lib, ... }: {
    imports =
      [ ./build-slave.nix
        systemImport
      ];
    #### # nixpkgs.crossSystem.system = "aarch64-linux";
    #### # nixpkgs.localSystem = pkgs.localSystem;
    #### # nixpkgs.localSystem = {
    #### #   # system = "x86_64-linux";
    #### #   # platform = lib.systems.platforms.pc64;
    #### #   system = "x86_64-linux";
    #### # };
    #### nixpkgs.crossSystem = lib.systems.examples.aarch64-multiplatform;
    #### nixpkgs.localSystem = lib.systems.examples.aarch64-multiplatform;

    deployment = {
      targetEnv = "ec2";
      ec2 = {
        inherit region;
        # instanceType = "a1.${instanceSize}";
        # instanceType = "a1.medium";
        instanceType = "a1.4xlarge";
        associatePublicIpAddress = true;
        subnetId = resources.vpcSubnets."${networkName}-subnet";
        keyPair = resources.ec2KeyPairs.keypair.name;
        securityGroupIds = [ resources.ec2SecurityGroups."${networkName}-sg".name ];
        # spotInstancePrice = 2;
        spotInstancePrice = 14;
        ebsInitialRootDiskSize = 30;
      };
    };
    nix.buildCores = 16; #
    # nix.maxJobs = "auto";

    # TEMP
    # nix.maxJobs = 1;
    # nix.buildCores = 1;
  };
in
{
  inherit resources;

  network = {
    description = "${networkName} cluster";
  };

  defaults = {
    # nixpkgs.pkgs = import ./nix { nix.distributedBuilds = true; };
    imports = [
      ./common.nix
    ];
  };

  "remotebuilder-aarch64" = ec2BuildSlave ./aarch64-configuration.nix "remotebuilder-aarch64";
}
# // lib.genAttrs
#     (map (n: "${networkName}-build-slave-${n}") (lib.range 1 buildSlaves))
#     (ec2BuildSlave "aarch64")
