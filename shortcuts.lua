local awful        = require( "awful"       )
awful.rules         = require("awful.rules")
local shorter      = require( "shorter" )
--local widgets      = require( "widgets"                    )
local alttab       = require( "radical.impl.alttab"        )
local alttag       = require( "radical.impl.alttag"        )
--local customButton = require( "customButton"               )
--local customMenu   = require( "customMenu"                 )
--local menubar      = require( "menubar"                    )
--local collision    = require( "collision"                  )
local util         = require( "awful.util"                 )
local beautiful     = require("beautiful")


shorter.Navigation = {
    desc = "Navigate between clients",

    {desc = "Move to the previous focussed client",
        key = {{ modkey, }, "j"},
        fct = function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end
    },

    {desc = "Move to the next focussed client",
        key  = {{ modkey,           }, "k"},
        fct  = function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end
    },

--     {desc = "",
--     key={{ modkey, "Shift"   }, "j"     }, fct = function () awful.client.swap.byidx(  1)                      end},
-- 
--     {desc = "",
--     key={{ modkey, "Shift"   }, "k"     }, fct = function () awful.client.swap.byidx( -1)                      end},

    {desc = "Jump to urgent clients",
    key={{  modkey,           }, "u"    }, fct = awful.client.urgent.jumpto                                       },

    {desc = "Display the mission center",
    key={{  modkey,           }, "Tab"  }, fct = function () alttab.altTab()                                   end},

    {desc = "Display the mission center",
    key={{  modkey, "Shift"   }, "Tab"  }, fct = function () alttab.altTabBack()                               end},

    {desc = "Select previous client",
    key={{  "Mod1",           }, "Tab"  }, fct = function () alttab.altTab({auto_release=true})                end},

    {desc = "Select the next client",
    key={{  "Mod1", "Shift"   }, "Tab"  }, fct = function () alttab.altTabBack({auto_release=true})            end},

    {desc = "Display the tag search box",
    key={{  modkey,           }, "#49"  }, fct = function () alttag()                                   end},

    {desc = "Display the tag switcher",
    key={{  "Mod1",           }, "#49"  }, fct = function () alttag()                                   end},
    {desc = "Take Screenshot",
    key={{             }, "Print"  }, fct = function () awful.util.spawn_with_shell("scrot")            end},
}

shorter.Client = {
   {desc = "Launch xkill",
   key={{          "Control" }, "Escape"}, fct = function () awful.util.spawn("xkill")                         end}
}
--[[
shorter.Screen = {
    {desc = "Select screen 2",
    key={ {                   }, "#179" }, fct = function () collision.select_screen(2)       end },

    {desc = "Select screen 3",
    key={ {                   }, "#175" }, fct = function () collision.select_screen(3)       end },

    {desc = "Select screen 4",
    key={ {                   }, "#176" }, fct = function () collision.select_screen(4)       end },

    {desc = "Select screen 1",
    key={ {                   }, "#178" }, fct = function () collision.select_screen(1)       end },

    {desc = "Select screen 5",
    key={ {                   }, "#177" }, fct = function () collision.select_screen(5)       end },
      
      
    {desc = "Select screen 5",
    key={ {                   }, "#180" }, fct = function () collision.swap_screens(5)       end },
  
  {desc = "Random Background",
    key={ {      modkey,             }, "b" }, fct = function () awful.util.spawn_with_shell("$HOME/.config/awesome/Scripts/randomBackground.sh")       end },
}
]]--
local hooks = {
    {{         },"Return",function(command)
        local result = awful.util.spawn(command)
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end},
    {{"Shift" },"Return",function(command)
        local result = awful.util.spawn('gnome-terminal -e "bash -c \"'.. command ..'; exec bash\""')
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end}
    --[[{{"Mod1"   },"Return",function(command)
        local result = awful.util.spawn(command,{intrusive=true})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end},
    {{"Shift"  },"Return",function(command)
        local result = awful.util.spawn(command,{intrusive=true,ontop=true,floating=true})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end}]]--
}

--Open clients in screen "s"
for s = 1, screen.count() do
    table.insert(hooks, {{"Mod4"  },tostring(s),function(command)
        local result = awful.util.spawn(command,{screen=s})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end})
    table.insert(hooks, {{  },"F"..s,function(command)
        local result = awful.util.spawn(command,{screen=s,intrusive=true,ontop=true,floating=true})
        mypromptbox[mouse.screen].widget:set_text(type(result) == "string" and result or "")
        return true
    end})
end

shorter.Launch = {
    {desc = "Launch a terminal",
    key={{  modkey,           }, "Return" }, fct = function () awful.util.spawn(terminal)                        end},

    --[[{desc = "Show the application menu",
    key={{  modkey }, "p"}, fct = function() print("meh");menubar.show()                                                     end},]]--

    {desc = "Run a command",
    key={{  modkey },            "r"},
        fct = function ()
            awful.prompt.run({ prompt = "Run: ", hooks = hooks},
            mypromptbox[mouse.screen].widget,
            function (com)
                    local result = awful.util.spawn(com)
                    if type(result) == "string" then
                        mypromptbox[mouse.screen].widget:set_text(result)
                    end
                    return true
            end, awful.completion.shell,
            awful.util.getdir("cache") .. "/history")
        end
    },

    {desc = "Run Lua code: ",
    key={{  modkey }, "x"}, fct = function ()
        awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end}
}

