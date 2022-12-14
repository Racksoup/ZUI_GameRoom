GR = LibStub("AceAddon-3.0"):NewAddon("ZUI_GameRoom", "AceConsole-3.0", "AceComm-3.0", "AceSerializer-3.0" )
L = LibStub("AceLocale-3.0"):GetLocale("ZUI_GameRoomLocale")
GR_GUI = {}
local icon = LibStub("LibDBIcon-1.0")
local GR_LDB = LibStub("LibDataBroker-1.1"):NewDataObject("GR", {
  type = "data source",
  text = "GameRoom",
  icon = "interface/icons/inv_misc_ticket_tarot_maelstrom_01.blp",
  OnClick = function()
    if (GR_GUI.Main:IsVisible()) then 
      --GR:HideMain()
      GR_GUI.Main:Hide()
    else 
      if (GR.FirstOpen) then
        GR.FirstOpen = false
        GR_GUI.Main:Show()
      else
        GR:ShowMain()
      end
    end
  end,
  OnTooltipShow = function(tooltip)
    tooltip:SetText("Game Room")
  end,
})

local defaults = {
  realm = {
    minimap = { hide = false },
    HideInCombat = false,
    tab = 1,
    showBN = true,
    disableChallenges = false,
    showChallengeAsMsg = false,
    Xpos = 200,
    Ypos = -150,
    Point = "TOPLEFT",
    Blacklist = {},
    Whitelist = {},
    Rivals = {},
    onlyWhitelist = false,
    WhitelistGuild = false,
    WhitelistParty = false,
    WhitelistFriends = false
  }
}

-- Create
function GR:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("ZUI_GameRoomDB", defaults, true)
  icon:Register("ZUI_GameRoom", GR_LDB, self.db.realm.minimap)
  GR:RegisterChatCommand("gr", "OpenClose")

  -- Window Consts
  GR.Win = {}
  GR.Win.Const = {}
  GR.Win.Const.Tab1Width = 750
  GR.Win.Const.Tab1Height = 510
  GR.Win.Const.Tab2Width = 310
  GR.Win.Const.Tab2Height = 250
  GR.Win.Const.Tab3Width = 310
  GR.Win.Const.Tab3Height = 460
  GR.Win.Const.Tab4Width = 450
  GR.Win.Const.Tab4Height = 570

  -- Window Varibales
  GR.Win.XRatio = 1
  GR.Win.YRatio = 1
  GR.Win.ScreenRatio = 1
  GR.FirstOpen = true

  -- Game Varibales
  GR.PlayerPos = nil
  GR.IsPlayerTurn = nil
  GR.GameOver = false
  GR.IsChallenged = false
  GR.PlayerName = UnitName("player")

  -- Retail or Classic/Wrath
  version, build, datex, tocversion = GetBuildInfo()
  if (tocversion > 40000) then 
    GR.Retail = true
  else
    GR.Retail = false
  end
  
  GR:CreateMainWindow()
  GR:CreateRegister()
  GR:CreateTicTacToe()
  GR:CreateBattleships()
  GR:CreateAsteroids()
  GR:CreateSnake()
  
  GR.db.realm.tab = 2
  GR:TabSelect()

  GR:RegisterComm("ZUI_GameRoom_Reg", function(...) GR:RegisterPlayers(...) end)
  GR:RegisterComm("ZUI_GameRoom_Inv", function(...) GR:Invite(...) end)
  GR:RegisterComm("ZUI_GameRoom_TiG", function(...) GR:TicTacToeComm(...) end)
  GR:RegisterComm("ZUI_GameRoom_BSG", function(...) GR:BattleshipsComm(...) end)

  GR_GUI.Main:Hide()
end

