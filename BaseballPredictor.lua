
--========================================
-- BASEBALL PREDICTOR v1.0
-- Mobile Observation GUI
--========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Enabled = true
local Ball = nil
local PredictionTime = 0.25
local PreviousPosition = nil
local CurrentVelocity = Vector3.zero

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "BaseballPredictor"
Gui.ResetOnSpawn = false

pcall(function()
    Gui.Parent = CoreGui
end)

if not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromOffset(220, 155)
Frame.Position = UDim2.new(0.5, -110, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(30, 120, 180)
Title.Text = "BASEBALL PREDICTOR"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Position = UDim2.fromOffset(10, 42)
Status.Size = UDim2.new(1, -20, 0, 25)
Status.BackgroundTransparency = 1
Status.Text = "공 탐색 중..."
Status.TextColor3 = Color3.new(1, 1, 1)
Status.TextSize = 13
Status.Parent = Frame

local PositionLabel = Instance.new("TextLabel")
PositionLabel.Position = UDim2.fromOffset(10, 70)
PositionLabel.Size = UDim2.new(1, -20, 0, 25)
PositionLabel.BackgroundTransparency = 1
PositionLabel.Text = "위치: -"
PositionLabel.TextColor3 = Color3.fromRGB(100, 220, 255)
PositionLabel.TextSize = 12
PositionLabel.Parent = Frame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Position = UDim2.fromOffset(10, 96)
SpeedLabel.Size = UDim2.new(1, -20, 0, 25)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "속도: -"
SpeedLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
SpeedLabel.TextSize = 12
SpeedLabel.Parent = Frame

local Toggle = Instance.new("TextButton")
Toggle.Position = UDim2.fromOffset(10, 125)
Toggle.Size = UDim2.new(1, -20, 0, 23)
Toggle.BackgroundColor3 = Color3.fromRGB(30, 150, 90)
Toggle.Text = "ON"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 12
Toggle.Parent = Frame

Toggle.MouseButton1Click:Connect(function()
    Enabled = not Enabled
    Toggle.Text = Enabled and "ON" or "OFF"
    Toggle.BackgroundColor3 = Enabled
        and Color3.fromRGB(30, 150, 90)
        or Color3.fromRGB(160, 50, 50)
end)

-- 공 탐색
local function FindBall()
    local BestBall = nil
    local BestDistance = math.huge

    local Character = Player.Character
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")

    if not Root then return nil end

    for _, Object in ipairs(Workspace:GetDescendants()) do
        if Object:IsA("BasePart") then
            local Name = Object.Name:lower()

            if Name:find("ball") or Name:find("baseball") then
                local Distance = (Object.Position - Root.Position).Magnitude

                if Distance < BestDistance then
                    BestDistance = Distance
                    BestBall = Object
                end
            end
        end
    end

    return BestBall
end

-- 예상 위치 표시
local Marker = Instance.new("Frame")
Marker.Size = UDim2.fromOffset(14, 14)
Marker.AnchorPoint = Vector2.new(0.5, 0.5)
Marker.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
Marker.BorderSizePixel = 0
Marker.Visible = false
Marker.Parent = Gui

local MarkerCorner = Instance.new("UICorner")
MarkerCorner.CornerRadius = UDim.new(1, 0)
MarkerCorner.Parent = Marker

-- 메인 분석
local ScanTimer = 0

RunService.RenderStepped:Connect(function(Delta)
    if not Enabled then
        Marker.Visible = false
        return
    end

    ScanTimer += Delta

    if ScanTimer >= 0.3 then
        ScanTimer = 0

        if not Ball or not Ball.Parent then
            Ball = FindBall()
            PreviousPosition = nil
        end
    end

    if not Ball or not Ball.Parent then
        Status.Text = "공 탐색 중..."
        Marker.Visible = false
        return
    end

    local Position = Ball.Position
    local Velocity = Ball.AssemblyLinearVelocity

    CurrentVelocity = Velocity

    local Predicted = Position + Velocity * PredictionTime

    local ScreenPosition, Visible =
        Camera:WorldToViewportPoint(Predicted)

    Status.Text = "공 감지: " .. Ball.Name

    PositionLabel.Text = string.format(
        "위치: %.1f / %.1f / %.1f",
        Position.X,
        Position.Y,
        Position.Z
    )

    SpeedLabel.Text = string.format(
        "속도: %.1f studs/s",
        Velocity.Magnitude
    )

    Marker.Visible = Visible

    if Visible then
        Marker.Position = UDim2.fromOffset(
            ScreenPosition.X,
            ScreenPosition.Y
        )
    end
end)

print("[Baseball Predictor] Loaded!")
