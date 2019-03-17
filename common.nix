{ pkgs
, ...
}:

{
  # networking.firewall = {
  #   enable = true;
  # };

  services = {
    openssh = {
      enable = true;
      # Larger MaxAuthTries helps to avoid ssh 'Too many authentication failures' issue
      # See https://github.com/NixOS/nixops/issues/593#issue-203407250
      extraConfig = ''
        MaxAuthTries 20
      '';
    };
  };

  # security = {
  #   apparmor.enable = true;
  # };
}