function GR:CreateMainWindow()
  -- Main Window
  GR_GUI.Main = CreateFrame("Frame", GameRoom, UIParent, "TranslucentFrameTemplate")
  local Main = GR_GUI.Main
  Main:SetSize(GR.Win.Const.Tab2Width, GR.Win.Const.Tab2Height)
  if (GR.Retail) then 
    Main:SetResizeBounds(100,120)
  else
    Main:SetMinResize(100,120)
  end
  Main:SetFrameStrata("HIGH")
  Main:SetPoint("TOP", UIParent, "TOP", 0, -130)
  Main:SetMovable(true)
  Main:EnableMouse(true)
  Main:SetResizable(true)
  Main:RegisterForDrag("LeftButton")
  Main:SetScript("OnDragStart", function() if(IsShiftKeyDown() == true) then Main:StartMoving() end end)
  Main:SetScript("OnDragStop", Main.StopMovingOrSizing)
  Main:SetPropagateKeyboardInput(true)
  Main:SetScript("OnKeyDown", function(self, key)
      if (key == "ESCAPE" and Main:IsVisible()) then
          Main:Hide()
          Main:SetPropagateKeyboardInput(false)
          C_Timer.After(.001, function() 
              Main:SetPropagateKeyboardInput(true)
          end)
      end
  end)
  Main:Show()
  Main:SetAlpha(1)
  Main.XRatio = 1
  Main.YRatio = 1
  Main.ScreenRatio = 1

  -- Resize Button
  Main.ResizeBtn = CreateFrame("Button", nil, Main)
  local ResizeBtn = Main.ResizeBtn    
  ResizeBtn:EnableMouse("true")
  ResizeBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  ResizeBtn:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  ResizeBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  ResizeBtn:SetScript("OnMouseDown", function(self)
      self:GetParent():StartSizing("BOTTOMRIGHT") 
  end)
  ResizeBtn:SetScript("OnMouseUp", function()
      Main:StopMovingOrSizing("BOTTOMRIGHT")
      GR:ResizeMain()
      GR:SizeTictactoe()
      GR:ResizeBattleships()
      GR:SizeAsteroids()
      GR:SnakeSize()
  end)
  
  -- Game Room Title
  Main.H1 =  Main:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local H1 = Main.H1
  H1:SetTextColor(.8,.8,.8,1)
  H1:SetText("Game Room")

  -- Header 2
  Main.H2 = Main:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local H2 = Main.H2
  H2:SetTextColor(.8,.8,.8,1)

  -- Close XButton
  Main.xButton = CreateFrame("Button", XButton, Main)
  local xButton = Main.xButton
  xButton:RegisterForClicks("AnyUp", "AnyDown")
  Main.xButton.tex = xButton:CreateTexture()
  local buttonTex = Main.xButton.tex
  buttonTex:SetAllPoints(xButton)
  buttonTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButton.blp")
  buttonTex:SetTexCoord(0, 1, 0, 1)
  Main.xButton.tint = xButton:CreateTexture()
  local buttonTint = Main.xButton.tint
  buttonTint:SetPoint("TOPLEFT", xButton, "TOPLEFT", 2, -2)
  buttonTint:SetPoint("BOTTOMRIGHT", xButton, "BOTTOMRIGHT", -2, 2)
  buttonTint:SetColorTexture(0,0,0,0);
  Main.xButton:SetScript("OnClick", function(self, button, down) 
      if(button == "LeftButton" and down == true) then Main.xButton.tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButtonDown.blp") end
      if(button == "LeftButton" and down == false) then 
          --GR:HideMain() 
          Main:Hide()
      end
  end)
  Main.xButton:SetScript("OnEnter", function(self, motion)
      Main.xButton.tint:SetColorTexture(0,0,0,.3);
  end)
  Main.xButton:SetScript("OnLeave", function(self, motion)
      Main.xButton.tint:SetColorTexture(0,0,0,0);
      Main.xButton.tex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\XButton.blp")
  end)

  -- Exit Button
  Main.ExitBtn = CreateFrame("Button", ExitBtn, Main, "UIPanelButtonTemplate")
  local ExitBtn = Main.ExitBtn
  ExitBtn.FS = ExitBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local ExitFS = ExitBtn.FS 
  ExitFS:SetTextColor(.8,.8,.8, 1)
  ExitFS:SetText("Exit Game")
  ExitBtn:SetScript("OnClick", function(self, button, down)
    if (button == "LeftButton" and down == false) then 
      GR:ExitGameClicked()
    end
  end)
  Main.ExitBtn:Hide()
  
  GR:CreateAcceptDecline()
  GR:CreateHeaderInfo()
  GR:CreateSoloGames()
  GR:CreateMultiGames()
  GR:CreateSettings()
  GR:ResizeMainNoRatioChange()
end

