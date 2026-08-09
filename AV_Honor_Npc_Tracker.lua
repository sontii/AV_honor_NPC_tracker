-- Player faction check
local playerFaction = UnitFactionGroup("player")

------------------------------------------------------------------
-- mark section:
-- mark = 8 (skull), 7 (X), 6 (square), 5 (moon), 4 (triangle), 3 (diamond), 2 (circle), 1 (star)
------------------------------------------------------------------
local MiddleNPCs = {}

if playerFaction == "Horde" then
    MiddleNPCs = {
        { name = "CDR Randolph",   realName = "Commander Randolph",    mark = 8 }, -- Skull
        { name = "CDR Karl P.",    realName = "Commander Karl Philips",mark = 7 }, -- X
        { name = "LT Stouthandle", realName = "Lieutenant Stouthandle",mark = 6 }, -- Square
        { name = "LT Mancuso",     realName = "Lieutenant Mancuso",    mark = 5 }, -- Moon
        { name = "LT Lonadin",     realName = "Lieutenant Lonadin",    mark = 4 }, -- Triangle
        { name = "LT Largent",     realName = "Lieutenant Largent",    mark = 3 }, -- Diamond
        { name = "LT Greywand",    realName = "Lieutenant Greywand",   mark = 2 }, -- Circle
    }
else
    MiddleNPCs = {
        { name = "CDR Lewis",     realName = "Commander Lewis",     mark = 8 }, -- Skull
        { name = "CDR Malgor",    realName = "Commander Malgor",    mark = 7 }, -- X
        { name = "LT Murp",        realName = "Lieutenant Murp",     mark = 6 }, -- Square
        { name = "LT Rugug",       realName = "Lieutenant Rugug",    mark = 5 }, -- Moon
        { name = "LT Vol'Gork",    realName = "Lieutenant Vol'Gork", mark = 4 }, -- Triangle
        { name = "LT Gorl",        realName = "Lieutenant Gorl",     mark = 3 }, -- Diamond
        { name = "LT Harke",       realName = "Lieutenant Harke",    mark = 2 }, -- Circle
    }
end

local OtherNPCs = {}
if playerFaction == "Horde" then
    OtherNPCs = {
        { name = "Cpt Balinda",   realName = "Captain Balinda Stonehearth", id = 11949 },
        { name = "LT Spencer",    realName = "Lieutenant Spencer",          id = 13138 },
        { name = "CDR Duffy",     realName = "Commander Duffy",             id = 13319 },
        { name = "CDR Mortimer",  realName = "Commander Mortimer",          id = 13318 },
    }
else
    OtherNPCs = {
        { name = "Cpt Galvangar", realName = "Captain Galvangar",           id = 11947 },
        { name = "CDR Mulfort",   realName = "Commander Mulfort",           id = 13323 },
        { name = "LT Spencer",    realName = "Lieutenant Spencer",          id = 13304 },
        { name = "LT Timmy",      realName = "Lieutenant Timmy",            id = 13307 },
    }
end

local CommonNPCs = {
    { name = "Vanndar",   realName = "Vanndar Stormpike", id = 11948, isBoss = true },
    { name = "Drek'Thar",  realName = "Drek'Thar",          id = 11946, isBoss = true },
}

-- NPC list
local TrackedNPCs = {}
for _, npc in ipairs(MiddleNPCs) do table.insert(TrackedNPCs, npc) end
for _, npc in ipairs(OtherNPCs) do table.insert(TrackedNPCs, npc) end
for _, npc in ipairs(CommonNPCs) do table.insert(TrackedNPCs, npc) end

-- position and size settings
local BUTTON_HEIGHT = 16
local BUTTON_GAP = 22
local BOSS_OFFSET = 10

-- Raid target icon helper function
local function MarkIcon(mark)
    return "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_" .. mark .. ":12:12|t"
end

-- Track current zone (avoids leaking a global)
local currentZone = nil

