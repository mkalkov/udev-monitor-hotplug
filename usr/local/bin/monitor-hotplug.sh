#!/bin/sh

export DISPLAY=:0
export XAUTHORITY=/var/run/lightdm/root/$DISPLAY

internal=false
external=false
for drm_device in /sys/class/drm/* ; do
  if $(grep -qs ^connected $drm_device/status); then
    case "$(basename $drm_device | cut -d- -f2- | tr -d -)" in
      LVDS1)
        internal=true
        ;;
      VGA1)
        external=true
        ;;
      *)
        ;;
    esac
  fi
done

# To query current Xrandr state, run `xrandr` without arguments
# To get current DPI run `xdpyinfo | grep resolution`
if $internal && ! $external; then
  xrandr --dpi 96x96 \
    --output LVDS1 --primary \
    --output VGA1 --off
elif $internal && $external; then
  # This modeline was obtained from running `cvt 1920 1080`
  # The resolution is based on monitor and Intel GM965 chipset specs
  # DPI is calculated as resolution divided by physical size in inches
  xrandr --newmode "1920x1080_60.00"  173.00 \
    1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync 2>/dev/null
  xrandr --addmode VGA1 1920x1080_60.00
  xrandr --dpi 82x82 \
    --output LVDS1 --mode 1280x800 --pos 1920x280 \
    --output VGA1 --mode 1920x1080_60.00 --pos 0x0 --primary
else
  echo Please adapt this script to your configuration
  exit 1
fi

