function GR:CreateBouncyChicken()
  -- Constants
  GR.BC = {}
  GR.BC.Const = {}
  GR.BC.Const.WallStartInt = 1.8
  GR.BC.Const.WallSpeed = 170
  GR.BC.Const.WallWidth = 80
  GR.BC.Const.WallHeight = 180
  GR.BC.Const.WallYPosOptions = { -120, -58, 4, 66, 128, 190, 252, 314, 376, 438 }
  GR.BC.Const.ChickenXPos = 100
  GR.BC.Const.ChickenYStart = 250
  GR.BC.Const.ChickenWidth = 50
  GR.BC.Const.ChickenHeight = 50
  GR.BC.Const.ChickenGravity = -9
  GR.BC.Const.ChickenMinVelY = -4.4
  GR.BC.Const.ChickenMaxVelY = 4.2
  
  -- Bouncy Chicken Frame
  GR_GUI.Main.BC = CreateFrame("Frame", BouncyChicken, GR_GUI.Main, "ThinBorderTemplate")
  local BC = GR_GUI.Main.BC
  BC:SetPoint("BOTTOM", 0, 25 * (GR_GUI.Main:GetHeight() / GR.Win.Const.Tab1Height))
  BC:SetSize(GR_GUI.Main:GetWidth() * (GR.Win.Const.GameScreenWidth / GR.Win.Const.Tab1Width), GR_GUI.Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  BC:SetClipsChildren(true)
  BC:Hide()
  
  -- Variables
  GR.BC.XRatio = BC:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.BC.YRatio = BC:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.BC.ScreenRatio = (BC:GetWidth() / GR.Win.Const.GameScreenWidth + BC:GetHeight() / GR.Win.Const.GameScreenHeight) / 2
  GR.BC.ActiveState = "Stop"
  GR.BC.GameTime = 0
  GR.BC.Points = 0
  GR.BC.WallSpeed = GR.BC.Const.WallSpeed
  GR.BC.WallWidth = GR.BC.Const.WallWidth * GR.BC.XRatio
  GR.BC.WallHeight = GR.BC.Const.WallHeight * GR.BC.YRatio
  GR.BC.WallStartX = BC:GetWidth() * 1.1
  GR.BC.WallEndX = BC:GetWidth() * -.15
  GR.BC.WallYPosOptions = {}
  for i,v in pairs(GR.BC.Const.WallYPosOptions) do
    GR.BC.WallYPosOptions[i] = v * GR.BC.YRatio
  end
  GR.BC.ChickenXPos = GR.BC.Const.ChickenXPos * GR.BC.XRatio
  GR.BC.ChickenYStart = GR.BC.Const.ChickenYStart * GR.BC.YRatio
  GR.BC.ChickenWidth = GR.BC.Const.ChickenWidth * GR.BC.XRatio
  GR.BC.ChickenHeight = GR.BC.Const.ChickenHeight * GR.BC.YRatio
  GR.BC.ChickenGravity = GR.BC.Const.ChickenGravity * GR.BC.YRatio
  GR.BC.ChickenMinVelY = GR.BC.Const.ChickenMinVelY * GR.BC.YRatio 
  GR.BC.ChickenMaxVelY = GR.BC.Const.ChickenMaxVelY * GR.BC.YRatio 

  -- Create
  GR:CreateBCGameLoop()
  GR:ControlsBC()
  GR:CreateBCActiveStatusBtns()
  GR:CreateBCInfo()
  GR:CreateBCWalls()
  GR:CreateBCChicken()
end

function GR:CreateBCGameLoop()
  local BC = GR_GUI.Main.BC

  -- Game Loop
  BC.Game = CreateFrame("Frame", Game, BC)
  local Game = BC.Game
  Game:SetScript("OnUpdate", function(self, elapsed)
    GR:UpdateBC(self, elapsed)
  end)
  Game:Hide()
end

function GR:CreateBCActiveStatusBtns()
  local Main = GR_GUI.Main
  local BC = GR_GUI.Main.BC

  -- Start / Unpause
  BC.Start = CreateFrame("Button", Start, Main)
  BC.Start.Line1 = BC.Start:CreateLine()
  BC.Start.Line1:SetColorTexture(0,1,0, 1)
  BC.Start.Line2 = BC.Start:CreateLine()
  BC.Start.Line2:SetColorTexture(0,1,0, 1)
  BC.Start.Line3 = BC.Start:CreateLine()
  BC.Start.Line3:SetColorTexture(0,1,0, 1)
  BC.Start:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      if (GR.BC.ActiveState == "Stop" or GR.BC.ActiveState == "Start") then
        GR.BC.ActiveState = "Start"
        GR.BCStart()
      end
      if (GR.BC.ActiveState == "Pause") then
        GR.BC.ActiveState = "Start"
        GR.BCUnpause()
      end
    end
  end)
  
  -- Stop
  BC.Stopx = CreateFrame("Button", Stopx, Main)
  BC.Stopx.Tex = BC.Stopx:CreateTexture()
  BC.Stopx.Tex:SetColorTexture(1,0,0, 1)
  BC.Stopx.Tex:SetPoint("CENTER")
  BC.Stopx:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      BC.ActiveState = "Stop"
      GR:BCStop()
    end
  end)
  BC.Stopx:Hide()
  
  -- Pause
  BC.Pausex = CreateFrame("Button", Pausex, Main)
  BC.Pausex.Tex1 = BC.Pausex:CreateTexture()
  BC.Pausex.Tex1:SetColorTexture(1,1,0, 1)
  BC.Pausex.Tex2 = BC.Pausex:CreateTexture()
  BC.Pausex.Tex2:SetColorTexture(1,1,0, 1)
  BC.Pausex:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      BC.ActiveState = "Pause"
      GR:BCPause()
    end
  end)
  BC.Pausex:Hide()
