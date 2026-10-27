{
  pkgs,
  lib,
  ...
}:

let
  # Copy a one-line agent prompt with the active pane id (e.g. %12). The model
  # already knows tmux from pretraining, so the prompt only supplies the one fact
  # it can't: the target. No trailing newline, so pasting into a chat box doesn't
  # auto-submit. Keep the command $-free — run-shell expands $var as env vars.
  copyPaneId = "printf 'My terminal is tmux pane %s; operate on it via the tmux CLI.' '#{pane_id}' | pbcopy && tmux display-message 'Pane prompt copied'";

  placeholders = {
    "@copyPaneId@" = copyPaneId;
    "@tmuxJump@" = "${pkgs.tmuxPlugins.jump}/share/tmux-plugins/jump/scripts/tmux-jump.sh";
    "@zsh@" = lib.getExe pkgs.zsh;
  };

  tmuxConfig = builtins.replaceStrings (builtins.attrNames placeholders) (builtins.attrValues placeholders) (
    builtins.readFile ./tmux.conf
  );
in
{
  programs.tmux = {
    enable = true;
    shell = lib.getExe pkgs.zsh;
    terminal = "xterm-256color";
    plugins = [
      pkgs.tmuxPlugins.nord
      pkgs.tmuxPlugins.jump
    ];
    extraConfig = tmuxConfig;
  };
}
