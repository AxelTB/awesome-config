local setmetatable = setmetatable
local wibox = require("wibox")

local spacer={}

local function new(args)

  if args.icon then
    spacer=wibox.widget.imagebox()
    spacer.width = args.width or 0
    spacer:set_image(args.icon)
  else
    spacer  = wibox.widget.textbox()
    spacer:set_text(args.text or "")
    spacer.width = args.width or 0
  end
  return spacer
end


return setmetatable(spacer, { __call = function(_, ...) return new(...) end })