function GR:CreateHeaderInfo()
  -- Frame
  GR_GUI.Main.HeaderInfo = CreateFrame("Frame", HeaderInfo, GR_GUI.Main)
  local HeaderInfo = GR_GUI.Main.HeaderInfo
  
  -- Turn String
  HeaderInfo.TurnString = HeaderInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local TurnString = HeaderInfo.TurnString

  -- Opponet String
  HeaderInfo.OpponentString = HeaderInfo:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local Opp = HeaderInfo.OpponentString
  Opp:SetTextColor(.8,.8,.8, 1)

  -- Reinvite Button
  HeaderInfo.ReInvite = CreateFrame("Button", ReInvite, HeaderInfo, "UIPanelButtonTemplate")
  local ReInvite = HeaderInfo.ReInvite
  ReInvite.FS = ReInvite:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  ReInvite.FS:SetTextColor(.8,.8,.8, 1)
  ReInvite.FS:SetText("Rematch?")
  ReInvite:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then
          local UserName = UnitName("player")
          if (GR.GameType == "Tictactoe") then
              GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Challenge, " .. UserName, "WHISPER", GR.Opponent)
          end
          if (GR.GameType == "Battleships") then
              GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Challenge, " .. UserName, "WHISPER", GR.Opponent)
          end
          GR.CanSendInvite = false
          ReInvite:Hide()
          C_Timer.After(4, function() 
              GR.CanSendInvite = true
          end)
      end
  end)

  -- Rematch Button
  HeaderInfo.ReMatch = CreateFrame("Button", ReMatch, HeaderInfo, "UIPanelButtonTemplate")
  local ReMatch = HeaderInfo.ReMatch
  ReMatch.FS = ReMatch:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local ReMatchFS = ReMatch.FS
  ReMatchFS:SetTextColor(.8,.8,.8, 1)
  ReMatchFS:SetText("Accept")
  ReMatch:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then 
          local Opponent = GR.Opponent
          local Rand = random(1,2)
          GR.PlayerPos = Rand
          if (GR.PlayerPos == 2) then
              GR.IsPlayerTurn = false
          else
              GR.IsPlayerTurn = true
          end
          if (GR.GameType == "Tictactoe") then
              GR:TicTacToeHideContent()
              GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Accept, " .. Rand .. ", " .. UnitName("Player"), "WHISPER", Opponent)
              GR.db.realm.tab = 1
              GR:TabSelect()
            end
            if (GR.GameType == "Battleships") then
              GR:BattleshipsHideContent()
              GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Accept, " .. Rand .. ", " .. UnitName("player"), "WHISPER", Opponent)
              GR.db.realm.tab = 1
              GR:TabSelect()
          end
      end
  end)

  -- Add Rival Button
  HeaderInfo.Rival = CreateFrame("Button", Rival, HeaderInfo, "UIPanelButtonTemplate")
  local Rival = HeaderInfo.Rival
  Rival.FS = Rival:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local RivalFS = Rival.FS
  RivalFS:SetTextColor(.8,.8,.8, 1)
  RivalFS:SetText("Add Rival")
  Rival:SetScript("OnClick", function(self, button, down)
      if (button == "LeftButton" and down == false) then 
          table.insert(GR.db.realm.Rivals, GR.Opponent)
          Rival:Hide()
      end
  end)

  HeaderInfo:Hide()
end

function GR:CreateAcceptDecline()
  -- Accept Button when GameRoom is closed
  local function CreateGRClosedAcceptBtns()
    local PlayerName = UnitName("player")
    GR_GUI.Accept = CreateFrame("Button", Accept, UIParent, "UIPanelButtonTemplate")
    local Accept = GR_GUI.Accept
    Accept:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
    Accept:SetSize(214, 58)
    local AcceptString = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    AcceptString:SetPoint("TOP", 0, -11)
    AcceptString:SetTextScale(1.5)
    AcceptString:SetTextColor(.8,1,0, 1)
    AcceptString:SetText("Incoming Challenge!")
    Accept.FS2 = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    local AcceptString2 = Accept.FS2
    AcceptString2:SetPoint("BOTTOM", 0, 10)
    AcceptString2:SetTextScale(1.3)
    AcceptString2:SetTextColor(.8,1,0, 1)
    Accept:SetScript("OnClick", function(self, button, down)
      GR_GUI.Main:Show() 
      GR:AcceptGameClicked()
    end)

    -- Decline Button while GameRoom is closed
    Accept.DeclineBtn = CreateFrame("Button", DeclineBtn, Accept, "UIPanelButtonTemplate")
    local DeclineBtn = Accept.DeclineBtn
    DeclineBtn:SetPoint("RIGHT", 100, 0)
    DeclineBtn:SetSize(70, 20)
    local DeclineFS = DeclineBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    DeclineFS:SetPoint("CENTER", 0, 0)
    DeclineFS:SetTextScale(1.1)
    DeclineFS:SetTextColor(.8,.8,.8, 1)
    DeclineFS:SetText("Decline")
    DeclineBtn:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then 
          GR_GUI.Main.Accept:Hide()
          GR_GUI.Accept:Hide()
          GR:DeclineGameClicked()
        end 
    end)

    -- Mover for Accept Button when GameRoom is closed
    GR_GUI.AcceptMover = CreateFrame("Frame", AcceptMover, UIParent)
    local AcceptMover = GR_GUI.AcceptMover
    AcceptMover:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
    AcceptMover:SetSize(50, 50)
    local AcceptMoverTex = AcceptMover:CreateTexture()
    AcceptMoverTex:SetAllPoints(AcceptMover)
    AcceptMoverTex:SetColorTexture(0,.4,1, 1)
    AcceptMover:SetMovable(true)
    AcceptMover:EnableMouse(true)
    AcceptMover:RegisterForDrag("LeftButton")
    AcceptMover:SetScript("OnDragStart", function(self, button) self:StartMoving() end)
    AcceptMover:SetScript("OnDragStop", function(self) 
        self:StopMovingOrSizing() 
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
        GR.db.realm.Point = point
        GR.db.realm.Xpos = xOfs
        GR.db.realm.Ypos = yOfs
        Accept:SetPoint(GR.db.realm.Point, GR.db.realm.Xpos, GR.db.realm.Ypos)
    end)

    Accept:Hide()
    AcceptMover:Hide()
  end
  CreateGRClosedAcceptBtns()

  -- Accept Button when GameRoom is open
  local function CreateGROpenAcceptBtns()
    -- Accept Button
    GR_GUI.Main.Accept = CreateFrame("Button", Accept, GR_GUI.Main, "UIPanelButtonTemplate")
    local Accept = GR_GUI.Main.Accept
    Accept.FS = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    local AcceptFS = Accept.FS
    AcceptFS:SetTextColor(.8,1,0, 1)
    AcceptFS:SetText("Incoming Challenge!")
    Accept.FS2 = Accept:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    local AcceptFS2 = Accept.FS2
    AcceptFS2:SetTextColor(.8,1,0, 1)
    Accept:SetScript("OnClick", function(self, button, down) 
      GR_GUI.Main.Accept:Hide()
      GR_GUI.Main.DeclineBtn:Hide()
      GR:AcceptGameClicked()
    end)

    -- Decline Button
    GR_GUI.Main.DeclineBtn = CreateFrame("Button", DeclineBtn, GR_GUI.Main, "UIPanelButtonTemplate")
    local DeclineBtn = GR_GUI.Main.DeclineBtn
    DeclineBtn.FS = DeclineBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    local DeclineFS = DeclineBtn.FS
    DeclineFS:SetTextColor(.8,.8,.8, 1)
    DeclineFS:SetText("Decline")
    DeclineBtn:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton" and down == false) then 
          GR_GUI.Main.Accept:Hide()
          GR_GUI.Main.DeclineBtn:Hide()
          GR_GUI.Accept:Hide()
          GR:DeclineGameClicked()
        end
    end)
    
    Accept:Hide()
    DeclineBtn:Hide()
  end
  CreateGROpenAcceptBtns()
