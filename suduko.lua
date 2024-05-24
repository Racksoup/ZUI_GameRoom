-- Create
function GR:CreateSuduko()
  local Main = GR_GUI.Main
  GR.Suduko = {}
  GR.Suduko.CurrTile = nil
  GR.Suduko.Board = {}
  GR.Suduko.Const = {}
  GR.Suduko.Const.NumOfCols = 9
  GR.Suduko.Const.NumOfRows = 9

  Main.Suduko = CreateFrame("Frame", "Suduko", Main, "ThinBorderTemplate")
  Main.Suduko:Hide()

  GR:CreateSudukoGrid()
  GR:CreateSudukoBlackLines()
  GR:SudukoControls()

  GR:SizeSuduko()
end

function GR:CreateSudukoGrid()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko
  local rows = GR.Suduko.Const.NumOfRows
  local cols = GR.Suduko.Const.NumOfCols

  Suduko.Grid = {}

  for i = 1, rows, 1 do
    for j = 1, cols, 1 do
      Suduko.Grid[j + ((i -1) * cols)] = CreateFrame("BUTTON", nil, Suduko, "ThinBorderTemplate")
      local Tile = Suduko.Grid[j + ((i -1) * cols)] 
      Tile.insertMode = nil
      Tile.Marks = {}
      Tile.Pick = nil
      Tile.Tex = Tile:CreateTexture()
      Tile.Tex:SetAllPoints(Tile)
      Tile.Tex:Hide()
      Tile.FS = Tile:CreateFontString(nil, "OVERLAY", "GameTooltipText")
      Tile.FS:Hide()
      Tile.MarksFS = Tile:CreateFontString(nil, "OVERLAY", "GameTooltipText")
      Tile.MarksFS:Hide()
      Tile:RegisterForClicks("LeftButtonDown", "RightButtonDown")
      Tile:SetScript("OnClick", function(self, button, down)
        GR:HideTiles()
        GR.Suduko.CurrTile = self
        Suduko.Controls:Show()
        if (button == "LeftButton") then
          Tile.insertMode = "pick"
          Tile.Tex:Show()
          Tile.Tex:SetColorTexture(255,0,0, .2)
        end
        
        if (button == "RightButton") then
          Tile.insertMode = "marks"
          Tile.Tex:Show()
          Tile.Tex:SetColorTexture(255,255,255, .2)
        end
      end)
    end
  end
end

function GR:CreateSudukoBlackLines()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko

  Suduko.BlackLines = CreateFrame("FRAME", "BlackLines", Suduko)
  local BlackLines = Suduko.BlackLines
  BlackLines:SetAllPoints(Suduko);
  BlackLines:Raise()

  BlackLines.VL = BlackLines:CreateLine()
  BlackLines.VL:SetColorTexture(0,255,255, 1)
  BlackLines.VR = BlackLines:CreateLine()
  BlackLines.VR:SetColorTexture(0,255,255, 1)
  BlackLines.HB = BlackLines:CreateLine()
  BlackLines.HB:SetColorTexture(0,255,255, 1)
  BlackLines.HT = BlackLines:CreateLine()
  BlackLines.HT:SetColorTexture(0,255,255, 1)
end

-- Size
function GR:SizeSuduko()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko

  Suduko:SetPoint("BOTTOM", 0, 25 * Main.YRatio)
  Suduko:SetSize(GR.Win.Const.SudukoScreenWidth * Main.XRatio, GR.Win.Const.SudukoScreenHeight * Main.YRatio)

  GR:SizeSudukoGrid()
  GR:SizeSudukoBlackLines()
end

function GR:SizeSudukoGrid()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko
  local Grid = Suduko.Grid
  local cols = GR.Suduko.Const.NumOfCols
  local rows = GR.Suduko.Const.NumOfRows
  local height = GR.Win.Const.SudukoScreenHeight
  local width = GR.Win.Const.SudukoScreenWidth
  
  for i = 1, rows, 1 do
    for j = 1, cols, 1 do
      local Tile = Suduko.Grid[j + ((i - 1) * cols)]
      Tile:SetPoint("BOTTOMLEFT", (width * Main.XRatio) * ((j -1) / cols), (height * Main.YRatio) * ((i -1) / rows))
      Tile:SetSize((width * Main.XRatio) / cols, (height * Main.YRatio) / rows)
      Tile.FS:SetPoint("CENTER")
      Tile.FS:SetTextScale(1.6 * Main.ScreenRatio)
      Tile.MarksFS:SetPoint("TOP", 0, -3 * Main.YRatio)
      Tile.MarksFS:SetTextScale(.8 * Main.ScreenRatio)
    end
  end
end

