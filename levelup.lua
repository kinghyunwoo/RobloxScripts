
--==================================================
-- KINGHYUNWOO QUEST LOGGER SAFE V4
-- NO HOOK / NO REMOTE INVOKE
--==================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

-- 기존 GUI 제거
pcall(function()
    CoreGui:FindFirstChild("KingHyunwooQuestLogger"):Destroy()
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "KingHyunwooQuestLogger"
Gui.ResetOnSpawn = false
Gui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 340, 0, 390)
Frame.Position = UDim2.new(0.5, -170, 0.5, -195)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -45, 0, 38)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KINGHYUNWOO QUEST LOGGER V4"
Title.TextColor3 = Color3.fromRGB(100, 255, 180)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 4)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(180, 55, 55)
Close.Parent = Frame

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

local Scan = Instance.new("TextButton")
Scan.Size = UDim2.new(1, -20, 0, 35)
Scan.Position = UDim2.new(0, 10, 0, 43)
Scan.Text = "퀘스트 Remote 다시 탐색"
Scan.TextColor3 = Color3.new(1,1,1)
Scan.BackgroundColor3 = Color3.fromRGB(45, 110, 85)
Scan.Font = Enum.Font.GothamBold
Scan.TextSize = 13
Scan.Parent = Frame

local Output = Instance.new("ScrollingFrame")
Output.Size = UDim2.new(1, -20, 1, -95)
Output.Position = UDim2.new(0, 10, 0, 85)
Output.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Output.BorderSizePixel = 0
Output.ScrollBarThickness = 5
Output.CanvasSize = UDim2.new(0, 0, 0, 0)
Output.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 4)
Layout.Parent = Output

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 6)
Padding.PaddingLeft = UDim.new(0, 6)
Padding.Parent = Output

local function AddLine(Text, Color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -12, 0, 30)
    Label.BackgroundColor3 = Color3.fromRGB(35, 35, 43)
    Label.TextColor3 = Color or Color3.fromRGB(220, 220, 220)
    Label.Text = Text
    Label.TextSize = 11
    Label.Font = Enum.Font.Code
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.TextWrapped = true
    Label.Parent = Output

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 5)
    C.Parent = Label
end

local function ScanRemotes()
    for _, Child in ipairs(Output:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end

    AddLine("탐색 시작...", Color3.fromRGB(100, 255, 180))

    local Found = 0

    for _, Obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if Obj:IsA("RemoteFunction") or Obj:IsA("RemoteEvent") then
            local Name = Obj.Name:lower()

            if Name:find("quest") or Name:find("npc") then
                Found += 1

                local Type = Obj:IsA("RemoteFunction")
                    and "RemoteFunction"
                    or "RemoteEvent"

                AddLine(
                    Type .. " | " .. Obj:GetFullName(),
                    Color3.fromRGB(255, 220, 120)
                )
            end
        end
    end

    AddLine("탐색 완료: " .. Found .. "개 발견",
        Color3.fromRGB(100, 255, 180))

    task.wait()

    Output.CanvasSize = UDim2.new(
        0, 0, 0, Layout.AbsoluteContentSize.Y + 15
    )
end

Scan.MouseButton1Click:Connect(ScanRemotes)

ScanRemotes()