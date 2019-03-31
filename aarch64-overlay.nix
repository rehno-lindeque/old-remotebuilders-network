self: super: {
  openblas = super.openblas.overrideAttrs (oldAttrs: {
    makeFlags = oldAttrs.makeFlags ++ ["NO_BINARY_MODE=1"];
  });
}
