local setmetatable = setmetatable
local table        = table
local print        = print
local button       = require( "awful.button"                 )
local beautiful    = require( "beautiful"                    )
local naughty      = require( "naughty"                      )
local tag          = require( "awful.tag"                    )
local util         = require( "awful.util"                   )
local config       = require( "config"                       )
local widget2      = require( "awful.widget"                 )
local wibox        = require( "awful.wibox"                  )
local button       = require( "awful.button"                 )
local desktopGrid  = require( "widgets.layout.desktopLayout" )

local capi = { image        = image       ,
               widget       = widget      ,
               mousegrabber = mousegrabber}

module("widgets.desktopIcon")

function new(screen, args) 
  local aWibox = wibox({position="free"})
  aWibox:geometry({x=400,y=400,width = 230, height = 30})
  local textTest = capi.widget({type="textbox" })
  local icon     = capi.widget({type="imagebox"})
  icon.image     = capi.image(config.data().iconPath .. "home.png")
  textTest.text  = "   text"
  aWibox.widgets = {icon,textTest, layout = widget2.layout.horizontal.leftrightcached }
  aWibox.bg      = "#ff000000"
  aWibox:add_signal("mouse::enter", function() aWibox.bg = beautiful.fg_normal.."25" end)
  aWibox:add_signal("mouse::leave", function() aWibox.bg = "#00000000"               end)
  
  desktopGrid.addWidget(aWibox)
  return aWibox
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })