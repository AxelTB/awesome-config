
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local fd_async = require("utils.fd_async")
-- Other libraries
-- Tag
local radical = require("radical")
local tyrannical = require("tyrannical")
require( "tyrannical.shortcut" )
require("repetitive")
local shorter = require( "shorter" )

-- Widgets
local customWidgets = require("customWidgets")
-- App Menu
local appmenu   = require( "appMenu")
app_menu = appmenu (
{ -- Main menu
filter      = true,
show_filter = true,
max_items   = 20,
style       = radical.style.classic,
item_style  = radical.item.style.classic
}
,{ -- Sub menus
max_items   = 20,
style       = radical.style.classic,
item_style  = radical.item.style.classic
})

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
  title = "Oops, there were errors during startup!",
  text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    -- Make sure we don't go into an endless error loop
    if in_error then return end
    in_error = true

    naughty.notify({ preset = naughty.config.presets.critical,
    title = "Oops, an error happened!",
    text = err })
    in_error = false
  end)
end
-- }}}

-- This is used later as the default terminal and editor to run.


local backgroundPath = os.getenv("HOME").."/wallpapers/"
-- Allow personal.lua file to overload some settings (If exists)
local personalPath=awful.util.getdir("config")..'/personal.lua'

local f=io.open('peronal.lua',"r")
if f~=nil then
  io.close(f)
  dofile('personal.lua')
  print("Info: personal.lua file loaded")

else
  print("Warn: personal.lua file not found")
end

-- {{{ Widgets
-- Create the clock
--local clock                  = drawer.dateInfo          ( nil,{camUrl=myCamUrl,camTimeout=myCamTimeout}                 )
-- clock.bg                     = beautiful.bar_bg_alternate or beautiful.bg_alternate

-- Create the volume box
local soundWidget           = customWidgets.sound()
--local powerWidget         = customWidgets.power()
-- Create the net manager
--local netinfo                = drawer.netInfo           ( 300                                )

-- Create the memory manager
--local meminfo                = drawer.memInfo           ( 300                                )

-- Create the cpu manager
--local cpuinfo                = drawer.cpuInfo           ( 300                                )
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/sky/theme.lua")

terminal = terminal or "mate-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier
}
-- }}}

-- First, set some settings
tyrannical.settings.default_layout =  awful.layout.suit.tile.left
tyrannical.settings.mwfact = 0.66

-- Setup some tags
dofile(awful.util.getdir("config") .. "/baseRule.lua")

-- Do not honor size hints request for those classes
--tyrannical.properties.size_hints_honor = { xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}


