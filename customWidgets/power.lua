local print = print
local wibox     = require( "wibox" )
--local beautiful = require( "beautiful" )
local awful     = require( "awful" )


local lgi  = require     'lgi'
local wirefu = require("wirefu")
local GLib = lgi.require 'GLib'

local radical=require("radical")
radical.context = require( "radical.context"       )
local fd_async     = require("utils.fd_async"         )

local capi = {timer=timer}
local ib = {widget = nil,battWirefuLink = nil}

local percentageWidget = nil
local imageWidget = nil

--Save config
local batConfig={batTimeout=3}
local batStatus={state="Unknown",rate,fullDesign,fullReal}
local powerStatus = {source = nil}
local t

--Controllable methods

    ib.updateBatteryStatus=function()
        if ib.battWirefuLink ~= nil then
            ib.battWirefuLink.Percentage : get(function(per) percentageWidget:set_text(per.." %") end)
        end
    end  

    ib.updatePowerStatus=function()
     wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower").org.freedesktop.UPower.EnumerateDevices():get(function (nameList)
            --print("NL",nameList)
            
            --Reset power source
            powerStatus.source=nil
            
            for i = 1, #nameList do
             if string.match(nameList[i],"BAT") then
               
                            --print("Battery found",nameList[i])
                            ib.battWirefuLink=wirefu.SYSTEM.org.freedesktop.UPower(nameList[i]).org.freedesktop.UPower.Device;
                            ib.battName=nameList[i]
                            --Set Widget
                            --Change icon if no line power
                            if powerStatus.source ~= "LINE" then
                            imageWidget:set_image(awful.util.getdir("config") .."/customWidgets/icons/power_batt.png")
                            powerStatus.source = "BAT"
                            end
                            --update
                            ib.updateBatteryStatus()
                                                        
             elseif string.match(nameList[i],"line") then
                        --If line found check if online
                       -- print("Found line",nameList[i])
                        wirefu.SYSTEM.org.freedesktop.UPower(nameList[i]).org.freedesktop.UPower.Device.Online : get(function(connected)
                        if connected then
                            --print("Line is ",connected)
                            --If online change icon and set source to line
                            powerStatus.source="LINE"
                            imageWidget:set_image(awful.util.getdir("config") .."/customWidgets/icons/power_line.png")
                        end
                        end, function(error) print("ERR::Power ",err) end)
                        
             end
            end
                
        end,
        function (err)
        print("Unknown devices",err)
        end)
        end
----- Local functions

local function createMenu()
    local menu = radical.context{}
    local menuText = wibox.widget.textbox()
    
    menu:add_widget(menuText)
    
    local battText=""
    local pipe = io.popen('upower -i `upower -e | grep BAT` | tr -d " "')
    while true do
    line=pipe:read("*line")
    if line == nil then break end
        --print("L: ",line)
        battText=battText.."\n"..line;
    end
    
    menuText:set_markup(battText)
 
 return menu
end
local function new(args)
    ib.widget = wibox.layout.fixed.horizontal()
    ib.widget:set_menu(createMenu(),1)
    --ib.widget:set_tooltip("BHO\n<br>BHO")
    
    imageWidget = wibox.widget.imagebox()
    percentageWidget = wibox.widget.textbox()
    
    ib.widget:add(imageWidget)
    ib.widget:add(percentageWidget)
    
    t = capi.timer({timeout=batConfig.batTimeout})
     
    
    --Update Status
    ib.updatePowerStatus()
                    
    t:connect_signal("timeout",ib.updatePowerStatus)
    t:start()              
    
--[[        wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower/devices/battery_BAT0").org.freedesktop.UPower.Device.State : get( function (work)
                
                if work ~= nil then
                    batStatus.state=dbusState_lookup[work]
                    print("BatState:",batStatus.state)
                    --ib.widget:emit_signal("widget::updated")
                    
                end
            end,function(err) print("ERR:",err) end)
]]--
   
    return ib.widget
    
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })

