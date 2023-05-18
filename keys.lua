local awful = require('awful')
local gears = require('gears')
local beautiful = require('beautiful')
local hotkeys_popup = require('awful.hotkeys_popup')
local menubar = require('menubar')
local app_menu = require('widgets.app-menu')

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')

-- Define mod keys
local modkey = 'Mod4'
-- local altkey = "Mod1"

local keys = {}

-- This is used later as the default terminal and editor to run.
local terminal = 'kitty'
local browser = 'firefox'
local files = 'thunar'
local editor = os.getenv('EDITOR') or 'nvim'
local editor_cmd = terminal .. ' -e ' .. editor

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Create a launcher widget and a main menu
local awesome_menu = {
    {
        'Hotkeys',
        function()
            hotkeys_popup.show_help(nil, awful.screen.focused())
        end,
    },
    { 'Manual', terminal .. ' -e man awesome' },
    { 'Config', editor_cmd .. ' ' .. awesome.conffile },
    { 'Restart', awesome.restart },
    {
        'Quit',
        function()
            awesome.quit()
        end,
    },
}

local main_menu = app_menu.build({
    before = {
        { 'Awesome', awesome_menu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { 'Terminal', terminal },
        -- other triads can be put here
    },
    -- sub_menu = 'Apps',
})

-- Mouse keys
root.buttons(gears.table.join(
    awful.button({}, 3, function()
        main_menu:toggle()
    end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))

-- Key bindings
keys.global_keys = gears.table.join(
    awful.key({ modkey }, '/', hotkeys_popup.show_help, { description = 'show help', group = 'awesome' }),
    awful.key({ modkey }, 'Left', awful.tag.viewprev, { description = 'view previous', group = 'tag' }),
    awful.key({ modkey }, 'Right', awful.tag.viewnext, { description = 'view next', group = 'tag' }),
    awful.key({ modkey }, 'Escape', awful.tag.history.restore, { description = 'go back', group = 'tag' }),

    awful.key({ modkey }, 'j', function()
        awful.client.focus.byidx(1)
    end, { description = 'focus next by index', group = 'client' }),
    awful.key({ modkey }, 'k', function()
        awful.client.focus.byidx(-1)
    end, { description = 'focus previous by index', group = 'client' }),
    -- awful.key({ modkey, }, "w", function() main_menu:show() end,
    --     { description = "show main menu", group = "awesome" }),

    -- Layout manipulation
    awful.key({ modkey, 'Shift' }, 'j', function()
        awful.client.swap.byidx(1)
    end, { description = 'swap with next client by index', group = 'client' }),
    awful.key({ modkey, 'Shift' }, 'k', function()
        awful.client.swap.byidx(-1)
    end, { description = 'swap with previous client by index', group = 'client' }),
    awful.key({ modkey, 'Control' }, 'j', function()
        awful.screen.focus_relative(1)
    end, { description = 'focus the next screen', group = 'screen' }),
    awful.key({ modkey, 'Control' }, 'k', function()
        awful.screen.focus_relative(-1)
    end, { description = 'focus the previous screen', group = 'screen' }),
    awful.key({ modkey }, 'u', awful.client.urgent.jumpto, { description = 'jump to urgent client', group = 'client' }),
    awful.key({ modkey }, 'Tab', function()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end, { description = 'go back', group = 'client' }),

    -- Standard program
    awful.key({ modkey }, 't', function()
        awful.spawn(terminal)
    end, { description = 'open a terminal', group = 'launcher' }),

    awful.key({ modkey }, '0', function()
        awful.spawn(terminal)
    end, { description = 'open a terminal', group = 'launcher' }),

    awful.key({ 'Mod1', 'Control' }, 't', function()
        awful.spawn(terminal)
    end, { description = 'open a terminal', group = 'launcher' }),

    awful.key({}, 'F12', function()
        awful.spawn(terminal, {
            floating = true,
            tag = mouse.screen.selected_tag,
            placement = awful.placement.top,
            opacity = 0.9,
            ontop = true,
            maximized_horizontal = true,
            height = 300,
        })
    end, { description = 'open a floating terminal', group = 'launcher' }),

    awful.key({ 'Mod1', 'Control' }, 'e', function()
        awful.spawn(files)
    end, { description = 'open a file explorer', group = 'launcher' }),

    awful.key({ 'Mod1', 'Control' }, 'w', function()
        awful.spawn(browser)
    end, { description = 'open a web browser', group = 'launcher' }),

    awful.key({ modkey, 'Control' }, 'r', awesome.restart, { description = 'reload awesome', group = 'awesome' }),
    awful.key({ modkey, 'Shift' }, 'q', awesome.quit, { description = 'quit awesome', group = 'awesome' }),

    awful.key({ modkey }, 'l', function()
        awful.tag.incmwfact(0.05)
    end, { description = 'increase master width factor', group = 'layout' }),
    awful.key({ modkey }, 'h', function()
        awful.tag.incmwfact(-0.05)
    end, { description = 'decrease master width factor', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'h', function()
        awful.tag.incnmaster(1, nil, true)
    end, { description = 'increase the number of master clients', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'l', function()
        awful.tag.incnmaster(-1, nil, true)
    end, { description = 'decrease the number of master clients', group = 'layout' }),
    awful.key({ modkey, 'Control' }, 'h', function()
        awful.tag.incncol(1, nil, true)
    end, { description = 'increase the number of columns', group = 'layout' }),
    awful.key({ modkey, 'Control' }, 'l', function()
        awful.tag.incncol(-1, nil, true)
    end, { description = 'decrease the number of columns', group = 'layout' }),
    awful.key({ modkey }, 'a', function()
        awful.layout.inc(1)
    end, { description = 'select next', group = 'layout' }),
    awful.key({ modkey, 'Shift' }, 'a', function()
        awful.layout.inc(-1)
    end, { description = 'select previous', group = 'layout' }),

    awful.key({ modkey, 'Shift' }, 'e', function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal('request::activate', 'key.unminimize', { raise = true })
        end
    end, { description = 'restore minimized', group = 'client' }),

    -- Prompt
    awful.key({ modkey }, 'd', function()
        awful.util.spawn_with_shell(
            "dmenu_run -p '' -y 6 -h 12 -fn 'FiraCode Nerd Font-10' -nf '#ccc' -nb '#000' -sf '#fff' -sb '#1688f0'"
        )
    end),
    -- awful.key({ modkey }, ' ', function()
    --     awful.util.spawn_with_shell('rofi -show drun')
    -- end),
    awful.key({ modkey }, 'space', function()
        awful.util.spawn_with_shell('rofi -show drun')
    end),
    awful.key({ modkey }, 'Tab', function()
        awful.util.spawn_with_shell('rofi -show window')
    end),
    awful.key({ modkey }, '.', function()
        awful.util.spawn_with_shell('rofi -show emoji')
    end),

    awful.key({ modkey }, 'x', function()
        awful.prompt.run({
            prompt = 'Run Lua code: ',
            textbox = awful.screen.focused().prompt_widget.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. '/history_eval',
        })
    end, { description = 'lua execute prompt', group = 'awesome' }),

    -- Menubar
    awful.key({ modkey }, 'p', function()
        menubar.show()
    end, { description = 'show the menubar', group = 'launcher' }),

    awful.key({ modkey, 'Shift' }, 's', function()
        awful.util.spawn(
            "scrot -e 'mv $f ~/Pictures/Screenshots/snap-%d-%m-%y-%H-%M-%S; \
            xclip -selection clipboard -t image/png -i ~/Pictures/Screenshots/snap-%d-%m-%y-%H-%M-%S 2>/dev/null'",
            false
        )
    end, { description = 'take full screenshot', group = 'client' }),

    awful.key({ modkey, 'Control' }, 's', function()
        awful.util.spawn(
            "scrot -ube 'mv $f ~/Pictures/Screenshots/snap-%d-%m-%y-%H-%M-%S; \
            xclip -selection clipboard -t image/png -i ~/Pictures/Screenshots/snap-%d-%m-%y-%H-%M-%S 2>/dev/null'",
            false
        )
    end, { description = 'take window screenshot', group = 'client' }),

    awful.key({ modkey }, 's', function()
        awful.util.spawn(
            "scrot -s -l width=3,color='#1688f0',mode=edge,opacity=75 \
            -e 'mv $f ~/Pictures/Screenshots/snap-%d-%m-%y-%H-%M-%S; \
            xclip -selection clipboard -t image/png -i ~/Pictures/Screenshots/snap-%d-%m-%y-%H-%M-%S 2>/dev/null'",
            false
        )
    end, { description = 'take regional screenshot', group = 'client' }),

    -- Volume Keys
    awful.key({}, 'XF86AudioLowerVolume', function()
        awful.util.spawn('amixer -q -D pulse sset Master 5%-', false)
    end),
    awful.key({}, 'XF86AudioRaiseVolume', function()
        awful.util.spawn('amixer -q -D pulse sset Master 5%+', false)
    end),
    awful.key({}, 'XF86AudioMute', function()
        awful.util.spawn('amixer -D pulse set Master 1+ toggle', false)
    end),
    -- Media Keys
    awful.key({}, 'XF86AudioPlay', function()
        awful.util.spawn('playerctl play-pause', false)
    end),
    awful.key({}, 'XF86AudioNext', function()
        awful.util.spawn('playerctl next', false)
    end),
    awful.key({}, 'XF86AudioPrev', function()
        awful.util.spawn('playerctl previous', false)
    end),
    -- Brightness
    awful.key({}, 'XF86MonBrightnessDown', function()
        awful.util.spawn('xbacklight -dec 10')
    end),
    awful.key({}, 'XF86MonBrightnessUp', function()
        awful.util.spawn('xbacklight -inc 10')
    end)
)

keys.client_keys = gears.table.join(
    awful.key({ modkey }, 'f', function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = 'toggle fullscreen', group = 'client' }),
    awful.key(
        { modkey, 'Control' },
        'f',
        awful.client.floating.toggle,
        { description = 'toggle floating', group = 'client' }
    ),
    awful.key({ modkey }, 'q', function(c)
        c:kill()
    end, { description = 'close', group = 'client' }),
    awful.key({ modkey }, 'Return', function(c)
        c:swap(awful.client.getmaster())
    end, { description = 'move to master', group = 'client' }),
    awful.key({ modkey }, 'w', function(c)
        c:move_to_screen()
    end, { description = 'move to screen', group = 'client' }),
    awful.key({ modkey }, 'o', function(c)
        c:move_to_screen()
    end, { description = 'move to screen', group = 'client' }),
    awful.key({ modkey, 'Shift' }, 't', function(c)
        c.ontop = not c.ontop
    end, { description = 'toggle keep on top', group = 'client' }),
    awful.key({ modkey }, 'e', function(c)
        c.minimized = true
    end, { description = 'minimize', group = 'client' }),
    awful.key({ modkey }, 'm', function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = '(un)maximize', group = 'client' }),
    awful.key({ modkey, 'Control' }, 'm', function(c)
        c.maximized_vertical = not c.maximized_vertical
        c:raise()
    end, { description = '(un)maximize vertically', group = 'client' }),
    awful.key({ modkey, 'Shift' }, 'm', function(c)
        c.maximized_horizontal = not c.maximized_horizontal
        c:raise()
    end, { description = '(un)maximize horizontally', group = 'client' })
)

-- Bind all key numbers to tags.
for i = 1, 9 do
    keys.global_keys = gears.table.join(
        keys.global_keys,
        -- View tag only.
        awful.key({ modkey }, '#' .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, { description = 'view tag #' .. i, group = 'tag' }),
        -- Toggle tag display.
        awful.key({ modkey, 'Control' }, '#' .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, { description = 'toggle tag #' .. i, group = 'tag' }),
        -- Move client to tag.
        awful.key({ modkey, 'Shift' }, '#' .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, { description = 'move focused client to tag #' .. i, group = 'tag' }),
        -- Toggle tag on focused client.
        awful.key({ modkey, 'Control', 'Shift' }, '#' .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, { description = 'toggle focused client on tag #' .. i, group = 'tag' })
    )
end

-- Mouse activates taskbar
keys.client_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal('request::activate', 'mouse_click', { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Create a wibox for each screen and add it
keys.taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
        t:view_only()
    end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end),
    awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end)
)

keys.tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal('request::activate', 'tasklist', { raise = true })
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end)
)

return keys