end

function GR:CreateBCInfo()
  local Main = GR_GUI.Main
  local BC = GR_GUI.Main.BC

  -- Timer
  BC.Timer = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.Timer:SetText(GR.BC.GameTime)
  BC.Timer:SetTextColor(.8,.8,.8, 1)

  -- Points
  BC.PointsFS = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.PointsFS:SetText(GR.BC.Points)
  BC.PointsFS:SetTextColor(.8,.8,.8, 1)

  -- GameOver
  BC.GameOverFS = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.GameOverFS:SetText("Game Over")
  BC.GameOverFS:SetTextColor(.8,0,0, 1)
  BC.GameOverFS:Hide()

  -- Controls Info
  BC.Info = Main:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  BC.Info:SetText("Bounce: Space, W, Up-Arrow")
  BC.Info:SetTextColor(.8,.8,.8, 1)
end

function GR:CreateBCWalls()
  local BC = GR_GUI.Main.BC
  BC.Walls = {}
  local Walls = BC.Walls

  for i = 1, 3, 1 do
    Walls[i] = CreateFrame("Frame", nil, BC)
    local Wall = Walls[i]
    Wall:SetPoint("BOTTOMLEFT")
    Wall.Tex = Wall:CreateTexture()
    Wall.Tex:SetColorTexture(1, 0, 1, 1)
    Wall.Tex:SetAllPoints(Wall)
    Wall:Hide()
  end
end

function GR:CreateBCChicken()
  local BC = GR_GUI.Main.BC

  BC.Chicken = CreateFrame("Frame", Chicken, BC)
  local Chicken = BC.Chicken
  BC.Chicken.VelY = 0
  BC.Chicken.YPos = GR.BC.ChickenYStart
  Chicken.Tex = Chicken:CreateTexture()
  Chicken.Tex:SetAllPoints(Chicken)
  Chicken.Tex:SetColorTexture(1, .6, .2, 1)
  Chicken:Hide()
end

