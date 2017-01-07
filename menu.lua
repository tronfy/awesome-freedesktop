
--[[
                                                        
     Awesome-Freedesktop                                
     Freedesktop.org compliant desktop entries and menu 
                                                        
     Menu section                                       
                                                        
     Licensed under GNU General Public License v2       
      * (c) 2016, Luke Bonham                           
      * (c) 2014, Harvey Mittens                        
                                                        
--]]

local menu_gen   = require("menubar.menu_gen")
local menu_utils = require("menubar.utils")
local pairs      = pairs
local table      = table
local string     = string
local os         = os

-- Add support for NixOS systems too
table.insert(menu_gen.all_menu_dirs, os.getenv("HOME") .. "/.nix-profile/share/applications")

-- Remove non existent paths in order to avoid issues
local existent_paths = {}
for k,v in pairs(menu_gen.all_menu_dirs) do
    if os.execute(string.format("ls %s", v)) then
        table.insert(existent_paths, v)
        require("naughty").notify({text = tostring(v)})
    end
end
menu_gen.all_menu_dirs = existent_paths

-- Expecting a wm_name of awesome omits too many applications and tools
menu_utils.wm_name = ""

-- Menu
-- freedesktop.menu
local menu = {}

-- Use MenuBar parsing utils to build a menu for Awesome
-- @return awful.menu compliant menu items tree
function menu.build()
    local result = {}

    -- Get menu table
    menu_gen.generate(function(entries)
        for k, v in pairs(entries) do
            for _, cat in pairs(result) do
                if cat[1] == v["category"] then
                    table.insert(cat[2] , { v["name"], v["cmdline"], v["icon"] })
                    break
                end
            end
        end
    end)

    -- Add category icons
    for k,v in pairs(menu_gen.all_categories) do
        table.insert(result, {k, {}, v["icon"] } )
    end

    -- Cleanup things a bit
    for k,v in pairs(result) do
        -- Remove unused categories
        if #v[2] == 0 then
            --table.remove(result, k)
        else
            --Sort entries alphabetically (by name)
            table.sort(v[2], function (a,b) return string.byte(a[1]) < string.byte(b[1]) end)
            -- Replace category name with nice name
            v[1] = menu_gen.all_categories[v[1]].name
        end
    end

    -- Sort categories alphabetically also
    table.sort(result, function(a,b) return string.byte(a[1]) < string.byte(b[1]) end)

	return result
end

return menu
