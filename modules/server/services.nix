{ config, pkgs, username, ... }:

{
  systemd.user.tmpfiles.users."${username}".rules = [
    "d /home/${username}/media 0770 ${username} users -"
    "d /home/${username}/backup 0770 ${username} users -"
    "d /home/${username}/cloud 0770 ${username} users -"
    "d /home/${username}/repositories 0770 ${username} users -"
    "d /home/${username}/game_servers 0770 ${username} users -"
    "d /home/${username}/inbox 0770 ${username} users -"
    "d /home/${username}/outbox 0770 ${username} users -"
  ];


}
