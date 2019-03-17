{ lib, ...}:
{
  nixpkgs.localSystem = lib.systems.examples.aarch64-multiplatform;

  # needed?
  # nixpkgs.system = "aarch64-linux";
  deployment.ec2.ami = "ami-0d57f28ae76a680e3";

  # boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = lib.mkForce "nodev";
  boot.loader.timeout = lib.mkForce 5;
  boot.loader.grub.copyKernels = true;
}