end

function GR:CreateSoloGames()
  local Main = GR_GUI.Main
  Main.Tab2 = CreateFrame("Frame", Tab2, Main)
  local Tab2 = Main.Tab2

  -- Nav
  Tab2.Nav = CreateFrame("Frame", Nav, Tab2)
  local Nav = Tab2.Nav
  Nav.MultiBtn = CreateFrame("Button", MultiBtn, Nav, "UIPanelButtonTemplate")
  local MultiBtn = Nav.MultiBtn
  MultiBtn.FS = MultiBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local MultiFS = MultiBtn.FS
  MultiFS:SetText("Multiplayer")
  MultiFS:SetTextColor(.8,.8,.8, 1)
  MultiBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.tab = 3
      GR:TabSelect()
    end
  end)
  Nav.SettingsBtn = CreateFrame("Button", SettingsBtn, Nav, "UIPanelButtonTemplate")
  local SettingsBtn = Nav.SettingsBtn
  SettingsBtn.FS = SettingsBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local SettingsFS = SettingsBtn.FS
  SettingsFS:SetText("Settings")
  SettingsFS:SetTextColor(.8,.8,.8, 1)
  SettingsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.db.realm.tab = 4
      GR:TabSelect()
    end
  end)
  
  -- Game Buttons
  Tab2.SoloGames = CreateFrame("Frame", SoloGames, Tab2)
  local SoloGames = Tab2.SoloGames
  SoloGames.AsteroidsBtn = CreateFrame("Button", AsteroidsBtn, SoloGames, "UIPanelButtonTemplate")
  local AsteroidsBtn = SoloGames.AsteroidsBtn
  AsteroidsBtn.FS = AsteroidsBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local AsteroidsFS = AsteroidsBtn.FS
  AsteroidsFS:SetTextColor(.8,.8,.8, 1)
  AsteroidsFS:SetText("Asteroids")
  AsteroidsBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR:AsteroidsShow()
    end
  end)
  SoloGames.SnakeBtn = CreateFrame("Button", SnakeBtn, SoloGames, "UIPanelButtonTemplate")
  local SnakeBtn = SoloGames.SnakeBtn
  SnakeBtn.FS = SnakeBtn:CreateFontString(nil, "OVERLAY", "GameTooltipText")
  local SnakeFS = SnakeBtn.FS
  SnakeFS:SetTextColor(.8,.8,.8, 1)
  SnakeFS:SetText("Snake")
  SnakeBtn:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      GR.GameType = "Snake"
      GR:ShowSoloGame()
    end
  end)

  Tab2:Hide()
end

-- Resize
function GR:ResizeMain()
  local Main = GR_GUI.Main

  -- Resize Main Ratios
  -- In Game
  if (GR.db.realm.tab == 1) then
    Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab1Width
    Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab1Height
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  -- Solo Games
  if (GR.db.realm.tab == 2) then
    Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab2Width 
    Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab2Height
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  -- Mutli Games
  if (GR.db.realm.tab == 3) then
    Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab3Width 
    Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab3Height
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  -- Settings
  if (GR.db.realm.tab == 4) then
    Main.XRatio = Main:GetWidth() / GR.Win.Const.Tab4Width 
    Main.YRatio = Main:GetHeight() / GR.Win.Const.Tab4Height
    Main.ScreenRatio = (Main.XRatio + Main.YRatio) / 2
  end
  

  GR:ResizeMainNoRatioChange()
