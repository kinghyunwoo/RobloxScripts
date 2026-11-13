
--==================================================
-- KINGHYUNWOO HUB
-- ZERO GRAVITY CAMERA FLY
-- SPEED / SUPER JUMP / MINIMIZE
--==================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
if not player then return end

pcall(function()
    local old = CoreGui:FindFirstChild("KINGHYUNWOO")
    if old then old:Destroy() end
end)

-- SETTINGS
local currentSpeed = 16
local flying = false
local superJumpEnabled = false

local bodyVelocity
local bodyGyro
local flyLoop
local oldAutoRotate

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KINGHYUNWOO"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local frame = make("Frame", {
    Size = UDim2.fromOffset(285, 300),
    Position = UDim2.new(0.5, -142, 0.5, -150),
    BackgroundColor3 = Color3.fromRGB(35, 18, 55),
    BorderSizePixel = 0,
    Active = true
}, gui)

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(225, 90, 220)
stroke.Thickness = 2
stroke.Parent = frame

local title = make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 43),
    BackgroundColor3 = Color3.fromRGB(155, 55, 205),
    Text = "KINGHYUNWOO HUB",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 18,
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

-- MINIMIZE
local minimized = false
local normalSize = frame.Size

minimize.Activated:Connect(function()
    minimized = not minimized

    for _, child in ipairs(frame:GetChildren()) do
        if child ~= title and child ~= close and child ~= minimize
        and not child:IsA("UICorner")
        and not child:IsA("UIStroke") then
            child.Visible = not minimized
        end
    end

    frame.Size = minimized
        and UDim2.fromOffset(175, 43)
        or normalSize

    minimize.Text = minimized and "+" or "ㅡ"
end)

-- SPEED
local speedBox = make("TextBox", {
    Size = UDim2.new(1, -30, 0, 40),
    Position = UDim2.fromOffset(15, 58),
    BackgroundColor3 = Color3.fromRGB(65, 35, 85),
    Text = "16",
    PlaceholderText = "이동속도 입력 (1~500)",
    TextColor3 = Color3.new(1, 1, 1),
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
    Text = "무중력 비행: 조이스틱 + 카메라",
    TextColor3 = Color3.fromRGB(215, 195, 225),
    TextSize = 11,
    Font = Enum.Font.Gotham
}, frame)

-- DRAG
title.Active = true

local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
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
    or input.UserInputType == Enum.UserInputType.Touch then

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- CHARACTER
local function getCharacter()
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    if humanoid and root then
        return character, humanoid, root
    end
end

-- SPEED APPLY
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

-- SUPER JUMP
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

--==================================================
-- ZERO GRAVITY FLY
--==================================================

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
        humanoid.AutoRotate = oldAutoRotate ~= nil
            and oldAutoRotate or true

        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
    end

    flyToggle.Text = "비행: OFF"
end

local function startFly()
    local _, humanoid, root = getCharacter()

    if not humanoid or not root then return end

    flying = true
    oldAutoRotate = humanoid.AutoRotate

    flyToggle.Text = "비행: ON"

    humanoid.PlatformStand = false
    humanoid.AutoRotate = false
    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

    -- 무중력 상태를 유지하면서 이동/정지 제어
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.P = 50000
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 30000
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    flyLoop = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent or humanoid.Health <= 0 then
            stopFly()
            return
        end

        local camera = workspace.CurrentCamera
        if not camera then return end

        -- 모바일 조이스틱 입력 읽기
        local moveDirection = humanoid.MoveDirection

        -- 카메라 기준 이동 입력
        local localMove =
            camera.CFrame:VectorToObjectSpace(moveDirection)

        local forward = -localMove.Z
        local right = localMove.X

        -- 카메라가 바라보는 방향으로 이동
        local direction =
            camera.CFrame.LookVector * forward
            + camera.CFrame.RightVector * right

        if direction.Magnitude > 0.05 then
            direction = direction.Unit

            bodyVelocity.Velocity =
                direction * currentSpeed
        else
            -- 조이스틱을 놓으면 완전히 정지
            bodyVelocity.Velocity = Vector3.zero
        end

        -- 카메라 방향 유지
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

-- RESPAWN
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

-- CLOSE
close.Activated:Connect(function()
    stopFly()
    gui:Destroy()
end)

-- INITIALIZE
task.defer(function()
    local _, humanoid = getCharacter()

    if humanoid then
        humanoid.WalkSpeed = currentSpeed
        updateJump(humanoid)
    end
end)
