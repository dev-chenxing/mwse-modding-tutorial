# Section 3: Mod Config Menu, If Statements, Concatenating Strings

Welcome back, today we're gonna learn about if statements, concatenating strings, and how to setup a mod config menu.

## If Statements

An if statement will first check a condition and if the condition is true then all the lines of code under the if statement and before `else/elseif/end` will execute.

A quick example, we can create an if statement here in the `initializedCallback` to check if we have Ashfall, Crafting Framework, and Skills Module installed. And if not, tell the script to stop running. 

Remember in the last episode, we imported these modules to our script using the `include` function. So when the module is not found, it returns nil. This means if we don't have Ashfall installed, the `ashfall` variable will be nil.

Since `not nil` equals `true`, the script will return and stop running. This is also called a nil check.

```Lua hl_lines="2-10"
local function initializedCallback(e)
    if not ashfall then
	    return
	end
	if not CraftingFramework then
		return
	end
	if not skillModule then
		return
	end
    event.register("Ashfall:ActivateBushcrafting:Registered",
	               registerBushcraftingRecipe)
```

This is an example code. We don't actually need them, as the dependency manager will do the same thing. We will discuss this in [section 5](https://dev-chenxing.github.io/mwse-modding-tutorial/5_metadata/).

## Mod Config Menu

Another condition that we should check for is whether the mod is enabled or not. The common way to disable a MWSE mod is through the Mod Config Menu. So we need to add one for our mod.

To do that, register the `"modConfigReady"` event outside of `initializedCallback`. We can go to the doc page for `"modConfigReady"` event and copy this template code to our main.lua.

```Lua
local config = require("MyMod.config")

local function onModConfigReady()
    local template = mwse.mcm.createTemplate({ name = "My Mod" })
    template:saveOnClose("My Mod", config)
    template:register()

    local settings = template:createSideBarPage({ label = "Settings" })
    settings.sidebar:createInfo({
        -- This text will be on the right-hand side block
        text = "My Mod v. 1.0\n\nCreated by me.\n\nHover over a feature for more info."
    })

    settings:createOnOffButton({
        label = "Feature",
        -- The text in the description will replace the text
        -- in sidebar on the right-hand side, when this button
        -- is hovered over.
        description = "This feature does...",
        variable = mwse.mcm.createTableVariable({
            id = "feature",
            table = config,
        })
    })
end

event.register(tes3.event.modConfigReady, onModConfigReady)
```

We need to change a few things here since right now this is a mod configuration menu for a mod called "My Mod".

First line here is loading another file, `config.lua`, in the `\MyMod` folder. This is a common way to load your config but since this is a relatively small mod, we can just load the config in `main.lua`. 

First, move the config variable as high as we can. And we will change `local config = require("MyMod.config")` to this:

```Lua
local configPath = "Craftable Bandage"
local defaultConfig = { enabled = true, logLevel = "INFO" }
local config = mwse.loadConfig(configPath, defaultConfig)
```

What this does is when the script gets configuration data from the `config` variable, MWSE will try to load a json file in the `config` folder with this `configPath` name. If the file doesn't exist, it loads `defaultConfig` table instead.

Let's use this `enabled` config option in our `initializedCallback` so it checks if the mod is enabled or not.

```Lua hl_lines="2-4"
local function initializedCallback(e)
	if not config.enabled then
		return
	end
```

Right now, the mod is always enabled because we don't have a way to disable it yet. So back to the MCM, replace all of the occurrences of "`"My Mod"`" with "`"Craftable Bandage""`. 

I'll explain the template code a bit here. `createTemplate()` paired with `template:register()` is how you add a page in the Mod Config Menu.

`saveOnClose()` is how your config gets saved in the json file. The first argument here is the configPath, the json file name that I mentioned before, and the second argument takes the config table.

`createSideBarPage()` is how you get the two-column page for your MCM. You can also use `createPage()` instead if you like a single-column page. If you choose to use the side bar page, usually we'll include some info on the right column using `createInfo()`. 

## Concatenating Strings

So let's copy over our mod description here.

```Lua
settings.sidebar:createInfo({
		-- This text will be on the right-hand side column
		text = "Craftable Bandage\n\nCreated by Amalie.\n\n" ..
        "This mod allows you to craft OAAB bandages with novice bushcrafting skill." ..
        "It serves as an alternative to alchemy and restoration",
	})
```

You can see the description gets quite long there, so I use string concatenation to split them into multiple lines. To concatenate strings in Lua, use the double dot `..` between two strings. And here `\n` means a new line.

## Mod Config Menu (Continued)

Back to MCM, `createOnOffButton` is the most used function and it's also how we create an enable/disable button for our mod. Let's change the `label` to "Enable Mod".

`description` is the text you'll see on the right column when the mouse hovers over the label and button. If your config option needs some explanation, this is how you add it. But an enable/disable button is pretty straight-forward, so I don't feel the need to specify that.

`variable` is the variable you want to change by clicking the button. `id` is the variable name. `table` is the table the variable is in. We want to change the config.enabled variable by clicking on this button. The `id` here should be `enabled` and table should be `config`. 