-- Size
function GR:SizeBC()
  local Main = GR_GUI.Main
  local BC = GR_GUI.Main.BC

  -- Game Screen
  BC:SetPoint("BOTTOM", 0, 25 * (Main:GetHeight() / GR.Win.Const.Tab1Height))
  BC:SetSize(Main:GetWidth() * (GR.Win.Const.GameScreenWidth / GR.Win.Const.Tab1Width), Main:GetHeight() * (GR.Win.Const.GameScreenHeight / GR.Win.Const.Tab1Height))
  GR.BC.XRatio = BC:GetWidth() / GR.Win.Const.GameScreenWidth
  GR.BC.YRatio = BC:GetHeight() / GR.Win.Const.GameScreenHeight
  GR.BC.ScreenRatio = (BC:GetWidth() / GR.Win.Const.GameScreenWidth + BC:GetHeight() / GR.Win.Const.GameScreenHeight) / 2

  GR:SizeBCActiveStatusBtns()
  GR:SizeBCInfo()
  GR:SizeBCWalls()
  GR:SizeBCChicken()
end

function GR:SizeBCActiveStatusBtns()
  local BC = GR_GUI.Main.BC
  local XRatio = GR.BC.XRatio
  local YRatio = GR.BC.YRatio
  local ScreenRatio = GR.BC.ScreenRatio
  
  -- Start
  BC.Start:SetPoint("TOPLEFT", BC, 50 * XRatio, 34 * YRatio)
  BC.Start:SetSize(30 * XRatio, 30 * YRatio)
  BC.Start.Line1:SetStartPoint("CENTER", -8 * XRatio, 8 * YRatio)
  BC.Start.Line1:SetEndPoint("CENTER", 8 * XRatio, 0)
  BC.Start.Line1:SetThickness(3 * ScreenRatio)
  BC.Start.Line2:SetStartPoint("CENTER", -8 * XRatio, -8 * YRatio)
  BC.Start.Line2:SetEndPoint("CENTER", 8 * XRatio, 0)
  BC.Start.Line2:SetThickness(3 * ScreenRatio)
  BC.Start.Line3:SetStartPoint("CENTER", -8 * XRatio, -8 * YRatio)
  BC.Start.Line3:SetEndPoint("CENTER", -8 * XRatio, 8 * YRatio)
  BC.Start.Line3:SetThickness(3 * ScreenRatio)

  -- Stop
  BC.Stopx:SetPoint("TOPLEFT", BC, 83 * XRatio, 34 * YRatio)
  BC.Stopx:SetSize(30 * XRatio, 30 * YRatio)
  BC.Stopx.Tex:SetSize(15 * XRatio, 15 * YRatio)
  
  -- Unpause
  BC.Pausex:SetPoint("TOPLEFT", BC, 50 * XRatio, 34 * YRatio)
  BC.Pausex:SetSize(30 * XRatio, 30 * YRatio)
  BC.Pausex.Tex1:SetSize(6 * XRatio, 15 * YRatio)
  BC.Pausex.Tex1:SetPoint("CENTER", -6 * XRatio, 0)
  BC.Pausex.Tex2:SetSize(6 * XRatio, 15 * YRatio)
  BC.Pausex.Tex2:SetPoint("CENTER", 6 * XRatio, 0)
end

function GR:SizeBCInfo()
  local BC = GR_GUI.Main.BC
  
  -- Timer
  BC.Timer:SetPoint("BOTTOMLEFT", BC, "TOPRIGHT", -220 * GR.BC.XRatio, 6 * GR.BC.YRatio)
  BC.Timer:SetTextScale(2 * GR.BC.ScreenRatio)
  
  -- Points
  BC.PointsFS:SetPoint("BOTTOMLEFT", BC, "TOPLEFT", 160 * GR.BC.XRatio, 6 * GR.BC.YRatio)
  BC.PointsFS:SetTextScale(2 * GR.BC.ScreenRatio)
  
  -- Game Over
  BC.GameOverFS:SetPoint("TOP", 0, -80 * GR.BC.YRatio)
  BC.GameOverFS:SetTextScale(3.7 * GR.BC.ScreenRatio)
  
  -- Controls Info
  BC.Info:SetPoint("TOP", BC, "TOPLEFT", 100 * GR.BC.XRatio, 57 * GR.BC.YRatio)
  BC.Info:SetTextScale(1 * GR.BC.ScreenRatio)
