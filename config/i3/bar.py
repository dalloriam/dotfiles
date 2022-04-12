from i3pystatus import Status
from i3pystatus.core.color import ColorRangeModule

COLOR_THING_GOOD = "#16A085"
COLOR_THING_BAD  = "#AA6161"


status = Status()

status.register("clock", format="%a %-d %b %X",)

# Shows the average load of the last minute and the last 5 minutes
# (the default value for format is used)
status.register("load")

# Shows your CPU temperature, if you have a Intel CPU
status.register("temp", format="{temp:.0f}°C",)

status.register("battery",
    format="{status}/{consumption:.2f}W {percentage:.2f}% [{percentage_design:.2f}%] {remaining:%E%hh:%Mm}",
    alert=True,
    full_color="#FFFFFF",
    charging_color="#FFFFFF",
    critical_color="#FFFFFF",
    alert_percentage=5,
    status={
        "DIS": "↓",
        "CHR": "↑",
        "FULL": "=",
    },)

# TODO: Detect network interfaces
status.register("network",
    color_up=COLOR_THING_GOOD,
    color_down=COLOR_THING_BAD,
    interface="wlp0s20f3",
    format_up="{essid} {quality:03.0f}%",)

# Shows disk usage of /
# Format:
# 42/128G
status.register("disk",
    path="/",
    format="{free}/{total}G",)

status.register("spotify", format="{artist} - {title} {status}")

status.register("pulseaudio",
    format="♪{volume}",)

status.run()
