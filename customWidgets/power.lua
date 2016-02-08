local print = print
local wibox     = require( "wibox"                    )
--local beautiful = require( "beautiful"                )
local awful     = require( "awful"                    )


local lgi  = require     'lgi'
local wirefu = require("wirefu")
local GLib = lgi.require 'GLib'

local capi = {timer=timer}
local ib = {widget = nil,battName = nil}

local percentageWidget = nil
local imageWidget = nil

--Save config
local batConfig={batTimeout=60}
local batStatus={state="Unknown",rate,fullDesign,fullReal}
local powerStatus = {source = nil}
local t

--Controllable methods

    ib.updateBatteryStatus=function()
        ib.battName.Percentage : get(function(per) print("PERCENTAGE",per) end)
        if ib.battName ~= nil then
            ib.battName.Percentage : get(function(per) percentageWidget:set_text(per.." %") end)
        end
    end  


local function new(args)
    ib.widget = wibox.layout.fixed.horizontal()
    
    imageWidget = wibox.widget.imagebox()
    percentageWidget = wibox.widget.textbox()
    
    ib.widget:add(imageWidget)
    ib.widget:add(percentageWidget)
    
    --
     
    
    --Search for battery
    wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower").org.freedesktop.UPower.EnumerateDevices():get(function (nameList)
            --print("NL",nameList)
            
            --Search for line power
            for i = 1, #nameList do          
                   --print("found ",nameList[i])
                    if string.match(nameList[i],"line") then
                        imageWidget:set_image(awful.util.getdir("config") .."/customWidgets/icons/power_line.png")
                        percentageWidget:set_text("")
                        powerStatus.source="LINE"
                    end
            end
            
            --Search for battery
            for i = 1, #nameList do
             if string.match(nameList[i],"BAT") then
               
                            print("Battery found",nameList[i])
                            ib.battName=wirefu.SYSTEM.org.freedesktop.UPower(nameList[i]).org.freedesktop.UPower.Device;
                            
                            --Set Widget
                            --Change icon if no line power
                            if powerStatus.source ~= "LINE" then
                            imageWidget:set_image(awful.util.getdir("config") .."/customWidgets/icons/power_batt.png")
                            end
                            --Set update
                            t = capi.timer({timeout=batConfig.batTimeout})
                            t:connect_signal("timeout",ib.updateBatteryStatus)
                            t:start()
                            
                            --Force first update
                            ib.updateBatteryStatus()
                    end
            end
        end,
        function (err)
        print("Unknown devices",err)
        end)
                    
                  
    
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