end

function GR:SizeBCWalls()
  local BC = GR_GUI.Main.BC
  local Walls = GR_GUI.Main.BC.Walls

  -- Variables
  GR.BC.WallSpeed = GR.BC.Const.WallSpeed * GR.BC.XRatio
  GR.BC.WallWidth = GR.BC.Const.WallWidth * GR.BC.XRatio
  GR.BC.WallHeight = GR.BC.Const.WallHeight * GR.BC.YRatio
  GR.BC.WallStartX = BC:GetWidth() * 1.1
  GR.BC.WallEndX = BC:GetWidth() * -.15
  for i,v in pairs(GR.BC.Const.WallYPosOptions) do
    GR.BC.WallYPosOptions[i] = v * GR.BC.YRatio
  end

  for i = 1, #Walls, 1 do
    local Wall = Walls[i]
    Wall:SetSize(GR.BC.WallWidth, GR.BC.WallHeight)
  end
end

function GR:SizeBCChicken()
  local BC = GR_GUI.Main.BC
  local Chicken = GR_GUI.Main.BC.Chicken

  GR.BC.ChickenMinVelY = GR.BC.Const.ChickenMinVelY * GR.BC.YRatio 
  GR.BC.ChickenMaxVelY = GR.BC.Const.ChickenMaxVelY * GR.BC.YRatio 
  GR.BC.ChickenGravity = GR.BC.Const.ChickenGravity * GR.BC.YRatio
  GR.BC.ChickenWidth = GR.BC.Const.ChickenWidth * GR.BC.XRatio
  GR.BC.ChickenHeight = GR.BC.Const.ChickenHeight * GR.BC.YRatio
  GR.BC.ChickenXPos = GR.BC.Const.ChickenXPos * GR.BC.XRatio
  GR.BC.ChickenYStart = GR.BC.Const.ChickenYStart * GR.BC.YRatio
  Chicken:SetPoint("BOTTOMLEFT", GR.BC.ChickenXPos, Chicken.YPos)
  Chicken:SetSize(GR.BC.ChickenWidth, GR.BC.ChickenHeight)
end

-- Update
function GR:UpdateBC(self, elapsed)
  local BC = GR_GUI.Main.BC

  GR.BC.GameTime = GR.BC.GameTime + elapsed

  BC.Timer:SetText(math.floor(GR.BC.GameTime * 100) / 100)

  GR:UpdateBCWalls(self, elapsed)
  GR:UpdateBCChicken(self, elapsed)
end

