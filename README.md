# Morrowind Modding Tutorial with MWSE-Lua

In this tutorial series, You will learn the basics of [MWSE-Lua](https://mwse.github.io/MWSE/) modding and you don't need any previous programming experience to follow along. I will be guiding you every step of the way to make a mod called Craftable Bandage.

## Craftable Bandages

This mod will allows you to use your bushcrafting skill to craft bandages from OAAB_Data and the effect varies depending on your Survival skill. 

So we need to install OAAB_Data, The Crafting Framework, Skill Module, and Ashfall. 

## Introduction

First, we'll get the development environment setup on your local operating system. We'll be using [Visual Studio Code](https://code.visualstudio.com/) as our IDE. 

Once you're in VSCode, click Open Folder, navigate to your Morrowind root foler\Data Files\MWSE. Select Folder. It will ask you Do you trust the authors of the files in this folder? Click Yes, I trust the authors. If you don't already have the Lua and vscode-lua-format extension installed, you'll see popups asking you to install then at the bottom left corner of the screen. Install both of them. 

Next, we'll save this as workspace. Click File -> Save Workspace As... Yes we're gonna save it inside the MWSE folder. Save. 

Now, we are going to create the folder for our MWSE mod. On the left side of the screen, we have the folders in the MWSE folder. Mods usually go under the mods folder. So Expands the mods folder. Everyone's mod list is different. You may or may not have the folders I have here. It's fine. We're gonna use the mods/modderName/modName naming convention here. But as long as it is a main.lua, you can put it anywhere you want under the mods folder. 

Right Click on mods -> New Folder... Here, you need to enter your modder name. I am Amalie so I'll type Amalie here. Then, right click on the folder you just created, New Folder... again. This time we need to enter the name for the mod that we're gonna be creating, Craftable Bandage.

You can put space between words or do camelCase like I did here. Just don't put dot in your folder name. 

Now, right click on craftableBandage and create New File... main.lua. This is the the main file of your mod and it must be named main.lua. 

## Variables and Functions 

I'm gonna start off by showing you how to create a variable in Lua. So this mod is Craftable Bandages. So I'm going to create a local variable called `bandageId` and set it to the id of the OAAB bandages. Load OAAB_Data.esm in The Construction Set. The bandages are in the Alchemy tab, with CSSE, we can filter Bandage and find them very easily. There are actually two bandage objects in OAAB so create two local variables `bandageId1` and `bandageId2`.
```
local bandageId1 = "AB_alc_HealBandage01"
local bandageId2 = "AB_alc_HealBandage02"
```

So let's look at a few components about this. In Lua, variables are global by default but you probably don't wanna do that. We need to specify that it is a local variable. `bandageId1` is the variable name. 