-- {{{ Wallpaper

if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end

math.randomseed( os.time() )
function randomBackground()
  fd_async.directory.list(backgroundPath):connect_signal("request::completed",function(list)
    for s = 1, screen.count() do
      gears.wallpaper.fit(backgroundPath .. list[math.random(#list)], s)
    end

  end)
end

randomBackground()
-- }}}

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu

--mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,                                     menu = app_menu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M %d-%m")

-- Create a wibox for each screen and add it
topWibox = {}
bottomWibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
awful.button({ }, 1, awful.tag.viewonly),
awful.button({ modkey }, 1, awful.client.movetotag),
awful.button({ }, 3, awful.tag.viewtoggle),
awful.button({ modkey }, 3, awful.client.toggletag),
awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
awful.button({ }, 1, function (c)
  if c == client.focus then
    c.minimized = true
  else
    -- Without this, the following
    -- :isvisible() makes no sense
    c.minimized = false
    if not c:isvisible() then
      awful.tag.viewonly(c:tags()[1])
    end
    -- This will also un-minimize
    -- the client, if needed
    client.focus = c
    c:raise()
  end
end),
awful.button({ }, 3, function ()
  if instance then
    instance:hide()
    instance = nil
  else
    instance = awful.menu.clients({ width=250 })
  end
end),
awful.button({ }, 4, function ()
  awful.client.focus.byidx(1)
  if client.focus then client.focus:raise() end
end),
awful.button({ }, 5, function ()
  awful.client.focus.byidx(-1)
  if client.focus then client.focus:raise() end
end))

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
  awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the top wibox top
  topWibox[s] = awful.wibox({ position = "top", screen = s })

  -- Widgets that are aligned to the left
  local top_left_layout = wibox.layout.fixed.horizontal()
  top_left_layout:add(mytaglist[s])
  top_left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right
  local top_right_layout = wibox.layout.fixed.horizontal()
  top_right_layout:add(soundWidget)
  top_right_layout:add(customWidgets.spacer({text=" | "}))
  top_right_layout:add(mytextclock)
  -- Now bring it all together (with the tasklist in the middle)
  local top_layout = wibox.layout.align.horizontal()
  top_layout:set_left(top_left_layout)
  top_layout:set_right(top_right_layout)
  topWibox[s]:set_widget(top_layout)

  -- Create the bottom wibox top
  bottomWibox[s] = awful.wibox({ position = "bottom", screen = s })

  -- Widgets that are aligned to the left

  -- Widgets that are aligned to the right
  local bottom_right_layout = wibox.layout.fixed.horizontal()
  -- On first Screen show battery and system tray
  if s == 1 then
    --bottom_right_layout:add(powerWidget)
    bottom_right_layout:add(customWidgets.spacer({text=" "}))
    bottom_right_layout:add(wibox.widget.systray())
    --bottom_right_layout:add(customWidgets.power())
  end
  bottom_right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local bottom_layout = wibox.layout.align.horizontal()


  local mylauncher = wibox.widget.imagebox();
  mylauncher:set_menu(app_menu,1)
  mylauncher:set_image(beautiful.awesome_icon)
  bottom_layout:set_left(mylauncher)
  bottom_layout:set_middle(mytasklist[s])
  bottom_layout:set_right(bottom_right_layout)

  bottomWibox[s]:set_widget(bottom_layout)


end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
-- Add keyboard shortcuts
dofile(awful.util.getdir("config") .. "/shortcuts.lua")
-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
  -- Enable sloppy focus
  c:connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    and awful.client.focus.filter(c) then
      client.focus = c
    end
  end)

  if not startup then
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)

    -- Put windows in a smart way, only if they does not set an initial position.
    if not c.size_hints.user_position and not c.size_hints.program_position then
      awful.placement.no_overlap(c)
      awful.placement.no_offscreen(c)
    end
  end

  local titlebars_enabled = true
  if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
    local sp=customWidgets.spacer({text = " "})

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(sp)
    left_layout:add(awful.titlebar.widget.iconwidget(c))

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(awful.titlebar.widget.floatingbutton(c))
    right_layout:add(sp)
    right_layout:add(awful.titlebar.widget.maximizedbutton(c))
    right_layout:add(sp)
    right_layout:add(awful.titlebar.widget.closebutton(c))
    right_layout:add(sp)

    -- The title goes in the middle
    local title = awful.titlebar.widget.titlewidget(c)
    title:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      client.focus = c
      c:raise()
      awful.mouse.client.move(c)
    end),
    awful.button({ }, 3, function()
      client.focus = c
      c:raise()
      awful.mouse.client.resize(c)
    end)
  ))

  -- Now bring it all together
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_right(right_layout)
  layout:set_middle(title)

  awful.titlebar(c):set_widget(layout)
end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


--[[shorter.register_section("TYRANNICAL",{
foo = "bar",
bar = "foo"
})]]--

shorter.Tag = {
  --[[{desc = "Set the tag state",
  key={{  modkey, "Control" }, "Tab"   }, fct = function () customButton.lockTag.show_menu()                  end},
  ]]--
  {desc = "Change background",
  key={{  modkey,   }, "b" }, fct = randomBackground},


  {desc = "Switch to the previous layout",
  key={{  modkey, "Shift"   }, "space" }, fct = function () awful.layout.inc(layouts,  -1) end},

  {desc = "Switch to the next layout",
  key={{  modkey,           }, "space" }, fct = function () awful.layout.inc(layouts,  1)      end}
}
