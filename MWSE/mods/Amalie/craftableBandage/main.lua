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

local configPath = "Craftable Bandage"
local defaultConfig = { enabled = true, logLevel = "INFO" }
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
		---@type CraftingFramework.Recipe.data[]
		local recipes = {
			{
				id = bandageId2,
				craftableId = bandageId2,
				description = "Simple cloth bandages for the dressing of wounds.",
				materials = { { material = "fabric", count = 1 } },
				skillRequirements = { ashfall.bushcrafting.survivalTiers.novice },
				soundType = "fabric",
				category = "Bandages",
			},
		}
		bushcraftingActivator:registerRecipes(recipes)
		log:info("Bandage recipe registered")
	end
end

---@param ref tes3reference
---@return integer duration
local function getEffectDuration(ref)
	local duration
	if ref == tes3.player then
		local skillLevel = skillModule.getSkill("Ashfall:Survival").value
		duration = math.clamp(skillLevel, 20, 40)
		return duration
	else
		return 30
	end
end

---@param e equipEventData
local function useBandage(e)
	if isBandage[e.item.id] then
		local duration = getEffectDuration(e.reference)
		tes3.applyMagicSource({
			reference = e.reference,
			name = "Bandage",
			effects = {
				{
					id = tes3.effect.restoreHealth,
					duration = duration,
					min = 1,
					max = 1,
				},
			},
		})
		timer.delayOneFrame(function()
			tes3.removeItem({
				reference = e.reference,
				item = e.item,
				playSound = false,
			})
		end, timer.real)
		if e.reference == tes3.player then
			tes3.messageBox("Bandage applied")
		end
		return false
	end
end

---@param e damagedEventData|damagedHandToHandEventData
local function removeBandageHealing(e)
	for _, activeMagicEffect in ipairs(
	                            e.reference.mobile.activeMagicEffectList) do
		if activeMagicEffect.instance.source.name == "Bandage" then
			activeMagicEffect.effectInstance.timeActive =
			activeMagicEffect.duration
		end
	end
end

--- @param e initializedEventData
local function initializedCallback(e)
	if not config.enabled then
		return
	end
	if not ashfall then
		return
	end
	if not CraftingFramework then
		return
	end
	if not skillModule then
		return
	end
	event.register("Ashfall:ActivateBushcrafting:Registered",
	               registerBushcraftingRecipe)
	event.register("equip", useBandage)
	event.register("damaged", removeBandageHealing)
	event.register("damagedHandToHand", removeBandageHealing)
	log:info("initialized")
end
event.register(tes3.event.initialized, initializedCallback,
               { priority = 100 }) -- before crafting framework

local function registerModConfig()
	local template = mwse.mcm.createTemplate("Craftable Bandage")
	template:saveOnClose(configPath, config)
	local page = template:createSideBarPage({})
	page:createOnOffButton({
		label = "Enable Mod",
		variable = mwse.mcm.createTableVariable({
			id = "enabled",
			table = config,
			restartRequired = true,
		}),
	})
	page:createDropdown({
		label = "Log Level",
		options = {
			{ label = "DEBUG", value = "DEBUG" },
			{ label = "INFO", value = "INFO" },
		},
		variable = mwse.mcm.createTableVariable({
			id = "logLevel",
			table = config,
		}),
		callback = function(self)
			log:setLogLevel(self.variable.value)
		end,
	})
	page.sidebar:createInfo({
		text = "Cratable Bandage allows you to craft OAAB Bandage with Ashfall Bushcrafting.",
	})
	template:register()
end
event.register("modConfigReady", registerModConfig)