end

function GR:ResizeMainNoRatioChange()
  -- resize FontStrings
  local Main = GR_GUI.Main
  local HeaderInfo = Main.HeaderInfo

  -- Main
  Main.ResizeBtn:SetPoint("BOTTOMRIGHT", -11 * Main.XRatio, 10 * Main.YRatio)
  Main.ResizeBtn:SetSize(16 * Main.XRatio, 16 * Main.YRatio)

  Main.H1:SetPoint("TOP", 0, -18 * Main.YRatio)
  Main.H1:SetTextScale(2.8 * Main.ScreenRatio)

  if (GR.db.realm.tab == 2 or GR.db.realm.tab == 3 or GR.db.realm.tab == 4) then
    Main.H2:SetPoint("TOP", 0, -105 * Main.YRatio)
  else
    Main.H2:SetPoint("TOP", 0, -65 * Main.YRatio)
  end
  Main.H2:SetTextScale(1.7 * Main.ScreenRatio)

  Main.xButton:SetSize(25 * Main.XRatio, 25 * Main.YRatio)
  Main.xButton:SetPoint("TOPRIGHT", -13 * Main.XRatio, -13 * Main.YRatio)

  -- Exit Button
  Main.ExitBtn:SetPoint("TOPRIGHT", -40 * Main.XRatio, -56 * Main.YRatio)
  Main.ExitBtn:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  Main.ExitBtn.FS:SetPoint("CENTER", 0, 0)
  Main.ExitBtn.FS:SetTextScale(1.1 * Main.ScreenRatio)
  
  GR:ResizeHeaderInfo()
  GR:ResizeSoloGames()
  GR:SizeMultiGames()
  GR:SizeSettings()
  GR:SizeAcceptDecline()
end

function GR:ResizeHeaderInfo()
  -- Frame
  local Main = GR_GUI.Main
  local HeaderInfo = GR_GUI.Main.HeaderInfo
  HeaderInfo:SetPoint("TOP", 0, -60 * Main.YRatio)
  HeaderInfo:SetSize(700 * Main.XRatio, 100 * Main.YRatio)
  
  -- Turn String
  local TurnString = HeaderInfo.TurnString
  TurnString:SetPoint("TOP", 0, 0 * Main.YRatio)
  TurnString:SetTextScale(2 * Main.ScreenRatio)

  -- Opponet String
  local Opp = HeaderInfo.OpponentString
  Opp:SetPoint("TOPLEFT", 0, -2 * Main.YRatio)
  Opp:SetTextScale(1.5 * Main.ScreenRatio)

  -- Reinvite Button
  local ReInvite = HeaderInfo.ReInvite
  ReInvite:SetPoint("TOPRIGHT", -130 * Main.XRatio, 7 * Main.YRatio)
  ReInvite:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local ReInviteFS = ReInvite.FS
  ReInviteFS:SetPoint("CENTER", 0, 0)
  ReInviteFS:SetTextScale(1.1 * Main.ScreenRatio)

  -- Rematch Button
  local ReMatch = HeaderInfo.ReMatch
  ReMatch:SetPoint("TOPRIGHT", -130 * Main.XRatio, 7 * Main.YRatio)
  ReMatch:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local ReMatchFS = ReMatch.FS
  ReMatchFS:SetPoint("CENTER", 0, 0)
  ReMatchFS:SetTextScale(1.1 * Main.ScreenRatio)

  -- Add Rival Button
  local Rival = HeaderInfo.Rival
  Rival:SetPoint("TOPLEFT", 0 * Main.XRatio, 7 * Main.YRatio)
  Rival:SetSize(100 * Main.XRatio, 30 * Main.YRatio)
  local RivalFS = Rival.FS
  RivalFS:SetPoint("CENTER", 0, 0)
  RivalFS:SetTextScale(1.1 * Main.ScreenRatio)
end

