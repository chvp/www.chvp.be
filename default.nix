{ stdenv
, zola
}:

stdenv.mkDerivation {
  pname = "www.chvp.be";
  version = "unstable";
  src = ./src;

  nativeBuildInputs = [ zola ];

  buildPhase = "zola build";
  installPhase = "cp -r public $out";
}
