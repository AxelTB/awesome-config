local print = print
local wibox     = require( "wibox" )
--local beautiful = require( "beautiful" )
local awful     = require( "awful" )
local fd_async     = require("utils.fd_async"         )

local capi = {timer=timer}
local ib = {widget = nil,tooltip=nil}

local percentageWidget = nil
local imageWidget = nil

--Save config
local batConfig={batTimeout=60}

--Controllable methods

ib.updatePowerStatus=function()
  local lineN = 0
  local  popupText = ''
  fd_async.exec.command('acpi -bi'):connect_signal("new::line",function(content)
    --print("------Content:",content)

    if content then
      if lineN == 0 then
        temp=string.split(content,',')
        head=string.split(temp[1],':')

        powerStatus=head[2]
        --print("PS:",powerStatus)
        percentageWidget:set_text(temp[2])

        if string.match(powerStatus,"Charging") then
          imageWidget:set_image(awful.util.getdir("config") .."/customWidgets/icons/power_line.png")
        elseif string.match(powerStatus,'Discharging') then
          imageWidget:set_image(awful.util.getdir("config") .."/customWidgets/icons/power_batt.png")
        end
        --popupText=content..'\n'
      end

      popupText=popupText..content..'\n'
      lineN=lineN+1
    else
      tooltip:set_text(popupText)
      print("popup:",popupText)
    end



  end)



end

local function new(args)
  ib.widget = wibox.layout.fixed.horizontal()

  imageWidget = wibox.widget.imagebox()
  percentageWidget = wibox.widget.textbox()

  ib.widget:add(imageWidget)
  ib.widget:add(percentageWidget)

  local t = capi.timer({timeout=batConfig.batTimeout})

  tooltip = awful.tooltip({ objects = { ib.widget},})
  --Update Status
  ib.updatePowerStatus()

  t:connect_signal("timeout",ib.updatePowerStatus)
  t:start()

  return ib.widget

end

return setmetatable({}, { __call = function(_, ...) return new(...) end })
