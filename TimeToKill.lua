local lastCheckTime = 0;
local checkInterval = 1;
local X_Offset = 0
local Y_Offset = -100
if not TimeToKill then
	TimeToKill = {};
end;
TimeToKill.TTK = CreateFrame("Frame", nil, UIParent);

local inCombat = false;

local remainingSeconds = 0;

local ttkFrame = CreateFrame("Frame")
ttkFrame:SetFrameStrata("HIGH")
ttkFrame:SetWidth(100)
ttkFrame:SetHeight(100)
ttkFrame:SetPoint("CENTER", UIParent, "CENTER", X_Offset, Y_Offset)

local textTimeTillDeath = ttkFrame:CreateFontString(nil, "OVERLAY", "GameTooltipText")
textTimeTillDeath:SetFont("Fonts\\ARIALN.TTF", 99, "OUTLINE")
textTimeTillDeath:SetPoint("CENTER", 0, 0)



local combatStart = GetTime();



local function TTKLogic()

	if UnitExists("target") and UnitCanAttack("player", "target") then
		ttkFrame:Show()
			
		local targetName = UnitName("target")
		local maxHP = UnitHealthMax("target")
		local curHP = UnitHealth("target")

		if not maxHP or maxHP == 0 then return end

		if targetName == 'Vaelastrasz the Corrupt' then
			maxHP = maxHP * 0.3
		end

		local EHealthPercent = curHP / maxHP * 100

		if EHealthPercent == 100 and not (targetName == 'Spore' or targetName == 'Fallout Slime' or targetName == 'Plagued Champion') then
			combatStart = GetTime()
		end

		local missingHP = maxHP - curHP
		local elapsed = GetTime() - combatStart

		if missingHP > 0 and elapsed > 0 then
			local estimatedTime = (maxHP / (missingHP / elapsed)) - elapsed
			local remainingSeconds = estimatedTime * 0.90

			if remainingSeconds == remainingSeconds then
				local intPart = math.floor(remainingSeconds)
				local decimalPart = math.floor((remainingSeconds - intPart) * 100)
				textTimeTillDeath:SetText(string.format("%d:%02d", intPart, decimalPart))
			-- else
				-- textTimeTillDeath:SetText("")
			end
		end
	else
		ttkFrame:Hide()
	end
end



function onUpdate()

	if GetTime()-lastCheckTime >= checkInterval then
		TTKLogic();
		lastCheckTime = GetTime()
	end
end
TimeToKill.TTK:SetScript("OnUpdate", function(self) if inCombat then onUpdate(); end; end);




TimeToKill.TTK:SetScript("OnEvent", function()
	if event == "PLAYER_REGEN_DISABLED" then
		combatStart = GetTime();
		inCombat = true;
	elseif event == "PLAYER_REGEN_ENABLED" then
		inCombat = false;
		combatStart = GetTime();
		textTimeTillDeath:SetText("");
		-- lastCheckTime = 0 -- not needed
	elseif event == "PLAYER_LOGIN" then
	elseif event == "PLAYER_DEAD" then
		inCombat = false;
	end
end);
TimeToKill.TTK:RegisterEvent("PLAYER_REGEN_ENABLED");
TimeToKill.TTK:RegisterEvent("PLAYER_REGEN_DISABLED");
TimeToKill.TTK:RegisterEvent("PLAYER_LOGIN");
TimeToKill.TTK:RegisterEvent("PLAYER_DEAD");