shorter.Session = {
    {desc = "Restart Awesome",
    key={{ modkey, "Control" }, "r"     }, fct = awesome.restart},

    {desc = "Quit Awesome",
    key={{ modkey, "Shift"   }, "q"     }, fct = awesome.quit},
  
    {desc = "Show hotkey help",
    key={{    }, "F1"     }, fct = function() shorter.show() end},
  
}

shorter.Tag = {
    {desc = "Increate the master width",
    key={{  modkey,           }, "l"     }, fct = function () awful.tag.incmwfact( 0.05)                        end},

    {desc = "Reduce the master width",
    key={{  modkey,           }, "h"     }, fct = function () awful.tag.incmwfact(-0.05)                        end},

    {desc = "Add a new master",
    key={{  modkey, "Shift"   }, "h"     }, fct = function () awful.tag.incnmaster( 1)                          end},

    {desc = "Remove a master",
    key={{  modkey, "Shift"   }, "l"     }, fct = function () awful.tag.incnmaster(-1)                          end},

    {desc = "Add a column",
    key={{  modkey, "Control" }, "h"     }, fct = function () awful.tag.incncol( 1)                             end},

    {desc = "Remove a column",
    key={{  modkey, "Control" }, "l"     }, fct = function () awful.tag.incncol(-1)                             end},
    {desc = "Move to next Tag",        key={{"Mod1",  "Control"      }, "Left"    },     fct = awful.tag.viewprev },
     {desc = "Move to previous Tag",    key={{"Mod1",  "Control"      }, "Right"   },     fct = awful.tag.viewnext }
}

shorter.Hardware = {
        {desc = "mute Volume",
    key={{},"XF86AudioMute" }, fct = function() util.spawn_with_shell("pactl set-sink-mute 1 toggle") end},
    {desc = "lower Volume",
    key={{},"XF86AudioLowerVolume" }, fct = function() util.spawn_with_shell("pactl set-sink-mute 1 false; pactl set-sink-volume 1 -5%") end},
    {desc = "Raise Volume",
    key={{}, "XF86AudioRaiseVolume" }, fct = function() util.spawn_with_shell("pactl set-sink-mute 1 false; pactl set-sink-volume 1 +5%") end},
	
	{desc = "Lower Bightness",
    key={{},"XF86MonBrightnessDown" }, fct = function() util.spawn_with_shell("xbacklight -dec 10") end},
    {desc = "Raise Bightness",
    key={{}, "XF86MonBrightnessUp" }, fct = function() util.spawn_with_shell("xbacklight -inc 10") end},
    
    
}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
local tagSelect = {}
for i = 1, 10 do
    tagSelect[#tagSelect+1] = {key={{ modkey }, "#" .. i},
        desc= "Switch to tag "..i,
        fct = function ()
            local screen = mouse.screen
            local tag = awful.tag.gettags(screen)[i]
            if tag then
                awful.tag.viewonly(tag)
            end
        end
    }
    tagSelect[#tagSelect+1] = {key={{ modkey, "Control" }, "#" .. i},
        desc= "Toggle tag "..i,
        fct = function ()
            local screen = mouse.screen
            local tag = awful.tag.gettags(screen)[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end
    }
    tagSelect[#tagSelect+1] = {key={{ modkey, "Shift" }, "#" .. i},
        desc= "Move cofussed to tag "..i,
        fct = function ()
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if client.focus and tag then
                awful.client.movetotag(tag)
            end
        end
    }
    tagSelect[#tagSelect+1] = {key={{ modkey, "Control", "Shift" }, "#" .. i},
        desc= "Toggle tag "..i,
        fct = function ()
            local tag = awful.tag.gettags(client.focus.screen)[i]
            if client.focus and tag then
                awful.client.toggletag(tag)
            end
        end
    }
end
shorter.Navigation = tagSelect

local copts_sec,copts_usec = 0,0

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
    --awful.button({  }, 6, collision.util.double_click(function() customMenu.client_opts() end))
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    --awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "Left",   function(c)   awful.client.movetoscreen(c) end   ),
    awful.key({ modkey,           }, "Right",   function(c)   awful.client.movetoscreen(c,-1) end   ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "m",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,  "Shift"  }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)


awful.rules.rules = {
    -- All clients will match this rule.
     {rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } }
}


shorter.register_section("Client",{
    close =         "Mod4 + Shift + c" ,
    fullScreen =    "Mod4 +f",
    floating =      "Mod4 + Ctrl + Space",
    toLeftScreen = "Mod4 + Left Arrow",
    toRightScreen = "Mod4 + Right Arrow",
    moveOnTop =     "Mod4 + t",
    minimize =      "Mod4 + m",
    toggleMaximize =      "Mod4 + Shift + m"
    --master =        "Mod4 + Ctrl + Return",
    
    
})