{ networkName
, region
, zone
}:
{
  ec2KeyPairs.keypair = { inherit region; };
  vpc."${networkName}-vpc" = {
    inherit region;
    instanceTenancy = "default";
    enableDnsSupport = true;
    enableDnsHostnames = true;
    cidrBlock = "10.0.0.0/16";
  };
  ec2SecurityGroups."${networkName}-sg" = { resources, lib, ... }: {
    inherit region;
    vpcId = resources.vpc."${networkName}-vpc";
    rules = [
      { toPort = 22; fromPort = 22; sourceIp = "0.0.0.0/0"; }   # ssh
      { toPort = 80; fromPort = 80; sourceIp = "0.0.0.0/0"; }   # http
      { toPort = 443; fromPort = 443; sourceIp = "0.0.0.0/0"; } # https
    ];
  };
  vpcSubnets."${networkName}-subnet" = { resources, ... }: {
    inherit region;
    vpcId = resources.vpc."${networkName}-vpc";
    cidrBlock = "10.0.0.0/16";
    zone = zone;
    mapPublicIpOnLaunch = true;
  };
  vpcRouteTables.route-table = { resources, ... }: {
    inherit region;
    vpcId = resources.vpc."${networkName}-vpc";
  };
  vpcRouteTableAssociations."${networkName}-association" = { resources, ... }: {
    inherit region;
    subnetId = resources.vpcSubnets."${networkName}-subnet";
    routeTableId = resources.vpcRouteTables.route-table;
  };
  vpcRoutes.igw-route = { resources, ... }: {
    inherit region;
    routeTableId = resources.vpcRouteTables.route-table;
    destinationCidrBlock = "0.0.0.0/0";
    gatewayId = resources.vpcInternetGateways.igw;
  };
  vpcInternetGateways.igw = { resources, ... }: {
    inherit region;
    vpcId = resources.vpc."${networkName}-vpc";
  };

  # # Shared storage
  # elasticFileSystems.sharedFilesystem = {
  #   inherit region;
  # };
  # elasticFileSystemMountTargets.sharedMount = { resources, ... }: {
  #   inherit region;
  #   # subnet = "${};
  #   subnetId = resources.vpcSubnets."${networkName}-subnet";
  #   fileSystem = resources.elasticFileSystems.sharedFilesystem;
  #   securityGroups = [ "default" ];
  # };
}
