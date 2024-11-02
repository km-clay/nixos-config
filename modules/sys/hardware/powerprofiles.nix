{lib, config,  ... }: {
  options = {
    powerProfiles.enable = lib.mkEnableOption "enables power profiles";
  };
  config = lib.mkIf config.powerProfiles.enable {
    services = {
      keyd = {
        enable = true;
        keyboards.default = {
          ids = ["*"];
          settings.main = {
            capslock = "esc";
          };
        };
      };

      power-profiles-daemon.enable = true;

      upower = {
        enable = true;
        percentageLow = 20;
        percentageCritical = 5;
        percentageAction = 3;
        criticalPowerAction = "PowerOff";
      };

      tlp.settings = {
        CPU_ENERGY_PERF_POLICY_ON_AC = "power";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 1;

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "performance";

        INTEL_GPU_MIN_FREQ_ON_AC = 500;
        INTEL_GPU_MIN_FREQ_ON_BAT = 500;
        # INTEL_GPU_MAX_FREQ_ON_AC=0;
        # INTEL_GPU_MAX_FREQ_ON_BAT=0;
        # INTEL_GPU_BOOST_FREQ_ON_AC=0;
        # INTEL_GPU_BOOST_FREQ_ON_BAT=0;

        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";
      };
    };
  };
}
