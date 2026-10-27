{
  pkgs,
  lib,
  ...
}:
{
  programs.zsh = {
    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkOrder 100 /* zsh */ ''
        function zvm_config() {
          # Initialize keymaps synchronously on source instead of deferring to first prompt,
          # preventing zsh-vi-mode from wiping keybindings registered by other plugins (e.g. navi, fzf).
          ZVM_INIT_MODE=sourcing
          ZVM_KEYTIMEOUT=0.1
          ZVM_VI_INSERT_ESCAPE_BINDKEY=kk
        }

        function zvm_after_init() {
          autoload -Uz edit-command-line
          zle -N edit-command-line
          # Bind Ctrl+G in vicmd (normal mode) to edit command line
          zvm_bindkey vicmd '^g' edit-command-line

          # Alt+H/L arrives as ESC then h or l. After ESC, zsh-vi-mode waits
          # ZVM_KEYTIMEOUT: timeout means NORMAL, extra byte means a chord.

          # Under load the second byte can miss that window, so INSERT (beam)
          # randomly becomes NORMAL (block).

          # undefined-key makes the whole sequence one no-op chord, so zle never
          # starts that wait. Bind in zvm_after_init: zvm rebuilds the keymap.
          for mode in viins vicmd; do
            bindkey -M $mode '^[h' undefined-key
            bindkey -M $mode '^[l' undefined-key
          done
        }
      '')
    ];
  };
}
