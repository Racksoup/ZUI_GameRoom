function GR:CreateTicTacToe() 
    GR.TicBoard = {0,0,0,0,0,0,0,0,0}
    GR.Tic = {}
    GR.Tic.Width = 600
    GR.Tic.Height = 390
    
    GR_GUI.Main.Tictactoe = CreateFrame("Frame", Game, GR_GUI.Main, "ThinBorderTemplate")
    GR_GUI.Main.Tictactoe:Hide()

    GR:CreateTicTacToeLines()
    GR:CreateTicTacToeButtons()

    GR:SizeTictactoe()
end

function GR:CreateTicTacToeLines()
    local Tictactoe = GR_GUI.Main.Tictactoe
    Tictactoe.VLine1 = Tictactoe:CreateLine()
    Tictactoe.VLine1:SetColorTexture(.8,.8,.8, 1)
    Tictactoe.VLine2 = Tictactoe:CreateLine()
    Tictactoe.VLine2:SetColorTexture(.8,.8,.8, 1)
    Tictactoe.HLine1 = Tictactoe:CreateLine()
    Tictactoe.HLine1:SetColorTexture(.8,.8,.8, 1)
    Tictactoe.HLine2 = Tictactoe:CreateLine()
    Tictactoe.HLine2:SetColorTexture(.8,.8,.8, 1)
end

function GR:CreateTicTacToeButtons()
  local Content = GR_GUI.Main.Tictactoe
  GR_GUI.Main.Tictactoe.Buttons = {}
  local Buttons = GR_GUI.Main.Tictactoe.Buttons

  for i=1, 9, 1 do
    local function xVal() 
      if (i == 3 or i == 6 or i == 9) then 
        return 385 
      elseif (i == 2 or i == 5 or i == 8) then 
        return 195 
      else  
        return 5
      end 
    end
    local function yVal() 
      if i > 6 then 
        return -305 
      elseif i > 3 then 
        return -155 
      else 
        return -6
      end 
    end

    local Btn = CreateFrame("Button", nil, Content)
    Btn:SetPoint("TOPLEFT", xVal(), yVal())
    Btn:SetSize(180,140)
    local BtnTex = Btn:CreateTexture()
    BtnTex:SetAllPoints(Btn)
    Btn:RegisterForClicks("AnyUp", "AnyDown")
    Btn:SetScript("OnClick", function(self, button, down) 
      local x = (180/1024)
      local y = (140/1024)
      if (button == "LeftButton" and down == false and GR.IsPlayerTurn and GR.GameOver == false and GR.TicBoard[i] == 0) then
        local TextureX = "Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeX.blp"
        local TextureO = "Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeO.blp"
        local MsgO = " O" 
        local MsgX = " X"
        if (GR.PlayerPos == 1) then 
          BtnTex:SetTexture(TextureX)
          GR.TicBoard[i] = 1
          GR:SendCommMessage("ZUI_GameRoom_TiG", tostring(i) .. MsgX, "WHISPER", GR.Opponent)
        end
        if (GR.PlayerPos == 2) then 
          BtnTex:SetTexture(TextureO)
          GR.TicBoard[i] = 2
          GR:SendCommMessage("ZUI_GameRoom_TiG", tostring(i) .. MsgO, "WHISPER", GR.Opponent)
        end
        BtnTex:SetTexCoord(0,0, 0,y, x,0, x,y)
        BtnTex:Show()
        GR.IsPlayerTurn = false
        GR:TicCheckForWin()
        GR:SetTurnString()
      end
    end)
    table.insert(Buttons, Btn)
  end
end

function GR:TicCheckForWin()
    if (
        -- Horizontal
        GR.TicBoard[1] ~= 0 and GR.TicBoard[1] == GR.TicBoard[2] and GR.TicBoard[1] == GR.TicBoard[3] or
        GR.TicBoard[4] ~= 0 and GR.TicBoard[4] == GR.TicBoard[5] and GR.TicBoard[4] == GR.TicBoard[6] or
        GR.TicBoard[7] ~= 0 and GR.TicBoard[7] == GR.TicBoard[8] and GR.TicBoard[7] == GR.TicBoard[9] or
        -- Vertical
        GR.TicBoard[1] ~= 0 and GR.TicBoard[1] == GR.TicBoard[4] and GR.TicBoard[1] == GR.TicBoard[7] or
        GR.TicBoard[2] ~= 0 and GR.TicBoard[2] == GR.TicBoard[5] and GR.TicBoard[2] == GR.TicBoard[8] or
        GR.TicBoard[3] ~= 0 and GR.TicBoard[3] == GR.TicBoard[6] and GR.TicBoard[3] == GR.TicBoard[9] or
        -- Diagonal
        GR.TicBoard[1] ~= 0 and GR.TicBoard[1] == GR.TicBoard[5] and GR.TicBoard[1] == GR.TicBoard[9] or
        GR.TicBoard[3] ~= 0 and GR.TicBoard[3] == GR.TicBoard[5] and GR.TicBoard[3] == GR.TicBoard[7] 
    ) then
        GR.GameOver = true
        -- GR_GUI.Main.HeaderInfo.ReInvite:Show()
        GR_GUI.Main.HeaderInfo.OpponentString:Hide()
        -- show add to rival if not in rivals
        -- GR:ShowRivalsBtn()
        local TurnString = GR_GUI.Main.HeaderInfo.TurnString
        if (GR.IsPlayerTurn == false) then
            TurnString:SetText("Win!")
        else
            TurnString:SetText("Lose")
        end
    end
