# Section 5: Metadata File

Welcome back! When we last left off, we have finished the mod. All we have to do right now is to add a metadata file for our mod. 

## Metadata File

A metadata file is a file that is primarily used for checking dependencies. Dependency Manager is a MWSE feature added in February 2023. Modders are strongly recommended to add a metadata file for their mods so users would get a warning if any required files are missing. 

To add a metadata file for your mod, in your `\Data Files` diretory, create a file with name that ends with `-metadata.toml`. Our mod is called `"Craftable Bandage"`, so I'll name it `Craftable Bandage-metadata.toml`. 

The metadata file mainly includes two types of information. First is the information about your mod: the name of mod, who's the modder, where to download your mod, and the version of the mod. They should be under the `[package]` section.

```toml
[package]
name = "Craftable Bandage"
homepage = "https://github.com/dev-chenxing/mwse-modding-tutorial"
authors = [ "Amalie",]
version = "1.0.0"
```

The second type of information is the dependencies of your mod. Besides checking if you have other mods installed, the dependency manager can check if assets like Meshes and Textures are missing. It can also check if your the bsa archives are registered, and if MWSE should be updated. You can read more about this in the [doc here](https://mwse.github.io/MWSE/guides/metadata/#dependencies-section).

Our mod depends on OAAB_Data, Ashfall, Crafting Framework, and Skills Module. So the `[dependencies]` section should look like this:

```toml
[dependencies]
assets = [ "MWSE/mods/Amalie/craftableBandage",]

[dependencies.mwse]
buildnumber = 3238

[dependencies.mods."OAAB_Data"]
version = "^2.1.9"
url = "https://www.nexusmods.com/morrowind/mods/49042"

[dependencies.mods."Ashfall"]
version = "^3.10.0"
url = "https://www.nexusmods.com/morrowind/mods/49057"

[dependencies.mods."The Crafting Framework"]
version = "^1.12.0"
url = "https://www.nexusmods.com/morrowind/mods/51009"

[dependencies.mods."Skills Module"]
mwse-module = "OtherSkills"
url = "https://www.nexusmods.com/morrowind/mods/46034"
```

In `assets`, you should add the file path of the assests of your mod.

If your mod uses recent added feature of mwse, you should specify the `buildnumber` in `mwse`. You can find the `buildnumber` in the first line of `MWSE.log`. It is the number after version number and before "built". For example, the buildnumber is `3238` if the first line is `Morrowind Script Extender v2.1.0-3132 (built Mar 30 2023) hooked.`

If your mod depends on other mods, you can specify them with `[dependencies.mods."Mod Name"]`. If the mod comes with a metadata file, you can check the version with `version = "^x.x.x"`. If the mod doesn't come with a metadata file, you could check if a plugin or master file is installed, write `plugin = plugin name.esp`. To check if the MWSE-Lua scripts are installed, write, for example, `mwse-module = mer.ashfall`. This is checking if the folder `\MWSE\mer\ashfall` is installed. `url` is where you specify where to download said mod. 

??? example "What your Craftable Bandage-metadata.toml should look like"
    
    ```toml linenums="1"
    [package]
    name = "Craftable Bandage"
    homepage = "https://github.com/dev-chenxing/mwse-modding-tutorial"
    authors = ["Amalie"]
    version = "1.0.0"

    [dependencies]
    assets = ["MWSE/mods/Amalie/craftableBandage"]

    [dependencies.mwse]
    buildnumber = 3238

    [dependencies.mods."OAAB_Data"]
    version = "^2.1.9"
    url = "https://www.nexusmods.com/morrowind/mods/49042"

    [dependencies.mods."Ashfall"]
    version = "^3.10.0"
    url = "https://www.nexusmods.com/morrowind/mods/49057"

    [dependencies.mods."The Crafting Framework"]
    version = "^1.12.0"
    url = "https://www.nexusmods.com/morrowind/mods/51009"

    [dependencies.mods."Skills Module"]
    mwse-module = "OtherSkills"
    url = "https://www.nexusmods.com/morrowind/mods/46034"
    ```

## Zip Up

Finally, we zip up the two files in `Craftable Bandage.7z`:

```
.
├─ MWSE/
│  └─ mods/
│     └─ Amalie/
│       └─ craftableBandage/
│          └─ main.lua
└─ Craftable Bandage-metadata.toml
```

That's it! Thank you so much for following this tutorial. 