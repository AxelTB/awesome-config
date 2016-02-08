local print = print
local io,math = io,math
local tostring,tonumber = tostring,tonumber
local color     = require( "gears.color"              )
local cairo     = require( "lgi"                      ).cairo
local gio       = require( "lgi"                      ).Gio
local wibox     = require( "wibox"                    )
local beautiful = require( "beautiful"                )
local awful     = require( "awful"                    )


local lgi  = require     'lgi'
local wirefu = require("wirefu")
local GLib = lgi.require 'GLib'

local capi = {timer=timer}
local ib = {widget = nil,battName = nil}

local percentageWidget = nil
local imageWidget = nil

--Save config
local batConfig={batId=0,batTimeout=60}
local batStatus={state="Unknown",rate,fullDesign,fullReal}

local battery_state = {
    ["Full"]        = "↯", ["Unknown"]     = "?",
    ["Charged"]     = "↯", ["Charging"]    = "⌁",
    ["Discharging"] = "",  ["Empty"] = "x",
    ["PCharge"] = ".", ["PDischage"] = ",",
}

local dbusState_lookup = {"Charging","Discharging","Empty","Charged","PCharge","PDischage"}
dbusState_lookup[0]="Unknown"



--[[Controllable methods
ib.hide=function()
    ib.widget = wibox.layout.fixed.horizontal()
end]]--

    ib.updateBatteryStatus=function()
    ib.battName.Percentage : get(function(per) print("PERCENTAGE",per) end)
        if ib.battName ~= nil then
            ib.battName.Percentage : get(function(per) percentageWidget:set_text(per.." %") end)
        end
    end  



---args={ battery_id, update_time}
---
---     battery_id: number of the visualized battery (Default 0)
---     update_time:    w idget update time in seconds (Default 15)
local function new(args)
    ib.widget = wibox.layout.fixed.horizontal()
    
    
    --Search for battery
    wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower").org.freedesktop.UPower.EnumerateDevices():get(function (nameList)
            --print("NL",nameList)
            for i = 1, #nameList do          
                   --print("found ",nameList[i])
                    if string.match(nameList[i],"BAT") then
                        percentageWidget = wibox.widget.textbox()
                        percentageWidget:set_text("Un")

                        imageWidget = wibox.widget.imagebox()
                        imageWidget:set_image(awful.util.getdir("config") .."/icons/batt.png")
    
                        ib.widget:add(imageWidget)
                        ib.widget:add(percentageWidget)

                        print("Battery found",nameList[i])
                        ib.battName=wirefu.SYSTEM.org.freedesktop.UPower(nameList[i]).org.freedesktop.UPower.Device;
                        
                        local t = capi.timer({timeout=batConfig.batTimeout})
                        t:connect_signal("timeout",ib.updateBatteryStatus)
                        t:start()
                        ib.updateBatteryStatus()
                        end
            end
        end,
        function (err)
        print("Unknown devices",err)
        end)
                    
                  
    
    --Update from dbus with wirefu
    local function updateDBusAsync()
        wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower/devices/battery_BAT0").org.freedesktop.UPower.Device.State : get( function (work)
                
                if work ~= nil then
                    batStatus.state=dbusState_lookup[work]
                    print("BatState:",batStatus.state)
                    --ib.widget:emit_signal("widget::updated")
                    
                end
            end,function(err) print("ERR:",err) end)
        
        wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower/devices/battery_BAT0").org.freedesktop.UPower.Device.Percentage : get(function (percentage)
                print("Percentage:",percentage)
                percentageWidget:set_text((tonumber(percentage) or 0)/100)
                --ib.widget:emit_signal("widget::updated")
            end,function(err) print("ERR:",err) end)
    end
    local function timeout(wdg)
        updateDBusAsync()
        --batStatus=parseAcpi()
        if batStatus.state == "Empty" or batStatus.state == "Unknown" then
            --AXTODO: Signal no battery and reduce rate of update 
            --ib= wibox.widget.base.empty_widget()
        end
        --wdg:set_value((tonumber(batStatus.rate) or 0)/100)
        --wdg:emit_signal("widget::updated")
    end

    --If any argument parse 'em
    if args~=nil then
        batConfig.batId = args.battery_id or batConfig.batId
        batConfig.batTimeout = args.update_time or batConfig.batTimeout
    end

    
    --
    --timeout(ib)
    
    return ib.widget
    
    --return ib
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