function GR:ResizeSoloGames()
  local Main = GR_GUI.Main
  local Tab2 = Main.Tab2
  Tab2:SetPoint("TOP", 0, -50 * Main.YRatio)
  Tab2:SetSize(250 * Main.XRatio, 200 * Main.YRatio)

  -- Nav
  local Nav = Tab2.Nav
  Nav:SetPoint("TOP", 0, 0)
  Nav:SetSize(240 * Main.XRatio, 40 * Main.YRatio)
  local MultiBtn = Nav.MultiBtn
  MultiBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -5 * Main.YRatio)
  MultiBtn:SetSize(110 * Main.XRatio, 30 * Main.YRatio)
  local MultiFS = MultiBtn.FS
  MultiFS:SetPoint("CENTER", 0, 0)
  MultiFS:SetTextScale(1.3 * Main.ScreenRatio)
  local SettingsBtn = Nav.SettingsBtn
  SettingsBtn:SetPoint("TOPRIGHT", -5 * Main.XRatio, -5 * Main.YRatio)
  SettingsBtn:SetSize(110 * Main.XRatio, 30 * Main.YRatio)
  local SettingsFS = SettingsBtn.FS
  SettingsFS:SetPoint("CENTER", 0, 0)
  SettingsFS:SetTextScale(1.3 * Main.ScreenRatio)

  -- Game Buttons
  local SoloGames = Tab2.SoloGames
  SoloGames:SetPoint("TOP", 0 * Main.XRatio, -75 * Main.YRatio)
  SoloGames:SetSize(250 * Main.XRatio, 100 * Main.YRatio)
  local AsteroidsBtn = SoloGames.AsteroidsBtn
  AsteroidsBtn:SetPoint("TOPLEFT", 5 * Main.XRatio, -5 * Main.YRatio)
  AsteroidsBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local AsteroidsFS = AsteroidsBtn.FS
  AsteroidsFS:SetPoint("CENTER", 0, 0)
  AsteroidsFS:SetTextScale(1.4 * Main.ScreenRatio)
  local SnakeBtn = SoloGames.SnakeBtn
  SnakeBtn:SetPoint("TOPRIGHT", -5 * Main.XRatio, -5 * Main.YRatio)
  SnakeBtn:SetSize(120 * Main.XRatio, 30 * Main.YRatio)
  local SnakeFS = SnakeBtn.FS
  SnakeFS:SetPoint("CENTER", 0, 0)
  SnakeFS:SetTextScale(1.4 * Main.ScreenRatio)
end

function GR:SizeAcceptDecline()
  -- Accept Button
  local Main = GR_GUI.Main
  local Accept = GR_GUI.Main.Accept
  Accept:SetPoint("BOTTOMLEFT", 13 * Main.XRatio, 14 * Main.YRatio)
  Accept:SetSize(210 * Main.XRatio, 55 * Main.YRatio)
  local AcceptFS = Accept.FS
  AcceptFS:SetPoint("TOP", 0, -11 * Main.YRatio)
  AcceptFS:SetTextScale(1.5 * Main.ScreenRatio)
  local AcceptFS2 = Accept.FS2
  AcceptFS2:SetPoint("BOTTOM", 0, 10 * Main.YRatio)
  AcceptFS2:SetTextScale(1.3 * Main.ScreenRatio)
  
  -- Decline Button
  local DeclineBtn = GR_GUI.Main.DeclineBtn
  DeclineBtn:SetPoint("BOTTOMRIGHT", -25 * Main.XRatio, 14 * Main.YRatio)
  DeclineBtn:SetSize(50 * Main.XRatio, 25 * Main.YRatio)
  local DeclineFS = DeclineBtn.FS
  DeclineFS:SetPoint("CENTER", 0, 0)
  DeclineFS:SetTextScale(1.1  * Main.ScreenRatio)
end

-- Functionality
function GR:TabSelect()
  local Main = GR_GUI.Main
  local tab = GR.db.realm.tab
  local point, relativeTo, relativePoint, xOfs, yOfs = Main:GetPoint()
  
  Main.Tab2:Hide()
  Main.Tab3:Hide()
  Main.Tab4:Hide() 
  Main.HeaderInfo:Hide() 
  Main.Asteroids:Hide() 
  Main.Tictactoe:Hide() 
  Main.Battleships:Hide()

  local function CheckWidthHeight(Width, Height)
    local Change = false
    if (Width > UIParent:GetWidth()) then
      Width = UIParent:GetWidth() - 100
      Change = true
    end
    if (Width < 150) then
      Width = 150
      Change = true
    end
    if (Height > UIParent:GetHeight()) then
      Height = UIParent:GetHeight() - 100
      Change = true
    end
    if (Height < 150) then
      Height = 150
      Change = true
    end

    return Width, Height, Change
  end
  
  -- In Game
  if (tab == 1) then
    local Width, Height, Change = CheckWidthHeight(GR.Win.Const.Tab1Width * Main.XRatio, GR.Win.Const.Tab1Height * Main.YRatio)

    Main:SetSize(Width, Height)
    Main:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)

    if (Change) then
      GR:ResizeMain()
    else
      GR:ResizeMainNoRatioChange()
    end
    
    if (GR.GameType == "Asteroids") then
      Main.Asteroids:Show()
      GR:SizeAsteroids()
    end
    if (GR.GameType == "Snake") then
      GR:SnakeShow()
    end
    if (GR.GameType == "Tictactoe") then
      GR:TictactoeShow()
    end
    if (GR.GameType == "Battleships") then
      GR:BattleshipsShow()
    end
  end
  -- Solo Games
  if (tab == 2) then
    local Width, Height, Change = CheckWidthHeight(GR.Win.Const.Tab2Width * Main.XRatio, GR.Win.Const.Tab2Height * Main.YRatio)

    Main:SetSize(Width, Height)
    if (point == nil) then
    else
      Main:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    end

    if (Change) then
      GR:ResizeMain()
    else
      GR:ResizeMainNoRatioChange()
    end

    Main.Tab2:Show()
    Main.H2:SetText("Single Player Games")
  end
  -- Multiplayer Games
  if (tab == 3) then
    local Width, Height, Change = CheckWidthHeight(GR.Win.Const.Tab3Width * Main.XRatio, GR.Win.Const.Tab3Height * Main.YRatio)

    Main:SetSize(Width, Height)
    Main:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    
    if (Change) then
      GR:ResizeMain()
    else
      GR:ResizeMainNoRatioChange()
    end

    Main.Tab3:Show()
    Main.Tab3.Invite:Hide()
    Main.Tab3.Invite.Tab:Hide()
    Main.Tab3.Invite.SendBtn:Hide()
    Main.H2:SetText("Multi-Player Games")
  end
  -- Settings
  if (tab == 4) then
    local Width, Height, Change = CheckWidthHeight(GR.Win.Const.Tab4Width * Main.XRatio, GR.Win.Const.Tab4Height * Main.YRatio)

    Main:SetSize(Width, Height)
    Main:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    
    if (Change) then
      GR:ResizeMain()
    else
      GR:ResizeMainNoRatioChange()
    end

    Main.Tab4:Show()
    Main.H2:SetText("Settings")
  end
