local awful = require('awful')
local wibox = require('wibox')
local spawn = require('awful.spawn')
local gears = require('gears')
local beautiful = require('beautiful')
local watch = require('awful.widget.watch')

local LIST_DEVICES_CMD = [[sh -c "pactl list short sinks | cut -f 2; pactl list short sources | cut -f 2"]]
local function GET_VOLUME_CMD(device)
    return 'amixer -D ' .. device .. ' sget Master'
end

local function INC_VOLUME_CMD(device, step)
    return 'amixer -D ' .. device .. ' sset Master ' .. step .. '%+'
end

local function DEC_VOLUME_CMD(device, step)
    return 'amixer -D ' .. device .. ' sset Master ' .. step .. '%-'
end

local function TOG_VOLUME_CMD(device)
    return 'amixer -D ' .. device .. ' sset Master toggle'
end

local widget_types = {
    icon_and_text = require('widgets.audio.icon-and-text'),
}
local volume = {}

local rows = { layout = wibox.layout.fixed.vertical }

local popup = awful.popup({
    bg = beautiful.bg_normal,
    ontop = true,
    visible = false,
    shape = gears.shape.rounded_rect,
    border_width = 2,
    border_color = beautiful.border_focus,
    maximum_width = 400,
    offset = { y = 5 },
    widget = {},
})

local function extract_devices(cmd_output)
    local sinks = {}
    local sources = {}

    for line in cmd_output:gmatch('[^\r\n]+') do
        if string.find(line, 'output') ~= nil then
            table.insert(sinks, line)
        end
        if string.match(line, 'input') ~= nil then
            table.insert(sources, line)
        end
    end

    return sinks, sources
end

local function split(string_to_split, separator)
    if separator == nil then
        separator = '%s'
    end
    local t = {}

    for str in string.gmatch(string_to_split, '([^' .. separator .. ']+)') do
        table.insert(t, str)
    end

    return t
end

local function build_main_line(device)
    local dev = split(device, '.')
    return dev[2]
end

local function build_rows(devices, on_checkbox_click, device_type)
    local device_rows = { layout = wibox.layout.fixed.vertical }
    for _, device in pairs(devices) do
        local checkbox = wibox.widget({
            checked = device.is_default,
            color = beautiful.bg_normal,
            paddings = 2,
            shape = gears.shape.circle,
            forced_width = 20,
            forced_height = 20,
            check_color = beautiful.fg_urgent,
            widget = wibox.widget.checkbox,
        })

        checkbox:connect_signal('button::press', function()
            spawn.easy_async(string.format([[sh -c 'pacmd set-default-%s "%s"']], device_type, device), function()
                on_checkbox_click()
            end)
        end)

        local row = wibox.widget({
            {
                {
                    {
                        checkbox,
                        valign = 'center',
                        layout = wibox.container.place,
                    },
                    {
                        {
                            text = build_main_line(device),
                            align = 'left',
                            widget = wibox.widget.textbox,
                            border_width = 1,
                            border_color = beautiful.border_focus,
                        },
                        left = 10,
                        layout = wibox.container.margin,
                    },
                    spacing = 8,
                    layout = wibox.layout.align.horizontal,
                },
                margins = 4,
                layout = wibox.container.margin,
            },
            bg = beautiful.bg_normal,
            widget = wibox.container.background,
        })

        row:connect_signal('mouse::enter', function(c)
            c:set_bg(beautiful.bg_focus)
        end)
        row:connect_signal('mouse::leave', function(c)
            c:set_bg(beautiful.bg_normal)
        end)

        local old_cursor, old_wibox
        row:connect_signal('mouse::enter', function()
            local wb = mouse.current_wibox
            old_cursor, old_wibox = wb.cursor, wb
            wb.cursor = 'hand1'
        end)
        row:connect_signal('mouse::leave', function()
            if old_wibox then
                old_wibox.cursor = old_cursor
                old_wibox = nil
            end
        end)

        row:connect_signal('button::press', function()
            spawn.easy_async(string.format([[sh -c 'pactl set-default-%s "%s"']], device_type, device), function()
                on_checkbox_click()
            end)
        end)

        table.insert(device_rows, row)
    end

    return device_rows
end

local function build_header_row(text)
    return wibox.widget({
        {
            markup = '<b>' .. text .. '</b>',
            align = 'center',
            widget = wibox.widget.textbox,
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background,
    })
end

local function rebuild_popup()
    spawn.easy_async(LIST_DEVICES_CMD, function(stdout)
        local sinks, sources = extract_devices(stdout)

        for i = 0, #rows do
            rows[i] = nil
        end

        table.insert(rows, build_header_row('Output'))
        table.insert(
            rows,
            build_rows(sinks, function()
                rebuild_popup()
            end, 'sink')
        )
        table.insert(rows, build_header_row('Input'))
        table.insert(
            rows,
            build_rows(sources, function()
                rebuild_popup()
            end, 'source')
        )

        popup:setup(rows)
    end)
end

local function worker(user_args)
    local args = user_args or {}

    local mixer_cmd = args.mixer_cmd or 'pavucontrol'
    local refresh_rate = args.refresh_rate or 1
    local step = args.step or 5
    local device = args.device or 'pulse'

    volume.widget = widget_types['icon_and_text'].get_widget(args.icon_and_text_args)

    local function update_graphic(widget, stdout)
        local mute = string.match(stdout, '%[(o%D%D?)%]') -- \[(o\D\D?)\] - [on] or [off]
        if mute == 'off' then
            widget:mute()
        elseif mute == 'on' then
            widget:unmute()
        end
        local volume_level = string.match(stdout, '(%d?%d?%d)%%') -- (\d?\d?\d)\%)
        volume_level = string.format('% 3d', volume_level)
        widget:set_volume_level(volume_level)
    end

    function volume:inc(s)
        spawn.easy_async(INC_VOLUME_CMD(device, s or step), function(stdout)
            update_graphic(volume.widget, stdout)
        end)
    end

    function volume:dec(s)
        spawn.easy_async(DEC_VOLUME_CMD(device, s or step), function(stdout)
            update_graphic(volume.widget, stdout)
        end)
    end

    function volume:toggle()
        spawn.easy_async(TOG_VOLUME_CMD(device), function(stdout)
            update_graphic(volume.widget, stdout)
        end)
    end

    function volume:mixer()
        if mixer_cmd then
            spawn.easy_async(mixer_cmd)
        end
    end

    volume.widget:buttons(awful.util.table.join(
        awful.button({}, 3, function()
            if popup.visible then
                popup.visible = not popup.visible
            else
                rebuild_popup()
                popup:move_next_to(mouse.current_widget_geometry)
            end
        end),
        awful.button({}, 4, function()
            volume:inc()
        end),
        awful.button({}, 5, function()
            volume:dec()
        end),
        awful.button({}, 2, function()
            volume:mixer()
        end),
        awful.button({}, 1, function()
            volume:toggle()
        end)
    ))

    watch(GET_VOLUME_CMD(device), refresh_rate, update_graphic, volume.widget)

    return volume.widget
end

return setmetatable(volume, {
    __call = function(_, ...)
        return worker(...)
    end,
})
