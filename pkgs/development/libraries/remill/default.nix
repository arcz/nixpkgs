{ clangStdenv, fetchFromGitHub, fetchpatch, lib, python3, clangMultiStdenv
, cmake, gtest, gmp, xed, llvm_11, ccache, ninja, gflags, glog, clang, multiStdenv, git
}:

clangMultiStdenv.mkDerivation rec {
  pname = "remill";
  version = "4.0.11";

  src = fetchFromGitHub {
    owner  = "lifting-bits";
    repo   = "remill";
    rev    = "v${version}";
    sha256 = "1nnqfzpz4sz0969ipg75gs5maqz5j9yc5zp87qfdgiy4iax89y8c";
  };

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ xed llvm_11 ccache gflags glog gtest ];

  prePatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'if (NOT DEFINED ENV{TRAILOFBITS_LIBRARIES})' 'if (False)' \
      --replace 'find_package(XED REQUIRED)' "" \
      --replace 'if("''${CXX_COMMON_REPOSITORY_ROOT}" STREQUAL "" OR NOT EXISTS "''${CXX_COMMON_REPOSITORY_ROOT}/llvm")' 'if (False)' \
      --replace 'InstallExternalTarget("ext_clang" "''${CXX_COMMON_REPOSITORY_ROOT}/llvm/bin/clang''${executable_extension}"' "" \
      --replace '"''${REMILL_INSTALL_BIN_DIR}" "''${INSTALLED_CLANG_NAME}")' "" \
      --replace 'InstallExternalTarget("ext_llvmlink" "''${CXX_COMMON_REPOSITORY_ROOT}/llvm/bin/llvm-link''${executable_extension}"' "" \
      --replace '"''${REMILL_INSTALL_BIN_DIR}" "''${INSTALLED_LLVMLINK_NAME}")' ""
  '';
      #--replace 'include(CMakeLists_vcpkg.txt)' "" \
  NIX_CFLAGS_COMPILE="-isysroot";

  cmakeFlags =
    [ #"-DBUILD_SHARED_LIBS=ON"
      "-DUSE_SYSTEM_DEPENDENCIES=ON"
      "-DCMAKE_INSTALL_PREFIX=$out"
      "-DCMAKE_VERBOSE_MAKEFILE=True"
      #"-DXED_INCLUDE_DIRS=${xed}/include"
      "-DXED_LIBRARIES=xed"
    ]; # ++ (lib.optional (gmp != null) "-DUSE_GMP=YES");

  #buildPhase = "cmake --build .";
  doCheck = false;

  #checkInputs = [ python3 ];
  #doCheck = false;
  /*
  preCheck =
    let var = if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in
      # tests modelgen and modelgensmt2 spawn boolector in another processes and
      # macOS strips DYLD_LIBRARY_PATH, hardcode it for testing
      stdenv.lib.optionalString stdenv.isDarwin ''
        cp -r bin bin.back
        install_name_tool -change libboolector.dylib $(pwd)/lib/libboolector.dylib bin/boolector
      '' + ''
        export ${var}=$(readlink -f lib)
        patchShebangs ..
      '';

  postCheck = stdenv.lib.optionalString stdenv.isDarwin ''
    rm -rf bin
    mv bin.back bin
  '';

  # this is what haskellPackages.boolector expects
  postInstall = ''
    cp $out/include/boolector/boolector.h $out/include/boolector.h
    cp $out/include/boolector/btortypes.h $out/include/btortypes.h
  '';
  */

}
