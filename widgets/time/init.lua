local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

beautiful.init("~/.config/awesome/awesome2k.lua")

local time_widget = wibox.widget {
    format = '  %I:%M %p  %a, %b %d',
    widget = wibox.widget.textclock
}

local month_calendar = awful.widget.calendar_popup.year()
month_calendar.border_color = beautiful.border_focus
month_calendar.border_width = '2'
month_calendar.shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 10) end
month_calendar:attach(time_widget, "tm")

return time_widget
