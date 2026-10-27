{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./vi-mode.nix
  ];

  home.packages = with pkgs; [
    trash-cli
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    # Cache compinit's fpath scan; refresh daily instead of adding ~1.5s to every tmux shell.
    completionInit = /* zsh */ ''
      autoload -U compinit
      if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
        compinit
      else
        compinit -C
      fi
    '';
    syntaxHighlighting.enable = true;

    initContent = lib.mkMerge [
      # Source any dynamic zsh snippets if present.
      (lib.mkOrder 900 /* zsh */ ''
        if [[ -d ~/.zsh/dynamic.d ]]; then
          for file in ~/.zsh/dynamic.d/*.zsh(N); do
            source "$file"
          done
        fi
      '')
    ];
  };
}
