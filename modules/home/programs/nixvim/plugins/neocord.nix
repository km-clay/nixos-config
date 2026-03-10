{
  programs.nixvim.plugins.neocord = {
    enable = true;
    settings = {
      logo = "https://styles.redditmedia.com/t5_30kix/styles/communityIcon_n2hvyn96zwk81.png";
      logo_tooltip = "Neovim";
      buttons = [
        {
          label = " My GitHub";
          url = "https://github.com/pagedMov";
        }
        {
          label = " Nixvim";
          url = "https://github.com/nix-community/nixvim";
        }
      ];
    };
  };
}
