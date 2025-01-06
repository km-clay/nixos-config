{ pkgs ? import <nixpkgs> {} }:

pkgs.rustPlatform.buildRustPackage {
  pname = "rsh";
  version = "0.0.1";

  src = ./rsh;

  cargoHash = "sha256-8Lb7AohSah2A7pcoT2JPDgza0LfIyD897yj4QHNklDw=";

  buildInputs = [ ];

  meta = {
    description = "Modern shell scripting";
    homepage = "https://github.com/pagedMov/rsh";
    license = pkgs.lib.licenses.gpl3;
    maintainers = with pkgs.lib.maintainers; [ pagedMov ];
  };
}
