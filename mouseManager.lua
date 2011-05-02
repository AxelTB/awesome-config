--Simple yet effective way to switch (the cursor and focus) from screen to screen
--Author: Emmanuel Lepage Vallee <elv1313@gmail.com>

local setmetatable = setmetatable
local io = io
local ipairs = ipairs
local table = table
local print = print
local capi = { screen = screen,
               mouse = mouse}

module("mouseManager")

local data = {screen = {}}
function new(screen, args) 
  return --Nothing to do
end

function switchTo(s)
  data.screen[capi.mouse.screen] = capi.mouse.coords()
  if (data.screen[s] ~= nil) then
    capi.mouse.coords(data.screen[s])
  else
    capi.mouse.screen = s
    capi.mouse.coords({x=capi.mouse.coords().x+(capi.screen[s].geometry.width/2),y=capi.mouse.coords().y+(capi.screen[s].geometry.height/2)})
  end
end

function reset()
  data.screen = nil
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
