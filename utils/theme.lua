local setmetatable = setmetatable
local print        = print
local tostring = tostring
local type         = type
local button       = require( "awful.button" )
local beautiful    = require( "beautiful"    )
local naughty      = require( "naughty"      )
local tag          = require( "awful.tag"    )
local wibox        = require( "awful.wibox"  )

local capi = { image  = image  ,
               widget = widget,
               screen = screen}

module("utils.theme")

local cacheE,cacheB = {},{}

function get_image_from_gradient(grad,width,height)
    local grad = grad or beautiful.bg_normal_grad
    local final_img = capi.image.argb32(width, height, nil)
    final_img:draw_rectangle_gradient(0,0,width,height,grad,0)
    return final_img
end

function set_wibox_background_gradient(w,g)
    if not g then return end
    w.bg = "#00000000"
    w.bg_image = get_image_from_gradient(g,w.width or capi.screen[w.screen or 1].geometry.width,w.height or capi.screen[w.screen or 1].geometry.height)
end

function get_end_arrow(bg_color,fg_color,padding,direction)
    local fcolor = fg_color or beautiful.fg_normal
    local bcolor = bg_color or beautiful.bg_normal_grad  or beautiful.bg_normal
    local bcolor_type  = type(bcolor) == "table" and not bcolor.pattern
    local bcolor_type2 = type(bcolor) == "table" and bcolor.pattern == true
    local hash = bcolor_type2 and bcolor or (fcolor..(bcolor_type and bcolor[1] or bcolor.name or bcolor)..(padding or 0)..(direction or ""))
    local search = cacheE[hash]
    if search then return search end
    local img = capi.image.argb32(9+(padding or 0), 16, nil)
    if bcolor_type then
        img:draw_rectangle_gradient(padding or 0, 0, 9, 16, bcolor,0)
        img:draw_rectangle_gradient(0, 0, padding or 0, 16, bcolor,0)
    elseif bcolor_type2 then
        img:insert(bcolor.image)
    else
        img:draw_rectangle(padding or 0, 0, 9, 16, true, bcolor)
        img:draw_rectangle(0, 0, padding or 0, 16, true, bcolor)
    end
    for i=0,(8) do
        img:draw_rectangle((padding or 0) +i,i, 9-i, 1, true, fcolor)
        img:draw_rectangle((padding or 0)+i,16-i,9-i, 1, true, fcolor)
    end
    if direction == "left" then
        img:rotate(2)
    end
    cacheE[hash] = img
    return img
end

function get_beg_arrow(bg_color,fg_color,padding,direction)
    local fcolor = fg_color or beautiful.fg_normal
    local bcolor = bg_color or beautiful.bg_normal_grad or beautiful.bg_normal
    local bcolor_type = type(bcolor) == "table" and not bcolor.pattern
    local bcolor_type2 = type(bcolor) == "table" and bcolor.pattern == true
    local hash = bcolor_type2 and bcolor or (fcolor..(bcolor_type and bcolor[1] or bcolor.name or bcolor)..(padding or 0)..(direction or ""))
    local search = cacheB[hash]
    if search then return search end
    local img = capi.image.argb32((direction == "left") and 8 or 9+(padding or 0), 16, nil)
    if bcolor_type then
        img:draw_rectangle_gradient(padding or 0, 0, 9, 16, bcolor,0)
    elseif bcolor_type2 then
        img:insert(bcolor.image)
    else
        img:draw_rectangle(0, 0, 9+(padding or 0), 16, true, bcolor)
    end
    for i=0,(8) do
        img:draw_rectangle((direction == "left") and 8-i+(padding or 0) or 0,i    , i, 1, true, fcolor)
        img:draw_rectangle((direction == "left") and 8-i+(padding or 0) or 0,16- i, i, 1, true, fcolor)
    end
    if direction == "left" then
        img:rotate(2)
    end
    cacheB[hash] = img
    return img
end

function new_arrow_widget(bg_color,fg_color,padding,direction)
    local wdg = capi.widget({type="imagebox"})
    wdg.image = get_end_arrow(bg_color,fg_color,padding,direction)
    return wdg
end

function get_beg_arrow_widget(bg_color,fg_color,padding,direction)
    local imgw = capi.widget({type="imagebox"})
    imgw.image = get_beg_arrow(bg_color,fg_color,padding,direction)
    return imgw
end

function gen_background_image(head_img,bg,tail_img,extents)
    local img = capi.image.argb32(extents.width, extents.height, nil)
    img:draw_rectangle(0, 0, extents.width, extents.height, true, bg)
    img:insert(head_img)
    img:insert(tail_img,extents.width -12)
    return img
end

--Create composited background image for buttons
local arr_nor,arr_foc
function gen_button_bg(head_img,extents,focus)
    local arr,bg
    if focus then
        if not arr_foc then
            arr_foc = get_end_arrow(beautiful.bg_highlight,nil,3)
        end
        arr = arr_foc
        bg  = beautiful.bg_highlight
    else
        if not arr_nor then
            arr_nor = get_end_arrow(beautiful.bg_normal,nil,3)
        end
        arr = arr_nor
        bg  = beautiful.bg_normal
    end
    return gen_background_image(head_img,bg,arr,extents)
end