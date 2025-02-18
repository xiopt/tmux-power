#!/usr/bin/env bash
#===============================================================================
#   Author: Wenxuan (modified by You)
#    Email: wenxuangm@gmail.com / your.email@example.com
#  Created: 2018-04-05 17:37
# Modified: 2025-02-18 - Added Neovim theme color scheme option
#===============================================================================

# $1: option
# $2: default value
tmux_get() {
    local value
    value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

# $1: option
# $2: value
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# Options and icons
rarrow=$(tmux_get '@tmux_power_right_arrow_icon' '')
larrow=$(tmux_get '@tmux_power_left_arrow_icon' '')
upload_speed_icon=$(tmux_get '@tmux_power_upload_speed_icon' '󰕒')
download_speed_icon=$(tmux_get '@tmux_power_download_speed_icon' '󰇚')
session_icon="$(tmux_get '@tmux_power_session_icon' '')"
user_icon="$(tmux_get '@tmux_power_user_icon' '')"
time_icon="$(tmux_get '@tmux_power_time_icon' '')"
date_icon="$(tmux_get '@tmux_power_date_icon' '')"
show_upload_speed=$(tmux_get @tmux_power_show_upload_speed false)
show_download_speed=$(tmux_get @tmux_power_show_download_speed false)
show_web_reachable=$(tmux_get @tmux_power_show_web_reachable false)
prefix_highlight_pos=$(tmux_get @tmux_power_prefix_highlight_pos)
time_format=$(tmux_get @tmux_power_time_format '%T')
date_format=$(tmux_get @tmux_power_date_format '%F')

# Get the theme option (default is "gold")
THEME=$(tmux_get '@tmux_power_theme' 'gold')

# Choose the accent color (TC) based on the theme
# For "nvim" we use the glow (or search_highlight) color from your Neovim theme.
case "$THEME" in
gold)
    TC='#ffb86c'
    ;;
redwine)
    TC='#b34a47'
    ;;
moon)
    TC='#00abab'
    ;;
forest)
    TC='#228b22'
    ;;
violet)
    TC='#9370db'
    ;;
snow)
    TC='#fffafa'
    ;;
coral)
    TC='#ff7f50'
    ;;
sky)
    TC='#87ceeb'
    ;;
bluemarin)
    TC='#66b2b2'
    ;;
everforest)
    TC='#a7c080'
    ;;
default)
    TC='colour3'
    ;;
darkvoid)
    TC='#2ead78'
    ;;
*)
    # Allow users to provide a custom color (e.g. a hex code)
    TC="$THEME"
    ;;
esac

# Default grayscale palette (used for status bar, borders, etc.)
G01='#080808' #232
G02='#121212' #233
G03='#1c1c1c' #234
G04='#262626' #235
G05='#303030' #236
G06='#3a3a3a' #237
G07='#444444' #238
G08='#4e4e4e' #239
G09='#585858' #240
G10='#626262' #241
G11='#6c6c6c' #242
G12='#767676' #243

# Basic foreground and background defaults (from the grayscale palette)
FG="$G10"
BG="$G04"

# If the user selected the "nvim" theme, override with Neovim theme colors.
if [ "$THEME" = "darkvoid" ]; then
    FG="#fffafa"  # Neovim: fg
    BG="#1c1c1c"  # Neovim: bg
    G04="$BG"     # Use bg for main left/right backgrounds
    G06="#303030" # Neovim: visual color for mid sections
    G07="#404040" # Neovim: line_nr color for pane borders
    G12="#585858" # Neovim: comment color for status-left text
fi

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-fg "$FG"
tmux_set status-bg "$BG"
tmux_set status-attr none

# tmux-prefix-highlight settings
tmux_set @prefix_highlight_fg "$BG"
tmux_set @prefix_highlight_bg "$FG"
tmux_set @prefix_highlight_show_copy_mode 'on'
tmux_set @prefix_highlight_copy_mode_attr "fg=$TC,bg=$BG,bold"
tmux_set @prefix_highlight_output_prefix "#[fg=$TC]#[bg=$BG]$larrow#[bg=$TC]#[fg=$BG]"
tmux_set @prefix_highlight_output_suffix "#[fg=$TC]#[bg=$BG]$rarrow"

# Left side of status bar
tmux_set status-left-bg "$G04"
tmux_set status-left-fg "$G12"
tmux_set status-left-length 150
user=$(whoami)
LS="#[fg=$G04,bg=$TC,bold] $user_icon $user@#h #[fg=$TC,bg=$G06,nobold]$rarrow#[fg=$TC,bg=$G06] $session_icon #S "
if [ "$show_upload_speed" = "true" ]; then
    LS="$LS#[fg=$G06,bg=$G05]$rarrow#[fg=$TC,bg=$G05] $upload_speed_icon #{upload_speed} #[fg=$G05,bg=$BG]$rarrow"
else
    LS="$LS#[fg=$G06,bg=$BG]$rarrow"
fi
if [[ $prefix_highlight_pos == 'L' || $prefix_highlight_pos == 'LR' ]]; then
    LS="$LS#{prefix_highlight}"
fi
tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-bg "$BG"
tmux_set status-right-fg "$G12"
tmux_set status-right-length 150
RS="#[fg=$G06]$larrow#[fg=$TC,bg=$G06] $time_icon $time_format #[fg=$TC,bg=$G06]$larrow#[fg=$G04,bg=$TC] $date_icon $date_format "
if [ "$show_download_speed" = "true" ]; then
    RS="#[fg=$G05,bg=$BG]$larrow#[fg=$TC,bg=$G05] $download_speed_icon #{download_speed} $RS"
fi
if [ "$show_web_reachable" = "true" ]; then
    RS=" #{web_reachable_status} $RS"
fi
if [[ $prefix_highlight_pos == 'R' || $prefix_highlight_pos == 'LR' ]]; then
    RS="#{prefix_highlight}$RS"
fi
tmux_set status-right "$RS"

# Window status formats
tmux_set window-status-format "#[fg=$BG,bg=$G06]$rarrow#[fg=$TC,bg=$G06] #I:#W#F #[fg=$G06,bg=$BG]$rarrow"
tmux_set window-status-current-format "#[fg=$BG,bg=$TC]$rarrow#[fg=$BG,bg=$TC,bold] #I:#W#F #[fg=$TC,bg=$BG,nobold]$rarrow"

# Window status styles
tmux_set window-status-style "fg=$TC,bg=$BG,none"
tmux_set window-status-last-style "fg=$TC,bg=$BG,bold"
tmux_set window-status-activity-style "fg=$TC,bg=$BG,bold"

# Window separator
tmux_set window-status-separator ""

# Pane border settings
tmux_set pane-border-style "fg=$G07,bg=default"
tmux_set pane-active-border-style "fg=$TC,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$G07"
tmux_set display-panes-active-colour "$TC"

# Clock mode settings
tmux_set clock-mode-colour "$TC"
tmux_set clock-mode-style 24

# Message and command message styles
tmux_set message-style "fg=$TC,bg=$BG"
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=$FG"
