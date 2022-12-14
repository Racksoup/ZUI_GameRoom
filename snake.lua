-- Create
function GR:CreateSnake()
  local Main = GR_GUI.Main

  -- Constants
  GR.Snake = {}
  GR.Snake.Const = {}
  GR.Snake.Const.Width = 720 
  GR.Snake.Const.Height = 395
  GR.Snake.Const.NumOfCols = 60
  GR.Snake.Const.NumOfRows = 30
  GR.Snake.Const.MoveInterval = .11

  -- Snake Frame
  Main.Snake = CreateFrame("Frame", Snake, Main, "ThinBorderTemplate")
  local Snake = Main.Snake
  Snake:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Snake:SetSize(GR.Snake.Const.Width * Main.XRatio, GR.Snake.Const.Height * Main.YRatio)
  Snake:Hide()

  -- Variables
  Snake.XRatio = Snake:GetWidth() / GR.Snake.Const.Width
  Snake.YRatio = Snake:GetHeight() / GR.Snake.Const.Height
  Snake.ScreenRatio = ((Snake:GetWidth() / GR.Snake.Const.Width) + (Snake:GetHeight() / GR.Snake.Const.Height)) / 2
  Snake.Pos = {
    X = math.floor(GR.Snake.Const.NumOfCols / 2),
    Y = math.floor(GR.Snake.Const.NumOfRows / 2),
  }
  Snake.Dir = "Up"
  Snake.LastDir = "Down"
  Snake.GameTime = 0
  Snake.MoveInterval = GR.Snake.Const.MoveInterval
  Snake.MoveTick = 0
  Snake.Tail = {}
  Snake.TailLength = 0
  Snake.Points = 0
  Snake.OnState = "Stop"


  -- Create
  GR:CreateSnakeGameLoop()
  GR:CreateSnakeStartStop()
  GR:CreateSnakeTimer()
  GR:CreateSnakeGrid()
  GR:CreateSnakeApple()

  -- Size
  GR:SnakeSize()
end

function GR:CreateSnakeGameLoop()
  local Snake = GR_GUI.Main.Snake

  Snake.Game = CreateFrame("Frame", Game, Snake)
  Snake.Game:SetScript("OnUpdate", function(self, elapsed) GR:SnakeUpdate(self, elapsed) end)
  Snake.Game:Hide()

  GR:SnakeControls()
end

function GR:CreateSnakeStartStop()
  local Snake = GR_GUI.Main.Snake

  Snake.Start = CreateFrame("Button", Start, Snake)
  Snake.Start.Line1 = Snake.Start:CreateLine()
  Snake.Start.Line1:SetColorTexture(0,1,0, 1)
  Snake.Start.Line2 = Snake.Start:CreateLine()
  Snake.Start.Line2:SetColorTexture(0,1,0, 1)
  Snake.Start.Line3 = Snake.Start:CreateLine()
  Snake.Start.Line3:SetColorTexture(0,1,0, 1)
  Snake.Start:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      if (Snake.OnState == "Stop" or Snake.OnState == "Start") then
        Snake.OnState = "Start"
        GR.SnakeStart()
      end
      if (Snake.OnState == "Pause") then
        Snake.OnState = "Start"
        GR.SnakeUnpause()
      end
    end
  end)

  Snake.Stopx = CreateFrame("Button", Stopx, Snake)
  Snake.Stopx.Tex = Snake.Stopx:CreateTexture()
  Snake.Stopx.Tex:SetColorTexture(1,0,0, 1)
  Snake.Stopx.Tex:SetPoint("CENTER")
  Snake.Stopx:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      Snake.OnState = "Stop"
      GR:SnakeStop()
    end
  end)
  Snake.Stopx:Hide()

  Snake.Pausex = CreateFrame("Button", Pausex, Snake)
  Snake.Pausex.Tex1 = Snake.Pausex:CreateTexture()
  Snake.Pausex.Tex1:SetColorTexture(1,1,0, 1)
  Snake.Pausex.Tex2 = Snake.Pausex:CreateTexture()
  Snake.Pausex.Tex2:SetColorTexture(1,1,0, 1)
  Snake.Pausex:SetScript("OnClick", function(self, button, down) 
    if (button == "LeftButton" and down == false) then
      Snake.OnState = "Pause"
      GR:SnakePause()
    end
  end)
  Snake.Pausex:Hide()
end

