local CraftingFramework = include("CraftingFramework")
local logging = require("logging.logger")

local configPath = "Craftable Bandage"
local defaultConfig = { enabled = true, logLevel = "DEBUG" } -- TODO: change it back to INFO
local config = mwse.loadConfig(configPath, defaultConfig)

---@type mwseLogger
local log = logging.new({
	name = "Craftable Bandage",
	logLevel = config.logLevel,
})

local bandageId1 = "AB_alc_HealBandage01"
local bandageId2 = "AB_alc_HealBandage02"
local isBandage = { [bandageId1] = true, [bandageId2] = true }

---@param e CraftingFramework.MenuActivator.RegisteredEvent
local function registerBushcraftingRecipe(e)
	local bushcraftingActivator = e.menuActivator
	if bushcraftingActivator then
		local recipes = {
			{
				id = bandageId2,
				craftableId = bandageId2,
				description = "Simple cloth bandages for the dressing of wounds.",
				materials = { { material = "fabric", count = 1 } },
				skillRequirements = {
					{ skill = "Bushcrafting", requirement = 20 }, -- novice
				},
				soundType = "fabric",
				category = "Other",
			},
		}
		bushcraftingActivator:registerRecipes(recipes)
	end
end

---@param e equipEventData
local function useBandage(e)
	if isBandage[e.item.id] then
		tes3.applyMagicSource({
			reference = e.reference,
			effects = {
				{ id = tes3.effect.restoreHealth, duration = 30, min = 1, max = 1 },
			},
		})
		return false
	end
end

local function initialized()
	if not config.enabled then
		return
	end
	if not CraftingFramework then
		return
	end
	event.register("Ashfall:ActivateBushcrafting:Registered",
	               registerBushcraftingRecipe)
	event.register("equip", useBandage)
	log:debug("initialized")
end
event.register("initialized", initialized)

local function registerModConfig()
	local template = mwse.mcm.createTemplate("Craftable Bandage")
	template:saveOnClose(configPath, config)
	local page = template:createSideBarPage({})
	page:createOnOffButton({
		label = "Enable Mod",
		variable = mwse.mcm.createTableVariable {
			id = "enabled",
			table = config,
			restartRequired = true,
		},
	})
	page.sidebar:createInfo({
		text = "Cratable Bandage allows you to craft OAAB Bandage with Ashfall Bushcrafting.",
	})
	template:register()
end
event.register("modConfigReady", registerModConfig)
