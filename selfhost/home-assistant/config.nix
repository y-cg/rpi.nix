{
  pkgs-unstable,
  ...
}:
{
  services.home-assistant = {
    enable = true;
    # Use unstable HA so it matches the custom components below
    package = pkgs-unstable.home-assistant;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      "homekit"
      "homekit_controller"
      "apple_tv"
      "xiaomi_ble"
      "thread"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"
      # Required by xiaomi_home (see package longDescription)
      "ffmpeg"
      "zeroconf"
    ];
    customComponents = [
      pkgs-unstable.home-assistant-custom-components.xiaomi_home
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
    };
  };
  networking.firewall.allowedTCPPorts = [
    8123
    21064 # homekit-bridge use this by default
  ];
}
