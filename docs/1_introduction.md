# Episode 1: Introduction, Variables, Functions, Event-Based Programming

## Introduction

First, open up [Visual Studio Code](https://code.visualstudio.com/). If you don't have it, download and install it. This is the preferred IDE for MWSE modding.

Once you have VSCode open, click **File** -> **Open Folder...**, then navigate to `Morrowind\Data Files\MWSE`, and **select the folder**. You will be asked, "Do you trust the authors of the files in this folder?" Click **"Yes, I trust the authors"**. 

If you don't already have the Lua and vscode-lua-format extensions installed, you'll see popups at the bottom left corner of the screen asking you to install them. Install both of them. 

![VSCode Lua extensions](assets/1/extensions.png){ loading=lazy }

Next, we'll save this as workspace. Click **File** -> **Save Workspace As...** **Save**.

Now, we are going to create the folder for our MWSE mod. On the left side of the screen, we have the folders within the `MWSE` folder. Mods usually go under the `mods` folder. Expand that folder. So long as your mod has a `main.lua`, you can put it anywhere within the `mods` folder. However, we will use the `mods/modderName/modName` naming convention. This avoids conflicting files and keeps everything tidy.

For example, in this mod, the path of main.lua will be `MWSE/mods/Amalie/craftableBandage/main.lua`.

You can name your folders any way you want, we used camelCase, that is, no separator between words, first letter lowercased, and the first letter of all other words capitalized. But you can use snake_case `craftable_bandage` or Normal `Craftable Bandage`. Just remember, don't put a dot in your folder name. Do not do this `craftable.bandage`, for example.

## Comments

Before we do any coding, let's learn about how to comment in Lua first. Oftentimes, you want to add information about the mod and its author at the top of the script.

When Lua code is run, comments will be skipped. Any line starting with a double dash `--` is considered a comment. This is a single line of comment.

```lua
-- Mod: Craftable Bandage
```

You can also do multi-line comment with ``--[[]]``. That is, double dash followed by two opening brackets with two closing brackets following the comment. Let's add some information about our mod. 

```lua
--[[
    Mod: Craftable Bandage
    Author: Amalie

	This mod allows you to craft OAAB bandages with novice bushcrafting skill.
	It serves as an alternative to alchemy and restoration.
]]
```
## Variables

Now let's learn how to create a variable in Lua. A variable holds some type of data which can be manipulated and referred to. This mod is Craftable Bandage, so we will create a local variable called `bandageId` and set it to the id of one of the OAAB bandages.

```lua
local bandageId = "AB_alc_HealBandage02"
```

In Lua, variables are global by default but you probably don't want that most of the time. The `local` here specifies that this is a local variable, as opposed to a global variable.

`bandageId` is the variable name. 

The equal symbol `=` is the assignment operator and we're assigning a string to `bandageId`. A string is a collection of characters like `AB_alc_HealBandage02` and it is enclosed in double or single quotation marks. 

One thing you'll notice is that you don't need to put a semicolon `;` at the end of each line in Lua. 

## Functions 

Let's move on to functions. A function is a block of code which only runs when it is called. Let's define an empty function called `registerBushcraftingRecipe`.

``` lua
local function registerBushcraftingRecipe()

end
```

If you are following along the tutorial, you can see in the IDE, both the function and the variable we just created are greyed out. Hovering over it, it tells us that they are unused function and unused local. That's because we haven't called them or used them anywhere in the script yet. Let's do that now.

To call a function, type the name of the function followed by a pair of parentheses.

```lua
registerBushcraftingRecipe()
```

Right now, when the function is called, it's not doing anything. So let's use this function to print some information to MWSE.log.

```lua
mwse.log("[Craftable Bandage] Registering bushcrafting recipe...")
```

This is one of the most common ways to write information to MWSE.log and we will look at another way (a better way) to do logging later. For now, let's run Morrowind.exe and check the log. You should be able to see `[Craftable Bandage] registering bushcrafting recipe...` in the log. 

MWSE.log can hold lots of useful information for modders if they know how to read and write it. The line starts with `[Craftable Bandage]` is the line our script wrote. Lines starts with `[Crafting Framework]` and `[Ashfall]` are the lines Crafting Framework (CF) and Ashfall wrote. Our line printed before CF implies that our function was run before CF and Ashfall started running. 

But we want to register the bandage recipe when CF is registering bushcrafting recipes. How do we do that? Well, let's learn about event-driven programming. 

## Event-Driven Programming

In event-driven programming, or event-based programming, events are "fired" when an action takes place. Your code listens for them and handles them accordingly. You can look up all the events MWSE provides [here](https://mwse.github.io/MWSE/events/initialized/).

Let's look at the `initialized` event. This fires when game code has finished initializing, and all masters and plugins have been loaded. Let's copy the example code provided in the document page and paste it in our main.lua.

```lua
--- @param e initializedEventData
local function initializedCallback(e)
end
event.register(tes3.event.initialized, initializedCallback)
```

Here, `tes3.event.initialized` is the event name and `initializedCallback` is the function to call when `initialized` event is fired. Same as before let's write some information to print out to MWSE.log.

```lua
mwse.log("[Craftable Bandage] Initialized")
```

Usually, you want to register your mod's events inside `initializedCallback`. And in our case, we need to register the `"Ashfall:ActivateBushcrafting:Registered"` event and `registerBushcraftingRecipe()` will be the event callback function.

```lua
event.register("Ashfall:ActivateBushcrafting:Registered", registerBushcraftingRecipe)
```

What this means is when Ashfall is registering their bushcrafting recipes, our `registerBushcraftingRecipe()` function will run. So let's test this. Launch the game and read the MWSE.log. 

If we search the log for "Bandage", you'll could only find the `"Initialized"` log but not the `"registering recipe"` log. That's because, the print order of the logs, you know that our mod was initialized after Crafting Framework finished registering all the MenuActivator. That's why our event callback never runs. 

We can fix this by tweaking the `priority` when registering our `initialized` event. 

```lua
event.register(tes3.event.initialized, initializedCallback, { priority = 100 })
```

Functions registered with higher `priority` will run first. The default is 0. Setting the `priority` to be anything higher than 0 can make sure our `initializedCallback` will run before The Crafting Framework registered all of the recipes. 

Launch the game again. Now you should be able to see in your log that our bandage recipe was registered right when The Crafting Framework was registering Ashfall's Bushcrafting MenuActivator.

That's it for today. You've learned how to comment, how to create variables and functions, and the concept of event-driven programming. See you in the next section.

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