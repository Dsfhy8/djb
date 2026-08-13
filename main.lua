local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- ========== 状态变量 ==========
local flying = false
local flySpeed = 50
local vehicleFlying = false
local walkSpeed = 16
local jumpPower = 50
local infiniteJump = false
local gravity = 196.2
local noclip = false
local semiNoclip = false
local espPlayers = false
local espItems = false
local aimbotEnabled = false
local aimSmoothness = 0.5
local godMode = false
local infStamina = false
local fov = 70
local nightVision = false
local antiFallDamage = false
local speedBoost = false
local tpPositions = {}

local bodyGyro, bodyVel = nil, nil
local vehicleGyro, vehicleVel = nil, nil

local leftJoyActive, leftJoyInput = false, Vector2.zero
local rightJoyActive, rightJoyInput = false, Vector2.zero

-- ========== GUI 创建 ==========
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "脚本中心"
gui.ResetOnSpawn = false

-- 主窗口（较小 420x420）
local win = Instance.new("Frame", gui)
win.Size = UDim2.new(0, 420, 0, 420)
win.Position = UDim2.new(0.5, -210, 0.5, -210)
win.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
win.Visible = false
win.ZIndex = 50
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 10)

-- 飞行控制面板
local flyPanel = Instance.new("Frame", gui)
flyPanel.Size = UDim2.new(0, 280, 0, 200)
flyPanel.Position = UDim2.new(0.8, -140, 0.65, -100)
flyPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
flyPanel.BackgroundTransparency = 0.2
flyPanel.Visible = false
flyPanel.ZIndex = 60
Instance.new("UICorner", flyPanel).CornerRadius = UDim.new(0, 10)

-- 标题栏
local titleBar = Instance.new("Frame", win)
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -30, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "脚本中心"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-28,0,4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 12
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0,4)
closeBtn.MouseButton1Click:Connect(function() win.Visible = false end)

-- 侧边栏（可滚动，功能多，高度足够）
local sidebar = Instance.new("Frame", win)
sidebar.Size = UDim2.new(0, 110, 1, -32)
sidebar.Position = UDim2.new(0,0,0,32)
sidebar.BackgroundColor3 = Color3.fromRGB(35,35,35)
sidebar.BorderSizePixel = 0

local sidebarScroll = Instance.new("ScrollingFrame", sidebar)
sidebarScroll.Size = UDim2.new(1, 0, 1, 0)
sidebarScroll.Position = UDim2.new(0, 0, 0, 0)
sidebarScroll.BackgroundTransparency = 1
sidebarScroll.ScrollBarThickness = 6
sidebarScroll.ScrollingDirection = Enum.ScrollingDirection.Y
sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, 1000)
sidebarScroll.BottomImage = "rbxassetid://0"
sidebarScroll.TopImage = "rbxassetid://0"
sidebarScroll.ClipsDescendants = true
sidebarScroll.TouchEnabled = true
sidebarScroll.TouchPanSpeed = 35

local sidebarList = Instance.new("UIListLayout", sidebarScroll)
sidebarList.Padding = UDim.new(0, 6)
sidebarList.FillDirection = Enum.FillDirection.Vertical
sidebarList.SortOrder = Enum.SortOrder.LayoutOrder

-- 内容区
local content = Instance.new("Frame", win)
content.Size = UDim2.new(1, -110, 1, -32)
content.Position = UDim2.new(0, 110, 0, 32)
content.BackgroundColor3 = Color3.fromRGB(25,25,25)
content.BorderSizePixel = 0

