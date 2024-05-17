# Section 4: Adding More Bandages Features

Our mod is almost complete. First we'll look at some scripts from OAAB_Data and then add some additional features for bandages ourselves.

## OAAB_Data Bandages

OAAB_Data actually already comes with a feature for bandages. It plays the bandaging sound instead of the potion drinking sound. We can take a look at how they do it in `\OAAB\MiscPotions\main.lua`.

Studying other people's scripts is a great way for beginners to learn how to mod with MWSE-Lua. 

All the MWSE-Lua code ever published on Nexusmods can be found at [mwse-lua-dump](https://github.com/MWSE/morrowind-nexus-lua-dump). If you don't know how to use certain functions or certain events, you can look it up by search the dump. Very very handy!

Back to OAAB_Data and the `MiscPotions` script:

```Lua
-- Prevent drink sounds
local function stopDrinkSounds(e)
    if not e.item.id:find("^AB_alc_") then return end

    addBlockedSound(e.reference, "drink")
    event.trigger("OAAB:equip", e)
end
event.register("equip", stopDrinkSounds, {priority = 1000})
```

It registers the `equip` event with very high priority to ensure it runs first. Then it checks if the `item` that's being equipped here has an `id` that starts with `"AB_alc_"`. The caret symbol `^` here anchors the pattern at the beginning of the string.

Then it calls the `addBlockedSound()` function to block the drink sound from playing. Then it triggers an event called `"OAAB:equip"` with `e` as the event data, which is the `equipEventData`. 

Next, let's look at another script from OAAB_Data, `\OAAB\Bandages\main.lua`. This is the script we are gonna base our script on. 

```Lua
local function bandageEquipEvent(e)
    if (e.item.id:find("^AB_alc_HealBandage")) then
        tes3.playSound({
            reference = e.reference,
            sound = "AB_Bandaging"
        })
    end
end
event.register("OAAB:equip", bandageEquipEvent)
```

It registers the aforementioned `"OAAB:equip"` event instead of `equip`. This is to make sure that the script from `MiscPotions` runs first. Then it checks if the item being equipped has an `id` that starts with `"AB_alc_HealBandage"`. If so, play the `"AB_Bandaging"` sound. 

## Adding Our Own Features

We're going to write a script that's based on this logic to implement two features for bandages.

First, we'll get rid of the magical visual effect when using a bandage. 

Second, we'll make the duration of the healing effect vary according to your character's Survival skill. So, if your skill is at level 20, it heals for 20 seconds; and if your skill is at 40, it heals for 40 seconds.

Before we continue, it's important to mention that you should always give credit to any source you use. Here, we're copying from Greatness7's script, and before we are using Merlord's script. Most MWSE-Lua modders are generally okay about other modders using their scripts but there are exceptions. Ask them if you can. Most MWSE-Lua modders hang out at either [Morrowind Modding Community](https://discord.me/mwmods) or [The Dahrk Realm](https://discord.gg/nPBUdbrXa3). "Be excellent to each other."

We will copy the above script to our main.lua.

Instead of `playSound`, we want to block the magical visual effect from playing. We can do that simply by blocking the event and applying the magical effect ourselves.

To block an event, return `false`. Then, to apply the magical effect, we use the `applyMagicSource()` function from the `tes3` API. Here we pass a table of magic effects to mimic the vanilla behaviour. 

```Lua hl_lines="4-16"
---@param e equipEventData
local function bandageEquipEvent(e)
	if (e.item.id:find("^AB_alc_HealBandage")) then
        tes3.applyMagicSource({
			reference = e.reference,
			name = "Bandage",
			effects = {
				{
					id = tes3.effect.restoreHealth,
					duration = 30,
					min = 1,
					max = 1,
				},
			},
		})
        return false
	end
end
```

We also need to remove the bandage, once it is consumed. Here we need to put `removeItem()` inside `timer.delayOneFrame()`. Otherwise, the game will crash. 

The default timer type for `delayOneFrame()` is `simulate` time, a timer that will not advance in menu mode. However, if we want the bandage to be removed immediately after we use it, we need to set it to `timer.real`, a timer that advances at real time. 

```Lua hl_lines="2-8"
    	})
        timer.delayOneFrame(function()
			tes3.removeItem({
				reference = e.reference,
				item = e.item,
				playSound = false,
			})
		end, timer.real)
        return false
```

Also, it's nice to have a message popup saying "Bandage applied" if the user is the player. 

```Lua hl_lines="2-4"
        end, timer.real)
	    if e.reference == tes3.player then
		    tes3.messageBox("Bandage applied")
	    end
	    return false
```

Now, if we test it in-game and we use the bandage, it won't play the vfx. That's the first feature done. Next, we want the duration of the effect to vary depending on your character's survival skill. 

Let's create two variables `bandageEffect` an `duration` and use it in the table of effects we pass in the `applyMagicSource()` function. The `bandageEffect` needs to be defined outside function `registerBushcraftingRecipe(e)`, as we need to use it later. Assign string `"Bandage"` to the variable. Then we'll create a function called `getEffectDuration()` that accepts `e.reference` as the argument and returns the duration to the `duration` variable. 

```Lua
local bandageEffect = "Bandage"

---@param ref tes3reference
---@return integer duration
local function getEffectDuration(ref)
	local duration
	return duration
end
...
    if (e.item.id:find("^AB_alc_HealBandage")) then
		local duration = getEffectDuration(e.reference)
		tes3.applyMagicSource({
			reference = e.reference,
			name = bandageEffect,
			effects = {
				{
					id = tes3.effect.restoreHealth,
					duration = duration,
					min = 1,
```

Next, we need to add our logic in the `getEffectDuration()` function so the duration varies. Since only the player has Skills Module skills, we want this survival-based duration feature to only affect the player. 

```Lua hl_lines="3-8"
local function getEffectDuration(ref)
    local duration
	if ref == tes3.player then

        return duration
	else
		return 30
	end
end
```

We can get the player's survival skill using the `getSkill()` function in Skills Module. We use the `clamp()` function from the `math` library to clamp the skill level between 20 and 40, then assign it to the return value `duration`.

```Lua hl_lines="2-3"
    if ref == tes3.player then
        local skillLevel = skillModule.getSkill("Ashfall:Survival").value
        duration = math.clamp(skillLevel, 20, 40)
		return duration
    else
```

Now, if our character is level 30 in Survival, the effect should last for 30 seconds. And if it's level 100, the duration will be clamped at 40 seconds. 

One final feature we'll add is stopping the healing effect if the bandage user gets hit while it's active. To do that, we need to register both the `damaged` and `damagedHandToHand` events. We'll name the callback `removeBandageHealing`. 

```Lua hl_lines="1-4 7-8"
---@param e damagedEventData|damagedHandToHandEventData
local function removeBandageHealing(e)

end
...
    event.register("OAAB:equip", bandageEquipEvent)
    event.register("damaged", removeBandageHealing)
	event.register("damagedHandToHand", removeBandageHealing)
    log:info("Initialized")
```

## Loops

We want the healing effect to stop when someone is damaged. First, we need to figure out if the `reference` is using the bandage when damaged. We can find that out by looping through the `activeMagicEffectList` of `e.reference.mobile`. 

Hovering over `activeMagicEffectList`, it says it is of type `tes3activeMagicEffect[]`. The pair of brackets here means it is a list of `tes3activeMagicEffect`. 

To iterate the effects in this list, we're gonna use a `for` loop. Loop is an essential part of programming, so it's important that you know how to use them. This is the basic structure of a for loop.

```Lua hl_lines="2-8"
local function removeBandageHealing(e)
	local activeMagicEffectList = e.reference.mobile
	                              .activeMagicEffectList
	for _, activeMagicEffect in ipairs(activeMagicEffectList) do
		
	end
end
```

We will add the logic in the loop to check if any of the effects has the name of `"Bandage"`. If so, we set the `timeActive` field to its `duration` so the effect will end. 

```Lua hl_lines="2-5"
    for _, activeMagicEffect in ipairs(activeMagicEffectList) do
        if activeMagicEffect.instance.source.name == bandageEffect then
			activeMagicEffect.effectInstance.timeActive =
			activeMagicEffect.duration
		end
    end
```

Of course, this is not the best way to do it as all effects called `"Bandage"` will then end whenever a `mobile` get damaged, even if the effect is not added by our mod. 

Also, keep in mind that the `source` here is not the bandage object, it is the magic source that we apply to `reference` that uses a bandage.

So, our mod is done! The only thing left to do right now is to add the metadata file and zip up the mod. We'll do that in the next section.

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
    local bandageEffect = "Bandage"

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

    ---@param ref tes3reference
    ---@return integer duration
    local function getEffectDuration(ref)
        local duration
        if ref == tes3.player then
            local skillLevel = skillModule.getSkill("Ashfall:Survival").value
            duration = math.clamp(skillLevel, 20, 40)
            return duration
        else
            return 30
        end
    end

    ---@param e equipEventData
    local function bandageEquipEvent(e)
        if (e.item.id:find("^AB_alc_HealBandage")) then
            local duration = getEffectDuration(e.reference)
            tes3.applyMagicSource({
                reference = e.reference,
                name = "Bandage",
                effects = {
                    {
                        id = tes3.effect.restoreHealth,
                        duration = duration,
                        min = 1,
                        max = 1,
                    },
                },
            })
            timer.delayOneFrame(function()
                tes3.removeItem({
                    reference = e.reference,
                    item = e.item,
                    playSound = false,
                })
            end, timer.real)
            if e.reference == tes3.player then
                tes3.messageBox("Bandage applied")
            end
            return false
        end
    end

    ---@param e damagedEventData|damagedHandToHandEventData
    local function removeBandageHealing(e)
        local activeMagicEffectList = e.reference.mobile
                                    .activeMagicEffectList
        for _, activeMagicEffect in ipairs(activeMagicEffectList) do
            if activeMagicEffect.instance.source.name == "Bandage" then
                activeMagicEffect.effectInstance.timeActive =
                activeMagicEffect.duration
            end
        end
    end

    --- @param e initializedEventData
    local function initializedCallback(e)
        if not config.enabled then
            return
        end
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
        event.register("OAAB:equip", bandageEquipEvent)
        event.register("damaged", removeBandageHealing)
        event.register("damagedHandToHand", removeBandageHealing)
        log:info("Initialized")
    end
    event.register(tes3.event.initialized, initializedCallback) -- before crafting framework

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

Next - [Section 5: Metadata Files](https://dev-chenxing.github.io/mwse-modding-tutorial/5_metadata/)