function GR:UpdateBCWalls(self, elapsed)
  local BC = GR_GUI.Main.BC
  local Walls = BC.Walls

  for i = 1, #Walls, 1 do
    if (Walls[i]:IsShown()) then
      local Wall = Walls[i]

      if (Wall.XPos < GR.BC.WallEndX) then
        Wall.YPos = GR.BC.WallYPosOptions[math.random(1,#GR.BC.Const.WallYPosOptions)]
        Wall.XPos = GR.BC.WallStartX
        Wall:SetPoint("BOTTOMLEFT", Wall.XPos, Wall.YPos)
      else
        Wall.XPos = Wall.XPos - elapsed * GR.BC.WallSpeed
        Wall:SetPoint("BOTTOMLEFT", Wall.XPos, Wall.YPos)
      end
    end
  end
end

function GR:UpdateBCChicken(self, elapsed)
  local BC = GR_GUI.Main.BC
  local Chicken = GR_GUI.Main.BC.Chicken

  Chicken.VelY = Chicken.VelY + (GR.BC.ChickenGravity * elapsed)
  if (Chicken.VelY <= GR.BC.ChickenMinVelY) then
    Chicken.VelY = GR.BC.ChickenMinVelY
  end

  if (Chicken.PosY == nil) then Chicken.PosY = GR.BC.ChickenYStart end
  Chicken.PosY = Chicken.PosY + Chicken.VelY
  Chicken:SetPoint("BOTTOMLEFT", GR.BC.ChickenXPos, Chicken.PosY)

end

-- Controls
function GR:ControlsBC()
  local Game = GR_GUI.Main.BC.Game

  Game:SetScript("OnKeyDown", function(self, key)
    if (key == "SPACE" or Key == "W" or Key == "UP") then 
      GR:BCBounce()
    end
  end)
end

-- Functions
function GR:BCBounce()
  GR_GUI.Main.BC.Chicken.VelY = GR.BC.ChickenMaxVelY
end

function GR:BCStartMovingWalls()
  local Walls = GR_GUI.Main.BC.Walls

  -- Scale WallYPosOptions for first render
  for i,v in pairs(GR.BC.Const.WallYPosOptions) do
    GR.BC.WallYPosOptions[i] = v * GR.BC.YRatio
  end

  -- Position Walls
  for i = 1, #Walls, 1 do
    Walls[i].XPos = GR.BC.WallStartX
    Walls[i].YPos = GR.BC.WallYPosOptions[math.random(1,#GR.BC.Const.WallYPosOptions)]
  end

  -- Cancel Old Wall Timers
  if (GR.BC.WallTimer1) then
    GR.BC.WallTimer1:Cancel()
    GR.BC.WallTimer2:Cancel()
  end

  -- Show First Wall
  Walls[1]:Show()
  
  -- Show Second Wall
  GR.BC.WallTimer1 = C_Timer.NewTimer(GR.BC.Const.WallStartInt, function()
    Walls[2]:Show()
  end)
  
  -- Show Third Wall 
  GR.BC.WallTimer2 = C_Timer.NewTimer(GR.BC.Const.WallStartInt * 2, function()
    Walls[3]:Show()
  end)
end

-- Hide Show
function GR:BCHide()
  local BC = GR_GUI.Main.BC
  
  GR:BCStop()

  BC:Hide()
end

function GR:BCShow()
  local BC = GR_GUI.Main.BC

  GR:SizeBC()

  BC:Show()
end

-- Start Stop Pause Unpause
function GR:BCStart()
  local BC = GR_GUI.Main.BC

  -- Reset Variables
  GR.BC.GameTime = 0
  GR.BC.Points = 0
  GR.BC.WallSpeed = GR.BC.Const.WallSpeed * GR.BC.XRatio
  BC.Chicken.VelY = 0
  BC.Chicken.YPos = GR.BC.ChickenYStart

  -- Start Game
  BC.Game:Show()
  BC.Chicken:Show()
  BC.Chicken.PosY = GR.BC.ChickenYStart
  BC.Chicken.VelY = 0
  GR:BCStartMovingWalls()
  
  -- Show Game Info and Buttons
  GR.BC.ActiveState = "Start"
  BC.PointsFS:SetText(GR.BC.Points)
  BC.Stopx:Show()
  BC.Pausex:Show()
  BC.Start:Hide()
  BC.GameOverFS:Hide()
end

function GR:BCStop()
  local BC = GR_GUI.Main.BC
  local Walls = BC.Walls

  for i = 1, #Walls, 1 do
    Walls[i]:Hide()
  end
  BC.Chicken:Hide()

  GR.BC.ActiveState = "Stop"
  BC.Game:Hide()
  BC.Start:Show()
  BC.Pausex:Hide()
  BC.Stopx:Hide()
end

function GR:BCPause()
  local BC = GR_GUI.Main.BC

  GR.BC.ActiveState = "Pause"
  BC.Start:Show()
  BC.Pausex:Hide()
  BC.Stopx:Hide()

  BC.Game:Hide()
end

function GR:BCUnpause()
  local BC = GR_GUI.Main.BC

  GR.BC.ActiveState = "Start"
  BC.Start:Hide()
  BC.Pausex:Show()
  BC.Stopx:Show()

  BC.Game:Show()
end

function GR:BCGameOver()
  GR:BCStop()

  GR_GUI.Main.BC.GameOverFS:Show()
end