-- 页面管理
local pages = {}
local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = (pageName == name)
    end
    for _, btn in ipairs(sidebarScroll:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3 = (btn.Text == name) and Color3.fromRGB(80,130,200) or Color3.fromRGB(55,55,55)
        end
    end
end

local function addSideButton(text, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.Position = UDim2.new(0, 6, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(55,55,55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.LayoutOrder = #sidebarScroll:GetChildren()
    btn.Parent = sidebarScroll
    btn.MouseButton1Click:Connect(function() showPage(pageName) end)
end

-- 滑条
local function addSlider(parent, label, min, max, default, callback, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0, 80, 0, 20)
    lbl.Position = UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLabel = Instance.new("TextLabel", frame)
    valLabel.Size = UDim2.new(0, 40, 0, 20)
    valLabel.Position = UDim2.new(1, -40, 0, 0)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(default)
    valLabel.TextColor3 = Color3.new(1,1,1)
    valLabel.Font = Enum.Font.SourceSansBold
    valLabel.TextSize = 13
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local sliderBg = Instance.new("Frame", frame)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(80,80,80)
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,4)

    local fill = Instance.new("Frame", sliderBg)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(80,130,200)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)

    local knob = Instance.new("TextButton", sliderBg)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default-min)/(max-min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.Text = ""
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local draggingSlider = false
    local function updateSlider(input)
        local relX = input.Position.X - sliderBg.AbsolutePosition.X
        local percent = math.clamp(relX / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + percent*(max-min))
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        valLabel.Text = tostring(value)
        callback(value)
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
        end
    end)
    knob.InputEnded:Connect(function() draggingSlider = false end)
    uis.InputChanged:Connect(function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            updateSlider(input)
        end
    end)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input)
            draggingSlider = true
        end
    end)
    sliderBg.InputEnded:Connect(function() draggingSlider = false end)
end

-- 开关按钮
local function addToggle(parent, text, default, callback, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = default and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
    btn.Text = text .. "：" .. (default and "开" or "关")
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
    btn.Parent = parent

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
        btn.Text = text .. "：" .. (state and "开" or "关")
        callback(state)
    end)
    callback(default)
end

-- 创建页面
local function createPage(name)
    local page = Instance.new("Frame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    pages[name] = page
    return page
end

-- ESP更新
local function updateESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and (obj.Name == "玩家高亮" or obj.Name == "物品高亮") then
            obj:Destroy()
        end
    end
    if espPlayers then
        for _, target in ipairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "玩家高亮"
                hl.FillColor = Color3.fromRGB(255,0,0)
                hl.OutlineColor = Color3.fromRGB(255,255,255)
                hl.Parent = target.Character
            end
        end
    end
    if espItems then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:FindFirstChild("Humanoid") then
                local hl = Instance.new("Highlight")
                hl.Name = "物品高亮"
                hl.FillColor = Color3.fromRGB(0,255,0)
                hl.OutlineColor = Color3.fromRGB(0,0,0)
                hl.Parent = obj
            end
        end
    end
end

-- ========== 飞行面板内容 ==========
local panelDragging = false
local panelDragStart = nil
local panelStartPos = nil
flyPanel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        panelDragging = true
        panelDragStart = input.Position
        panelStartPos = flyPanel.Position
    end
end)
flyPanel.InputEnded:Connect(function() panelDragging = false end)
uis.InputChanged:Connect(function(input)
    if panelDragging and panelDragStart and panelStartPos and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - panelDragStart
        flyPanel.Position = UDim2.new(panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X, panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y)
    end
end)

-- 左摇杆
local leftJoyBase = Instance.new("Frame", flyPanel)
leftJoyBase.Size = UDim2.new(0,90,0,90)
leftJoyBase.Position = UDim2.new(0.15,-45,0.5,-45)
leftJoyBase.BackgroundColor3 = Color3.fromRGB(60,60,60)
leftJoyBase.BackgroundTransparency = 0.3
Instance.new("UICorner", leftJoyBase).CornerRadius = UDim.new(1,0)
local leftJoyKnob = Instance.new("TextButton", leftJoyBase)
leftJoyKnob.Size = UDim2.new(0,36,0,36)
leftJoyKnob.Position = UDim2.new(0.5,-18,0.5,-18)
leftJoyKnob.BackgroundColor3 = Color3.fromRGB(80,130,200)
leftJoyKnob.Text = ""
leftJoyKnob.AutoButtonColor = false
Instance.new("UICorner", leftJoyKnob).CornerRadius = UDim.new(1,0)

local function getLeftJoyInput(inputPosition)
    local center = leftJoyBase.AbsolutePosition + leftJoyBase.AbsoluteSize/2
    local vector = inputPosition - center
    local maxDist = leftJoyBase.AbsoluteSize.X/2
    if vector.Magnitude > maxDist then vector = vector.Unit * maxDist end
    return vector/maxDist
end
leftJoyBase.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        leftJoyActive = true
        leftJoyInput = getLeftJoyInput(input.Position)
        leftJoyKnob.Position = UDim2.new(0.5 + leftJoyInput.X/2 - 0.5, 0, 0.5 + leftJoyInput.Y/2 - 0.5, 0)
    end
