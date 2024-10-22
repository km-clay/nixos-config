{username, ...}: {
  programs.git = {
    enable = true;
    userEmail = "${username}@gmail.com";
    userName = "${username}";
  };
}
