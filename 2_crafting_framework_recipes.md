# Episode 2: Libraries, Logging, Crafting Framework Recipes

Welcome back, today we're gonna learn about libraries, logging, function arguments, lists, Crafting Framework recipe, and we are going to test our script in game. 

## Libraries

Remember that our mod relies on Skill Module, The Crafting Framework, and Ashfall. So let me show you how to import them to your script, so you get access to their functions. They are usually put at the top at the script.

```lua
local ashfall = include("mer.ashfall.interop")
local CraftingFramework = include("CraftingFramework")
local skillModule = include("OtherSkills.skillModule")
local logging = require("logging.logger")
```

`include` and `require` are the two ways to import libraries to your script. The difference is that `include` doesn't require you to have the mod installed, but `require` requires. 

## Logging

Besides the three mods, I've also imported the logging library. In the last episode, I mentioned another way to do logging. So let me show you. We can create a new logger with name "Craftable Bandage" and set the logLevel to "INFO".

```Lua
---@type mwseLogger
local log = logging.new({
	name = "Craftable Bandage",
	logLevel = "INFO",
})
```

Now we can replace all the `mwse.log` to `log:info`. To replace phrases in VSCode, highlight the phrase and press `Ctrl + H`, enter `log:info` and Replace All.

## Function Arguments

Now let's look back at the `initalizedCallback` function that we copied and pasted from the MWSE doc. You'll notice there is this `e` inside the parenthese. This is a function argument, specifically event data.

Event data is defined by MWSE and you can look them up in the MWSE doc events page. Here `@param` is a tag to specify the types of the parameters of a function. So parameter `e` here is of type `initializedEventData`.

And we want to specify the parameter for function `registerBushcraftingRecipe` as well. But the `Ashfall:ActivateBushcrafting:Registered` event is not added by MWSE. It is added by Crafting Framework and Ashfall. 

The documentation for them is great yet. The best place to ask questions about CF will be over at the #crafting-framework channel in [Morrowind Modding Community discord server](https://discord.me/mwmods). 

You can also just search the script for them. You can find the event data type here `CraftingFramework\components\MenuActivator.lua`. And it has a menuActivator field. Copy it over to our script. 

```Lua
--- @param e CraftingFramework.MenuActivator.RegisteredEvent
local function registerBushcraftingRecipe(e)
```

The menuActivator here is the activator that was just registered. I want you to create a local variable called bushcraftingActivator inside this function and assign it to the menuActivator that the event data passes in.

```Lua
local bushcraftingActivator = e.menuActivator
```

## List

Next, I am going to create a list of recipes to register. A list is used to store multiple items in a single variable. Lists are enclosed in curly braces and each item is separated by a comma. 

```
local recipe1
local recipe2
local recipes = { recipe1, recipe2 }
```

So this is a list of recipe. But we really only need one. It is still a list but only has one item. And we can specify its type `CraftingFramework.Recipe.data` using the `@type` tag. 

```Lua
--- @type CraftingFramework.Recipe.data
local recipe
local recipes = { recipe }
```

## Crafting Framework Recipe

Now if you hover over `recipe`, you can see a recipe can hold tons of information. 

But this is a simple mod. We only need to specify: id, the recipe identifier; craftableId, the id of the bandage; description; materials, what you need to craft this bandage. You need to give a list of material requirement here. 

You can enter ashfall material id or any object id. A list of ashfall material can be found in table `this.materials` in `mer\ashfall\bushcrafting\config.lua`. The idea is that if you have one of any kind of fabric, you can craft a bandage.

Next, skillRequirements, a list of skill requirement data. So we want the character to have at least novice level of bushcrafting to be able to craft a bandage. We imported ashfall, now we can access the data from ashfall. `skillRequirements = { ashfall.bushcrafting.survivalTiers.novice },`

Next, soundType, you can either specify soundType or soundId or soundPath or nothing and use the default sound. A list of soundType can be found in table `constructionSounds` in `CraftingFramework\components\Craftables.lua`. We're gonna use the "fabric" soundType.

Category can be anything you like but we're going to use one of the Ashfall categories "Other". A list of Ashfall categories can be found in table `this.categories` in `mer\ashfall\bushcrafting\config.lua`.

```Lua
local recipe = {
    id = bandageId2,
	craftableId = bandageId2,
	description = "Simple cloth bandages for the dressing of wounds.",
	materials = { { material = "fabric", count = 1 } },
	skillRequirements = { ashfall.bushcrafting.survivalTiers.novice },
	soundType = "fabric",
	category = "Other",
}
```

Finally, use the `registerRecipes` function to register our recipe! And I'm going to edit the log here as well. We are almost there.

```Lua
bushcraftingActivator:registerRecipes(recipes)
log:info("Registered bandage recipe")
```

## Testing

Before we launch the game and test the script. I suggest you write a script so when you load your save, your character will have 5 fabric in their inventory and is level 20 in bushcrafting. 

To do that, we register the `loaded` event. Same as before, go to the `loaded` event page and copy paste the code to main.lua. But we will rename the function to `testOnly` and move the `event.register` line inside our `initializedCallback` function.

To give item to the player, we use the `addItem()` function in `tes3` API. We want to give the player 5 fabric, so we pass the reference of the player, that is tes3.player, to the reference parameter. 

```Lua
--- @param e loadedEventData
local function testOnly(e)
tes3.addItem({
		reference = tes3.player,
		item = "ashfall_fabric",
		count = 5,
	})
```

The script of leveling up skill module skill is a bit complicated. If you want to level up a skill module skill. you pass the skill id to the `getSkill()` function and the increase value to the `levelUpSkill()` function.

```Lua
skillModule.getSkill("Bushcrafting"):levelUpSkill(10)
end
```

Now we can finally test the script. As you can see, our character has 5 fabric in their inventory and is level 20 in bushcrafting. Let's activate the fabric. Our Craftable Bandage is right here. Craft! You have successfully craft Bandage!

That's it for today! You've officially made your first MWSE mod! But both the tutorial and the mod are not finished jusy yet. There is still a lot to learn and some features to add. Stay tune for the next video. Bye!

Next - [Episode 3: ]()