end)
leftJoyBase.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        leftJoyActive = false
        leftJoyInput = Vector2.zero
        leftJoyKnob.Position = UDim2.new(0.5,-18,0.5,-18)
    end
end)
uis.InputChanged:Connect(function(input)
    if leftJoyActive and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        leftJoyInput = getLeftJoyInput(input.Position)
        leftJoyKnob.Position = UDim2.new(0.5 + leftJoyInput.X/2 - 0.5, 0, 0.5 + leftJoyInput.Y/2 - 0.5, 0)
    end
end)

-- 右摇杆
local rightJoyBase = Instance.new("Frame", flyPanel)
rightJoyBase.Size = UDim2.new(0,90,0,90)
rightJoyBase.Position = UDim2.new(0.85,-45,0.5,-45)
rightJoyBase.BackgroundColor3 = Color3.fromRGB(60,60,60)
rightJoyBase.BackgroundTransparency = 0.3
Instance.new("UICorner", rightJoyBase).CornerRadius = UDim.new(1,0)
local rightJoyKnob = Instance.new("TextButton", rightJoyBase)
rightJoyKnob.Size = UDim2.new(0,36,0,36)
rightJoyKnob.Position = UDim2.new(0.5,-18,0.5,-18)
rightJoyKnob.BackgroundColor3 = Color3.fromRGB(200,100,50)
rightJoyKnob.Text = ""
rightJoyKnob.AutoButtonColor = false
Instance.new("UICorner", rightJoyKnob).CornerRadius = UDim.new(1,0)

local function getRightJoyInput(inputPosition)
    local center = rightJoyBase.AbsolutePosition + rightJoyBase.AbsoluteSize/2
    local vector = inputPosition - center
    local maxDist = rightJoyBase.AbsoluteSize.X/2
    if vector.Magnitude > maxDist then vector = vector.Unit * maxDist end
    return vector/maxDist
end
rightJoyBase.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        rightJoyActive = true
        rightJoyInput = getRightJoyInput(input.Position)
        rightJoyKnob.Position = UDim2.new(0.5 + rightJoyInput.X/2 - 0.5, 0, 0.5 + rightJoyInput.Y/2 - 0.5, 0)
    end
end)
rightJoyBase.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        rightJoyActive = false
        rightJoyInput = Vector2.zero
        rightJoyKnob.Position = UDim2.new(0.5,-18,0.5,-18)
    end
end)
uis.InputChanged:Connect(function(input)
    if rightJoyActive and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        rightJoyInput = getRightJoyInput(input.Position)
        rightJoyKnob.Position = UDim2.new(0.5 + rightJoyInput.X/2 - 0.5, 0, 0.5 + rightJoyInput.Y/2 - 0.5, 0)
    end
end)

-- 面板关闭按钮
local panelClose = Instance.new("TextButton", flyPanel)
panelClose.Size = UDim2.new(0,20,0,20)
panelClose.Position = UDim2.new(1,-22,0,2)
panelClose.BackgroundColor3 = Color3.fromRGB(200,60,60)
panelClose.Text = "X"
panelClose.TextColor3 = Color3.new(1,1,1)
panelClose.Font = Enum.Font.SourceSansBold
panelClose.TextSize = 12
Instance.new("UICorner", panelClose).CornerRadius = UDim.new(0,4)
panelClose.MouseButton1Click:Connect(function() flyPanel.Visible = false end)

-- ========== 页面创建 ==========
-- 飞行页面
local flyPage = createPage("飞行")
local flyToggle = Instance.new("TextButton")
flyToggle.Size = UDim2.new(1,-20,0,36)
flyToggle.Position = UDim2.new(0,10,0,10)
flyToggle.BackgroundColor3 = Color3.fromRGB(255,100,100)
flyToggle.Text = "飞行：关"
flyToggle.TextColor3 = Color3.new(1,1,1)
flyToggle.Font = Enum.Font.SourceSansBold
flyToggle.TextSize = 16
flyToggle.AutoButtonColor = false
Instance.new("UICorner", flyToggle).CornerRadius = UDim.new(0,6)
flyToggle.Parent = flyPage
flyToggle.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        flyToggle.Text = "飞行：开"
        flyToggle.BackgroundColor3 = Color3.fromRGB(100,255,100)
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro", root)
            bodyGyro.P = 9e4
            bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
            bodyGyro.CFrame = root.CFrame
            bodyVel = Instance.new("BodyVelocity", root)
            bodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
            bodyVel.Velocity = Vector3.zero
            hum.PlatformStand = true
        end
        flyPanel.Visible = true
    else
        flyToggle.Text = "飞行：关"
        flyToggle.BackgroundColor3 = Color3.fromRGB(255,100,100)
        if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
        if bodyVel then bodyVel:Destroy(); bodyVel = nil end
        hum.PlatformStand = false
        flyPanel.Visible = false
    end
