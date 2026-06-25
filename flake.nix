{
  description = "conseillers-entreprises dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
    {
      devShells.aarch64-darwin.default = pkgs.mkShell {
        # pkg-config's setup hook auto-populates PKG_CONFIG_PATH from buildInputs,
        # so native gems (pg, openssl, ffi) compile without manual flag exports.
        nativeBuildInputs = [ pkgs.pkg-config ];

        buildInputs = with pkgs; [
          postgresql_17 # libpq headers/.pc + psql client
          postgresql_17.pg_config # pg gem looks up pg_config first (separate output)
          redis
          openssl
          libyaml # psych / native gems
          libffi # ffi gem
        ];
      };
    };
}