end

function GR:SetTurnString()
    local TurnString = GR_GUI.Main.HeaderInfo.TurnString
    if (GR.GameOver == false) then
        if (GR.IsPlayerTurn) then
            TurnString:SetTextColor(0,1,0,1)
            TurnString:SetText(UnitName("player"))
        else
            TurnString:SetTextColor(1,0,0,1)
            TurnString:SetText(GR.Opponent)
        end
    end
end

function GR:ShowRivalsBtn() 
    local InRivals = false
    for i,v in ipairs(GR.db.realm.Rivals) do
        if (string.match(v, GR.Opponent)) then
            InRivals = true
        end
    end
    if (InRivals == false) then
        GR_GUI.Main.HeaderInfo.Rival:Show()
    end
end

function GR:ExitGameClicked()
  if (GR.GameType == "Tictactoe") then
    if (GR.UseGroupChat) then 
      GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_GameEnd", "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_GameEnd", "WHISPER", GR.Opponent)
    end
    GR:TicTacToeHideContent()
  end
  if (GR.GameType == "Battleships") then
    if (GR.UseGroupChat) then 
      GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_GameEnd", "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_GameEnd", "WHISPER", GR.Opponent)
    end
    GR:BattleshipsHideContent()
  end
  if (GR.GameType == "Asteroids") then
    GR:AsteroidsHide()    
  end
  if (GR.GameType == "Snake") then
    GR:SnakeHide()    
  end
  GR.GameType = nil
  GR.db.realm.tab = 2
  GR:TabSelect()
end

function GR:AcceptGameClicked()
  local ChatChannel
  if (GR.GroupType == "PART") then ChatChannel = "PARTY" end
  if (GR.GroupType == "RAID") then ChatChannel = "RAID" end

  GR.PlayerPos = random(1,2)
  if (GR.PlayerPos == 2) then
    GR.IsPlayerTurn = false
  else
    GR.IsPlayerTurn = true
  end
  GR.Target = GR.Opponent
  
  -- send message to show other user board
  if (GR.IncGameType == "Tictactoe") then
    if (GR.GroupType == nil) then
      GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Accept, " .. GR.PlayerPos .. ", " .. UnitName("Player"), "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Accept, " .. GR.GroupType .. GR.PlayerPos .. ", " .. UnitName("Player"), ChatChannel)
      GR.GroupType = ChatChannel
      GR.UseGroupChat = true
    end
    GR.GameType = "Tictactoe"
    GR.db.realm.tab = 1
    GR:TabSelect()
    end
  if (GR.IncGameType == "Battleships") then
    if (GR.GroupType == nil) then
      GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Accept, " .. GR.PlayerPos .. ", " .. UnitName("Player"), "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Accept, " .. GR.GroupType .. GR.PlayerPos  .. UnitName("Player"), ChatChannel)
      GR.GroupType = ChatChannel
      GR.UseGroupChat = true
    end
    GR.GameType = "Battleships"
    GR.db.realm.tab = 1
    GR:TabSelect()
  end
end

function GR:DeclineGameClicked()
  local ChatChannel
  if (GR.GroupType == "PART") then ChatChannel = "PARTY" end
  if (GR.GroupType == "RAID") then ChatChannel = "RAID" end

  GR.IsChallenged = false
  
  -- send decline game message
  if (GR.GameType == "Tictactoe") then
    if (GR.GroupType == nil) then
      GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Decline, ", "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_Decline, " .. GR.Opponent, ChatChannel)
    end
  end 
  if (GR.GameType == "Battleships") then
    if (GR.GroupType == nil) then
      GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Decline, ", "WHISPER", GR.Opponent)
    else
      GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_Decline, " .. GR.Opponent, ChatChannel)
    end
  end 
  GR.Opponent = nil
