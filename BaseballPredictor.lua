
--========================================
-- BASEBALL PREDICTOR v1.1
-- OBJECT SCANNER
--========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local Enabled = true
local ScanInterval = 0.25
local MaxDistance = 350
local MaxCandidates = 8

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "BaseballPredictorV11"
Gui.ResetOnSpawn = false

local success = pcall(function()
    Gui.Parent = CoreGui
end)

if not success or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(280, 300)
Frame.Position = UDim2.new(0.5, -140, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(30, 110, 170)
Title.Text = "BASEBALL PREDICTOR v1.1"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(8, 40)
Status.Size = UDim2.new(1, -16, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "탐색 준비"
Status.TextColor3 = Color3.fromRGB(100,255,150)
Status.TextSize = 12
Status.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(8, 68)
Toggle.Size = UDim2.new(1, -16, 0, 27)
Toggle.BackgroundColor3 = Color3.fromRGB(30,150,90)
Toggle.Text = "SCAN ON"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.TextSize = 12
Toggle.Parent = Frame

local List = Instance.new("ScrollingFrame")
List.Position = UDim2.fromOffset(8, 102)
List.Size = UDim2.new(1, -16, 1, -110)
List.BackgroundColor3 = Color3.fromRGB(28,33,45)
List.BorderSizePixel = 0
List.ScrollBarThickness = 4
List.CanvasSize = UDim2.new(0,0,0,0)
List.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,4)
Layout.Parent = List

local function MakeLabel(text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -6, 0, 43)
    Label.BackgroundColor3 = Color3.fromRGB(40,48,62)
    Label.TextColor3 = Color3.new(1,1,1)
    Label.TextSize = 11
    Label.Font = Enum.Font.Gotham
    Label.TextWrapped = true
    Label.Text = text
    Label.Parent = List
    return Label
end

local function GetRoot()
    local Character = Player.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function IsCharacterPart(Object)
    for _, P in ipairs(Players:GetPlayers()) do
        local Character = P.Character
        if Character and Object:IsDescendantOf(Character) then
            return true
        end
    end
    return false
end

local function Scan()
    local Root = GetRoot()
    if not Root then return end

    local Candidates = {}

    for _, Object in ipairs(Workspace:GetDescendants()) do
        if Object:IsA("BasePart")
        and Object.Parent
        and not Object.Anchored
        and not IsCharacterPart(Object) then

            local Size = Object.Size
            local Largest = math.max(Size.X, Size.Y, Size.Z)
            local Distance = (Object.Position - Root.Position).Magnitude
            local Speed = Object.AssemblyLinearVelocity.Magnitude

            if Largest <= 3
            and Largest >= 0.1
            and Distance <= MaxDistance
            and Speed >= 5 then

                table.insert(Candidates, {
                    Object = Object,
                    Distance = Distance,
                    Speed = Speed,
                    Size = Size,
                    Score = Speed / math.max(Largest, 0.1)
                })
            end
        end
    end

    table.sort(Candidates, function(a,b)
        return a.Score > b.Score
    end)

    for _, Child in ipairs(List:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end

    local Count = math.min(#Candidates, MaxCandidates)

    for i = 1, Count do
        local Data = Candidates[i]
        local Object = Data.Object

        MakeLabel(string.format(
            "#%d  %s (%s)\n속도: %.1f | 거리: %.1f\n크기: %.2f / %.2f / %.2f",
            i,
            Object.Name,
            Object.ClassName,
            Data.Speed,
            Data.Distance,
            Data.Size.X,
            Data.Size.Y,
            Data.Size.Z
        ))
    end

    List.CanvasSize = UDim2.new(
        0,0,0,Count * 47
    )

    Status.Text = "탐색 완료: 후보 " .. #Candidates .. "개"
end

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    Toggle.Text = Enabled and "SCAN ON" or "SCAN OFF"

    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30,150,90)
        or Color3.fromRGB(160,50,50)

    Status.Text = Enabled and "탐색 재개" or "탐색 중지"
end)

local Timer = 0

RunService.Heartbeat:Connect(function(dt)
    if not Enabled then return end

    Timer += dt

    if Timer >= ScanInterval then
        Timer = 0

        pcall(Scan)
    end
end)

print("[Baseball Predictor v1.1] Loaded")
