
--========================================
-- BASEBALL PREDICTOR v1.3
-- GUI CONTROL UPDATE
--========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local Enabled = true
local Alive = true
local Minimized = false
local Expanded = false
local Timer = 0

local NormalSize = UDim2.fromOffset(290, 360)
local BigSize = UDim2.fromOffset(340, 480)

--========================================
-- GUI
--========================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "BaseballPredictorV13"
Gui.ResetOnSpawn = false

local ok = pcall(function()
    Gui.Parent = CoreGui
end)

if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = NormalSize
Frame.Position = UDim2.new(0.5, -145, 0.35, 0)
Frame.BackgroundColor3 = Color3.fromRGB(20,25,35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Frame

--========================================
-- TITLE
--========================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-105,0,35)
Title.Position = UDim2.fromOffset(5,0)
Title.BackgroundTransparency = 1
Title.Text = "BASEBALL PREDICTOR"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local function CreateButton(Text, Position, Color)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(30,27)
    Button.Position = Position
    Button.BackgroundColor3 = Color
    Button.Text = Text
    Button.TextColor3 = Color3.new(1,1,1)
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.Parent = Frame

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0,5)
    C.Parent = Button

    return Button
end

local MinButton = CreateButton(
    "—", UDim2.new(1,-100,0,4),
    Color3.fromRGB(70,80,100)
)

local ExpandButton = CreateButton(
    "□", UDim2.new(1,-66,0,4),
    Color3.fromRGB(40,110,170)
)

local DeleteButton = CreateButton(
    "X", UDim2.new(1,-32,0,4),
    Color3.fromRGB(170,45,45)
)

--========================================
-- CONTENT
--========================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(0,38)
Content.Size = UDim2.new(1,0,1,-38)
Content.BackgroundTransparency = 1
Content.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(8,0)
Status.Size = UDim2.new(1,-16,0,25)
Status.BackgroundTransparency = 1
Status.Text = "준비 중"
Status.TextColor3 = Color3.fromRGB(100,255,150)
Status.TextSize = 12
Status.Parent = Content

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(8,28)
Toggle.Size = UDim2.new(1,-16,0,27)
Toggle.BackgroundColor3 = Color3.fromRGB(30,150,90)
Toggle.Text = "SCAN ON"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Parent = Content

local List = Instance.new("ScrollingFrame")
List.Position = UDim2.fromOffset(8,62)
List.Size = UDim2.new(1,-16,1,-70)
List.BackgroundColor3 = Color3.fromRGB(28,33,45)
List.BorderSizePixel = 0
List.ScrollBarThickness = 5
List.Parent = Content

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,4)
Layout.Parent = List

--========================================
-- GUI CONTROLS
--========================================

MinButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized

    Content.Visible = not Minimized
    Frame.Size = Minimized
        and UDim2.fromOffset(Frame.AbsoluteSize.X,38)
        or (Expanded and BigSize or NormalSize)
end)

ExpandButton.MouseButton1Click:Connect(function()
    Expanded = not Expanded
    Minimized = false

    Content.Visible = true
    Frame.Size = Expanded and BigSize or NormalSize
    ExpandButton.Text = Expanded and "↩" or "□"
end)

local ScanConnection

DeleteButton.MouseButton1Click:Connect(function()
    Alive = false
    Enabled = false

    if ScanConnection then
        ScanConnection:Disconnect()
    end

    Gui:Destroy()
end)

--========================================
-- SCANNER
--========================================

local MaxDistance = 350
local MaxCandidates = 12

local function IsCharacterPart(Object)
    for _, P in ipairs(Players:GetPlayers()) do
        local Character = P.Character

        if Character and Object:IsDescendantOf(Character) then
            return true
        end
    end

    return false
end

local function GetRoot()
    local Character = Player.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function GetPath(Object)
    local Parts = {}
    local Current = Object

    for i = 1,4 do
        if not Current or Current == Workspace then
            break
        end

        table.insert(Parts,1,Current.Name)
        Current = Current.Parent
    end

    return table.concat(Parts,".")
end

local function Scan()
    local Root = GetRoot()
    if not Root then return end

    local Candidates = {}

    for _, Object in ipairs(Workspace:GetDescendants()) do
        if Object:IsA("BasePart")
        and Object.Parent
        and not IsCharacterPart(Object) then

            local Size = Object.Size
            local Largest = math.max(Size.X,Size.Y,Size.Z)
            local Smallest = math.min(Size.X,Size.Y,Size.Z)

            local Distance =
                (Object.Position-Root.Position).Magnitude

            local Speed =
                Object.AssemblyLinearVelocity.Magnitude

            if Largest <= 4
            and Smallest >= 0.05
            and Distance <= MaxDistance then

                table.insert(Candidates,{
                    Object = Object,
                    Distance = Distance,
                    Speed = Speed,
                    Size = Size,
                    Anchored = Object.Anchored,
                    Path = GetPath(Object)
                })
            end
        end
    end

    table.sort(Candidates,function(a,b)
        return a.Speed > b.Speed
    end)

    for _, Child in ipairs(List:GetChildren()) do
        if Child:IsA("TextLabel") then
            Child:Destroy()
        end
    end

    local Count = math.min(#Candidates,MaxCandidates)

    for i = 1,Count do
        local D = Candidates[i]
        local O = D.Object

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1,-6,0,65)
        Label.BackgroundColor3 = Color3.fromRGB(40,48,62)
        Label.TextColor3 = Color3.new(1,1,1)
        Label.TextSize = 10
        Label.TextWrapped = true
        Label.Font = Enum.Font.Gotham

        Label.Text = string.format(
            "#%d %s [%s]\n속도: %.2f | 거리: %.1f\n크기: %.2f / %.2f / %.2f\nAnchored: %s\n%s",
            i,O.Name,O.ClassName,
            D.Speed,D.Distance,
            D.Size.X,D.Size.Y,D.Size.Z,
            tostring(D.Anchored),D.Path
        )

        Label.Parent = List
    end

    List.CanvasSize = UDim2.new(0,0,0,Count*69)
    Status.Text = "후보 객체: "..#Candidates
end

--========================================
-- SCAN TOGGLE
--========================================

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    Toggle.Text = Enabled and "SCAN ON" or "SCAN OFF"

    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30,150,90)
        or Color3.fromRGB(160,50,50)

    Status.Text = Enabled and "탐색 재개" or "탐색 중지"
end)

--========================================
-- MAIN LOOP
--========================================

ScanConnection = RunService.Heartbeat:Connect(function(dt)
    if not Alive or not Enabled then
        return
    end

    Timer += dt

    if Timer >= 0.5 then
        Timer = 0
        pcall(Scan)
    end
end)

print("[Baseball Predictor v1.3] Loaded!")