end

-- Show/Hide Game
function GR:ShowGame()
  GR.InGame = true

  GR_GUI.Main.HeaderInfo:Show()
  GR_GUI.Main.HeaderInfo.OpponentString:Show()
  GR_GUI.Main.HeaderInfo.TurnString:Show()
  GR_GUI.Main.ExitBtn:Show()
  
  GR_GUI.Accept:Hide()
  GR_GUI.Main.HeaderInfo.ReInvite:Hide()
  GR_GUI.Main.HeaderInfo.ReMatch:Hide()
  GR_GUI.Main.HeaderInfo.Rival:Hide()
  GR_GUI.Main.Register:Hide()
  
  if (GR.Opponent) then 
    GR_GUI.Main.HeaderInfo.OpponentString:SetText("Opponent: " .. GR.Opponent)
  end
  GR:SetTurnString()
end
  
function GR:ShowSoloGame()
  GR.InGame = true
  GR_GUI.Accept:Hide()
  
  GR_GUI.Main.ExitBtn:Show()
  GR_GUI.Main.H2:SetText(GR.GameType)

  GR.db.realm.tab = 1
  GR:TabSelect()
end

function GR:HideGame()
  GR.PlayerPos = nil
  GR.IsPlayerTurn = nil
  GR.InGame = false
  GR.GameOver = false
  GR.db.realm.tab = 2
  GR.CanSendInvite = true
  GR.IsChallenged = false
  GR.Opponent = nil
  GR_GUI.Main.HeaderInfo:Hide()
  GR_GUI.Main.ExitBtn:Hide()
  GR_GUI.Main.Register:Show()

  GR:TabSelect()
end

-- Show/Hide Main
function GR:OpenClose(input)
  if (GR_GUI.Main:IsVisible()) then 
      --GR:HideMain()
      GR_GUI.Main:Hide()
  else
      GR:ShowMain()
  end
end

function GR:HideMain()
  if (GR.GameType == "Tictactoe" and GR.InGame) then
      GR:SendCommMessage("ZUI_GameRoom_Inv", "TicTacToe_GameEnd", "WHISPER", GR.Opponent)
      GR:TicTacToeHideContent()
  end
  if (GR.GameType == "Battleships" and GR.InGame) then
      GR:SendCommMessage("ZUI_GameRoom_Inv", "Battleships_GameEnd", "WHISPER", GR.Opponent)
      GR:BattleshipsHideContent()
  end
  GR_GUI.Main:Hide() 
  GR.GameType = nil
end

function GR:ShowMain()
  GR_GUI.Main:Show() 

  if (GR:CheckOutOfBoundsRects(GR_GUI.Main, UIParent)) then
    Main:SetPoint("TOPLEFT", UIParent, "TOPLEFT", UIParent:GetWidth() / 2 - GR.Win.Const.Tab2Width / 2, -130)
  end

  -- if main is bigger than screen, reset main size
  if (GR_GUI.Main:GetHeight() > UIParent:GetHeight() or GR_GUI.Main:GetWidth() > UIParent:GetWidth()) then
      GR_GUI.Main:SetSize(GR.Tab2Width, GR.Tab2Width)
  end
  GR:ResizeMain()
  GR:ShowChalOnInvite() 
end

-- Extra
function GR:CheckOutOfBoundsRects(Rect1, Rect2)
    local Rect1X, Rect1Y, Rect1Width, Rect1Height = Rect1:GetRect()
    local Rect2X, Rect2Y, Rect2Width, Rect2Height = Rect2:GetRect()
    -- out of bounds check. rect1 is fully out of rect2
    if (Rect1X > Rect2X + Rect2Width or Rect1X + Rect1Width < Rect2X or Rect1Y > Rect2Y + Rect2Height or Rect1Y + Rect1Height < Rect2Y) then
        return true
    end
    return false
end

function ScrollFrame_OnMouseWheel(self, delta)
  local newValue = self:GetVerticalScroll() - (delta * 20);
 
  if (newValue < 0) then
    newValue = 0;
  elseif (newValue > self:GetVerticalScrollRange()) then
    newValue = self:GetVerticalScrollRange();
  end
 
  self:SetVerticalScroll(newValue);
end

-- BUGS
-- exit game needs to close game
-- tictactoe needs to do cross-server
-- fix cross-server battlenet registers
-- refresh raid/party needs to fix
-- fix asteroids show
-- fix show / hide game funcitons
-- fix show / hide main fucntions

-- Testing

-- Commenting

-- Re-Release

-- GAMES
-- chess
-- flappy bird
-- pin-ball macheine

-- FUNCTIONS
-- rematch button
-- look into retail custom chat channel addon comms

-- highlight selected opponent on multiplayer invite scroll
