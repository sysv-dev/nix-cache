{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { lib, inputs', ... }:
        let
          pkgsUnstable = inputs'.nixpkgs.legacyPackages;
          pkgs2411 = inputs'.nixos-24-11.legacyPackages;

          linkFarmAttrs = pkgs: name: attrs:
            pkgs.linkFarm name (lib.mapAttrsToList (name: path: { inherit name path; }) attrs);

          stdenvFor = pkgs: pkgs.stdenv;

          packagesFor = pkgs: linkFarmAttrs pkgs "cross-${pkgs.system}" {
            inherit (pkgs)
              busybox
              # clang
              coreutils
              curl
              curlMinimal
              cyrus_sasl
              entr
              findutils
              gnugrep
              gnused
              gnutar
              gzip
              libmysqlclient
              # nix
              # openssh
              openssl
              # postgresql
              rdkafka
              # rustPlatform.bindgenHook
              sqlite
              xz
              zstd
              ;
          };
        in
        {
          packages = {
            stdenv-nixos-unstable-aarch64-linux = stdenvFor pkgsUnstable.pkgsCross.aarch64-multiplatform;
            stdenv-nixos-unstable-x86_64-linux = stdenvFor pkgsUnstable.pkgsCross.gnu64;
            stdenv-nixos-24-11-aarch64-linux = stdenvFor pkgs2411.pkgsCross.aarch64-multiplatform;
            stdenv-nixos-24-11-x86_64-linux = stdenvFor pkgs2411.pkgsCross.gnu64;

            packages-nixos-unstable-aarch64-linux = packagesFor pkgsUnstable.pkgsCross.aarch64-multiplatform;
            packages-nixos-unstable-x86_64-linux = packagesFor pkgsUnstable.pkgsCross.gnu64;
            packages-nixos-24-11-aarch64-linux = packagesFor pkgs2411.pkgsCross.aarch64-multiplatform;
            packages-nixos-24-11-x86_64-linux = packagesFor pkgs2411.pkgsCross.gnu64;
          };
        };
    };
}
