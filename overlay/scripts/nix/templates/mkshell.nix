{
  pkgs ? import <nixpkgs> { },
}:

pkgs.writeShellApplication {
  name = "mkshell";
  runtimeInputs = [ ];
  text = ''
        command cat <<EOF
    devShells.\''${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
      ];

      shellHook = '''
        export SHELL=\''${pkgs.zsh}/bin/zsh
        exec \''${pkgs.zsh}/bin/zsh
      ''';
    };
    EOF
  '';
}
