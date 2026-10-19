{
  description = "PicoGK Runtime development environment";

  inputs = {
    self.submodules = true;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forEachSystem =
        function: nixpkgs.lib.genAttrs supportedSystems (system: function nixpkgs.legacyPackages.${system});

      linuxSystems = builtins.filter (nixpkgs.lib.hasSuffix "-linux") supportedSystems;

      forEachLinuxSystem =
        function: nixpkgs.lib.genAttrs linuxSystems (system: function nixpkgs.legacyPackages.${system});
    in
    {
      packages = forEachLinuxSystem (pkgs: {
        default = pkgs.callPackage ./runtime.nix { src = self; };
      });

      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.cmake
            pkgs.ninja
            pkgs.pkg-config

            # OpenVDB
            pkgs.boost
            pkgs.tbb
            pkgs.c-blosc
            pkgs.zlib
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            # GLFW (X11 and Wayland backends) and OpenGL
            pkgs.libGL
            pkgs.libxkbcommon
            pkgs.wayland
            pkgs.wayland-protocols
            pkgs.wayland-scanner
            pkgs.libffi
            pkgs.libx11
            pkgs.libxcursor
            pkgs.libxext
            pkgs.libxi
            pkgs.libxinerama
            pkgs.libxrandr
          ];

          # mkShell pins SOURCE_DATE_EPOCH to 1980, which CMake's string(TIMESTAMP)
          # would embed as the build date in API/PicoGKBuild.h.
          shellHook = ''
            unset SOURCE_DATE_EPOCH
          '';
        };
      });

      formatter = forEachSystem (pkgs: pkgs.nixfmt);
    };
}