function GR:SizeSudukoBlackLines()
  local Main = GR_GUI.Main
  local Suduko = Main.Suduko
  local BlackLines = Suduko.BlackLines

  BlackLines.VL:SetThickness(5 * Main.ScreenRatio)
  BlackLines.VR:SetThickness(5 * Main.ScreenRatio)
  BlackLines.HB:SetThickness(5 * Main.ScreenRatio)
  BlackLines.HT:SetThickness(5 * Main.ScreenRatio)
  BlackLines.VL:SetStartPoint("TOPLEFT", GR.Win.Const.SudukoScreenWidth * Main.XRatio /3, -3 * Main.YRatio)
  BlackLines.VL:SetEndPoint("BOTTOMLEFT", GR.Win.Const.SudukoScreenWidth * Main.XRatio /3, 3 * Main.YRatio)
  BlackLines.VR:SetStartPoint("TOPLEFT", (GR.Win.Const.SudukoScreenWidth * Main.XRatio /3) *2, -3 * Main.YRatio)
  BlackLines.VR:SetEndPoint("BOTTOMLEFT", (GR.Win.Const.SudukoScreenWidth * Main.XRatio /3) *2, 3 * Main.YRatio)
  BlackLines.HB:SetStartPoint("BOTTOMLEFT", 3 * Main.XRatio, GR.Win.Const.SudukoScreenHeight * Main.YRatio /3)
  BlackLines.HB:SetEndPoint("BOTTOMRIGHT", -3 * Main.XRatio, GR.Win.Const.SudukoScreenHeight * Main.YRatio /3)
  BlackLines.HT:SetStartPoint("BOTTOMLEFT", 3 * Main.XRatio, (GR.Win.Const.SudukoScreenHeight * Main.YRatio /3) *2)
  BlackLines.HT:SetEndPoint("BOTTOMRIGHT", -3 * Main.XRatio, (GR.Win.Const.SudukoScreenHeight * Main.YRatio /3) *2)
end

-- Func
function GR:HideTiles()					
  local Main = GR_GUI.Main
  local Grid = Main.Suduko.Grid

  GR.Suduko.CurrTile = nil

  for i,v in ipairs(Grid) do
    v.Tex:Hide()
  end
end

function GR:SudukoControls()
  local Suduko = GR_GUI.Main.Suduko
  local Tile = GR.Suduko.CurrTile

  Suduko.Controls = CreateFrame("FRAME")
  local Controls = Suduko.Controls
  Controls:Hide()

  Controls:SetScript("OnKeyDown", function(self, key)
    if GR.Suduko.CurrTile ~= nil then
      if key:match("[123456789]") then
        if (GR.Suduko.CurrTile.insertMode == "pick") then
          GR.Suduko.CurrTile.Pick = key
          GR.Suduko.CurrTile.MarksFS:Hide()
          GR.Suduko.CurrTile.FS:Show()
          GR.Suduko.CurrTile.FS:SetText(key)
        end
        if (GR.Suduko.CurrTile.insertMode == "marks") then
          GR.Suduko.CurrTile.Pick = nil 
          GR.Suduko.CurrTile.FS:Hide()
          GR.Suduko.CurrTile.MarksFS:Show()
          table.insert(GR.Suduko.CurrTile.Marks, key)
          GR.Suduko.CurrTile.MarksFS:SetText(
            table.concat(GR.Suduko.CurrTile.Marks, " ")
          )
        end
        GR.Suduko.CurrTile.insertMode = nil
        GR.Suduko.CurrTile.Tex:Hide()
        GR.Suduko.CurrTile = nil
        Controls:Hide()
      end

      if key == "BACKSPACE" then
        GR.Suduko.CurrTile.Marks = {}
        GR.Suduko.CurrTile.Pick = nil 
        GR.Suduko.CurrTile.MarksFS:SetText("")
        GR.Suduko.CurrTile.MarksFS:Hide()
        GR.Suduko.CurrTile.insertMode = nil
        GR.Suduko.CurrTile.Tex:Hide()
        GR.Suduko.CurrTile = nil
        Controls:Hide()
      end
    end 
  end)
end

