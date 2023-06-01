# Section 2: Modules, Logging, Crafting Framework Recipes

Welcome back, today we're gonna learn about modules, logging, function arguments, lists, Crafting Framework recipes, and we are going to test our script in game.

## Modules

Our mod relies on Skills Module, The Crafting Framework, and Ashfall. They need to be imported into our script so we have access to their functions. Imports are typically placed at the top of the script.

```lua
local ashfall = include("mer.ashfall.interop")
local CraftingFramework = include("CraftingFramework")
local skillModule = include("OtherSkills.skillModule")
local logging = require("logging.logger")
```

`include` and `require` are the two ways to import modules to your script. The difference between the two is that `include` doesn't require you to have the mod installed, but `require` does.

## Logging

Besides the aforementioned mods, we should also import the logging module. I mentioned before there is another way to do and it's by creating a logger with the logging module. 

```Lua
---@type mwseLogger
local log = logging.new({
	name = "Craftable Bandage",
	logLevel = "INFO",
})
```

Now we can replace all occurrences of `mwse.log` with `log:info`. To replace phrases in VSCode, highlight the phrase you want to replace and press **Ctrl + H**, enter `log:info` and click **Replace All**.

## Function Arguments

Now let's look back at the `initalizedCallback` function that we copied from the MWSE doc. You'll notice there is an `e` inside the parentheses. This is a function argument, specifically event data.

Event data is defined by MWSE and you can look them up in the [MWSE doc events pages](https://mwse.github.io/MWSE/events/absorbedMagic/). Here `@param` is a tag to specify the types of the parameters of a function. So here, parameter `e` is of type `initializedEventData`.

And we want to specify the parameter for function `registerBushcraftingRecipe()` as well. But the `Ashfall:ActivateBushcrafting:Registered` event is not added by MWSE. It is added by Crafting Framework (CF) and Ashfall.

The documentation for them isn't great yet. The best place to ask questions about CF will be over at the #crafting-framework channel in the [Morrowind Modding Community discord server](https://discord.me/mwmods). 

Alternatively, you can just search the script. You can find the event data type in `CraftingFramework\components\MenuActivator.lua`. The event data is of type `CraftingFramework.MenuActivator.RegisteredEvent` and it has a menuActivator field. Copy this over to our script.

```Lua
--- @param e CraftingFramework.MenuActivator.RegisteredEvent
local function registerBushcraftingRecipe(e)
```

The menuActivator here is the activator that Crafting Framework just registered. Now let's create a local variable called `bushcraftingActivator` inside this function and set it to the `menuActivator` that the event data passes in.

```Lua
local bushcraftingActivator = e.menuActivator
```

## List

Next, we are going to create a list of recipes to register. A list is used to store multiple items in a single variable. Lists are enclosed in curly braces and each item is separated by a comma, like this:

```Lua
local recipe1
local recipe2
local recipes = { recipe1, recipe2 }
```

So this is a list of recipes. For our purposes, we only need one recipe. A list is still a list if it only has one item. Additionally, we can specify its type `CraftingFramework.Recipe.data` using the `@type` tag.

```Lua
--- @type CraftingFramework.Recipe.data
local recipe
local recipes = { recipe }
```

## Crafting Framework Recipe

If you hover over `recipe` in your IDE, you can see a recipe can hold a lot of information.

Since we're making a simple mod, we only need to specify the following:

`id`: the recipe identifier; 

`craftableId`, the id of the craftable bandage; 

`description`, this one is pretty straight-forward; 

`materials`, what you need to craft this bandage. You need to give a list of material requirements here. You can enter Ashfall material id or any object id. A list of Ashfall materials can be found in the table `this.materials` in `mer\ashfall\bushcrafting\config.lua`. The idea is that many different items can be classified as the same material, so we don't have to write duplicate recipes for each of the similar or same items. 

Next, `skillRequirements`, a list of skill requirement data. So if we want the character to have at least novice level of bushcrafting to be able to craft a bandage, we can do `skillRequirements = { ashfall.bushcrafting.survivalTiers.novice },` You can set both vanilla and Skills Module skills as the requirements.

`soundType`, you can specify `soundType`, `soundId`, `soundPath`, or nothing (to use the default sound). This is the sound that plays when players press the Craft button. A list of `soundType`s can be found in the table `constructionSounds` in `CraftingFramework\components\Craftables.lua`. We will use the "fabric" `soundType`.

`category` can be anything you like but we're going to use one of the Ashfall categories `"Other"`. A list of Ashfall categories can be found in the table `this.categories` in `mer\ashfall\bushcrafting\config.lua`.

```Lua
local recipe = {
    id = bandageId,
	craftableId = bandageId,
	description = "Simple cloth bandages for the dressing of wounds.",
	materials = { { material = "fabric", count = 1 } },
	skillRequirements = { ashfall.bushcrafting.survivalTiers.novice },
	soundType = "fabric",
	category = "Other",
}
```

Finally, use the `registerRecipes()` function to register our recipe! 

```Lua
bushcraftingActivator:registerRecipes(recipes)
log:info("Registered bandage recipe")
```

## Testing

Before we launch the game and test the script, if you don't have NullCascade's [UI Expansion](https://www.nexusmods.com/morrowind/mods/46071) installed, I highly recommend you install it, as we will use it for our testing.

Once you load into a save, open the console menu by hitting back quote or tilde `~` key. We want to give the player 5 fabric and level up bushcrafting to 20 to meet the requirement to craft a bandage. 

Enter the following two lines in the lua console. You can tell you are typing to the lua console if you see the **lua** button. If yours says mwscript, click on it to switch the lua console. If you don't see any button, enable the console component of UI Expansion in Mod Config Menu.

```Lua
tes3.addItem({ reference = tes3.player, item = "ashfall_fabric", count = 5 })
include("OtherSkills.skillModule").getSkill("Bushcrafting"):levelUpSkill(10)
```

Let's activate the fabric to open the crafting menu. You should be able to see our Craftable Bandage under the Other category. **Craft**! You have successfully crafted a Bandage!

That's it for today! You've officially made your first MWSE mod! But both the tutorial and the mod are not yet finished. There is still a lot to learn and some features to add. Bye!

??? example "What your main.lua should look like"
    
    ```lua linenums="1"
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

	---@type mwseLogger
	local log = logging.new({
		name = "Craftable Bandage",
		logLevel = "INFO",
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
		log:info("Registered bandage recipe")
	end

	--- @param e initializedEventData
	local function initializedCallback(e)
		event.register("Ashfall:ActivateBushcrafting:Registered",
					registerBushcraftingRecipe)
		log:info("Initialized")
	end
	event.register(tes3.event.initialized, initializedCallback,
				{ priority = 100 }) -- before crafting framework
    ```

Next - [Section 3: Mod Config Menu, If Statements, Concatenating Strings](https://amaliegay.github.io/mwse-modding-tutorial/3_mcm/)