end

-- Size
function GR:SizeTictactoe()
  local Main = GR_GUI.Main
  local Tictactoe = Main.Tictactoe
  
  Tictactoe:SetPoint("BOTTOM", 0 * Main.XRatio, 17 * Main.YRatio)
  Tictactoe:SetSize(GR.Tic.Width * Main.XRatio, GR.Tic.Height * Main.YRatio)

  Main.HeaderInfo.TurnString:SetPoint("TOP", 0 * Main.XRatio, 0 * Main.YRatio)

  Tictactoe.VLine1:SetStartPoint("TOPLEFT", (GR.Tic.Width / 3) * Main.XRatio, 0 * Main.YRatio)
  Tictactoe.VLine1:SetEndPoint("BOTTOMLEFT", (GR.Tic.Width / 3) * Main.XRatio, 0 * Main.YRatio)
  Tictactoe.VLine2:SetStartPoint("TOPLEFT", ((GR.Tic.Width / 3) *2) * Main.XRatio, 0 * Main.YRatio)
  Tictactoe.VLine2:SetEndPoint("BOTTOMLEFT", ((GR.Tic.Width / 3) *2) * Main.XRatio, 0 * Main.YRatio)
  Tictactoe.HLine1:SetStartPoint("TOPLEFT", 0 * Main.XRatio, -(GR.Tic.Height / 3) * Main.YRatio)
  Tictactoe.HLine1:SetEndPoint("TOPRIGHT", 0 * Main.XRatio, -(GR.Tic.Height / 3) * Main.YRatio)
  Tictactoe.HLine2:SetStartPoint("TOPLEFT", 0 * Main.XRatio, -((GR.Tic.Height / 3) *2) * Main.YRatio)
  Tictactoe.HLine2:SetEndPoint("TOPRIGHT", 0 * Main.XRatio, -((GR.Tic.Height / 3) *2) * Main.YRatio)

  GR:SizeTictactoeButtons()
end

function GR:SizeTictactoeButtons()
  local Main = GR_GUI.Main
  local Tictactoe = Main.Tictactoe

  local Buttons = GR_GUI.Main.Tictactoe.Buttons

  for i=1, #Buttons, 1 do
    local function xVal() 
      if (i == 3 or i == 6 or i == 9) then 
        return (((GR.Tic.Width / 3) *2) + 5) * Main.XRatio
      elseif (i == 2 or i == 5 or i == 8) then 
        return ((GR.Tic.Width / 3) + 5) * Main.XRatio
      else  
        return 5 * Main.XRatio
      end 
    end
    local function yVal() 
      if i > 6 then 
        return (-((GR.Tic.Height / 3) *2) - 5) * Main.YRatio 
      elseif i > 3 then 
        return (-(GR.Tic.Height / 3) - 5) * Main.YRatio 
      else 
        return -6 * Main.YRatio
      end 
    end

    Buttons[i]:SetPoint("TOPLEFT", xVal(), yVal())
    Buttons[i]:SetSize((GR.Tic.Width / 3) * Main.XRatio, (GR.Tic.Height / 3) * Main.YRatio)
  end
end

function GR:TicTacToeHideContent()
    GR_GUI.Main.Tictactoe:Hide()
    GR.TicBoard = {0,0,0,0,0,0,0,0,0}
    GR.UseGroupChat = false
    local Buttons = GR_GUI.Main.Tictactoe.Buttons
    for i,v in ipairs(Buttons) do 
        local BtnTex = v:GetRegions()
        BtnTex:Hide()
    end
    GR:HideGame()
end

function GR:TictactoeShow()
    GR_GUI.Main.Tictactoe:Show()
    GR_GUI.Main.H2:Hide()
    GR:ShowGame()            
end

function GR:TicTacToeComm(...) 
    local prefix, text, distribution, target = ...
    local Buttons = GR_GUI.Main.Tictactoe.Buttons
    local Move = (string.sub(text, 2, 3))
    local Place = tonumber((string.sub(text, 0, 1)))
    local x = (180/1024)
    local y = (140/1024)

    -- Sets Buttons To X or O
    if (type(Place) == "number" ) then
        if (Place > 0 and Place < 10 and string.match(Move, "O") or Place > 0 and Place < 10 and string.match(Move, "X") ) then
            for i,v in ipairs(Buttons) do 
                if (i == Place and string.match(Move, "O")) then 
                    local BtnTex = v:GetRegions()
                    BtnTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeO.blp")
                    BtnTex:SetTexCoord(0,0, 0,y, x,0, x,y)
                    BtnTex:Show()
                    GR.TicBoard[i] = 2
                end
                if (i == Place and string.match(Move, "X")) then 
                    local BtnTex = v:GetRegions()
                    BtnTex:SetTexture("Interface\\AddOns\\ZUI_GameRoom\\images\\TicTacToeX.blp")
                    BtnTex:SetTexCoord(0,0, 0,y, x,0, x,y)
                    BtnTex:Show()
                    GR.TicBoard[i] = 1
                end
            end
            GR.IsPlayerTurn = true
            GR:TicCheckForWin()
            GR:SetTurnString()
        end
    end
end

-- rematch button