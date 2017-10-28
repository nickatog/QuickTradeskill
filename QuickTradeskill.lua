--[[ SAVEDVARIABLES ]]
QuickTradeskillSVar = {}

--[[ BINDING HEADER ]]
BINDING_HEADER_QuickTradeskillHeader = "QuickTradeskill"

--[[ GLOBALS ]]
QuickTradeskill = {}
local TradeSkillData = {}
local ResultData = {}
ResultFrames = {}

local g_Ritual = LibStub("Ritual-1.0")
local g_LibPeriodicTable = LibStub("LibPeriodicTable-3.1")

--[[ SCRIPT HANDLERS ]]
function QuickTradeskill:OnLoad()
	QuickTradeskillFrame:SetBackdropColor(0, 0, 0)
	QuickTradeskillFrame:RegisterForDrag("LeftButton")
	QuickTradeskillFrame:RegisterEvent("ADDON_LOADED")
	
	SLASH_QUICKTRADESKILL1 = "/qts"
	SlashCmdList["QUICKTRADESKILL"] = function(msg)
										self:SlashCommandHandler(msg)
									  end
end

function QuickTradeskill:OnEvent(event, ...)
	if self[event] and type(self[event]) == "function" then
		self[event](...)
	end
end

function QuickTradeskill:SlashCommandHandler(msg)
	local _, _, cmd = strfind(msg, "(%w*)")
	
	if strlower(cmd) == "show" then
		if not QuickTradeskillFrame:IsVisible() then
			QuickTradeskillFrame:Show()
		end
	elseif strlower(cmd) == "hide" then
		if QuickTradeskillFrame:IsVisible() then
			QuickTradeskillFrame:Hide()
		end
	else
		InterfaceOptionsFrame_OpenToCategory("QuickTradeskill")
	end
end

--[[ EVENT HANDLERS ]]
function QuickTradeskill:ADDON_LOADED(...)
	if not QuickTradeskillSVar.ResultLimit then
		QuickTradeskillSVar.ResultLimit = 5
	end
	if QuickTradeskillSVar.Complete == nil then
		QuickTradeskillSVar.Complete = true
	end
end

-- Searches the player's spellbook for any professions and inserts table entries for every tradeskill recipe
-- Calling this while a batch craft cast is in progress will interrupt the cast after the current item
function QuickTradeskill:PopulateTradeSkillData()
	self:ClearData()

	local _, _, _, numGeneralSpells = GetSpellTabInfo(1)
	
	for i = 1, numGeneralSpells do -- Loop through the spells on the 'General' tab
		local spellName = GetSpellName(i, "spell")
		if (g_Ritual:IsTradeskillName(spellName)) then
			CastSpell(i, "spell")
			for j = 1, GetNumTradeSkills() do
				local tradeSkillName, tradeSkillType, numAvailable = GetTradeSkillInfo(j)
				if (tradeSkillType ~= "header") then -- Store recipe data for non-header items
					local tradeSkillIcon = GetTradeSkillIcon(j)
					local tradeSkillLink = GetTradeSkillRecipeLink(j)
					tinsert(TradeSkillData, { link = tradeSkillLink, name = tradeSkillName, profession = spellName, id = j, difficulty = tradeSkillType, available = numAvailable, icon = tradeSkillIcon })
				end
			end
			CloseTradeSkill()
		end
	end
end

