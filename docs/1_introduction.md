# Episode 1: Introduction, Variables, Functions, Event-Based Programming

## Introduction

First, open up [Visual Studio Code](https://code.visualstudio.com/). If you don't have it installed, you do need to go and download it. 

Once you have your VSCode open, click Open Folder, navigate to your Morrowind root foler\Data Files\MWSE. Select Folder. It will ask you Do you trust the authors of the files in this folder? Click Yes, I trust the authors. If you don't already have the Lua and vscode-lua-format extension installed, you'll see popups asking you to install them at the bottom left corner of the screen. Install both of them. 

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
mwse.log("[Craftable Bandage] Registering bushcrafting recipe...")
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
mwse.log("[Craftable Bandage] Initialized")
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

??? example "What your main.lua should look like"
    
    ```lua
    --[[
        Mod: Craftable Bandage
        Author: Amalie
        
        This mod allows you to craft OAAB bandages with novice bushcrafting skill.
        It serves as an alternative to alchemy and restoration.
    ]] --

    local bandageId1 = "AB_alc_Healbandage01"
    local bandageId2 = "AB_alc_Healbandage02"

    local function registerBushcraftingRecipe()
        mwse.log("[Craftable Bandage] Registering bandage recipe...")
    end

    --- @param e initializedEventData
    local function initializedCallback(e)
        event.register("Ashfall:ActivateBushcrafting:Registered",
                    registerBushcraftingRecipe)
        mwse.log("[Craftable Bandage] Initialized")
    end
    event.register(tes3.event.initialized, initializedCallback,
                { priority = 100 }) -- before crafting framework
    ```

Next - [Episode 2: Libraries, Logging, Crafting Framework Recipes](https://amaliegay.github.io/mwse-modding-tutorial/2_crafting_framework_recipes/)