end)

local vehicleFlyToggle = Instance.new("TextButton")
vehicleFlyToggle.Size = UDim2.new(1,-20,0,36)
vehicleFlyToggle.Position = UDim2.new(0,10,0,55)
vehicleFlyToggle.BackgroundColor3 = Color3.fromRGB(255,100,100)
vehicleFlyToggle.Text = "载具飞行：关"
vehicleFlyToggle.TextColor3 = Color3.new(1,1,1)
vehicleFlyToggle.Font = Enum.Font.SourceSansBold
vehicleFlyToggle.TextSize = 14
vehicleFlyToggle.AutoButtonColor = false
Instance.new("UICorner", vehicleFlyToggle).CornerRadius = UDim.new(0,6)
vehicleFlyToggle.Parent = flyPage
vehicleFlyToggle.MouseButton1Click:Connect(function()
    vehicleFlying = not vehicleFlying
    if vehicleFlying then
        vehicleFlyToggle.Text = "载具飞行：开"
        vehicleFlyToggle.BackgroundColor3 = Color3.fromRGB(100,255,100)
    else
        vehicleFlyToggle.Text = "载具飞行：关"
        vehicleFlyToggle.BackgroundColor3 = Color3.fromRGB(255,100,100)
    end
end)

addSlider(flyPage, "飞行速度", 10, 200, 50, function(v) flySpeed = v end, 100)

-- 速度页面
local speedPage = createPage("速度")
addSlider(speedPage, "走路速度", 16, 100, 16, function(v) walkSpeed = v; hum.WalkSpeed = v end, 10)
addSlider(speedPage, "跳跃高度", 50, 200, 50, function(v) jumpPower = v; hum.JumpPower = v end, 60)
addToggle(speedPage, "冲刺加速", false, function(v) speedBoost = v end, 110)

-- 跳跃页面
local jumpPage = createPage("跳跃")
addSlider(jumpPage, "跳跃高度", 50, 200, 50, function(v) jumpPower = v; hum.JumpPower = v end, 10)
addToggle(jumpPage, "无限跳", false, function(v) infiniteJump = v end, 60)

-- 重力页面
local gravPage = createPage("重力")
addSlider(gravPage, "重力", 0, 196.2, 196.2, function(v) gravity = v; workspace.Gravity = v end, 10)

-- 穿墙页面
local noclipPage = createPage("穿墙")
addToggle(noclipPage, "完整穿墙", false, function(v) noclip = v end, 10)
addToggle(noclipPage, "半穿墙", false, function(v)
    semiNoclip = v
    if v then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = false end
        end
    else
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end, 60)

-- 透视页面
local espPage = createPage("透视")
addToggle(espPage, "玩家透视", false, function(v) espPlayers = v; updateESP() end, 10)
addToggle(espPage, "物品透视", false, function(v) espItems = v; updateESP() end, 60)

-- 自瞄页面
local aimbotPage = createPage("自瞄")
addToggle(aimbotPage, "自瞄", false, function(v) aimbotEnabled = v end, 10)
addSlider(aimbotPage, "平滑度", 0, 1, 0.5, function(v) aimSmoothness = v end, 60)

-- 神模式页面
local godPage = createPage("神模式")
addToggle(godPage, "无敌模式", false, function(v)
    godMode = v
    if v then
        hum.MaxHealth = 99999
        hum.Health = 99999
    else
        hum.MaxHealth = 100
        hum.Health = 100
    end
end, 10)
addToggle(godPage, "无限体力", false, function(v) infStamina = v end, 60)

