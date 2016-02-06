local print = print
local io,math = io,math
local tostring,tonumber = tostring,tonumber
local color     = require( "gears.color"              )
local cairo     = require( "lgi"                      ).cairo
local gio       = require( "lgi"                      ).Gio
local wibox     = require( "wibox"                    )
local beautiful = require( "beautiful"                )


local lgi  = require     'lgi'
local wirefu = require("wirefu")
local GLib = lgi.require 'GLib'

local capi = {timer=timer}

--Save config
local batConfig={batId=0,batTimeout=15}
local batStatus={state,rate,fullDesign,fullReal}

local battery_state = {
    ["Full"]        = "↯", ["Unknown"]     = "?",
    ["Charged"]     = "↯", ["Charging"]    = "⌁",
    ["Discharging"] = "",  ["Empty"] = "x",
    ["PCharge"] = ".", ["PDischage"] = ",",
}

local dbusState_lookup = {"Charging","Discharging","Empty","Charged","PCharge","PDischage"}
dbusState_lookup[0]="Unknown"

local function set_value(self,value)
    self._value = value
    self:emit_signal("widget::updated")
end

local function fit(self,width,height)
    return width > (height * 1.5) and (height * 1.5) or width,height
end

local function draw(self,w,cr,width,height)
    cr:save()
    cr:set_source(color(beautiful.icon_grad or beautiful.fg_normal))
    cr:paint()
    local ratio = height / 10
    cr:set_source(color(beautiful.bg_alternate or beautiful.bg_normal))
    cr:rectangle(ratio,2*ratio,width-4*ratio,height-4*ratio)
    cr:stroke()
    cr:rectangle(width-3*ratio,height/3,1.5*ratio,height/3)
    cr:fill()
    cr:rectangle(2*ratio,3*ratio,(width-6*ratio)*(self._value or 0),height-6*ratio)
    cr:fill()
    self._tooltip.text = ((self._value or 0)*100)..'%'
    cr:set_source_rgba(1,0,0,1)
    cr:set_font_size(15)
    local extents = cr:text_extents(battery_state[batStatus.state or "Unknown"] or '*')
    cr:move_to(ratio+(width-4*ratio)/2-extents.width/2,height/2+extents.height)
    cr:show_text(battery_state[batStatus.state or "Unknown"] or '*')
    cr:restore()
end






---args={ battery_id, update_time}
---
---     battery_id: number of the visualized battery (Default 0)
---     update_time:    w idget update time in seconds (Default 15)
local function new(args)
    local ib = wibox.widget.base.empty_widget()

    --Update from dbus with wirefu
    local function updateDBusAsync()
        wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower/devices/battery_BAT0").org.freedesktop.UPower.Device.State : get( function (work)
                
                if work ~= nil then
                    batStatus.state=dbusState_lookup[work]
                    print("BatState:",batStatus.state)
                    ib:emit_signal("widget::updated")
                end
            end,function(err) print("ERR:",err) end)
        
        wirefu.SYSTEM.org.freedesktop.UPower("/org/freedesktop/UPower/devices/battery_BAT0").org.freedesktop.UPower.Device.Percentage : get(function (percentage)
                print("Percentage:",percentage)
                ib._value = ((tonumber(percentage) or 0)/100)
                ib:emit_signal("widget::updated")
            end,function(err) print("ERR:",err) end)
    end
    local function timeout(wdg)
        updateDBusAsync()
        --batStatus=parseAcpi()
        if batStatus.state == "Empty" then
            --AXTODO: Signal no battery and reduce rate of update 
        end
        --wdg:set_value((tonumber(batStatus.rate) or 0)/100)
        --wdg:emit_signal("widget::updated")
    end

    --If any argument parse 'em
    if args~=nil then
        batConfig.batId = args.battery_id or batConfig.batId
        batConfig.batTimeout = args.update_time or batConfig.batTimeout
    end




    ib.set_value = set_value
    ib.fit=fit
    ib.draw = draw
    ib:set_tooltip("100%")
    local t = capi.timer({timeout=batConfig.batTimeout})
    t:connect_signal("timeout",function() timeout(ib) end)
    t:start()
    timeout(ib)
    return ib
end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
-- kate: space-indent on; indent-width 2; replace-tabs on;