-- Main window frame
local mainFrame = CreateFrame("Frame", "AVTrackerMainFrame", UIParent, "BackdropTemplate")
mainFrame:SetSize(130, (#TrackedNPCs * BUTTON_GAP) + 30 + BOSS_OFFSET + 10)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 300, 0)
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)

-- Background/Border
mainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

-- Header
local title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", mainFrame, "TOP", 0, -6)
title:SetText("AV Honor NPC")

local buttons = {}

------------------------------------------------------------------
-- NPC buttons (left click: target, right click: target + apply assigned mark)
------------------------------------------------------------------
for i, npc in ipairs(TrackedNPCs) do
    local btn = CreateFrame("Button", "AVTrackerBtn"..i, mainFrame, "SecureActionButtonTemplate, BackdropTemplate")
    btn:SetSize(118, BUTTON_HEIGHT)

    local yOffset = -20 - ((i - 1) * BUTTON_GAP)
    if npc.isBoss then
        yOffset = yOffset - BOSS_OFFSET
    end

    btn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 6, yOffset)
    btn:RegisterForClicks("AnyUp", "AnyDown")

    -- If the NPC has its own mark defined (MiddleNPCs), use that.
    -- If not (OtherNPCs / CommonNPCs), fall back to skull (8).
    local markToUse = npc.mark or 8

    btn:SetAttribute("type1", "macro")
    btn:SetAttribute("macrotext1", "/targetexact " .. npc.realName)

    btn:SetAttribute("type2", "macro")
    btn:SetAttribute("macrotext2", "/targetexact " .. npc.realName .. "\n/tm " .. markToUse)

    btn.hpBar = CreateFrame("StatusBar", nil, btn)
    btn.hpBar:SetAllPoints()
    btn.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    btn.hpBar:SetStatusBarColor(0.1, 0.8, 0.1, 0.8)
    btn.hpBar:SetMinMaxValues(0, 100)
    btn.hpBar:SetValue(100)
    btn.hpBar:EnableMouse(false)

    btn.text = btn.hpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("LEFT", btn.hpBar, "LEFT", 5, 0)

    -- Mark icon shown right-aligned on the button
    btn.markText = btn.hpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.markText:SetPoint("RIGHT", btn.hpBar, "RIGHT", -4, 0)

    btn.plainName = npc.name
    btn.markToUse = markToUse
    btn.displayName = npc.name
    btn.text:SetText(btn.displayName)
    btn.markText:SetText(MarkIcon(markToUse))

    buttons[npc.realName] = btn
end

------------------------------------------------------------------
-- Reset HP
local function ResetButtons()
    for _, btn in pairs(buttons) do
        btn.hpBar:SetValue(100)
        btn.hpBar:SetStatusBarColor(0.1, 0.8, 0.1, 0.8)
        btn.text:SetText(btn.displayName)
        btn.markText:SetText(MarkIcon(btn.markToUse))
        btn:SetAlpha(1.0)
    end
end

-- Zone check (AV only)
local function CheckZone()
    local zone = GetRealZoneText()

    if zone == "Alterac Valley" then
        if currentZone ~= "Alterac Valley" then
            ResetButtons() -- only reset when we just entered the battleground
            currentZone = "Alterac Valley"
        end
        mainFrame:Show()
    else
        currentZone = zone
        mainFrame:Hide()
    end
end

-- Target scan
local function ScanTargets()
    if not mainFrame:IsShown() then return end

    for i = 1, GetNumGroupMembers() do
        local unit = "raid" .. i .. "target"
        if UnitExists(unit) then
            local realName = UnitName(unit)
            local btn = buttons[realName]

            if btn then
                if UnitIsDead(unit) then
                    btn.hpBar:SetValue(0)
                    btn.hpBar:SetStatusBarColor(0.3, 0.3, 0.3, 0.5)
                    btn.text:SetText("|cff808080" .. btn.plainName .. "|r")
                    btn.markText:SetText(MarkIcon(8))
                    btn:SetAlpha(0.5)
                else
                    local maxHp = UnitHealthMax(unit)
                    local curHp = UnitHealth(unit)

                    if maxHp > 0 then
                        local hpPct = math.floor((curHp / maxHp) * 100)
                        btn.hpBar:SetValue(hpPct)
                        btn.text:SetText(btn.plainName .. " - " .. hpPct .. "%")
                        btn.markText:SetText(MarkIcon(btn.markToUse))

                        if hpPct > 50 then
                            btn.hpBar:SetStatusBarColor(0.1, 0.8, 0.1, 0.8)
                        elseif hpPct > 20 then
                            btn.hpBar:SetStatusBarColor(0.9, 0.7, 0.1, 0.8)
                        else
                            btn.hpBar:SetStatusBarColor(0.9, 0.1, 0.1, 0.8)
                        end
                        btn:SetAlpha(1.0)
                    end
                end
            end
        end
    end
end

-- Event tracker
local zoneCheckFrame = CreateFrame("Frame")
zoneCheckFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
zoneCheckFrame:RegisterEvent("ZONE_CHANGED")
zoneCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
zoneCheckFrame:SetScript("OnEvent", CheckZone)

-- Timer (0.5s)
C_Timer.NewTicker(0.5, ScanTargets)