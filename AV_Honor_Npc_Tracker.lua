-- Player faction check
local playerFaction = UnitFactionGroup("player")

------------------------------------------------------------------
-- mark section:
-- mark = 8 (skull), 7 (X), 6 (square), 5 (moon), 4 (triangle), 3 (diamond), 2 (circle), 1 (star)
------------------------------------------------------------------
local MiddleNPCs = {}

if playerFaction == "Horde" then
    MiddleNPCs = {
        { name = "CDR Randolph",   realName = "Commander Randolph",    mark = 8 }, -- Koponya
        { name = "CDR Karl P.",    realName = "Commander Karl Philips",mark = 7 }, -- X
        { name = "LT Stouthandle", realName = "Lieutenant Stouthandle",mark = 6 }, -- Négyzet
        { name = "LT Mancuso",     realName = "Lieutenant Mancuso",    mark = 5 }, -- Hold
        { name = "LT Lonadin",     realName = "Lieutenant Lonadin",    mark = 4 }, -- Háromszög
        { name = "LT Largent",     realName = "Lieutenant Largent",    mark = 3 }, -- Gyémánt
        { name = "LT Greywand",    realName = "Lieutenant Greywand",   mark = 2 }, -- Kör
    }
else
    MiddleNPCs = {
        { name = "CDR Lewis",     realName = "Commander Lewis",     mark = 8 }, -- Koponya
        { name = "CDR Malgor",    realName = "Commander Malgor",    mark = 7 }, -- X
        { name = "LT Murp",        realName = "Lieutenant Murp",     mark = 6 }, -- Négyzet
        { name = "LT Rugug",       realName = "Lieutenant Rugug",    mark = 5 }, -- Hold
        { name = "LT Vol'Gork",    realName = "Lieutenant Vol'Gork", mark = 4 }, -- Háromszög
        { name = "LT Gorl",        realName = "Lieutenant Gorl",     mark = 3 }, -- Gyémánt
        { name = "LT Harke",       realName = "Lieutenant Harke",    mark = 2 }, -- Kör
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

-- positiin and dimension settings
local BUTTON_HEIGHT = 16 
local BUTTON_GAP = 22    
local BOSS_OFFSET = 10   
local MARK_BTN_HEIGHT = 20

-- Main window frame
local mainFrame = CreateFrame("Frame", "AVTrackerMainFrame", UIParent, "BackdropTemplate")
mainFrame:SetSize(130, (#TrackedNPCs * BUTTON_GAP) + 30 + BOSS_OFFSET + MARK_BTN_HEIGHT + 5)
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

-- Buttons
for i, npc in ipairs(TrackedNPCs) do
    local btn = CreateFrame("Button", "AVTrackerBtn"..i, mainFrame, "SecureActionButtonTemplate, BackdropTemplate")
    btn:SetSize(118, BUTTON_HEIGHT)
    
    local yOffset = -20 - ((i - 1) * BUTTON_GAP)
    if npc.isBoss then
        yOffset = yOffset - BOSS_OFFSET
    end
    
    btn:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 6, yOffset)
    btn:RegisterForClicks("AnyUp", "AnyDown")

    btn:SetAttribute("type1", "macro")
    btn:SetAttribute("macrotext1", "/targetexact " .. npc.realName)

    btn:SetAttribute("type2", "macro")
    btn:SetAttribute("macrotext2", "/targetexact " .. npc.realName .. "\n/tm 8")

    btn.hpBar = CreateFrame("StatusBar", nil, btn)
    btn.hpBar:SetAllPoints()
    btn.hpBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    btn.hpBar:SetStatusBarColor(0.1, 0.8, 0.1, 0.8)
    btn.hpBar:SetMinMaxValues(0, 100)
    btn.hpBar:SetValue(100)
    btn.hpBar:EnableMouse(false)

    btn.text = btn.hpBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("LEFT", btn.hpBar, "LEFT", 5, 0)
    btn.text:SetText(npc.name)
    btn.displayName = npc.name

    buttons[npc.realName] = btn
end

------------------------------------------------------------------
-- macro button for middle NPC
------------------------------------------------------------------
local markBtn = CreateFrame("Button", "AVTrackerMarkButton", mainFrame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
markBtn:SetSize(118, MARK_BTN_HEIGHT)
markBtn:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 6, 6)
markBtn:SetText("Mark Mid LTs")

-- Macro build for marks
local macroText = ""
for _, npc in ipairs(MiddleNPCs) do
    if npc.mark then
        macroText = macroText .. "/targetexact " .. npc.realName .. "\n/tm " .. npc.mark .. "\n"
    end
end
macroText = macroText .. "/cleartarget"

markBtn:SetAttribute("type", "macro")
markBtn:SetAttribute("macrotext", macroText)

------------------------------------------------------------------

-- Reset HP
local function ResetButtons()
    for _, btn in pairs(buttons) do
        btn.hpBar:SetValue(100)
        btn.hpBar:SetStatusBarColor(0.1, 0.8, 0.1, 0.8)
        btn.text:SetText(btn.displayName)
        btn:SetAlpha(1.0)
    end
end

local currentZone = ""

-- Zone check (Csak AV)
local function CheckZone()
    local zone = GetRealZoneText()
    
    -- Ha most léptünk be Alterac Valley-be
    if zone == "Alterac Valley" then
        if currentZone ~= "Alterac Valley" then
            ResetButtons() -- CSÁK AKKOR resetel, ha most léptünk be a csatatérre!
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
                local displayName = btn.displayName
                if UnitIsDead(unit) then
                    btn.hpBar:SetValue(0)
                    btn.hpBar:SetStatusBarColor(0.3, 0.3, 0.3, 0.5)
                    btn.text:SetText("|cff808080" .. displayName .. " |TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:12:12|t|r")
                    btn:SetAlpha(0.5)
                else
                    local maxHp = UnitHealthMax(unit)
                    local curHp = UnitHealth(unit)
                    
                    if maxHp > 0 then
                        local hpPct = math.floor((curHp / maxHp) * 100)
                        btn.hpBar:SetValue(hpPct)
                        btn.text:SetText(displayName .. " - " .. hpPct .. "%")

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