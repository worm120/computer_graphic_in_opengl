{ pkgs ? import <nixpkgs> { } }:

# Toolchain + GL libraries for the OpenGL samples.
# Used by direnv (.envrc → `use nix`) and also directly:
#   nix-shell          # if you do not use direnv
pkgs.mkShell {
  buildInputs = with pkgs; [
    # compiler + pkg-config: xmake resolves the libraries below through .pc files
    gcc
    gnumake
    pkg-config
    # what the samples link against (glew/glfw/glm via add_requires{system=true})
    glew
    glfw
    glm
    # bundled SOIL2 sources include <X11/Xlib.h>
    libx11
  ];

  shellHook = ''
    export CC=gcc CXX=g++
    echo "OpenGL samples shell: xmake build -y && xmake run <target>   (./run.sh --list)"
  '';
}
