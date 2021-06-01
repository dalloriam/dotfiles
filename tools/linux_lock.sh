#!/bin/sh

# Screen lock script for i3wm. Requires i3lock_color.

B='#00000000'  # blank
C='#ffffff22'  # clear ish
D='#595B5Bcc'  # default
T='#F9FAF9ee'  # text
W='#E5201Dbb'  # wrong
V='#16A085bb'  # verifying

i3lock \
--insidevercolor=$C   \
--ringvercolor=$V     \
\
--insidewrongcolor=$C \
--ringwrongcolor=$W   \
\
--insidecolor=$B      \
--ringcolor=$D        \
--linecolor=$B        \
--separatorcolor=$D   \
\
--verifcolor=$T        \
--wrongcolor=$T        \
--timecolor=$T        \
--datecolor=$T \
--layoutcolor=$T      \
--keyhlcolor=$W       \
--bshlcolor=$W        \
--screen 1            \
--indicator           \
--keylayout 2         \
--datestr "Enter Password" \