function GR:CreateSnakeTimer()
  local Snake = GR_GUI.Main.Snake

  -- Timer
  Snake.Timer = Snake:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Snake.Timer:SetText(Snake.GameTime)
  Snake.Timer:SetTextColor(.8,.8,.8, 1)

  -- Points
  Snake.PointsFS = Snake:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Snake.PointsFS:SetText(Snake.Points)
  Snake.PointsFS:SetTextColor(.8,.8,.8, 1)

  -- GameOver
  Snake.GameOverFS = Snake:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Snake.GameOverFS:SetText("Game Over")
  Snake.GameOverFS:SetTextColor(.8,0,0, 1)
  Snake.GameOverFS:Hide()

  -- Info
  Snake.Info = Snake:CreateFontString(nil, "ARTWORK", "GameTooltipText")
  Snake.Info:SetText("move: w,a,s,d")
  Snake.Info:SetTextColor(.8,.8,.8, 1)
end

function GR:CreateSnakeGrid()
  local Snake = GR_GUI.Main.Snake
  
  Snake.Grid = {}

  for i = 1, GR.Snake.Const.NumOfRows, 1 do
    for j = 1, GR.Snake.Const.NumOfCols, 1 do
      Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)] = CreateFrame("Frame", nil, Snake)
      local Tile = Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)]
      Tile.Tex = Tile:CreateTexture()
      Tile.Tex:SetColorTexture(255,255,255, 1)
      Tile.Tex:SetAllPoints(Tile)
      Tile:Hide()
    end
  end
end

function GR:CreateSnakeApple()
  local Snake = GR_GUI.Main.Snake

  Snake.Apple = CreateFrame("Frame", Apple, Snake)
  local Apple = Snake.Apple
  Apple.Tex = Apple:CreateTexture()
  Apple.Tex:SetColorTexture(255,0,0, 1)
  Apple.Tex:SetAllPoints(Apple)
  Apple.Pos = {
    X = math.random(1, GR.Snake.Const.NumOfCols),
    Y = math.random(1, GR.Snake.Const.NumOfRows),
  }
  Apple:Hide()
end

-- Resize
function GR:SnakeSize()
  local Snake = GR_GUI.Main.Snake

  -- Snake Frame
  Snake:SetPoint("BOTTOM", 0, 25 * GR_GUI.Main.YRatio)
  Snake:SetSize(GR.Snake.Const.Width * GR_GUI.Main.XRatio, GR.Snake.Const.Height * GR_GUI.Main.YRatio)

  -- Reset Snake Screen Variables
  Snake.XRatio = Snake:GetWidth() / GR.Snake.Const.Width
  Snake.YRatio = Snake:GetHeight() / GR.Snake.Const.Height
  Snake.ScreenRatio = ((Snake:GetWidth() / GR.Snake.Const.Width) + (Snake:GetHeight() / GR.Snake.Const.Height)) / 2


  GR:SnakeSizeStartStop()
  GR:SizeSnakeTimer()
  GR:SizeSnakeGrid()
  GR:SizeSnakeApple()
end

function GR:SnakeSizeStartStop()
  local Snake = GR_GUI.Main.Snake
  
  Snake.Start:SetPoint("TOPLEFT", 50 * Snake.XRatio, 34 * Snake.YRatio)
  Snake.Start:SetSize(30 * Snake.XRatio, 30 * Snake.YRatio)
  Snake.Start.Line1:SetStartPoint("CENTER", -8 * Snake.XRatio, 8 * Snake.YRatio)
  Snake.Start.Line1:SetEndPoint("CENTER", 8 * Snake.XRatio, 0)
  Snake.Start.Line1:SetThickness(3 * Snake.ScreenRatio)
  Snake.Start.Line2:SetStartPoint("CENTER", -8 * Snake.XRatio, -8 * Snake.YRatio)
  Snake.Start.Line2:SetEndPoint("CENTER", 8 * Snake.XRatio, 0)
  Snake.Start.Line2:SetThickness(3 * Snake.ScreenRatio)
  Snake.Start.Line3:SetStartPoint("CENTER", -8 * Snake.XRatio, -8 * Snake.YRatio)
  Snake.Start.Line3:SetEndPoint("CENTER", -8 * Snake.XRatio, 8 * Snake.YRatio)
  Snake.Start.Line3:SetThickness(3 * Snake.ScreenRatio)

  Snake.Stopx:SetPoint("TOPLEFT", 83 * Snake.XRatio, 34 * Snake.YRatio)
  Snake.Stopx:SetSize(30 * Snake.XRatio, 30 * Snake.YRatio)
  Snake.Stopx.Tex:SetSize(15 * Snake.XRatio, 15 * Snake.YRatio)
  
  Snake.Pausex:SetPoint("TOPLEFT", 50 * Snake.XRatio, 34 * Snake.YRatio)
  Snake.Pausex:SetSize(30 * Snake.XRatio, 30 * Snake.YRatio)
  Snake.Pausex.Tex1:SetSize(6 * Snake.XRatio, 15 * Snake.YRatio)
  Snake.Pausex.Tex1:SetPoint("CENTER", -6 * Snake.XRatio, 0)
  Snake.Pausex.Tex2:SetSize(6 * Snake.XRatio, 15 * Snake.YRatio)
  Snake.Pausex.Tex2:SetPoint("CENTER", 6 * Snake.XRatio, 0)
