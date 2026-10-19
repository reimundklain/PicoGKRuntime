{
  lib,
  stdenv,
  src,
  cmake,
  ninja,
  pkg-config,
  wayland-scanner,
  addDriverRunpath,
  boost,
  tbb,
  c-blosc,
  zlib,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxrender,
  libxxf86vm,
  libxcb,
  libxkbcommon,
  libdecor,
  wayland,
  wayland-protocols,
}:

let
  libraryVersion = "26.2";
  libraryFile = "picogk.${libraryVersion}.so";

  glfwRuntimeLibraries = [
    libGL
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxrandr
    libxrender
    libxxf86vm
    libxcb
    libxkbcommon
    libdecor
    wayland
  ];
in
stdenv.mkDerivation {
  pname = "picogk-runtime";
  version = "${libraryVersion}.0";

  inherit src;

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    wayland-scanner
    addDriverRunpath
  ];

  buildInputs = [
    boost
    tbb
    c-blosc
    zlib
    wayland-protocols
  ]
  ++ glfwRuntimeLibraries;

  ninjaFlags = [ "picogk" ];

  installPhase = ''
    runHook preInstall

    install -Dm755 lib/picogk.so $out/lib/${libraryFile}
    ln -s ${libraryFile} $out/lib/picogk.so
    install -Dm644 -t $out/include ../API/*.h

    runHook postInstall
  '';

  # GLFW loads its windowing and OpenGL libraries with dlopen at runtime.
  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath glfwRuntimeLibraries} $out/lib/${libraryFile}
    addDriverRunpath $out/lib/${libraryFile}
  '';

  meta = {
    description = "Native C++ runtime of the PicoGK geometry kernel";
    homepage = "https://github.com/leap71/PicoGKRuntime";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
}
