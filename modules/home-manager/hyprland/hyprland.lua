-- IMPORTANT:
-- if not using NixOS, set these manually:
-- local terminal = "ghostty"
-- local menu = "wofi"
-- local fileManager = "dolphin"
--
-- hl.monitor({
--  output = "<check with `hyprctl monitors`>",
--  mode = "highrr",
--  position = "auto",
--  scale = "auto",
-- })
--
-- FALLBACK - leave 'output' empty
-- hl.monitor({
--  output = "",
--  mode = "preferred",
--  position = "auto",
--  scale = "auto",
-- })
--
-- hl.on("hyprland.start", (function()
--   hl.exec_cmd("hyprpaper")
--   hl.exec_cmd("mako")
--   hl.exec_cmd("waybar")
-- end))
--
-- hl.bind(mod .. " + D", hl.dsp.exec_cmd("wofi --run")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
    };

    input = {
        accel_profile = "flat",
        sensitivity = 0,
        -- force_no_accel = true, -- not recommended in Hyprland docs

        kb_layout = "pl",
    },

    animations = {
        enabled = true,
    }
})

hl.animation({ leaf = "workspaces", enabled = false })
hl.animation({ leaf = "windows", enabled = true, speed = 1, curve = "default" })

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + R", hl.dsp.reload_config())

hl.bind(mod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + W", hl.dsp.exec_cmd("firefox"))
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))

for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i}))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("Print", hl.dsp.exec_cmd("grim -t png -g \"$(slurp)\" ${HOME}/Pictures/screenshot_$(date --iso-8601=seconds).png"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("grim -t png -g \"$(slurp)\" - | wl-copy"))

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +10%"))

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0 && wpctl set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 0.02+"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