end

function GR:SizeSnakeTimer()
  local Snake = GR_GUI.Main.Snake
  Snake.Timer:SetPoint("BOTTOMLEFT", Snake, "TOPRIGHT", -220 * Snake.XRatio, 6 * Snake.YRatio)
  Snake.Timer:SetTextScale(2 * Snake.ScreenRatio)
  Snake.PointsFS:SetPoint("BOTTOMLEFT", Snake, "TOPLEFT", 160 * Snake.XRatio, 6 * Snake.YRatio)
  Snake.PointsFS:SetTextScale(2 * Snake.ScreenRatio)
  Snake.GameOverFS:SetPoint("TOP", 0, -80 * Snake.YRatio)
  Snake.GameOverFS:SetTextScale(3.7 * Snake.ScreenRatio)
  Snake.Info:SetPoint("TOP", Snake, "TOPLEFT", 100 * Snake.XRatio, 57 * Snake.YRatio)
  Snake.Info:SetTextScale(1 * Snake.ScreenRatio)
end

function GR:SizeSnakeGrid()
  local Snake = GR_GUI.Main.Snake
  local Grid = Snake.Grid

  for i = 1, GR.Snake.Const.NumOfRows, 1 do
    for j = 1, GR.Snake.Const.NumOfCols, 1 do
      local Tile = Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)]
      Tile:SetPoint("BOTTOMLEFT", (GR.Snake.Const.Width * Snake.XRatio) * ((j -1) / GR.Snake.Const.NumOfCols), (GR.Snake.Const.Height * Snake.YRatio) * ((i -1) / GR.Snake.Const.NumOfRows))
      Tile:SetSize((GR.Snake.Const.Width * Snake.XRatio) / GR.Snake.Const.NumOfCols, (GR.Snake.Const.Height * Snake.YRatio) / GR.Snake.Const.NumOfRows)
    end
  end
end

function GR:SizeSnakeApple()
  local Snake = GR_GUI.Main.Snake
  local Apple = Snake.Apple

  Apple:SetPoint("BOTTOMLEFT", (GR.Snake.Const.Width * Snake.XRatio) * (Apple.Pos.X / GR.Snake.Const.NumOfCols), (GR.Snake.Const.Height * Snake.YRatio) * (Apple.Pos.Y / GR.Snake.Const.NumOfRows))
  Apple:SetSize((GR.Snake.Const.Width * Snake.XRatio) / GR.Snake.Const.NumOfCols, (GR.Snake.Const.Height * Snake.YRatio) / GR.Snake.Const.NumOfRows)
end

-- Show / Hide
function GR:SnakeShow()
  local Snake = GR_GUI.Main.Snake

  GR:SnakeSize()

  Snake:Show()
end

function GR:SnakeHide()
  local Snake = GR_GUI.Main.Snake
  
  GR:SnakeStop()

  Snake:Hide()
end

-- Start Stop Pause Unpause
function GR:SnakeStart()
  local Snake = GR_GUI.Main.Snake
  local Apple = Snake.Apple

  Snake.GameTime = 0
  Snake.Points = 0
  Snake.Dir = "Up"
  Snake.OnState = "Stop"
  Snake.MoveInterval = GR.Snake.Const.MoveInterval
  Snake.Pos = {
    X = math.floor(GR.Snake.Const.NumOfCols / 2),
    Y = math.floor(GR.Snake.Const.NumOfRows / 2),
  }
  Snake.Tail = {}
  Snake.TailLength = 0
  GR:SnakeMoveApple()

  Snake.PointsFS:SetText(Snake.Points)

  Snake.Game:Show()
  Snake.Stopx:Show()
  Snake.Pausex:Show()
  Snake.Apple:Show()
  Snake.Start:Hide()
  Snake.GameOverFS:Hide()