-- 视野页面
local viewPage = createPage("视野")
addSlider(viewPage, "视野范围", 30, 120, 70, function(v)
    fov = v
    if workspace.CurrentCamera then workspace.CurrentCamera.FieldOfView = v end
end, 10)
addToggle(viewPage, "夜视", false, function(v)
    nightVision = v
    local lighting = game:GetService("Lighting")
    if v then
        lighting.Brightness = 2
        lighting.ClockTime = 14
    else
        lighting.Brightness = 1
        lighting.ClockTime = 14
    end
end, 60)
addToggle(viewPage, "防摔落伤害", false, function(v) antiFallDamage = v end, 110)

-- 传送页面
local teleportPage = createPage("传送")
local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1,-20,0,20)
tpLabel.Position = UDim2.new(0,10,0,10)
tpLabel.BackgroundTransparency = 1
tpLabel.Text = "点击保存当前位置，点击传送回到保存点"
tpLabel.TextColor3 = Color3.new(1,1,1)
tpLabel.Font = Enum.Font.SourceSansBold
tpLabel.TextSize = 12
tpLabel.TextWrapped = true
tpLabel.Parent = teleportPage

local saveTpBtn = Instance.new("TextButton")
saveTpBtn.Size = UDim2.new(1,-20,0,36)
saveTpBtn.Position = UDim2.new(0,10,0,50)
saveTpBtn.BackgroundColor3 = Color3.fromRGB(80,130,200)
saveTpBtn.Text = "保存位置"
saveTpBtn.TextColor3 = Color3.new(1,1,1)
saveTpBtn.Font = Enum.Font.SourceSansBold
saveTpBtn.TextSize = 14
saveTpBtn.Parent = teleportPage
saveTpBtn.MouseButton1Click:Connect(function()
    if root then
        table.insert(tpPositions, root.Position)
        tpLabel.Text = "已保存位置！共" .. #tpPositions .. "个点"
    end
end)

