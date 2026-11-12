-- PURPLE PINK HUB
-- Speed / Fly / Super Jump / Minimize

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then return end

pcall(function()
    local old = CoreGui:FindFirstChild("PurplePinkHub")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "PurplePinkHub"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(285, 300)
frame.Position = UDim2.new(0.5, -142, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(35, 18, 55)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(225, 90, 220)
stroke.Thickness = 2
stroke.Parent = frame

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local title = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundColor3 = Color3.fromRGB(155, 55, 205),
    Text = "PURPLE PINK HUB",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 19,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0
}, frame)

Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local close = make("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -36, 0, 6),
    BackgroundColor3 = Color3.fromRGB(245, 75, 145),
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0
}, frame)

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local minimize = make("TextButton", {
    Size = UDim2.fromOffset(30, 30),
    Position = UDim2.new(1, -72, 0, 6),
    BackgroundColor3 = Color3.fromRGB(205, 75, 185),
    Text = "ㅡ",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0
}, frame)

Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 8)

local minimized = false
local normalSize = frame.Size

minimize.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        for _, child in ipairs(frame:GetChildren()) do
            if child ~= title and child ~= close and child ~= minimize
            and not child:IsA("UICorner") and not child:IsA("UIStroke") then
                child.Visible = false
            end
        end

        frame.Size = UDim2.fromOffset(175, 43)
        minimize.Text = "+"
    else
        frame.Size = normalSize

        for _, child in ipairs(frame:GetChildren()) do
            if child ~= title and child ~= close and child ~= minimize
            and not child:IsA("UICorner") and not child:IsA("UIStroke") then
                child.Visible = true
            end
        end

        minimize.Text = "ㅡ"
    end
end)

local speedBox = make("TextBox", {
    Size = UDim2.new(1, -30, 0, 40),
    Position = UDim2.fromOffset(15, 58),
    BackgroundColor3 = Color3.fromRGB(65, 35, 85),
    Text = "16",
    PlaceholderText = "이동속도 입력 (1~500)",
    TextColor3 = Color3.new(1, 1, 1),
    PlaceholderColor3 = Color3.fromRGB(205, 180, 215),
    TextSize = 16,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    BorderSizePixel = 0
}, frame)

Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

local speedApply = make("TextButton", {
    Size = UDim2.new(1, -30, 0, 38),
    Position = UDim2.fromOffset(15, 108),
    BackgroundColor3 = Color3.fromRGB(205, 75, 185),
    Text = "속도 적용",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0
}, frame)

Instance.new("UICorner", speedApply).CornerRadius = UDim.new(0, 8)

local flyToggle = make("TextButton", {
    Size = UDim2.new(1, -30, 0, 40),
    Position = UDim2.fromOffset(15, 157),
    BackgroundColor3 = Color3.fromRGB(130, 65, 195),
    Text = "비행: OFF",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0
}, frame)

Instance.new("UICorner", flyToggle).CornerRadius = UDim.new(0, 8)

local jumpToggle = make("TextButton", {
    Size = UDim2.new(1, -30, 0, 38),
    Position = UDim2.fromOffset(15, 208),
    BackgroundColor3 = Color3.fromRGB(130, 65, 195),
    Text = "슈퍼 점프: OFF",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0
}, frame)

Instance.new("UICorner", jumpToggle).CornerRadius = UDim.new(0, 8)

local hint = make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 28),
    Position = UDim2.fromOffset(10, 258),
    BackgroundTransparency = 1,
    Text = "비행: 카메라 방향으로 이동",
    TextColor3 = Color3.fromRGB(215, 195, 225),
    TextSize = 11,
    Font = Enum.Font.Gotham
}, frame)

-- GUI 드래그
title.Active = true

local dragging = false
local dragInput
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragInput = input
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end

    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input == dragInput then

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local currentSpeed = 16

local function getCharacter()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if humanoid and root then
        return character, humanoid, root
    end
end

-- 이동속도
speedApply.Activated:Connect(function()
    local value = tonumber(speedBox.Text)

    if not value then
        speedBox.Text = tostring(currentSpeed)
        return
    end

    currentSpeed = math.clamp(math.floor(value), 1, 500)
    speedBox.Text = tostring(currentSpeed)

    local _, humanoid = getCharacter()

    if humanoid then
        humanoid.WalkSpeed = currentSpeed
    end
end)

-- 슈퍼 점프 ON/OFF
local superJumpEnabled = false
local normalUseJumpPower
local normalJumpPower
local normalJumpHeight

local function updateJump(humanoid)
    if not humanoid then return end

    if normalUseJumpPower == nil then
        normalUseJumpPower = humanoid.UseJumpPower
        normalJumpPower = humanoid.JumpPower
        normalJumpHeight = humanoid.JumpHeight
    end

    if superJumpEnabled then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = 120
    else
        humanoid.UseJumpPower = normalUseJumpPower
        humanoid.JumpPower = normalJumpPower
        humanoid.JumpHeight = normalJumpHeight
    end
end

jumpToggle.Activated:Connect(function()
    superJumpEnabled = not superJumpEnabled

    jumpToggle.Text = superJumpEnabled
        and "슈퍼 점프: ON"
        or "슈퍼 점프: OFF"

    local _, humanoid = getCharacter()

    if humanoid then
        updateJump(humanoid)
    end
end)

-- 비행
local flying = false
local bodyVelocity
local bodyGyro
local flyLoop

local function stopFly()
    flying = false

    if flyLoop then
        flyLoop:Disconnect()
        flyLoop = nil
    end

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    local _, humanoid = getCharacter()

    if humanoid then
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
    end

    flyToggle.Text = "비행: OFF"
end

local function startFly()
    local _, humanoid, root = getCharacter()

    if not humanoid or not root then return end

    flying = true
    flyToggle.Text = "비행: ON"

    humanoid.PlatformStand = true
    humanoid.AutoRotate = false

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.P = 1e4
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 1e4
    bodyGyro.Parent = root

    flyLoop = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        local localMove =
            camera.CFrame:VectorToObjectSpace(humanoid.MoveDirection)

        local rightAmount = localMove.X
        local forwardAmount = -localMove.Z

        local direction =
            camera.CFrame.RightVector * rightAmount
            + camera.CFrame.LookVector * forwardAmount

        bodyVelocity.Velocity = direction * 55
        bodyGyro.CFrame = camera.CFrame
    end)
end

flyToggle.Activated:Connect(function()
    if flying then
        stopFly()
    else
        startFly()
    end
end)

-- 캐릭터 재생성 시 설정 복원
player.CharacterAdded:Connect(function()
    stopFly()
    task.wait(0.5)

    local _, humanoid = getCharacter()

    if humanoid then
        humanoid.WalkSpeed = currentSpeed

        normalUseJumpPower = nil
        normalJumpPower = nil
        normalJumpHeight = nil

        updateJump(humanoid)
    end
end)

-- 닫기
close.Activated:Connect(function()
    stopFly()
    gui:Destroy()
end)

task.defer(function()
    local _, humanoid = getCharacter()

    if humanoid then
        humanoid.WalkSpeed = currentSpeed
        updateJump(humanoid)
    end
end)