end

function GR:SnakeStop()
  local Snake = GR_GUI.Main.Snake
  
  Snake.Game:Hide()
  Snake.Start:Show()
  Snake.Pausex:Hide()
  Snake.Stopx:Hide()
end

function GR:SnakePause()
  local Snake = GR_GUI.Main.Snake

  Snake.Start:Show()
  Snake.Pausex:Hide()
  Snake.Stopx:Hide()

  Snake.Game:Hide()
end

function GR:SnakeUnpause()
  local Snake = GR_GUI.Main.Snake

  Snake.Start:Hide()
  Snake.Pausex:Show()
  Snake.Stopx:Show()

  Snake.Game:Show()
end

-- Update
function GR:SnakeUpdate(self, elapsed)
  local Snake = GR_GUI.Main.Snake

  Snake.GameTime = Snake.GameTime + elapsed

  Snake.Timer:SetText(math.floor(Snake.GameTime * 100) / 100)

  local MoveSnake = GR:SnakeUpdatePos(elapsed)

  if (MoveSnake) then 
    GR:SnakeMove() 

    -- collision
    if (GR:SnakeHitApple()) then GR:SnakeMoveApple() GR:SnakeAddPoints() GR:SnakeIntervalSpeed() end
    if (GR:SnakeHitSnake()) then GR:SnakeGameOver() end
    if (GR:SnakeHitWall()) then GR:SnakeGameOver() end
  end

  local Grid = Snake.Grid
  for i = 1, GR.Snake.Const.NumOfRows, 1 do
    for j = 1, GR.Snake.Const.NumOfCols, 1 do
      local Tile = Snake.Grid[j + ((i - 1) * GR.Snake.Const.NumOfCols)]

      -- Show Current Pos Tile
      if (i == Snake.Pos.Y and j == Snake.Pos.X) then
        Tile:Show()
      else
        Tile:Hide()
      end
      
      -- Show Tail
      for q = 1, #Snake.Tail, 1 do
        if (i == Snake.Tail[q].Y and j == Snake.Tail[q].X) then
          Tile:Show()
        end
      end

      -- Light Up Animation
      -- if (math.floor(Snake.GameTime) % 2 == 0) then
      --   if (j % 2 == 0) then
      --     Tile:Show()
      --   else
      --     Tile:Hide()
      --   end
      -- end
      -- if (math.floor(Snake.GameTime) % 2 == 1) then
      --   if (j % 2 == 1) then
      --     Tile:Show()
      --   else
      --     Tile:Hide()
      --   end
      -- end
    end
  end
end

function GR:SnakeUpdatePos(elapsed)
  local Snake = GR_GUI.Main.Snake

  Snake.MoveTick = Snake.MoveTick + elapsed

  if (Snake.MoveTick > Snake.MoveInterval) then
    Snake.MoveTick = Snake.MoveTick - Snake.MoveInterval

    return true
  end
  return false
end

-- Function
function GR:SnakeControls()
  local Snake = GR_GUI.Main.Snake
  local Game = GR_GUI.Main.Snake.Game

  Game:SetScript("OnKeyDown", function(self, key) 
    if (key == "W" and Snake.LastDir ~= "Down") then
      Snake.Dir = "Up"
    end
    if (key == "A" and Snake.LastDir ~= "Right") then
      Snake.Dir = "Left"
    end
    if (key == "S" and Snake.LastDir ~= "Up") then
      Snake.Dir = "Down"
    end
    if (key == "D" and Snake.LastDir ~= "Left") then
      Snake.Dir = "Right"
    end
  end)
end

