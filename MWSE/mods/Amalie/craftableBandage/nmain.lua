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

local bandageId1 = "AB_alc_Healbandage01"
local bandageId2 = "AB_alc_Healbandage02"
local isBandage = { [bandageId1] = true, [bandageId2] = true }

--- @param e CraftingFramework.MenuActivator.RegisteredEvent
local function registerBushcraftingRecipe(e)
	local bushcraftingActivator = e.menuActivator
	---@type CraftingFramework.Recipe.data
	local recipe = {
		id = bandageId2,
		craftableId = bandageId2,
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

--- @param e loadedEventData
local function testOnly(e)
	tes3.addItem({
		reference = tes3.player,
		item = "ashfall_fabric",
		count = 5,
	})
	skillModule.getSkill("Bushcrafting"):levelUpSkill(10)
end

--- @param e initializedEventData
local function initializedCallback(e)
	event.register("Ashfall:ActivateBushcrafting:Registered",
	               registerBushcraftingRecipe)
	event.register(tes3.event.loaded, testOnly)
	log:info("[Craftable Bandage] initialized")
end
event.register(tes3.event.initialized, initializedCallback,
               { priority = 100 }) -- before crafting framework