-- Searches TradeSkillData table to find matches to the input text and creates QuickTradeskillResultFrames
function QuickTradeskill:Search(text)
	self:ClearResultFrames()
	self:ClearResultData()
	
	if (strlen(text) < 2) then -- Don't bother searching for very short strings
		QuickTradeskillUp:Hide() -- Clear these since we are returning early
		QuickTradeskillDown:Hide()
		QuickTradeskillResultString:SetText("")
		return nil
	end
	
	-- Exhaustive search is ugly for now, but it works
	
	for i = 1, table.getn(TradeSkillData) do -- Search through user's own recipes
		local skip = false
		if strfind(text, "^%+") then -- EXHAUSTIVE SEARCH
			local ttext
			if strfind(text, "^%+%+") then
				ttext = strsub(text, 3, strlen(text))
			else
				ttext = strsub(text, 2, strlen(text))
			end
			QuickTradeskillTooltip:SetOwner(QuickTradeskillFrame)
			QuickTradeskillTooltip:SetHyperlink(TradeSkillData[i].link)
			for j = 1, QuickTradeskillTooltip:NumLines() do
				local tooltipText = getglobal("QuickTradeskillTooltipTextLeft" .. j)
				if tooltipText and tooltipText:GetText() and strfind(strlower(tooltipText:GetText()), strlower(ttext)) then
					tinsert(ResultData, TradeSkillData[i])
					skip = true
					break
				end
			end
			QuickTradeskillTooltip:Hide()
		end
		if (not skip and strfind(strlower(TradeSkillData[i].name), strlower(text))) then
			tinsert(ResultData, TradeSkillData[i])
		end
	end
	
	if QuickTradeskillSVar.Complete then
	local ttable = g_LibPeriodicTable:GetSetString("Tradeskill.RecipeLinks") -- Search through all recipes provided in LibPeriodicTable
	if (ttable) then
		ttable = strsub(ttable, 3, strlen(ttable)) -- Chop off initial part of the set string
		for t in ttable:gmatch("([^,]*),?") do -- Loop through each tradeskill
			local u = g_LibPeriodicTable:GetSetString(t)
			if (u) then
				for id in u:gmatch("-?(%d+):[^,]*") do -- Loop through each recipe
					if GetSpellInfo(id) then
						local skip = false
						if strfind(text, "^%+%+") then -- EXHAUSTIVE SEARCH
							local ttext = strsub(text, 3, strlen(text))
							QuickTradeskillTooltip:SetOwner(QuickTradeskillFrame)
							QuickTradeskillTooltip:SetHyperlink(GetSpellLink(id))
							for i = 1, QuickTradeskillTooltip:NumLines() do
								local tooltipText = getglobal("QuickTradeskillTooltipTextLeft" .. i)
								if tooltipText and tooltipText:GetText() and strfind(strlower(tooltipText:GetText()), strlower(ttext)) then
									--local found = false
									for _, v in pairs(ResultData) do
										if (v.name and (v.name == GetSpellInfo(id))) then
											skip = true
										end
									end
									if not skip then
										tinsert(ResultData, { link = GetSpellLink(id), name = GetSpellInfo(id), difficulty = "impossible", icon = nil })
										skip = true
										break
									end
								end
							end
							QuickTradeskillTooltip:Hide()
						end
						local _, _, tttext = strfind(text, "^%+*(.*)")
						if not skip and strfind(strlower(GetSpellInfo(id)), strlower(tttext)) then
							local found = false
							for _, v in pairs(ResultData) do -- Find duplicates in our result list
								if (v.name and (v.name == GetSpellInfo(id))) then
									found = true
								end
							end
							if (not found) then -- Only add unique recipes
								tinsert(ResultData, { link = GetSpellLink(id), name = GetSpellInfo(id), difficulty = "impossible", icon = nil })
							end
						end
					end
				end
			end
		end
	end
	end

	table.sort(ResultData, function(a, b) return a.name < b.name end) -- Sort results
	
	if table.getn(ResultData) > QuickTradeskillSVar.ResultLimit then -- Throttle output
		QuickTradeskillUp:Show()
		self:DisableUp()
		QuickTradeskillDown:Show()
		self:EnableDown()
		for i = 1, QuickTradeskillSVar.ResultLimit do
			self:ResultFrameBuilder(ResultData, i, -QuickTradeskillUp:GetHeight() - 2)
		end
		QuickTradeskillDown:SetPoint("TOP", ResultFrames[QuickTradeskillSVar.ResultLimit], "BOTTOM")
	else
		QuickTradeskillUp:Hide()
		QuickTradeskillDown:Hide()
		for i = 1, table.getn(ResultData) do
			self:ResultFrameBuilder(ResultData, i, 0)
		end
	end
	
	local resultStr
	if #ResultData == 1 then
		resultStr = " result found!"
	else
		resultStr = " results found!"
	end
	QuickTradeskillResultString:SetText(#ResultData .. resultStr)
	UIFrameFadeIn(QuickTradeskillResultString, 0, 0, 1)
	QuickTradeskillResultString.time = 0
	QuickTradeskillFrame:SetScript("OnUpdate", QuickTradeskillResultString_OnUpdate)
end

-- Helper function for above; builds the clickable tradeskill result frames
function QuickTradeskill:ResultFrameBuilder(results, location, offset)
	local frameToInsert = CreateFrame("BUTTON", nil, QuickTradeskillFrame, "SecureUnitButtonTemplate, QuickTradeskillFrameResult")
	frameToInsert:SetHeight(QuickTradeskillFrame:GetHeight())
	frameToInsert:SetWidth(QuickTradeskillFrame:GetWidth())
	frameToInsert:RegisterForClicks("LeftButtonUp")
	frameToInsert:SetBackdropColor(0, 0, 0)
	frameToInsert:SetPoint("TOP", QuickTradeskillFrame, "BOTTOM", 0, table.getn(ResultFrames) * -frameToInsert:GetHeight() + offset)
	local iconTexture = frameToInsert:CreateTexture(nil, "ARTWORK")
	iconTexture:SetHeight(20)
	iconTexture:SetWidth(20)
	iconTexture:SetPoint("LEFT", frameToInsert, "LEFT", 12, 0)
	local nameFontString = frameToInsert:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	nameFontString:SetPoint("LEFT", iconTexture, "RIGHT", 6, 0)
	frameToInsert.link = results[location].link
	frameToInsert.profession = results[location].profession
	frameToInsert.id = results[location].id
	frameToInsert.num = results[location].available
	frameToInsert.location = location
	iconTexture:SetTexture(results[location].icon)
	nameFontString:SetText(results[location].name)
	g_Ritual:SetTextColorByDifficulty(nameFontString, results[location].difficulty)	
	if (results[location].difficulty ~= "impossible") then
		frameToInsert.madebyme = true
	end
	
	frameToInsert:Show()
	tinsert(ResultFrames, frameToInsert)
end

function QuickTradeskill:ClearData()
	g_Ritual:ClearTable(TradeSkillData)
	collectgarbage()
end

function QuickTradeskill:ClearResultData()
	g_Ritual:ClearTable(ResultData)
	collectgarbage()
end

function QuickTradeskill:ClearResultFrames()
	for i = 1, table.getn(ResultFrames) do
		ResultFrames[table.getn(ResultFrames)]:Hide()
		tremove(ResultFrames)
	end
end

function QuickTradeskill:RunOnClick(profession, id, num)
	local _, _, _, numGeneralSpells = GetSpellTabInfo(1)
	
	for i = 1, numGeneralSpells do
		if (GetSpellName(i, "spell") == profession) then
			CastSpell(i, "spell")
			CloseTradeSkill()
			DoTradeSkill(id, num)
		end
	end
end

function QuickTradeskill:ScrollUp()
	local floc = ResultFrames[1].location - 1
	self:ClearResultFrames()
	for i = 1, QuickTradeskillSVar.ResultLimit do
		self:ResultFrameBuilder(ResultData, floc, -QuickTradeskillUp:GetHeight() - 2)
		floc = floc + 1
	end
	self:EnableDown()
	if floc - QuickTradeskillSVar.ResultLimit == 1 then
		self:DisableUp()
	end
end

function QuickTradeskill:ScrollDown()
	local floc = ResultFrames[1].location + 1
	self:ClearResultFrames()
	for i = 1, QuickTradeskillSVar.ResultLimit do
		self:ResultFrameBuilder(ResultData, floc, -QuickTradeskillUp:GetHeight() - 2)
		floc = floc + 1
	end
	self:EnableUp()
	if floc - 1 == table.getn(ResultData) then
		self:DisableDown()
	end
end

function QuickTradeskill:EnableUp()
	QuickTradeskillUp:RegisterForClicks("LeftButtonUp")
	QuickTradeskillUp:SetAlpha(1.0)
	QuickTradeskillUp.enabled = true
end

function QuickTradeskill:DisableUp()
	QuickTradeskillUp:RegisterForClicks()
	QuickTradeskillUp:SetAlpha(0.50)
	QuickTradeskillUp.enabled = false
end

function QuickTradeskill:EnableDown()
	QuickTradeskillDown:RegisterForClicks("LeftButtonUp")
	QuickTradeskillDown:SetAlpha(1.0)
	QuickTradeskillDown.enabled = true
end

function QuickTradeskill:DisableDown()
	QuickTradeskillDown:RegisterForClicks()
	QuickTradeskillDown:SetAlpha(0.50)
	QuickTradeskillDown.enabled = false
end

function QuickTradeskill:ScrollWheel(in_arg)
	if in_arg > 0 and QuickTradeskillUp.enabled then
		self:ScrollUp()
	elseif in_arg < 0 and QuickTradeskillDown.enabled then
		self:ScrollDown()
	end
end

function QuickTradeskill:LoadOptions(in_panel)
	in_panel.name = "QuickTradeskill"
	InterfaceOptions_AddCategory(in_panel)
end

function QuickTradeskillResultString_OnUpdate(in_self, in_elapsed)
	QuickTradeskillResultString.time = QuickTradeskillResultString.time + in_elapsed
	if QuickTradeskillResultString.time >= 3 then
		UIFrameFadeOut(QuickTradeskillResultString, 2, 1, 0)
		QuickTradeskillResultString.time = nil
		QuickTradeskillFrame:SetScript("OnUpdate", nil)
	end
end
