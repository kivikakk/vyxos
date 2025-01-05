{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.vyxos.desktop.enable) {
    fonts.packages = with pkgs; [
      (iosevka.override {
        set = "TermSlab";
        privateBuildPlan = {
          family = "Iosevka Term Slab";
          spacing = "term";
          serifs = "slab";
          noCvSs = false;
          exportGlyphNames = true;

          widths = {
            Condensed = {
              shape = 500;
              menu = 3;
              css = "condensed";
            };
            Normal = {
              shape = 600;
              menu = 5;
              css = "normal";
            };
          };
        };
      })
    ];
  };
}
