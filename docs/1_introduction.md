# Episode 1: Introduction, Variables, Functions, Event-Based Programming

## Introduction

First, open up [Visual Studio Code](https://code.visualstudio.com/). If you don't have it installed, you do need to go and download it. 

Once you have your VSCode open, click **Open Folder**, navigate to your Morrowind root folder .. `\Data Files\MWSE`. **Select Folder**. It will ask you Do you trust the authors of the files in this folder? Click **Yes, I trust the authors**. If you don't already have the Lua and vscode-lua-format extension installed, you'll see popups asking you to install them at the bottom left corner of the screen. Install both of them. 

![VSCode Lua extensions](assets/1/extensions.png){ loading=lazy }

Next, we'll save this as workspace. Click **File** -> **Save Workspace As...** **Save**. 

Now, we are going to create the folder for our MWSE mod. On the left side of the screen, we have the folders in the `\MWSE` folder. Mods usually go under the `\mods` folder. So Expands the `\mods` folder. Everyone's mod list is different. You may or may not have the folders I have here. It's fine. We're gonna use the `mods/modderName/modName` naming convention here. But as long as it is a `main.lua`, you can put it anywhere you want under the `\mods` folder. 

Right Click on `\mods` -> **New Folder...** Here, you need to enter your modder name. I am Amalie so I'll type `Amalie` here. Then, right click on the folder you just created, **New Folder...** again. This time we need to enter the name for the mod that we're gonna be creating, `craftableBandage`.

I personally like using camelCase. But you can use snake_case `craftable_bandage` or Normal `Craftable Bandage`. Just remember, don't put dot in your folder name. 

Now, right click on `\craftableBandage` and create **New File...** name it `main.lua`. This is the the main file of your mod and it must be named `main.lua`. 

## Comments

Before we do any coding, I would like to tell you how to comment in Lua first. Oftentimes, you want to add information about the mod and its author at the top of the script. 

In a Lua script, comments will be skipped. Any line starts with `--` is considered a line of comment. This is a single line of comment. 

```lua
-- Mod: Craftable Bandage
```

You can also do multi-line comment with ``--[[]]``. Let's add some information about our mod. 

```lua
--[[
    Mod: Craftable Bandage
    Author: Amalie
	
	This mod allows you to craft OAAB bandages with novice bushcrafting skill.
	It serves as an alternative to alchemy and restoration.
]] 
```
## Variables

Now I'm gonna show you how to create a variable in Lua. This mod is Craftable Bandage. So I'm going to create a local variable called `bandageId` and set it to the id of the OAAB bandage. 

Load OAAB_Data.esm in The Construction Set. The bandages are in the Alchemy tab. There are actually two bandage objects in OAAB. I don't want to create two recipes for essentially the same object so I'm just gonna choose the second one.

```lua
local bandageId = "AB_alc_HealBandage02"
```

Let's look at a few components about this. In Lua, variables are global by default but you probably don't want that. We need to specify that it is a local variable. 

`bandageId` is the variable name. Different people use different naming conventions. I tend to use camelCase for everything, that is, no separator between words, first letter lowercased, and all other capitalized. 

The equal symbol `=` is the assignment operator and we're assigning a string to `bandageId`. A string is a collection of characters like `AB_alc_HealBandage02` and it is enclosed in double or single quotation marks. One thing you'll notice is that you don't put semicolon `;` at the end of each line in Lua. 

## Functions 

Now, I'm going to talk about functions. A function is a set of code which only runs when it is called. Let's define an empty function called registerBushcraftingRecipe.

``` lua
local function registerBushcraftingRecipe()

end
```

You can see in our IDE, the text of both the function and the variable we just created is greyed out. Hovering over it, it tells us that they are unused function and unused local. That's because we haven't called them or used them anywhere in the code yet, which is exactly what I'm going to do next. 

To call a function, type the name of the function followed by a pair of parentheses.

```lua
registerBushcraftingRecipe()
```

Right now, when the function is called, it's not doing anything. So let's use this function to print some information to MWSE.log. 

```lua
mwse.log("[Craftable Bandage] Registering bushcrafting recipe...")
```

This is one of the most common ways to write information to MWSE.log and we will look at another way to do logging later. Let's run Morrowind.exe and check the log. You can see `[Craftable Bandage] registering bushcrafting recipe...` in the log here. 

MWSE.log can hold lots of useful information for modders if they know how to read and write it. The line starts with `[Craftable Bandage]` is the line our script wrote. Lines starts with `[Crafting Framework]` and `[Ashfall]` are the lines Crafting Framework and Ashfall wrote. Our line printed before CF is implying that our function was run before CF and Ashfall did their things. 

But we want to register the bandage recipe when CF is registering bushcrafting recipes. How do we do that? Well, let me introduce you to event-driven programming. 

## Event-Driven Programming

In event-driven programming, or event-based programming, events are "fired" when an action takes place. Your code listens for them and handles them accordingly. You can look up all the events MWSE provides [here](https://mwse.github.io/MWSE/events/initialized/). 

Let's look at the `initialized` event. This fires when game code has finished initializing, and all masters and plugins have been loaded. Let's copy this code and paste it in our main.lua.

```lua
--- @param e initializedEventData
local function initializedCallback(e)
end
event.register(tes3.event.initialized, initializedCallback)
```

Here, `tes3.event.initialized` is the event name and `initializedCallback` is the function to call when `initialized` event is fired. Same as before I will write some information to print.

```lua
mwse.log("[Craftable Bandage] Initialized")
```

Usually, you want to register your mod's events inside `initializedCallback`. And in our case, we need to register the `"Ashfall:ActivateBushcrafting:Registered"` event and `registerBushcraftingRecipe()` will be the event callback function.

```lua
event.register("Ashfall:ActivateBushcrafting:Registered", registerBushcraftingRecipe)
```

What this means is when Ashfall is registering their bushcrafting recipes, our `registerBushcraftingRecipe()` function will run. So let's test this. 

Okay, so if I search the log for "Bandage" right now, I could only find the `"Initialized"` log but not the `"registering recipe"` log. 

That's because, from MWSE.log, you know that our mod was initialized after Crafting Framework finished registering all the MenuActivator. That's why our event callback never runs. 

We can fix this by tweaking the `priority` when registering our `initialized` event. 

```lua
event.register(tes3.event.initialized, initializedCallback, { priority = 100 })
```

Functions registered with higher `priority` will run first. The default is 0. We setting the `priority` to be anything higher than 0 can make sure our `initializedCallback` will run before The Crafting Framework registered all the recipes. 

Let's test it again. Now as you can see from the log here, our bandage recipe was registered right when The Crafting Framework was registering Ashfall's Bushcrafting MenuActivator.

That's it for today. You have learnt how to comment, how to create variables and functions, and the concept of event-driven programming. See you in the next video. 

??? example "What your main.lua should look like"
    
    ```lua linenums="1"
    --[[
        Mod: Craftable Bandage
        Author: Amalie
        
        This mod allows you to craft OAAB bandages with novice bushcrafting skill.
        It serves as an alternative to alchemy and restoration.
    ]] --

    local bandageId = "AB_alc_Healbandage02"

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