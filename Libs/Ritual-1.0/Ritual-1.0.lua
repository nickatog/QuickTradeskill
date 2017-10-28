-- Ritual: A library of miscellaneous functions for my addons
-- Author: Kjado (nandersoncs@gmail.com)
local Ritual = LibStub:NewLibrary("Ritual-1.0", 1)

if not Ritual then
	return
end

-- Localized tradeskill strings
Ritual.TradeskillNames = Ritual.TradeskillNames or {
														Alchemy			= GetSpellInfo(2259),
														Blacksmithing	= GetSpellInfo(2018),
														Cooking			= GetSpellInfo(2550),
														Enchanting		= GetSpellInfo(7411),
														Engineering		= GetSpellInfo(4036),
														FirstAid		= GetSpellInfo(3273),
														Inscription		= GetSpellInfo(45357),
														Jewelcrafting	= GetSpellInfo(25229),
														Leatherworking	= GetSpellInfo(2108),
														Smelting		= GetSpellInfo(2656),
														Tailoring		= GetSpellInfo(3908)
													}

-- Clears in_table by setting all keys to nil values
function Ritual:ClearTable(in_table)
	for k, _ in pairs(in_table) do
		in_table[k] = nil
	end
end

-- Returns true if in_name matches the name of an in-game tradeskill, false otherwise
function Ritual:IsTradeskillName(in_name)
	for k, v in pairs(Ritual.TradeskillNames) do
		if v == in_name then
			return true
		end
	end
	
	return false
end

-- Colors a FontString according to crafting difficulty
function Ritual:SetTextColorByDifficulty(in_fontString, in_diff)
	if (in_diff == "trivial") then
		in_fontString:SetTextColor(1, 1, 1)
	elseif (in_diff == "easy") then
		in_fontString:SetTextColor(0, 0.8, 0)
	elseif (in_diff == "medium") then
		in_fontString:SetTextColor(0.8, 0.8, 0)
	elseif (in_diff == "optimal") then
		in_fontString:SetTextColor(0.8, 0.5, 0)
	elseif (in_diff == "impossible") then -- results from LibPeriodicTable
		in_fontString:SetTextColor(0.8, 0, 0)
	end
end
