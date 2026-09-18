{
  lib,
  ...
}:

{
  options.personal.shell = {
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Attribute set of shell aliases to set, e.g. vim = nvim";
    };

    variables = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Attribute set of environment variables to set, e.g. EDITOR = nvim";
    };
  };
}
