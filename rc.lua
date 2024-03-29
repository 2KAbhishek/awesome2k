-- If LuaRocks is installed, load packages from there
pcall(require, 'luarocks.loader')

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
-- Widget and layout library
local wibox = require('wibox')
-- Theme handling library
local beautiful = require('beautiful')
-- Notification library
local naughty = require('naughty')
require('awful.autofocus')

-- Themes define colours, icons, font and wallpapers.
local HOME = os.getenv('HOME')
beautiful.init(HOME .. '/.config/awesome/awesome2k.lua')
local round_rect = function(cr, w, h)
    gears.shape.rounded_rect(cr, w, h, 10)
end

-- Set keys
local keys = require('keys')
root.keys(keys.global_keys)

-- Set rules
local create_rules = require('rules').create
awful.rules.rules = create_rules(keys.client_keys, keys.client_buttons)

-- Widgets
local audio_widget = require('widgets.audio')
local network_widget = require('widgets.network')
local battery_widget = require('widgets.battery')
local session_widget = require('widgets.session')
local todo_widget = require('widgets.todo')
local cpu_widget = require('widgets.cpu')
local ram_widget = require('widgets.ram')
local disk_widget = require('widgets.disk')
local time_widget = require('widgets.time')
local separator = require('widgets.text')
separator.markup = '  '
local systray_widget = wibox.widget.systray()
systray_widget.set_base_size(15)

-- Enabled Layouts
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.top,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.corner.nw,
    awful.layout.suit.corner.se,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
}

awful.screen.connect_for_each_screen(function(screen)
    -- Each screen has its own tag table.
    awful.tag({ ' ', ' ', ' ', ' ', ' ' }, screen, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    screen.prompt_widget = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    screen.layout_widget = awful.widget.layoutbox(screen)
    screen.layout_widget:buttons(gears.table.join(
        awful.button({}, 1, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 3, function()
            awful.layout.inc(-1)
        end),
        awful.button({}, 4, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 5, function()
            awful.layout.inc(-1)
        end)
    ))

    -- Create a taglist widget
    screen.taglist_widget = awful.widget.taglist({
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        buttons = keys.taglist_buttons,
    })

    -- Create a tasklist widget
    screen.tasklist_widget = awful.widget.tasklist({
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = keys.tasklist_buttons,
        style = {
            shape_border_width = 1,
            shape_border_color = beautiful.fg_minimize,
            shape_border_color_focus = beautiful.border_focus,
            shape = round_rect,
            bg_focus = beautiful.bg_focus,
            fg_focus = beautiful.fg_focus,
        },
        layout = {
            spacing = 8,
            fixed_width = 50,
            layout = wibox.layout.flex.horizontal,
        },
        widget_template = {
            {
                {
                    {
                        {
                            id = 'icon_role',
                            widget = wibox.widget.imagebox,
                        },
                        margins = 2,
                        widget = wibox.container.margin,
                    },
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal,
                },
                left = 10,
                right = 10,
                widget = wibox.container.margin,
                forced_width = 10,
            },
            id = 'background_role',
            widget = wibox.container.background,
        },
    })

    -- Create the wibar
    screen.wibar = awful.wibar({
        position = 'top',
        screen = screen,
        border_width = 4,
        opacity = 0.7,
        shape = round_rect,
    })

    -- Add widgets to the wibox
    screen.wibar:setup({
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 6,
            screen.layout_widget,
            screen.taglist_widget,
            screen.prompt_widget,
            separator,
        },
        screen.tasklist_widget, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 6,
            separator,
            todo_widget(),
            time_widget,
            audio_widget(),
            battery_widget(),
            network_widget(),
            ram_widget(),
            disk_widget(),
            cpu_widget(),
            separator,
            systray_widget,
            separator,
            session_widget(),
        },
    })
end)

-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal('request::titlebars', function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal('request::activate', 'titlebar', { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal('request::activate', 'titlebar', { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup({
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Middle
            { -- Title
                align = 'center',
                widget = awful.titlebar.widget.titlewidget(c),
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal,
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal(),
        },
        layout = wibox.layout.align.horizontal,
    })
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal('mouse::enter', function(c)
    c:emit_signal('request::activate', 'mouse_enter', { raise = false })
end)

client.connect_signal('focus', function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal('unfocus', function(c)
    c.border_color = beautiful.border_normal
end)

-- Rounded windows
client.connect_signal('manage', function(c)
    c.shape = round_rect
end)

-- Make floating windows always on top
client.connect_signal('property::floating', function(c)
    if not c.fullscreen then
        if c.floating then
            c.ontop = true
        else
            c.ontop = false
        end
    end
end)

-- Autostart
awful.spawn.with_shell('autorandr -l default')
awful.spawn.with_shell('picom')
awful.spawn.with_shell('nitrogen --restore')
awful.spawn.with_shell('copyq')
awful.spawn.with_shell('dropbox start')

-- Check if awesome encountered an error during startup
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = 'Oops, there were errors during startup!',
        text = awesome.startup_errors,
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal('debug::error', function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = 'Oops, an error happened!',
            text = tostring(err),
        })
        in_error = false
    end)
end

-- Run garbage collector regularly to prevent memory leaks
gears.timer({
    timeout = 60,
    autostart = true,
    callback = function()
        collectgarbage()
    end,
})
