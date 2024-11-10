{
  programs.nixvim.plugins.chatgpt = {
    enable = true;
    settings = {
      api_key_cmd = "pass keys/openai/apikey";
    };
  };
}
