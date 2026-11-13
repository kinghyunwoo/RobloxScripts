
--========================================
-- BASEBALL PREDICTOR v1.4
-- INBOUND OBJECT FILTER
--========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local Enabled = true
local Alive = true
local Expanded = false
local Minimized = false
local Timer = 0

local MaxDistance = 350
local MaxCandidates = 3
local MinSpeed = 8

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "BaseballPredictorV14"
Gui.ResetOnSpawn = false

local ok = pcall(function()
    Gui.Parent = CoreGui
end)

if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(290,360)
Frame.Position = UDim2.new(0.5,-145,0.35,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,25,35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-105,0,35)
Title.Position = UDim2.fromOffset(5,0)
Title.BackgroundTransparency = 1
Title.Text = "BASEBALL PREDICTOR v1.4"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local function CreateButton(text,position,color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(30,27)
    b.Position = position
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.Parent = Frame
    return b
end

local MinButton = CreateButton(
    "—",UDim2.new(1,-100,0,4),
    Color3.fromRGB(70,80,100)
)

local ExpandButton = CreateButton(
    "□",UDim2.new(1,-66,0,4),
    Color3.fromRGB(40,110,170)
)

local DeleteButton = CreateButton(
    "X",UDim2.new(1,-32,0,4),
    Color3.fromRGB(170,45,45)
)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(0,38)
Content.Size = UDim2.new(1,0,1,-38)
Content.BackgroundTransparency = 1
Content.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(8,0)
Status.Size = UDim2.new(1,-16,0,25)
Status.BackgroundTransparency = 1
Status.Text = "탐색 준비"
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
Layout.Padding = UDim.new(0,5)
Layout.Parent = List

-- GUI controls
MinButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized

    Frame.Size = Minimized
        and UDim2.fromOffset(290,38)
        or (Expanded
            and UDim2.fromOffset(340,480)
            or UDim2.fromOffset(290,360))
end)

ExpandButton.MouseButton1Click:Connect(function()
    Expanded = not Expanded
    Minimized = false
    Content.Visible = true

    Frame.Size = Expanded
        and UDim2.fromOffset(340,480)
        or UDim2.fromOffset(290,360)

    ExpandButton.Text = Expanded and "↩" or "□"
end)

-- Player root
local function GetRoot()
    local Character = Player.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

-- Exclude player characters
local function IsCharacterPart(Object)
    for _,P in ipairs(Players:GetPlayers()) do
        local Character = P.Character

        if Character and Object:IsDescendantOf(Character) then
            return true
        end
    end

    return false
end

-- Object scan
local function Scan()
    local Root = GetRoot()
    if not Root then return end

    local Candidates = {}

    for _,Object in ipairs(Workspace:GetDescendants()) do
        if Object:IsA("BasePart")
        and Object.Parent
        and not IsCharacterPart(Object) then

            local Position = Object.Position
            local Velocity = Object.AssemblyLinearVelocity
            local Speed = Velocity.Magnitude

            local Difference = Root.Position - Position
            local Distance = Difference.Magnitude

            local Size = Object.Size
            local Largest = math.max(Size.X,Size.Y,Size.Z)
            local Smallest = math.min(Size.X,Size.Y,Size.Z)

            if Largest <= 3
            and Smallest >= 0.05
            and Distance <= MaxDistance
            and Speed >= MinSpeed
            and Distance > 0 then

                -- Direction toward player
                local Direction = Difference.Unit
                local Approach = Velocity:Dot(Direction)

                -- Positive means moving toward player
                if Approach > 0 then
                    local Score = Approach / math.max(Largest,0.1)

                    table.insert(Candidates,{
                        Object = Object,
                        Speed = Speed,
                        Approach = Approach,
                        Distance = Distance,
                        Size = Size,
                        Score = Score
                    })
                end
            end
        end
    end

    table.sort(Candidates,function(a,b)
        return a.Score > b.Score
    end)

    for _,Child in ipairs(List:GetChildren()) do
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
        Label.BackgroundColor3 = Color3.fromRGB(40,70,90)
        Label.TextColor3 = Color3.new(1,1,1)
        Label.TextSize = 11
        Label.TextWrapped = true
        Label.Font = Enum.Font.Gotham

        Label.Text = string.format(
            "#%d %s\n속도: %.1f studs/s\n접근속도: %.1f | 거리: %.1f\n크기: %.2f / %.2f / %.2f",
            i,
            O.Name,
            D.Speed,
            D.Approach,
            D.Distance,
            D.Size.X,
            D.Size.Y,
            D.Size.Z
        )

        Label.Parent = List
    end

    List.CanvasSize = UDim2.new(0,0,0,Count*70)

    Status.Text = "접근 후보: "..#Candidates
end

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    Toggle.Text = Enabled and "SCAN ON" or "SCAN OFF"

    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30,150,90)
        or Color3.fromRGB(160,50,50)

    Status.Text = Enabled and "탐색 재개" or "탐색 중지"
end)

-- Delete
DeleteButton.MouseButton1Click:Connect(function()
    Alive = false
    Enabled = false
    Gui:Destroy()
end)

-- Main loop
local Connection

Connection = RunService.Heartbeat:Connect(function(dt)
    if not Alive then
        Connection:Disconnect()
        return
    end

    if not Enabled then return end

    Timer += dt

    if Timer >= 0.5 then
        Timer = 0
        pcall(Scan)
    end
end)

print("[Baseball Predictor v1.4] Loaded")

