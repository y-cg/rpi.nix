{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false; # Disable password login
      PermitRootLogin = "no";
      PubkeyAuthentication = true; # Ensure pubkey auth is enabled
    };
  };
}