function GR:SudukoSetBoard()
  local Board = GR.Suduko.Board
  local Grid = GR_GUI.Main.Suduko.Grid

  Board = {
    r1 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r2 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r3 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r4 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r5 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r6 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r7 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r8 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
    r9 = {0, 0, 0, 0, 0, 0, 0, 0, 0},
  }

  -- Set Lines
  -- First
  for i,v in ipairs(Board.r1) do
    local function findNum1()
      Board.r1[i] = math.random(1, 9)
      for j,k in ipairs(Board.r1) do
        if Board.r1[j] == Board.r1[i] and i ~= j then
          findNum1()
        end
      end
    end
    findNum1()
  end

  -- Second
  for i,v in ipairs(Board.r2) do 
    local function findNum2()
      Board.r2[i] = math.random(1,9)
      
      -- Row
      for j,k in ipairs(Board.r2) do
        if i ~= j then 
          if Board.r2[i] == Board.r2[j] then
            findNum2()
          end
        end
      end

      -- Col
      if Board.r2[i] == Board.r1[i] then
        findNum2()
      end

      -- Square
      if tostring(i):match("[123]") then
        if Board.r2[i] == Board.r1[1] or Board.r2[i] == Board.r1[2] or Board.r2[i] == Board.r1[3] then
          findNum2()
        end
      end
      if tostring(i):match("[456]") then
        if Board.r2[i] == Board.r1[4] or Board.r2[i] == Board.r1[5] or Board.r2[i] == Board.r1[6] then
          findNum2()
        end
      end 
      if tostring(i):match("[789]") then
        if Board.r2[i] == Board.r1[7] or Board.r2[i] == Board.r1[8] or Board.r2[i] == Board.r1[9] then
          findNum2()
        end
      end 

    end
    findNum2()
  end

  -- Third
  for i,v in ipairs(Board.r3) do 
    local function findNum3()
      Board.r3[i] = math.random(1,9)
      
      -- Check Row
      for j,k in ipairs(Board.r3) do
        if i ~= j then 
          if Board.r3[i] == Board.r3[j] then
            findNum3()
          end
        end
      end

      -- Check Col
      if Board.r3[i] == Board.r1[i] or 
        Board.r3[i] == Board.r2[i] then
        findNum3()
      end


      -- Check Square
      if tostring(i):match("[123]") then
        if Board.r3[i] == Board.r1[1] or Board.r3[i] == Board.r1[2] or Board.r3[i] == Board.r1[3] or 
          Board.r3[i] == Board.r2[1] or Board.r3[i] == Board.r2[2] or Board.r3[i] == Board.r2[3] then
          findNum3()
        end
      end
      if tostring(i):match("[456]") then
        if Board.r3[i] == Board.r1[4] or Board.r3[i] == Board.r1[5] or Board.r3[i] == Board.r1[6] or 
          Board.r3[i] == Board.r2[4] or Board.r3[i] == Board.r2[5] or Board.r3[i] == Board.r2[6] then
          findNum3()
        end
      end 
      if tostring(i):match("[789]") then
        if Board.r3[i] == Board.r1[7] or Board.r3[i] == Board.r1[8] or Board.r3[i] == Board.r1[9] or 
          Board.r3[i] == Board.r2[7] or Board.r3[i] == Board.r2[8] or Board.r3[i] == Board.r2[9] then
          findNum3()
        end
      end 

    end
    findNum3()
  end

  -- Fourth
  for i,v in ipairs(Board.r4) do 
    local function findNum4()
      Board.r4[i] = math.random(1,9)
      
      -- Check Row
      for j,k in ipairs(Board.r4) do
        if i ~= j then 
          if Board.r4[i] == Board.r4[j] then
            findNum4()
          end
        end
      end

      -- Check Col
      if Board.r4[i] == Board.r1[i] or 
        Board.r4[i] == Board.r2[i] or
        Board.r4[i] == Board.r3[i] then
        findNum4()
      end

    end
    findNum4()
  end
  
  -- Fifth
  for i,v in ipairs(Board.r5) do 
    local function findNum5()
      Board.r5[i] = math.random(1,9)
      
      -- Row
      for j,k in ipairs(Board.r5) do
        if i ~= j then 
          if Board.r5[i] == Board.r5[j] then
            findNum5()
          end
        end
      end

      -- Check Col
      if Board.r5[i] == Board.r1[i] or 
        Board.r5[i] == Board.r2[i] or
        Board.r5[i] == Board.r3[i] or
        Board.r5[i] == Board.r4[i] then
        findNum5()
      end
 
      -- Square
      if tostring(i):match("[123]") then
        if Board.r5[i] == Board.r4[1] or Board.r5[i] == Board.r4[2] or Board.r5[i] == Board.r4[3] then
          findNum5()
        end
      end
      if tostring(i):match("[456]") then
        if Board.r5[i] == Board.r4[4] or Board.r5[i] == Board.r4[5] or Board.r5[i] == Board.r4[6] then
          findNum5()
        end
      end 
      if tostring(i):match("[789]") then
        if Board.r5[i] == Board.r4[7] or Board.r5[i] == Board.r4[8] or Board.r5[i] == Board.r4[9] then
          findNum5()
        end
      end 

    end
    findNum5()
  end

  -- Set Text
  for i,v in ipairs(Board.r1) do 
    Grid[i].FS:Show()
    Grid[i].FS:SetText(v)
  end

  for i,v in ipairs(Board.r2) do
    Grid[i+9].FS:Show()
    Grid[i+9].FS:SetText(v)
  end

  for i,v in ipairs(Board.r3) do
    Grid[i+18].FS:Show()
    Grid[i+18].FS:SetText(v)
  end

  for i,v in ipairs(Board.r4) do
    Grid[i+27].FS:Show()
    Grid[i+27].FS:SetText(v)
  end

  for i,v in ipairs(Board.r5) do
    Grid[i+36].FS:Show()
    Grid[i+36].FS:SetText(v)
  end
end

-- Show / Hide
function GR:SudukoShow()
  GR:SizeSuduko()  
  
  GR:SudukoSetBoard()

  GR_GUI.Main.Suduko:Show()
end

function GR:SudukoHide()
  GR_GUI.Main.Suduko:Hide()
end 