--========================================
-- BASEBALL PREDICTOR v1.4
-- INBOUND OBJECT FILTER
--========================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

local Enabled = true
local Alive = true
local Expanded = false
local Minimized = false
local Timer = 0

local MaxDistance = 350
local MaxCandidates = 3
local MinSpeed = 8

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "BaseballPredictorV14"
Gui.ResetOnSpawn = false

local ok = pcall(function()
    Gui.Parent = CoreGui
end)

if not ok or not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(290,360)
Frame.Position = UDim2.new(0.5,-145,0.35,0)
Frame.BackgroundColor3 = Color3.fromRGB(20,25,35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,10)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-105,0,35)
Title.Position = UDim2.fromOffset(5,0)
Title.BackgroundTransparency = 1
Title.Text = "BASEBALL PREDICTOR v1.4"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 11
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local function CreateButton(text,position,color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(30,27)
    b.Position = position
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.Parent = Frame
    return b
end

local MinButton = CreateButton(
    "—",UDim2.new(1,-100,0,4),
    Color3.fromRGB(70,80,100)
)

local ExpandButton = CreateButton(
    "□",UDim2.new(1,-66,0,4),
    Color3.fromRGB(40,110,170)
)

local DeleteButton = CreateButton(
    "X",UDim2.new(1,-32,0,4),
    Color3.fromRGB(170,45,45)
)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(0,38)
Content.Size = UDim2.new(1,0,1,-38)
Content.BackgroundTransparency = 1
Content.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(8,0)
Status.Size = UDim2.new(1,-16,0,25)
Status.BackgroundTransparency = 1
Status.Text = "탐색 준비"
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
Layout.Padding = UDim.new(0,5)
Layout.Parent = List

-- GUI controls
MinButton.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    Content.Visible = not Minimized

    Frame.Size = Minimized
        and UDim2.fromOffset(290,38)
        or (Expanded
            and UDim2.fromOffset(340,480)
            or UDim2.fromOffset(290,360))
end)

ExpandButton.MouseButton1Click:Connect(function()
    Expanded = not Expanded
    Minimized = false
    Content.Visible = true

    Frame.Size = Expanded
        and UDim2.fromOffset(340,480)
        or UDim2.fromOffset(290,360)

    ExpandButton.Text = Expanded and "↩" or "□"
end)

-- Player root
local function GetRoot()
    local Character = Player.Character
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

-- Exclude player characters
local function IsCharacterPart(Object)
    for _,P in ipairs(Players:GetPlayers()) do
        local Character = P.Character

        if Character and Object:IsDescendantOf(Character) then
            return true
        end
    end

    return false
end

-- Object scan
local function Scan()
    local Root = GetRoot()
    if not Root then return end

    local Candidates = {}

    for _,Object in ipairs(Workspace:GetDescendants()) do
        if Object:IsA("BasePart")
        and Object.Parent
        and not IsCharacterPart(Object) then

            local Position = Object.Position
            local Velocity = Object.AssemblyLinearVelocity
            local Speed = Velocity.Magnitude

            local Difference = Root.Position - Position
            local Distance = Difference.Magnitude

            local Size = Object.Size
            local Largest = math.max(Size.X,Size.Y,Size.Z)
            local Smallest = math.min(Size.X,Size.Y,Size.Z)

            if Largest <= 3
            and Smallest >= 0.05
            and Distance <= MaxDistance
            and Speed >= MinSpeed
            and Distance > 0 then

                -- Direction toward player
                local Direction = Difference.Unit
                local Approach = Velocity:Dot(Direction)

                -- Positive means moving toward player
                if Approach > 0 then
                    local Score = Approach / math.max(Largest,0.1)

                    table.insert(Candidates,{
                        Object = Object,
                        Speed = Speed,
                        Approach = Approach,
                        Distance = Distance,
                        Size = Size,
                        Score = Score
                    })
                end
            end
        end
    end

    table.sort(Candidates,function(a,b)
        return a.Score > b.Score
    end)

    for _,Child in ipairs(List:GetChildren()) do
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
        Label.BackgroundColor3 = Color3.fromRGB(40,70,90)
        Label.TextColor3 = Color3.new(1,1,1)
        Label.TextSize = 11
        Label.TextWrapped = true
        Label.Font = Enum.Font.Gotham

        Label.Text = string.format(
            "#%d %s\n속도: %.1f studs/s\n접근속도: %.1f | 거리: %.1f\n크기: %.2f / %.2f / %.2f",
            i,
            O.Name,
            D.Speed,
            D.Approach,
            D.Distance,
            D.Size.X,
            D.Size.Y,
            D.Size.Z
        )

        Label.Parent = List
    end

    List.CanvasSize = UDim2.new(0,0,0,Count*70)

    Status.Text = "접근 후보: "..#Candidates
end

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled

    Toggle.Text = Enabled and "SCAN ON" or "SCAN OFF"

    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30,150,90)
        or Color3.fromRGB(160,50,50)

    Status.Text = Enabled and "탐색 재개" or "탐색 중지"
end)

-- Delete
DeleteButton.MouseButton1Click:Connect(function()
    Alive = false
    Enabled = false
    Gui:Destroy()
end)

-- Main loop
local Connection

Connection = RunService.Heartbeat:Connect(function(dt)
    if not Alive then
        Connection:Disconnect()
        return
    end

    if not Enabled then return end

    Timer += dt

    if Timer >= 0.5 then
        Timer = 0
        pcall(Scan)
    end
end)

print("[Baseball Predictor v1.4] Loaded")