local loadTpBtn = Instance.new("TextButton")
loadTpBtn.Size = UDim2.new(1,-20,0,36)
loadTpBtn.Position = UDim2.new(0,10,0,95)
loadTpBtn.BackgroundColor3 = Color3.fromRGB(200,100,50)
loadTpBtn.Text = "传送到保存点"
loadTpBtn.TextColor3 = Color3.new(1,1,1)
loadTpBtn.Font = Enum.Font.SourceSansBold
loadTpBtn.TextSize = 14
loadTpBtn.Parent = teleportPage
loadTpBtn.MouseButton1Click:Connect(function()
    if #tpPositions > 0 and root then
        root.CFrame = CFrame.new(tpPositions[#tpPositions])
        tpLabel.Text = "已传送到最近保存点"
    else
        tpLabel.Text = "没有保存点"
    end
end)

-- 侧边栏按钮（按顺序，多到离谱）
addSideButton("飞行", "飞行")
addSideButton("速度", "速度")
addSideButton("跳跃", "跳跃")
addSideButton("重力", "重力")
addSideButton("穿墙", "穿墙")
addSideButton("透视", "透视")
addSideButton("自瞄", "自瞄")
addSideButton("神模式", "神模式")
addSideButton("视野", "视野")
addSideButton("传送", "传送")

-- 默认页面
pages["飞行"].Visible = true

-- 右侧边缘按钮
local edgeBtn = Instance.new("TextButton", gui)
edgeBtn.Size = UDim2.new(0, 50, 0, 100)
edgeBtn.Position = UDim2.new(1, -50, 0.5, -50)
edgeBtn.BackgroundColor3 = Color3.fromRGB(70,130,200)
edgeBtn.Text = "菜单"
edgeBtn.TextColor3 = Color3.new(1,1,1)
edgeBtn.Font = Enum.Font.SourceSansBold
edgeBtn.TextSize = 14
edgeBtn.BorderSizePixel = 0
edgeBtn.AutoButtonColor = false
edgeBtn.ZIndex = 80
Instance.new("UICorner", edgeBtn).CornerRadius = UDim.new(0,8)
edgeBtn.MouseButton1Click:Connect(function()
    win.Visible = not win.Visible
end)

-- ========== 主循环 ==========
rs.RenderStepped:Connect(function()
    -- 飞行
    if flying and bodyVel and bodyGyro and root then
        local cam = workspace.CurrentCamera
        if cam then
            local dir = Vector3.zero
            dir += cam.CFrame.RightVector * leftJoyInput.X
            dir += cam.CFrame.LookVector * leftJoyInput.Y
            dir += Vector3.new(0, rightJoyInput.Y, 0)
            bodyVel.Velocity = (dir.Magnitude > 0) and (dir.Unit * flySpeed) or Vector3.zero
            bodyGyro.CFrame = CFrame.lookAt(root.Position, root.Position + cam.CFrame.LookVector)
        end
    end

    -- 载具飞行
    if vehicleFlying then
        local vehicle = findVehicle()
        if vehicle then
            if not vehicleGyro then
                vehicleGyro = Instance.new("BodyGyro", vehicle)
                vehicleGyro.P = 9e4
                vehicleGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
                vehicleVel = Instance.new("BodyVelocity", vehicle)
                vehicleVel.MaxForce = Vector3.new(9e9,9e9,9e9)
            end
            local cam = workspace.CurrentCamera
            if cam then
                local dir = Vector3.zero
                dir += cam.CFrame.RightVector * leftJoyInput.X
                dir += cam.CFrame.LookVector * leftJoyInput.Y
                dir += Vector3.new(0, rightJoyInput.Y, 0)
                vehicleVel.Velocity = (dir.Magnitude > 0) and (dir.Unit * flySpeed) or Vector3.zero
                vehicleGyro.CFrame = CFrame.lookAt(vehicle.Position, vehicle.Position + cam.CFrame.LookVector)
            end
        else
            if vehicleGyro then vehicleGyro:Destroy(); vehicleGyro = nil end
            if vehicleVel then vehicleVel:Destroy(); vehicleVel = nil end
        end
    else
        if vehicleGyro then vehicleGyro:Destroy(); vehicleGyro = nil end
        if vehicleVel then vehicleVel:Destroy(); vehicleVel = nil end
    end

    -- 穿墙
    if noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    elseif semiNoclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = false end
        end
    end

    -- 无限跳
    if infiniteJump and hum and hum.FloorMaterial ~= Enum.Material.Air then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- 无敌
    if godMode and hum then
        hum.Health = hum.MaxHealth
    end

    -- 无限体力
    if infStamina and hum then
        -- 可根据具体游戏实现
    end

    -- 冲刺加速
    if speedBoost and hum then
        hum.WalkSpeed = walkSpeed * 1.5
    end

    -- 防摔落伤害
    if antiFallDamage and hum then
        hum.FallSpeed = 0
    end

    -- 自瞄
    if aimbotEnabled and char and root then
        local nearest = nil
        local nearestDist = math.huge
        for _, target in ipairs(game.Players:GetPlayers()) do
            if target ~= player and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetRoot = target.Character.HumanoidRootPart
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearest = targetRoot
                end
            end
        end
        if nearest then
            local cam = workspace.CurrentCamera
            local targetCFrame = CFrame.lookAt(cam.CFrame.Position, nearest.Position)
            cam.CFrame = cam.CFrame:Lerp(targetCFrame, aimSmoothness)
        end
    end

    -- FOV
    if workspace.CurrentCamera then
        workspace.CurrentCamera.FieldOfView = fov
    end
end)

local function findVehicle()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("VehicleSeat") then
            return v:FindFirstChild("VehicleSeat") or v:FindFirstChildWhichIsA("BasePart")
        end
    end
    return nil
end

player.CharacterAdded:Connect(function(c)
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
    if vehicleGyro then vehicleGyro:Destroy(); vehicleGyro = nil end
    if vehicleVel then vehicleVel:Destroy(); vehicleVel = nil end
    flying = false
    flyToggle.Text = "飞行：关"
    flyToggle.BackgroundColor3 = Color3.fromRGB(255,100,100)
    flyPanel.Visible = false
    char = c
    hum = c:WaitForChild("Humanoid")
    root = c:WaitForChild("HumanoidRootPart")
    hum.WalkSpeed = walkSpeed
    hum.JumpPower = jumpPower
    workspace.Gravity = gravity
    noclip = false
    semiNoclip = false
    espPlayers = false
    espItems = false
    aimbotEnabled = false
    godMode = false
    infiniteJump = false
    infStamina = false
    speedBoost = false
    antiFallDamage = false
end)
