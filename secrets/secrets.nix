let
  # User key (for editing secrets)
  pagedmov = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0Eew2n6M2HtsTHHFBfMrsGsz9mt6gqN3XTM4RG5h6N pagedmov@oganesson";

  # Host keys (for decryption at activation time)
  phosphorous = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBhyhqppXv0SPQ6n3xkTqPXH866e2cCpDkw7f1Rxzjbu root@phosphorous";
in
{
  "copyparty-admin.age".publicKeys = [
    pagedmov
    phosphorous
  ];
  "copyparty-pagedmov.age".publicKeys = [
    pagedmov
    phosphorous
  ];
  "copyparty-testuser.age".publicKeys = [
    pagedmov
    phosphorous
  ];
}