function GR:SnakeMove()
  local Snake = GR_GUI.Main.Snake

  local OldSnakePos = {
    X = Snake.Pos.X,
    Y = Snake.Pos.Y,
  }

  -- Change Pos
  if (Snake.Dir == "Up") then 
    Snake.Pos.Y = Snake.Pos.Y + 1 
    Snake.LastDir = "Up"
  end
  if (Snake.Dir == "Down") then 
    Snake.Pos.Y = Snake.Pos.Y - 1 
    Snake.LastDir = "Down"
  end
  if (Snake.Dir == "Right") then
    Snake.Pos.X = Snake.Pos.X + 1 
    Snake.LastDir = "Right"
  end
  if (Snake.Dir == "Left") then
    Snake.Pos.X = Snake.Pos.X - 1 
    Snake.LastDir = "Left"
  end
  
  -- -- Bounds Check
  -- if (Snake.Pos.Y > GR.Snake.Const.NumOfRows) then Snake.Pos.Y = 1 end
  -- if (Snake.Pos.Y < 1) then Snake.Pos.Y = GR.Snake.Const.NumOfRows end
  -- if (Snake.Pos.X > GR.Snake.Const.NumOfCols) then Snake.Pos.X = 1 end
  -- if (Snake.Pos.X < 1) then Snake.Pos.X = GR.Snake.Const.NumOfCols end

  -- Snake Tail
  if (Snake.TailLength == 1) then
    Snake.Tail[1] = OldSnakePos
  end
  if (Snake.TailLength > 1) then
    for i = Snake.TailLength, 2, -1 do
      Snake.Tail[i] = Snake.Tail[i -1]
    end
    Snake.Tail[1] = OldSnakePos
  end
end

function GR:SnakeMoveApple()
  local Snake = GR_GUI.Main.Snake
  local Apple = Snake.Apple

  Apple.Pos = {
    X = math.random(1, GR.Snake.Const.NumOfCols),
    Y = math.random(1, GR.Snake.Const.NumOfRows),
  }

  Apple:SetPoint("BOTTOMLEFT", (GR.Snake.Const.Width * Snake.XRatio) * ((Apple.Pos.X -1) / GR.Snake.Const.NumOfCols), (GR.Snake.Const.Height * Snake.YRatio) * ((Apple.Pos.Y -1) / GR.Snake.Const.NumOfRows))
end

function GR:SnakeGameOver()
  GR:SnakeStop()

  GR_GUI.Main.Snake.GameOverFS:Show()
end

function GR:SnakeAddPoints()
  local Snake = GR_GUI.Main.Snake
  
  if (Snake.Points == 0) then
    Snake.Points = 5
  end
  
  if (Snake.Points > 0 and Snake.Points < 1000) then
    Snake.Points = math.floor(Snake.Points * 2 - (Snake.Points * .34))
  end
  if (Snake.Points > 1000 and Snake.Points < 3000) then
    Snake.Points = math.floor(Snake.Points * 2 - (Snake.Points * .5))
  end
  if (Snake.Points > 3000 and Snake.Points < 10000) then 
    Snake.Points = math.floor(Snake.Points * 2 - (Snake.Points * .65))
  end
  if (Snake.Points > 10000 and Snake.Points < 30000) then
    Snake.Points = math.floor(Snake.Points * 2 - (Snake.Points * .73))
  end
  if (Snake.Points > 30000 and Snake.Points < 70000) then
    Snake.Points = math.floor(Snake.Points * 2 - (Snake.Points * .83))
  end
  if (Snake.Points > 70000 and Snake.Points < 100000) then
    Snake.Points = math.floor(Snake.Points * 2 - (Snake.Points * .87))
  end
  if (Snake.Points > 100000 and Snake.Points < 1000000) then
    Snake.Points = math.floor(Snake.Points * 2 - (Snake.Points * .91))
  end

  Snake.PointsFS:SetText(Snake.Points)
end

function GR:SnakeIntervalSpeed()
  local Snake = GR_GUI.Main.Snake

  Snake.MoveInterval = Snake.MoveInterval - (Snake.MoveInterval / 35)
end

-- Collision
function GR:SnakeHitApple()
  local Snake = GR_GUI.Main.Snake
  local Apple = Snake.Apple

  if (Snake.Pos.X == Apple.Pos.X and Snake.Pos.Y == Apple.Pos.Y) then
    Snake.TailLength = Snake.TailLength + 1
    return true
  end
  return false
end

function GR:SnakeHitSnake()
  local Snake = GR_GUI.Main.Snake
  local Tail = Snake.Tail

  for i = 1, #Tail, 1 do
    if (Snake.Pos.X == Tail[i].X and Snake.Pos.Y == Tail[i].Y) then
      return true
    end
  end
  return false
end

function GR:SnakeHitWall()
  local Snake = GR_GUI.Main.Snake

  if (Snake.Pos.X < 1 or Snake.Pos.X > GR.Snake.Const.NumOfCols or Snake.Pos.Y < 1 or Snake.Pos.Y > GR.Snake.Const.NumOfRows) then
    return true
  end
  return false
end