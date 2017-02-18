{ mkDerivation, aeson, base, bytestring, http-conduit, http-types
, stdenv, text, unordered-containers, zlib
}:
mkDerivation {
  pname = "hoauth2";
  version = "0.5.8";
  sha256 = "0q0fh85cmshpgng8mzdrwl0wkasdrbl8zhvqrg8yjpa5b49frb6a";
  libraryHaskellDepends = [
    aeson base bytestring http-conduit http-types text
    unordered-containers
  ];
  homepage = "https://github.com/freizl/hoauth2";
  description = "Haskell OAuth2 authentication client";
  license = stdenv.lib.licenses.bsd3;
}
