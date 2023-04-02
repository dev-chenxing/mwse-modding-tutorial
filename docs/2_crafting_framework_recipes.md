# Episode 2: Libraries, Logging, Crafting Framework Recipes

Welcome back, today we're gonna learn about libraries, logging, function arguments, lists, Crafting Framework recipe, and test our script in game. 

## Libraries (or Modules)

Remember that our mod relies on Skills Module, The Crafting Framework, and Ashfall? Let me show you how to import them to your script, so you get access to their functions. Imported libraries are usually put at the top of the script.

```lua
local ashfall = include("mer.ashfall.interop")
local CraftingFramework = include("CraftingFramework")
local skillModule = include("OtherSkills.skillModule")
local logging = require("logging.logger")
```

`include` and `require` are the two ways to import libraries to your script. The difference is that `include` doesn't require you to have the mod installed, but `require` requires. 

## Logging

Besides the three mods, I've also imported the logging library. In the last episode, I mentioned another way to do logging. So let me show you how to create a new logger with the logging library. 

```Lua
---@type mwseLogger
local log = logging.new({
	name = "Craftable Bandage",
	logLevel = "INFO",
})
```

Now we can replace all the `mwse.log` to `log:info`. To replace phrases in VSCode, highlight the phrase you want to replace and press **Ctrl + H**, enter `log:info` and **Replace All**.

## Function Arguments

Now let's look back at the `initalizedCallback` function that we copied and pasted from the MWSE doc. You'll notice there is this `e` inside the parenthese. This is a function argument, specifically event data.

Event data is defined by MWSE and you can look them up in the [doc events pages](https://mwse.github.io/MWSE/events/absorbedMagic/). Here `@param` is a tag to specify the types of the parameters of a function. So parameter `e` here is of type `initializedEventData`.

And we want to specify the parameter for function `registerBushcraftingRecipe()` as well. But the `Ashfall:ActivateBushcrafting:Registered` event is not added by MWSE. It is added by Crafting Framework and Ashfall. 

The documentation for them is great yet. The best place to ask questions about CF will be over at the #crafting-framework channel in [Morrowind Modding Community discord server](https://discord.me/mwmods). 

Alternatively, you can just search the script. You can find the event data type here `CraftingFramework\components\MenuActivator.lua`. So the event data is of type `CraftingFramework.MenuActivator.RegisteredEvent` and it has a menuActivator field. Copy this over to our script. 

```Lua
--- @param e CraftingFramework.MenuActivator.RegisteredEvent
local function registerBushcraftingRecipe(e)
```

The menuActivator here is the activator that Crafting Framework just registered. Now let's create a local variable called `bushcraftingActivator` inside this function and set it to the `menuActivator` that the event data passes in.

```Lua
local bushcraftingActivator = e.menuActivator
```

## List

Next, I am going to create a list of recipes to register. A list is used to store multiple items in a single variable. Lists are enclosed in curly braces and each item is separated by a comma, like this:

```Lua
local recipe1
local recipe2
local recipes = { recipe1, recipe2 }
```

So this is a list of recipe. But we really only need one recipe. It is still a list but only has one item. And we can specify its type `CraftingFramework.Recipe.data` using the `@type` tag. 

```Lua
--- @type CraftingFramework.Recipe.data
local recipe
local recipes = { recipe }
```

## Crafting Framework Recipe

Now if you hover over `recipe`, you can see a recipe can hold tons of information. 

But this is a simple mod. We will only need to specify a few things:

`id`: the recipe identifier; 

`craftableId`, the id of the craftable bandage; 

`description`, this one is pretty straight-forward; 

`materials`, what you need to craft this bandage. You need to give a list of material requirement here. You can enter ashfall material id or any object id. A list of ashfall material can be found in table `this.materials` in `mer\ashfall\bushcrafting\config.lua`. The idea is that if you have one of any kind of fabric, you can craft a bandage.

Next, `skillRequirements`, a list of skill requirement data. So if we want the character to have at least novice level of bushcrafting to be able to craft a bandage, we can do this `skillRequirements = { ashfall.bushcrafting.survivalTiers.novice },`

`soundType`, you can either specify `soundType` or `soundId` or `soundPath` or nothing and use the default sound. A list of `soundType` can be found in table `constructionSounds` in `CraftingFramework\components\Craftables.lua`. We're gonna use the "fabric" `soundType` here.

`category` can be anything you like but we're going to use one of the Ashfall categories `"Other"`. A list of Ashfall categories can be found in table `this.categories` in `mer\ashfall\bushcrafting\config.lua`.

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

Finally, use the `registerRecipes()` function to register our recipe! And I'm going to edit the log here as well. 

```Lua
bushcraftingActivator:registerRecipes(recipes)
log:info("Registered bandage recipe")
```

## Testing

Before we launch the game, if you don't have NullCascade's [UI Expansion](https://www.nexusmods.com/morrowind/mods/46071) installed, I highly recommend you install it, as we will use it for our testing.

Once you load into a save, open the console menu by hitting back quote or tilde `~` key. We want to give the player 5 fabric and level up to bushcrafting 20 to they meet the requirement to craft a bandage. 

Enter the following two lines in the lua console. You can tell you are typing to the lua console if you see the **lua** button. If yours says mwscript, click on it to switch the lua console.  

```Lua
tes3.addItem({ reference = tes3.player, item = "ashfall_fabric", count = 5 })
include("OtherSkills.skillModule").getSkill("Bushcrafting"):levelUpSkill(10)
```

Let's activate the fabric to open the crafting menu. You can see the Craftable Bandage is right here. **Craft**! You have successfully craft Bandage!

That's it for today! You've officially made your first MWSE mod! But both the tutorial and the mod are not finished yet. There's still a lot to learn and some features to add. So stay tune for the next video. Bye!

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

Next - [Episode 3: Mod Config Menu, If Statements, Concatenating Strings](https://amaliegay.github.io/mwse-modding-tutorial/3_mcm/)