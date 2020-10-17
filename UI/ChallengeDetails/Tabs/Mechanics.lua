--[[--
@module MyDungeonsBook
]]

--[[--
UI
@section UI
]]

--[[--
Creates a frame for Mechanics tab

@param[type=Frame] parentFrame
@return[type=Frame]
]]
function MyDungeonsBook:MechanicsFrame_Create(parentFrame)
	local mechanicsFrame = CreateFrame("Frame", nil, parentFrame);
	mechanicsFrame:SetPoint("TOPLEFT", 0, -30);
	mechanicsFrame:SetWidth(900);
	mechanicsFrame:SetHeight(650);
	mechanicsFrame.tabButtonsFrame = self:MechanicsFrame_CreateTabButtonsFrame(mechanicsFrame);
	mechanicsFrame.usedItemsFrame = self:UsedItemsFrame_Create(mechanicsFrame);
	mechanicsFrame.damageFrame = self:DamageFrame_Create(mechanicsFrame);
	mechanicsFrame.effectsAndAurasFrame = self:EffectsAndAurasFrame_Create(mechanicsFrame);
	mechanicsFrame.castsFrame = self:CastsFrame_Create(mechanicsFrame);
	mechanicsFrame.tabs = {
		usedItems = mechanicsFrame.usedItemsFrame,
		effectsAndAuras = mechanicsFrame.effectsAndAurasFrame,
		damage = mechanicsFrame.damageFrame,
		casts = mechanicsFrame.castsFrame
	};
	mechanicsFrame:Hide();
	return mechanicsFrame;
end

--[[--
Updates a Mechanics frame with data for challenge with id `challengeId`.

@param[type=number] challengeId
]]
function MyDungeonsBook:MechanicsFrame_Update(challengeId)
	self:UsedItemsFrame_Update(challengeId);
	self:DamageFrame_Update(challengeId);
	self:EffectsAndAurasFrame_Update(challengeId);
	self:CastsFrame_Update(challengeId);
	self:Tab_Click(self.challengeDetailsFrame.mechanicsFrame, "usedItems");
end