In our case, we also need to set the `restartRequired` field to `true` so a message box will popup to warn the user. When the game first loads this script, if the mod is enabled, it registers the recipe, so it doesn't matter if we disable it in game. 

```Lua
settings:createOnOffButton({
	label = "Enable Mod",
	variable = mwse.mcm.createTableVariable({
		id = "enabled",
		table = config,
        restartRequired = true,
	}),
})
```

While you're at it, let's add a dropdown element to set the log level of our logger through MCM. Remember to also change the `logLevel` to `config.logLevel` when we create the logger using `logging.new()`.

```Lua hl_lines="3 7-20"
local log = logging.new({
	name = "Craftable Bandage",
	logLevel = config.logLevel,
})
...
    })
    settings:createDropdown({
        label = "Log Level",
        options = {
            { label = "TRACE", value = "TRACE" },
            { label = "DEBUG", value = "DEBUG" },
            { label = "INFO", value = "INFO" },
        },
        variable = mwse.mcm.createTableVariable({
            id = "logLevel",
            table = config,
        }),
        callback = function(self)
            log:setLogLevel(self.variable.value)
        end,
    })
end
```

To test the MCM, you can change the "Registered bandage recipe" log to be a debug log. So now when we load the game and the `logLevel` is set to `"INFO"`, you should not be able to see this, but if you change it to `"DEBUG"`, after a restart you should be able to see it again.

```Lua
log:debug("Registered bandage recipe")
```

Let's launch the game to check if our mod config menu is registered successfully. You should be able to see the enable mod button and the log level setting dropdown.

That's it for today. It is encouraged that you play around with these settings to have a better understanding of how the mod gets disabled and enabled by pressing the button, and how the log level gets changed.

Today, you've learned what an if statement is, how to concatenate strings, and most importantly how to add a mod config menu to your MWSE mod.

??? example "What your main.lua should look like"
    
    ```Lua linenums="1"
    --[[
        Mod: Craftable Bandage
        Author: Amalie

        This mod allows you to craft OAAB bandages with novice bushcrafting skill.
        It serves as an alternative to alchemy and restoration.
    ]] --
    local ashfall = include("mer.ashfall.interop")
    local CraftingFramework = include("CraftingFramework")
    local skillModule = include("OtherSkills.skillModule")
    local logging = require("logging.logger")

    local configPath = "Craftable Bandage"
    local defaultConfig = { enabled = true, logLevel = "INFO" }
    local config = mwse.loadConfig(configPath, defaultConfig)

    ---@type mwseLogger
    local log = logging.new({
        name = "Craftable Bandage",
        logLevel = config.logLevel,
    })

    local bandageId = "AB_alc_Healbandage02"

    --- @param e CraftingFramework.MenuActivator.RegisteredEvent
    local function registerBushcraftingRecipe(e)
        local bushcraftingActivator = e.menuActivator
        --- @type CraftingFramework.Recipe.data
        local recipe = {
            id = bandageId,
            craftableId = bandageId,
            description = "Simple cloth bandages for the dressing of wounds.",
            materials = { { material = "fabric", count = 1 } },
            skillRequirements = { ashfall.bushcrafting.survivalTiers.novice },
            soundType = "fabric",
            category = "Other",
        }
        local recipes = { recipe }
        bushcraftingActivator:registerRecipes(recipes)
        log:debug("Registered bandage recipe")
    end

    --- @param e initializedEventData
    local function initializedCallback(e)
        if not config.enabled then
            return
        end
        event.register("Ashfall:ActivateBushcrafting:Registered",
                    registerBushcraftingRecipe)
        log:info("Initialized")
    end
    event.register(tes3.event.initialized, initializedCallback,
                { priority = 100 }) -- before crafting framework

    local function onModConfigReady()
        local template = mwse.mcm.createTemplate(
                        { name = "Craftable Bandage" })
        template:saveOnClose("Craftable Bandage", config)
        template:register()

        local settings = template:createSideBarPage({ label = "Settings" })
        settings.sidebar:createInfo({
		    -- This text will be on the right-hand side block
		    text = "Craftable Bandage\n\nCreated by Amalie.\n\n" ..
		    "This mod allows you to craft OAAB bandages with novice bushcrafting skill." ..
		    "It serves as an alternative to alchemy and restoration",
	    })

        settings:createOnOffButton({
            label = "Enable Mod",
            variable = mwse.mcm.createTableVariable({
                id = "enabled",
                table = config,
                restartRequired = true,
            }),
        })
        settings:createDropdown({
            label = "Log Level",
            options = {
                { label = "TRACE", value = "TRACE" },
                { label = "DEBUG", value = "DEBUG" },
                { label = "INFO", value = "INFO" },
            },
            variable = mwse.mcm.createTableVariable({
                id = "logLevel",
                table = config,
            }),
            callback = function(self)
                log:setLogLevel(self.variable.value)
            end,
        })
    end

    event.register(tes3.event.modConfigReady, onModConfigReady)
    ```

Next - [Section 4: Adding More Bandages Features](https://dev-chenxing.github.io/mwse-modding-tutorial/4_adding_bandage_features/)