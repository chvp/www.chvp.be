{ stdenv
, zola
, cacert
}:

stdenv.mkDerivation {
  pname = "www.chvp.be";
  version = "unstable";
  src = ./src;

  nativeBuildInputs = [ zola cacert ];

  buildPhase = "zola build";
  installPhase = "cp -r public $out";
}
