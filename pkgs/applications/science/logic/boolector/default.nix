{ stdenv, fetchFromGitHub, lib, python3
, cmake, lingeling, btor2tools, gtest, gmp
}:

stdenv.mkDerivation rec {
  pname = "boolector";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner  = "boolector";
    repo   = "boolector";
    rev    = "refs/tags/${version}";
    sha256 = "0jkmaw678njqgkflzj9g374yk1mci8yqvsxkrqzlifn6bwhwb7ci";
  };

  postPatch = ''
    sed s@REPLACEME@file://${gtest.src}@ ${./cmake-gtest.patch} | patch -p1
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ lingeling btor2tools gmp ];

  prePatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ''${CMAKE_BINARY_DIR}/lib)' "set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY $lib/lib)" \
      --replace 'set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ''${CMAKE_BINARY_DIR}/lib)' "set(CMAKE_LIBRARY_OUTPUT_DIRECTORY $lib/lib)" \
      --replace 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ''${CMAKE_BINARY_DIR}/bin)' "set(CMAKE_RUNTIME_OUTPUT_DIRECTORY $out/bin)"
  '';

  cmakeFlags =
    [ "-DBUILD_SHARED_LIBS=ON"
      "-DUSE_LINGELING=YES"
      "-DCMAKE_BUILD_WITH_INSTALL_NAME_DIR=ON"
    ] ++ (lib.optional (gmp != null) "-DUSE_GMP=YES");

  checkInputs = [ python3 ];
  doCheck = true;
  preCheck =
    let libPathVar = if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
    in ''
      export ${libPathVar}=$(readlink -f lib)
      patchShebangs ..
    '';

  # rm stuff from outputs
  postInstall = ''
    rm -rf $out/bin/{examples,tests}
    rm -rf $out/lib
    # we don't care about gtest related libs
    rm -rf $lib/lib/libg*

    rm -rf $dev/*
    cd ../src
    find . -iname '*.h' -exec cp --parents '{}' $dev/include \;
  '';

  outputs = [ "out" "dev" "lib" ];

  meta = with stdenv.lib; {
    description = "An extremely fast SMT solver for bit-vectors and arrays";
    homepage    = "https://boolector.github.io";
    license     = licenses.mit;
    platforms   = with platforms; linux ++ darwin;
    maintainers = with maintainers; [ thoughtpolice ];
  };
}
