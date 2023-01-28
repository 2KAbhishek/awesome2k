local wibox = require("wibox")

local icon_widget = wibox.widget {
    markup = " ",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

return icon_widget
