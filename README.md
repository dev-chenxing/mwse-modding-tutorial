# Morrowind Modding Tutorial with MWSE-Lua

In this tutorial series, You will learn the basics of [MWSE-Lua](https://mwse.github.io/MWSE/) modding and you don't need any previous programming experience to follow along. I will be guiding you every step of the way to make a mod called Craftable Bandage.

This mod will allows you to use your character's bushcrafting skill to craft bandages from OAAB_Data and the effect varies depending on your character's Survival skill. 

The mod requires OAAB_Data, The Crafting Framework, Skill Module, and Ashfall. So install them if you haven't already.

## Introduction

First, you open up [Visual Studio Code](https://code.visualstudio.com/). If you don't have it installed, you do need to go and download it. 

Once you have your VSCode open, click Open Folder, navigate to your Morrowind root foler\Data Files\MWSE. Select Folder. It will ask you Do you trust the authors of the files in this folder? Click Yes, I trust the authors. If you don't already have the Lua and vscode-lua-format extension installed, you'll see popups asking you to install then at the bottom left corner of the screen. Install both of them. 

Next, we'll save this as workspace. Click File -> Save Workspace As... Yes we're gonna save it inside the MWSE folder. Save. 

Now, we are going to create the folder for our MWSE mod. On the left side of the screen, we have the folders in the MWSE folder. Mods usually go under the mods folder. So Expands the mods folder. Everyone's mod list is different. You may or may not have the folders I have here. It's fine. We're gonna use the mods/modderName/modName naming convention here. But as long as it is a main.lua, you can put it anywhere you want under the mods folder. 

Right Click on mods -> New Folder... Here, you need to enter your modder name. I am Amalie so I'll type Amalie here. Then, right click on the folder you just created, New Folder... again. This time we need to enter the name for the mod that we're gonna be creating, craftableBandage.

You can do it any way you want. I like using camelCase. Just remember, don't put dot in your folder name. 

Now, right click on craftableBandage and create New File... name it main.lua. This is the the main file of your mod and it must be named main.lua. 

## Comments

Before we do any coding, I would like to tell you how to comment in Lua first. Oftentimes, you want to add information about the mod and its author in the top section of the script. 

When you run the Lua code, comments will be skipped. Any line starts with `--` is considered a line of comment. This is a single line of comment. 

```lua
-- Mod: Craftable Bandage
```

You can also do multi-line comment with ``--[[]]``

```lua
--[[
    Mod: Craftable Bandage
    Author: Amalie
	
	This mod allows you to craft OAAB bandages with novice bushcrafting skill.
	It serves as an alternative to alchemy and restoration.
]] 
```
## Variables and Functions 

Now I'm gonna show you how to create a variable in Lua. This mod is Craftable Bandage. So I'm going to create a local variable called `bandageId` and set it to the id of the OAAB bandages. 

Load OAAB_Data.esm in The Construction Set. The bandages are in the Alchemy tab. There are actually two bandage objects in OAAB. I'm gonna create just one variable for now.

```lua
local bandageId1 = "AB_alc_HealBandage01"
```

Let's look at a few components about this. In Lua, variables are global by default but you probably don't wanna that. We need to specify that it is a local variable. 

`bandageId1` is the variable name. Different people use different naming conventions. I tend to use camelCase, that is, no separator between words, first letter lowercased, and all other capitalized. 

The equal symbol is the assign operator and we're assigning `bandageId1` to a string. A string is a collection of characters like AB_alc_HealBandage01 and it is enclosed in double or single quotation marks. One thing you'll noticed is that you don't put semicolon at the end of each line. 

I would like this tutorial to be as interactive as possible so I encourage you follow along. Throughout this tutorial, I will tell you what is the next thing to do and I want you to pause the video and try to implement what I say yourself before you watch what I'm gonna do. 

Let's start simple. This is the first thing I want you to do: see if you can create another local variable in the next line, called bandageId2 and set it to equal AB_alc_HealBandage02. 

```lua
local bandageId2 = "AB_alc_HealBandage02"
```

Now, I'm going to talk about functions. A function is a set of code which only runs when it is called. Let's define an empty function called registerBushcraftingRecipe.

``` lua
local function registerBushcraftingRecipe()

end
```

You can see the text of both the function and the variables we just created is greyed out. Hovering over it, it tells us that they are unused function and unused local. That's because we haven't called them or used them everywhere in the code yet, which is exactly what I'm going to next. 

## Calling Functions

To call the function, I just type the name and a pair of parentheses.

```lua
registerBushcraftingRecipe()
```

Right now, when the function is called, it's not doing anything. So let's print some information to MWSE.log. 

```lua
mwse.log("[Craftable Bandage] registering bushcrafting recipe...")
```

This is one of the common ways to write information to MWSE.log and we will look at another way to do logging later. Let's run Morrowind.exe and check the log. You can see [Craftable Bandage] registering bushcrafting recipe... here. 

You'll notice it run before Ashfall and Crafting Framework. But we want to register the bandage recipe when CF is registering bushcrafting recipes. How do we do that? Well, let me introduce you to event-driven programming. 

## Event-Driven Programming

In event-driven programming, events are "fired" when an action takes place. Your code listens for them and handles them accordingly. You can look up all the events MWSE provides [here](https://mwse.github.io/MWSE/events/initialized/). 

Let's look at the initialized event. This fires when game code has finished initializing, and all masters and plugins have been loaded. Let's copy this code and paste it in our main.lua.

```lua
--- @param e initializedEventData
local function initializedCallback(e)
end
event.register(tes3.event.initialized, initializedCallback)
```

Here, `tes3.event.initialized` is the event name and `initializedCallback` is the function to be called when the `initialized` event is fired. Same as before I will write some information to print out to MWSE.log.

```lua
mwse.log("[Craftable Bandage] initialized")
```

Usually, you want to register your mod's events here. And in our case, we need to register the "Ashfall:ActivateBushcrafting:Registered" event. 

```lua
event.register("Ashfall:ActivateBushcrafting:Registered", registerBushcraftingRecipe)
```

What this means is when Ashfall is registering their bushcrafting recipe, our registerBushcraftingRecipe function will run. So let's test it. Okay, so if we search the log for "Bandage", you'll only find the "initialized" log but not the registering recipe log. 

That is because our mod is initialized after The Crafting Framework register all the crafting recipes. We can fix this by tweaking the priority when registering our initialized event. 

```lua
event.register(tes3.event.initialized, initializedCallback, { priority = 100 })
```

Functions registered with higher priority will run first. The default is 0. We set the priority here to anything higher than 0. That means when the game first loads in, our initialized function will run before The Crafting Framework. 

Let's test it again. Now as you can see our bandage recipe is registered right when The Crafting Framework is registering Ashfall's Bushcrafting MenuActivator.

That's it for today. You learnt how to comment, create variables and functions, call functions, and the concept of event-driven programming. See you in the next video. 

## Libraries

Welcome back, today we're gonna learn about libraries, logging, function arguments, lists, Crafting Framework recipe, and we are going to test our script in game. 

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

## If statement

So in the `initializedCallback`, we can check if we have these three mods installed. If yes, the script keeps running. If no, stop running the code. 

## Dictionaries

Now let's talk about dictionaries. Dictionaries are used to store data values in key-value pairs. Let me show you an example. 

```lua
local isBandage = { [bandageId1] = true, [bandageId2] = true }
```

So, a dictionary is enclosed in curly braces. `[bandageId1] = true` is one key-value pair, separated by a comma, and `[bandageId2] = true` is another key-value pair. `bandageId1` is the key, and `true` is the value.

A dictionary is a common way to classify thing. Here, it means `bandageId1` aka `"AB_alc_Healbandage01"` `isBandage` is `true`. In other words, "AB_alc_Healbandage01" is bandage. 

## Libraries

