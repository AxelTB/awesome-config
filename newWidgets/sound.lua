local setmetatable = setmetatable
local tonumber = tonumber
local io = io
local type = type
local print = print
local button = require("awful.button")
local vicious =  require("vicious")
local wibox = require("wibox")
local widget2 = require("awful.widget")
--local config = require("forgotten")
local beautiful = require("beautiful")
local util = require("awful.util")
local radical      = require( "radical"                  )
local capi = { screen = screen, mouse = mouse}
local awful = require("awful")

local moduleSound = {}

local mainMenu = nil

local errcount = 0

local iconWidget = nil

local pavuSinkN=1

local iconPath=awful.util.getdir("config")..'/icons/'

-- Adds a line for a device
-- mainMenu:    menu in wich add item
-- name:        dev name
-- aVolume:     dev volume
-- isMute
-- commArgs:    arguments to be passed to function itemScrollUp and itemScrollDown
function addVolumeDevice(mainMenu,name,aVolume,isMute,commArgs)

  local icon = wibox.widget.imagebox()
  if isMute then icon:set_image(iconPath.."volm.png")
  else icon:set_image(iconPath.."vol3.png") end

  local volume = widget2.progressbar()
  volume:set_width(80)
  volume:set_height(20)
  volume:set_background_color(beautiful.bg_normal)
  volume:set_border_color(beautiful.fg_normal)
  volume:set_color(beautiful.fg_normal)
  volume:set_value(aVolume or 0)
  if (widget2.progressbar.set_offset ~= nil) then
    volume:set_offset(1)
  end

  --Add line and set scroll volume control
  mainMenu:add_item({text=name,prefix_widget=icon,suffix_widget=volume,
  button3=function(geo,parent)
    --Toggle mute
    isMute = not isMute
    if isMute then icon:set_image(iconPath .. "volm.png")
    else icon:set_image(iconPath .. "vol3.png") end
    moduleSound.itemToggleMute(commArgs)
    --AXTODO: toggle mute
  end,
  button4=function(geo,parent)
    aVolume=aVolume+0.02
    if aVolume>1 then aVolume=1 end
    volume:set_value(aVolume)
    volume:emit_signal("widget::updated")
    moduleSound.itemScrollUp(commArgs)
  end,
  button5=function(geo,parent)
    aVolume=aVolume-0.02
    if aVolume<0 then aVolume=0 end
    volume:set_value(aVolume)
    volume:emit_signal("widget::updated")
    moduleSound.itemScrollDown(commArgs)
  end})
end



local function new(mywibox3)
  --Variables---------------------------------------------------------

  --Functions------------------------------------------------------------------------
  -- Alsa mode functions-----------------------------------
  moduleSound.itemScrollUp=function(devId)
    util.spawn_with_shell("amixer -q sset "..devId.." 2%+ >/dev/null")
  end
  moduleSound.itemScrollDown=function(devId)
    util.spawn_with_shell("amixer -q sset "..devId.." 2%- >/dev/null")
  end
  moduleSound.itemToggleMute=function(devId)
    util.spawn_with_shell("amixer -q set "..devId.." 1+ toggle")
  end

  function drawMenu()
    local mainMenu=  radical.context({width=200,arrow_type=radical.base.arrow_type.CENTERED})
    --Add menu header
    mainMenu:add_widget(radical.widgets.header(mainMenu,"OUT:")  , {height = 20  , width = 200})
    mainMenu:add_widget(radical.widgets.separator())
    --Parse Devices names
    local pipe = io.popen("amixer | awk -f "..util.getdir("config").."/drawer/Scripts/parseAlsa.awk")
    for line in pipe:lines() do
      local data=string.split(line,";")
      local aChannal = data[1]
      local aVolume = (tonumber(data[2]:match("%d+")) or 0) / 100
      local isMute = false
      if data[3]:match("off") then isMute=true end
      --Add device
      addVolumeDevice(mainMenu,aChannal,aVolume,isMute,aChannal)
    end
    pipe:close()
    return mainMenu
  end


  --Master Volume parser for widget
  function amixer_volume_int(format)
    local f= io.popen("amixer sget Master | awk '/Front.*Playback/{print $5; exit}'| grep -o -e '[0-9]*'")

    if f then
      return tonumber(f:read("*a")) or 0
    else
      print("Calling amixer failed")
    end

    return 0
  end

  function toggle()
    if not mainMenu then
      mainMenu = drawMenu()
      mainMenu.parent_geometry = geo
      mainMenu.visible = true
    else
      --Close and destroy main menu
      mainMenu.visible = false
      mainMenu = nil
    end
  end

  --Constructor ------------------------------------------------------
  --if widget then return widget end
  local widget = wibox.layout.fixed.horizontal()
  local valueWidget=wibox.widget.textbox()

  local btn = util.table.join(
  button({ }, 1, function(geo)
    toggle()
  end),
  --button({ }, 3, function()  util.spawn_with_shell("pactl set-sink-mute "..pavuSinkN.." toggle")   end),
  button({ }, 3, function()  util.spawn_with_shell("pavucontrol")   end),
  button({ }, 4, function()  util.spawn_with_shell("amixer -q sset Master 2%+") valueWidget:set_text(amixer_volume_int()) end),
  button({ }, 5, function()  util.spawn_with_shell("amixer -q sset Master 2%-") valueWidget:set_text(amixer_volume_int()) end)
)

vicious.register(valueWidget, amixer_volume_int,1)
-- iconWidget
iconWidget = wibox.widget.imagebox()
iconWidget:set_image(iconPath.."vol3.png")

-- pWidget
local pWidget= wibox.widget.textbox()
pWidget:set_text(" %");
widget:buttons(btn)

widget:add(iconWidget)
widget:add(valueWidget)
widget:add(pWidget)
return widget
end

return setmetatable(moduleSound, { __call = function(_, ...) return new(...) end })
