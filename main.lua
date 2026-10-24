-- ==================== 反作弊基础绕过 ====================
pcall(function()
    local oldNameCall
    oldNameCall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" then return end
        return oldNameCall(self, ...)
    end)
end)

local player=game.Players.LocalPlayer

-- 黑名单检查
local blacklist = {}
for _, name in ipairs(blacklist) do
    if player.Name == name then
        pcall(function() player:Kick("你已被此脚本拉黑") end)
        return
    end
end

local cam=workspace.CurrentCamera
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=workspace
local UIS=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local TweenService=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")

local scriptClosed=false
local introFinished=false
local introCoroutine=nil
local isDev = (player.Name == "Dsfhy8")

local st={
    aim=false,lockh=false,silent=false,wallcheck=false,teamcheck=false,aimrange=200,
    aimCircle=false,aimCircleSize=100,aimSmooth=0.12,
    hitbox=false, hitboxSize=3,
    esp=false,espBox=false,espn=false,espd=false,esphp=false,espnpc=true,espRange=500,
    espTeamcheck=false,espBones=false,espHpBar=false,
    speed=false,walkspeed=16,jumpboost=false,jumppower=50,autobhop=false,third=false,
    night=false,nofall=false,
    fly=false,flyspeed=50,flyNoclip=false,noclip=false,noplayercol=false,zoom=false,
    savepos=false,tpto=false,swimBoost=false,waterWalk=false,
    trackPlayer=false,spin=false,spinSpeed=50,fastInteract=false,
    watchedAlert=false,showTargetList=false,
    lowGraphics=false, freeCam=false,
    antiflash=false, antismoke=false, antishake=false
}

local savedPos=nil
local bodyGyro,bodyVel,bodyFloat,bodySpin
local selectedTarget=nil
local targetList={}
local targetIndex=0
local baseWalkSpeed=16
local baseJumpPower=50
local appliedWalkSpeed=nil
local appliedJumpPower=nil
local watchedHumanoid=nil
local healthConn=nil
local flyProtectUntil=0

local espColorList={
    Color3.fromRGB(255,255,255), Color3.fromRGB(0,255,100), Color3.fromRGB(255,80,80),
    Color3.fromRGB(255,255,0), Color3.fromRGB(180,80,255), Color3.fromRGB(0,200,255),
    Color3.fromRGB(255,100,200)
}
local espColorIndex=1
local aimColorList={
    Color3.fromRGB(255,255,255), Color3.fromRGB(0,255,100), Color3.fromRGB(255,80,80),
    Color3.fromRGB(255,255,0), Color3.fromRGB(180,80,255), Color3.fromRGB(0,200,255)
}
local aimColorIndex=1

local function notif(text)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title="机械脚本",Text=text,Duration=5})
    end)
end

local function recordBaseSpeed()
    if player.Character then
        local hum=player.Character:FindFirstChild("Humanoid")
        if hum then
            baseWalkSpeed=hum.WalkSpeed
            baseJumpPower=hum.JumpPower
            st.walkspeed=baseWalkSpeed
            st.jumppower=baseJumpPower
        end
    end
end
recordBaseSpeed()
player.CharacterAdded:Connect(function()
    task.wait(0.5)
    recordBaseSpeed()
end)

local function bindHealthProtection(hum)
    if healthConn then healthConn:Disconnect() end
    healthConn=hum.HealthChanged:Connect(function(newHealth)
        if scriptClosed then return end
        local protect=st.fly or (os.clock()<flyProtectUntil)
        if protect and newHealth<hum.MaxHealth then
            pcall(function() hum.Health=hum.MaxHealth end)
        end
    end)
end

-- ==================== UI根 ====================
local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
gui.Name="机械脚本"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

local blur=Instance.new("BlurEffect",Lighting)
blur.Name="HackBlur"
blur.Size=60
blur.Enabled=false

-- ==================== 加载与欢迎界面 ====================
local hackOverlay=Instance.new("Frame",gui)
hackOverlay.Size=UDim2.new(3,0,3,0)
hackOverlay.Position=UDim2.new(-1,0,-1,0)
hackOverlay.BackgroundColor3=Color3.new(0,0,0)
hackOverlay.BackgroundTransparency=0.6
hackOverlay.BorderSizePixel=0
hackOverlay.ZIndex=300
hackOverlay.Visible=true

local rainFrame=Instance.new("Frame",hackOverlay)
rainFrame.Size=UDim2.new(1,0,1,0)
rainFrame.BackgroundTransparency=1
rainFrame.ZIndex=298
rainFrame.ClipsDescendants=true

local rainLabels={}
for i=1,25 do
    local label=Instance.new("TextLabel",rainFrame)
    label.Size=UDim2.new(0,18,0,120)
    label.Position=UDim2.new((i-1)/24,0,0,math.random(-300,0))
    label.BackgroundTransparency=1
    label.TextColor3=Color3.new(0,1,0)
    label.Font=Enum.Font.SourceSansBold
    label.TextSize=14
    label.Text=""
    table.insert(rainLabels,label)
end

task.spawn(function()
    while true do
        for _,label in ipairs(rainLabels) do
            local y=label.Position.Y.Offset+8
            if y>500 then y=-150 end
            label.Position=UDim2.new(label.Position.X.Scale,label.Position.X.Offset,0,y)
            local str=""
            for _=1,10 do str=str..string.char(math.random(48,57)).."\n" end
            label.Text=str
        end
        task.wait(0.1)
    end
end)

local terminal=Instance.new("Frame",hackOverlay)
terminal.Size=UDim2.new(0,380,0,360)
terminal.Position=UDim2.new(0.5,-190,0.5,-180)
terminal.BackgroundColor3=Color3.new(10/255,12/255,14/255)
terminal.BorderSizePixel=2
terminal.BorderColor3=Color3.new(0,1,0)
terminal.ZIndex=301

local termStroke = Instance.new("UIStroke", terminal)
termStroke.Color = Color3.fromRGB(0, 255, 100)
termStroke.Thickness = 1.5
termStroke.Transparency = 0.3

local termGrid = Instance.new("Frame", terminal)
termGrid.Size = UDim2.new(1,0,1,0)
termGrid.BackgroundTransparency = 1
termGrid.ZIndex = 301
for i=1,10 do
    local line = Instance.new("Frame", termGrid)
    line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,i/10,0)
    line.BackgroundColor3 = Color3.new(0,1,0)
    line.BackgroundTransparency = 0.9
    line.BorderSizePixel = 0
end

local termTitleBar=Instance.new("Frame",terminal)
termTitleBar.Size=UDim2.new(1,0,0,22)
termTitleBar.BackgroundColor3=Color3.new(0,30/255,0)
termTitleBar.BorderSizePixel=0
termTitleBar.ZIndex=302

local function createLED(x)
    local led = Instance.new("Frame", termTitleBar)
    led.Size = UDim2.new(0,8,0,8)
    led.Position = UDim2.new(0,x,0.5,-4)
    led.BackgroundColor3 = Color3.new(1,0,0)
    led.BorderSizePixel = 0
    led.ZIndex = 303
    local corner = Instance.new("UICorner", led)
    corner.CornerRadius = UDim.new(1,0)
    task.spawn(function()
        while true do
            task.wait(math.random(5,15)/10)
            led.BackgroundTransparency = math.random(0,1)
        end
    end)
end
createLED(10)
local ledY = Instance.new("Frame", termTitleBar)
ledY.Size = UDim2.new(0,8,0,8)
ledY.Position = UDim2.new(0,22,0.5,-4)
ledY.BackgroundColor3 = Color3.fromRGB(255,200,0)
ledY.BorderSizePixel = 0
ledY.ZIndex = 303
local cY = Instance.new("UICorner", ledY)
cY.CornerRadius = UDim.new(1,0)
task.spawn(function()
    while true do task.wait(math.random(5,10)/10); ledY.BackgroundTransparency = math.random(0,1) end
end)
createLED(34)

local termTitle=Instance.new("TextLabel",termTitleBar)
termTitle.Size=UDim2.new(1,-50,1,0)
termTitle.Position=UDim2.new(0,50,0,0)
termTitle.BackgroundTransparency=1
termTitle.Text="ROBLOX_EXPLOIT_CONSOLE"
termTitle.TextColor3=Color3.new(0,1,0)
termTitle.Font=Enum.Font.SourceSansBold
termTitle.TextSize=12
termTitle.TextXAlignment=Enum.TextXAlignment.Left
termTitle.ZIndex=302

local termText=Instance.new("TextLabel",terminal)
termText.Size=UDim2.new(1,-20,0,280)
termText.Position=UDim2.new(0,10,0,30)
termText.BackgroundTransparency=1
termText.TextColor3=Color3.new(0,1,0)
termText.Font=Enum.Font.SourceSansBold
termText.TextSize=14
termText.TextXAlignment=Enum.TextXAlignment.Left
termText.TextYAlignment=Enum.TextYAlignment.Top
termText.RichText=true
termText.ZIndex=303

local termScan = Instance.new("Frame", terminal)
termScan.Size = UDim2.new(1,0,0,2)
termScan.Position = UDim2.new(0,0,0,20)
termScan.BackgroundColor3 = Color3.fromRGB(0,255,100)
termScan.BackgroundTransparency = 0.8
termScan.BorderSizePixel = 0
termScan.ZIndex = 302
task.spawn(function()
    while true do
        task.wait(0.05)
        termScan.Position = UDim2.new(0,0, (termScan.Position.Y.Scale + 0.02)%1, 0)
    end
end)

local progressFrame=Instance.new("Frame",terminal)
progressFrame.Size=UDim2.new(1,-20,0,20)
progressFrame.Position=UDim2.new(0,10,1,-30)
progressFrame.BackgroundTransparency=1
progressFrame.Visible=false
progressFrame.ZIndex=303

local progressBg=Instance.new("Frame",progressFrame)
progressBg.Size=UDim2.new(1,0,0,10)
progressBg.Position=UDim2.new(0,0,0.5,-5)
progressBg.BackgroundColor3=Color3.fromRGB(40,40,40)
progressBg.BorderSizePixel=0

local progressFill=Instance.new("Frame",progressBg)
progressFill.Size=UDim2.new(0,0,1,0)
progressFill.BackgroundColor3=Color3.fromRGB(0,255,100)
progressFill.BorderSizePixel=0

local progressText=Instance.new("TextLabel",progressFrame)
progressText.Size=UDim2.new(1,0,0,14)
progressText.Position=UDim2.new(0,0,0,-14)
progressText.BackgroundTransparency=1
progressText.Text="> Loading... 0%"
progressText.TextColor3=Color3.fromRGB(0,255,100)
progressText.Font=Enum.Font.SourceSansBold
progressText.TextSize=12
progressText.TextXAlignment=Enum.TextXAlignment.Left
progressText.ZIndex=303

local skipButton
if isDev then
    skipButton=Instance.new("TextButton",gui)
    skipButton.Size=UDim2.new(0,140,0,32)
    skipButton.Position=UDim2.new(0,20,0.5,-16)
    skipButton.BackgroundColor3=Color3.new(0, 20/255, 0)
    skipButton.Text="[>>] SKIP_INJECTION"
    skipButton.TextColor3=Color3.fromRGB(0,255,100)
    skipButton.Font=Enum.Font.Code
    skipButton.TextSize=14
    skipButton.AutoLocalize=false
    skipButton.ZIndex=400
    skipButton.Visible=true
    
    local skipStroke = Instance.new("UIStroke", skipButton)
    skipStroke.Color = Color3.fromRGB(0,255,100)
    skipStroke.Thickness = 1
end

-- ==================== 欢迎界面 ====================
local welcomeOverlay=Instance.new("Frame",gui)
welcomeOverlay.Size=UDim2.new(3,0,3,0)
welcomeOverlay.Position=UDim2.new(-1,0,-1,0)
welcomeOverlay.BackgroundColor3=Color3.fromRGB(5,5,5)
welcomeOverlay.BackgroundTransparency=1
welcomeOverlay.BorderSizePixel=0
welcomeOverlay.ZIndex=2000
welcomeOverlay.Visible=false

local welcomeGrid = Instance.new("Frame", welcomeOverlay)
welcomeGrid.Size = UDim2.new(1,0,1,0)
welcomeGrid.BackgroundTransparency = 1
welcomeGrid.ZIndex = 2001
for i=1,20 do
    local vl = Instance.new("Frame", welcomeGrid)
    vl.Size = UDim2.new(0,1,1,0); vl.Position = UDim2.new(i/20,0,0,0)
    vl.BackgroundColor3 = Color3.new(0,1,0); vl.BackgroundTransparency = 0.95
    local hl = Instance.new("Frame", welcomeGrid)
    hl.Size = UDim2.new(1,0,0,1); hl.Position = UDim2.new(0,0,i/20,0)
    hl.BackgroundColor3 = Color3.new(0,1,0); hl.BackgroundTransparency = 0.95
end

local scanLine=Instance.new("Frame",welcomeOverlay)
scanLine.Size=UDim2.new(0,0,0,4)
scanLine.Position=UDim2.new(0.5,0,0.5,0)
scanLine.BackgroundColor3=Color3.fromRGB(0,255,100)
scanLine.BorderSizePixel=0
scanLine.ZIndex=2002
scanLine.Visible=false

local welcomeText=Instance.new("TextLabel",welcomeOverlay)
welcomeText.Size=UDim2.new(1,0,0,100)
welcomeText.Position=UDim2.new(0,0,0.5,-70)
welcomeText.BackgroundTransparency=1
welcomeText.Text="[ 欢迎使用机械脚本 V3.0 ]"
welcomeText.TextColor3=Color3.fromRGB(0,255,100)
welcomeText.Font=Enum.Font.Code
welcomeText.TextSize=42
welcomeText.TextTransparency=1
welcomeText.ZIndex=2003

local welcomeStroke=Instance.new("UIStroke",welcomeText)
welcomeStroke.Color=Color3.fromRGB(0,150,50)
welcomeStroke.Thickness=2
welcomeStroke.Transparency=1

local welcomeSub=Instance.new("TextLabel",welcomeOverlay)
welcomeSub.Size=UDim2.new(1,0,0,50)
welcomeSub.Position=UDim2.new(0,0,0.5,20)
welcomeSub.BackgroundTransparency=1
welcomeSub.Text="> SYSTEM UNLOCKED\n> WELCOME, OPERATOR: " .. player.Name
welcomeSub.TextColor3=Color3.fromRGB(0,200,80)
welcomeSub.Font=Enum.Font.Code
welcomeSub.TextSize=20
welcomeSub.TextTransparency=1
welcomeSub.ZIndex=2003

-- ==================== 灵动岛 ====================
local island=Instance.new("TextButton",gui)
island.Size=UDim2.new(0,170,0,36)
island.Position=UDim2.new(0.5,-85,0.02,0)
island.BackgroundColor3=Color3.new(0,0,0)
island.BackgroundTransparency=1
island.BorderSizePixel=0
island.Text=""
island.AutoLocalize=false
island.ZIndex=160
island.Visible=false
island.ClipsDescendants=true

local islandCorner=Instance.new("UICorner",island)
islandCorner.CornerRadius=UDim.new(1,0)

local borderFrame=Instance.new("Frame",island)
borderFrame.Size=UDim2.new(1,0,1,0)
borderFrame.BackgroundColor3=Color3.new(1,1,1)
borderFrame.BorderSizePixel=0
borderFrame.ZIndex=161

local borderCorner=Instance.new("UICorner",borderFrame)
borderCorner.CornerRadius=UDim.new(1,0)

local borderGradient=Instance.new("UIGradient",borderFrame)
borderGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,0.2,0.8)),
    ColorSequenceKeypoint.new(0.5, Color3.new(0.4,0.6,1)),
    ColorSequenceKeypoint.new(1, Color3.new(0.6,1,0.9))
})
borderGradient.Rotation=90

local innerFrame=Instance.new("Frame",island)
innerFrame.Size=UDim2.new(1,-4,1,-4)
innerFrame.Position=UDim2.new(0,2,0,2)
innerFrame.BackgroundColor3=Color3.new(20/255,20/255,20/255)
innerFrame.BackgroundTransparency=0.1
innerFrame.BorderSizePixel=0
innerFrame.ZIndex=162

local innerCorner=Instance.new("UICorner",innerFrame)
innerCorner.CornerRadius=UDim.new(1,0)

local moveIcon=Instance.new("TextLabel",innerFrame)
moveIcon.Size=UDim2.new(0,24,1,0)
moveIcon.Position=UDim2.new(0,6,0,0)
moveIcon.BackgroundTransparency=1
moveIcon.Text="⇔"
moveIcon.TextColor3=Color3.new(1,1,1)
moveIcon.Font=Enum.Font.SourceSansBold
moveIcon.TextSize=16
moveIcon.TextXAlignment=Enum.TextXAlignment.Center
moveIcon.TextYAlignment=Enum.TextYAlignment.Center
moveIcon.ZIndex=163

local titleLabel=Instance.new("TextLabel",innerFrame)
titleLabel.Size=UDim2.new(0,80,1,0)
titleLabel.Position=UDim2.new(0,32,0,0)
titleLabel.BackgroundTransparency=1
titleLabel.Text="机械脚本"
titleLabel.Font=Enum.Font.SourceSansBold
titleLabel.TextSize=13
titleLabel.TextXAlignment=Enum.TextXAlignment.Left
titleLabel.TextYAlignment=Enum.TextYAlignment.Center
titleLabel.ZIndex=163

local titleGradient=Instance.new("UIGradient",titleLabel)
titleGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1,0.4,0.9)),
    ColorSequenceKeypoint.new(0.5, Color3.new(0.6,0.8,1)),
    ColorSequenceKeypoint.new(1, Color3.new(0.8,1,0.9))
})

local titleStroke=Instance.new("UIStroke",titleLabel)
titleStroke.Color=Color3.new(1,1,1)
titleStroke.Thickness=1

local openLabel=Instance.new("TextLabel",innerFrame)
openLabel.Size=UDim2.new(0,40,1,0)
openLabel.Position=UDim2.new(1,-46,0,0)
openLabel.BackgroundTransparency=1
openLabel.Text="打开"
openLabel.TextColor3=Color3.new(1,1,1)
openLabel.Font=Enum.Font.SourceSansBold
openLabel.TextSize=13
openLabel.TextXAlignment=Enum.TextXAlignment.Right
openLabel.TextYAlignment=Enum.TextYAlignment.Center
openLabel.ZIndex=163

-- ==================== 主面板 ====================
local panel=Instance.new("Frame",gui)
panel.AnchorPoint=Vector2.new(0.5,0.5)
panel.Size=UDim2.new(0,20,0,20)
panel.Position=UDim2.new(0.5,0,0.5,0)
panel.BackgroundColor3=Color3.new(22/255,22/255,22/255)
panel.BorderSizePixel=0
panel.Visible=false
panel.ZIndex=50
panel.ClipsDescendants=true
panel.Rotation=-15

local panelGradient=Instance.new("UIGradient",panel)
panelGradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30,30,35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,20))
})
panelGradient.Rotation=45

local panelGlowStroke=Instance.new("UIStroke",panel)
panelGlowStroke.Thickness=2
panelGlowStroke.Color=Color3.fromRGB(0,255,200)
panelGlowStroke.Transparency=0.5
local panelGlowGrad=Instance.new("UIGradient",panelGlowStroke)
panelGlowGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,150))
})
panelGlowGrad.Rotation=90
pcall(function()
    TweenService:Create(panelGlowStroke,TweenInfo.new(1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=0.1,Thickness=4}):Play()
end)

local function createCorner(parent,px,py)
    local c=Instance.new("Frame",parent)
    c.Size=UDim2.new(0,12,0,12)
    c.Position=UDim2.new(px,0,py,0)
    c.BackgroundTransparency=1
    c.ZIndex=52
    local l1=Instance.new("Frame",c)
    l1.Size=UDim2.new(1,0,0,2)
    l1.Position=UDim2.new(0,0,py==0 and 0 or 1,-2)
    l1.BackgroundColor3=Color3.fromRGB(0,255,200)
    l1.BorderSizePixel=0
    local l2=Instance.new("Frame",c)
    l2.Size=UDim2.new(0,2,1,0)
    l2.Position=UDim2.new(px==0 and 0 or 1,-2,0,0)
    l2.BackgroundColor3=Color3.fromRGB(0,255,200)
    l2.BorderSizePixel=0
end
createCorner(panel,0,0)
createCorner(panel,1,-12)
createCorner(panel,0,1)
createCorner(panel,1,1)

local titleBar=Instance.new("Frame",panel)
titleBar.Size=UDim2.new(1,0,0,32)
titleBar.BackgroundColor3=Color3.fromRGB(40,40,45)
titleBar.BorderSizePixel=0
titleBar.ZIndex=55

local titleText=Instance.new("TextLabel",titleBar)
titleText.Size=UDim2.new(1,-30,1,0)
titleText.Position=UDim2.new(0,12,0,0)
titleText.BackgroundTransparency=1
titleText.Text="机械脚本"
titleText.TextColor3=Color3.new(1,1,1)
titleText.Font=Enum.Font.SourceSansBold
titleText.TextSize=18
titleText.TextXAlignment=Enum.TextXAlignment.Left

local closeBtn=Instance.new("TextButton",titleBar)
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.Position=UDim2.new(1,-30,0,4)
closeBtn.BackgroundColor3=Color3.fromRGB(220,50,50)
closeBtn.Text="×"
closeBtn.TextColor3=Color3.new(1,1,1)
closeBtn.Font=Enum.Font.SourceSansBold
closeBtn.TextSize=18
closeBtn.AutoLocalize=false
closeBtn.ZIndex=80
local closeCorner=Instance.new("UICorner",closeBtn)
closeCorner.CornerRadius=UDim.new(0,4)

local pages={}
local names={"自瞄合集","透视合集","通用合集","移动合集","武器合集","娱乐合集","其他合集","更多合集","外部脚本"}
for i=1,9 do
    local p=Instance.new("Frame",panel)
    p.Size=UDim2.new(1,0,1,-85)
    p.Position=UDim2.new(0,0,0,32)
    p.BackgroundTransparency=1
    p.ZIndex=60
    p.Visible=(i==1)
    p.ClipsDescendants=true
    local h=Instance.new("TextLabel",p)
    h.Size=UDim2.new(1,0,0,20)
    h.Position=UDim2.new(0,10,0,5)
    h.BackgroundTransparency=1
    h.Text=names[i]
    h.TextColor3=Color3.new(255/255,225/255,90/255)
    h.Font=Enum.Font.SourceSansBold
    h.TextSize=14
    h.TextXAlignment=Enum.TextXAlignment.Left
    pages[i]=p
end

local avatarFrame=Instance.new("Frame",panel)
avatarFrame.Size=UDim2.new(0,32,0,32)
avatarFrame.Position=UDim2.new(0,12,1,-70)
avatarFrame.BackgroundColor3=Color3.new(25/255,25/255,25/255)
avatarFrame.BorderSizePixel=0
avatarFrame.ZIndex=75
local avatarCorner=Instance.new("UICorner",avatarFrame)
avatarCorner.CornerRadius=UDim.new(1,0)
local avatarStroke=Instance.new("UIStroke",avatarFrame)
avatarStroke.Color=Color3.fromRGB(0,200,255)
avatarStroke.Thickness=1.5

local avatarImage=Instance.new("ImageLabel",avatarFrame)
avatarImage.Size=UDim2.new(1,-4,1,-4)
avatarImage.Position=UDim2.new(0,2,0,2)
avatarImage.BackgroundTransparency=1
avatarImage.Image=""
avatarImage.ScaleType=Enum.ScaleType.Crop
avatarImage.ZIndex=76
local avatarImageCorner=Instance.new("UICorner",avatarImage)
avatarImageCorner.CornerRadius=UDim.new(1,0)

local avatarName=Instance.new("TextLabel",panel)
avatarName.Size=UDim2.new(0,120,0,20)
avatarName.Position=UDim2.new(0,50,1,-64)
avatarName.BackgroundTransparency=1
avatarName.Text=player.Name
avatarName.TextColor3=Color3.new(1,1,1)
avatarName.Font=Enum.Font.SourceSansBold
avatarName.TextSize=13
avatarName.TextXAlignment=Enum.TextXAlignment.Left
avatarName.ZIndex=75

task.spawn(function()
    pcall(function()
        local thumb=Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
        if avatarImage then avatarImage.Image=thumb end
    end)
end)

local curPage=1
local prevBtn=Instance.new("TextButton",panel)
prevBtn.Size=UDim2.new(0,60,0,26)
prevBtn.Position=UDim2.new(0,175,1,-67)
prevBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
prevBtn.Text="上一页"
prevBtn.TextColor3=Color3.new(1,1,1)
prevBtn.Font=Enum.Font.SourceSansBold
prevBtn.TextSize=12
prevBtn.AutoLocalize=false
prevBtn.ZIndex=70
prevBtn.Visible=false
local prevCorner=Instance.new("UICorner",prevBtn)
prevCorner.CornerRadius=UDim.new(0,4)

local nextBtn=Instance.new("TextButton",panel)
nextBtn.Size=UDim2.new(0,60,0,26)
nextBtn.Position=UDim2.new(0,240,1,-67)
nextBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
nextBtn.Text="下一页"
nextBtn.TextColor3=Color3.new(1,1,1)
nextBtn.Font=Enum.Font.SourceSansBold
nextBtn.TextSize=12
nextBtn.AutoLocalize=false
nextBtn.ZIndex=70
local nextCorner=Instance.new("UICorner",nextBtn)
nextCorner.CornerRadius=UDim.new(0,4)

local pageLabel=Instance.new("TextLabel",panel)
pageLabel.Size=UDim2.new(0,80,0,20)
pageLabel.Position=UDim2.new(0,305,1,-64)
pageLabel.BackgroundTransparency=1
pageLabel.Text="1/9页"
pageLabel.TextColor3=Color3.new(1,1,1)
pageLabel.Font=Enum.Font.SourceSansBold
pageLabel.TextSize=11
pageLabel.ZIndex=70
pageLabel.TextXAlignment=Enum.TextXAlignment.Center

local function showPage(p)
    for i=1,9 do pages[i].Visible=(i==p) end
    prevBtn.Visible=(p>1)
    nextBtn.Visible=(p<9)
    pageLabel.Text=p.."/9页"
    curPage=p
end
prevBtn.MouseButton1Click:Connect(function() showPage(curPage-1) end)
nextBtn.MouseButton1Click:Connect(function() showPage(curPage+1) end)

local panelTween=nil
local function animatePanel(show)
    if scriptClosed then return end
    if panelTween then panelTween:Cancel() end
    if show then
        panel.Position=UDim2.new(0.5,0,0.5,0)
        panel.Visible=true
        panel.Size=UDim2.new(0,20,0,20)
        panel.Rotation=-15
        panelTween=TweenService:Create(panel,TweenInfo.new(0.4,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out),{Size=UDim2.new(0,380,0,340),Rotation=0})
        panelTween:Play()
    else
        panelTween=TweenService:Create(panel,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,20,0,20),Rotation=15})
        panelTween:Play()
        panelTween.Completed:Connect(function() panel.Visible=false end)
    end
end

local panelDragging=false
local panelDragStart=nil
local panelStartPos=nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        panelDragging=true
        panelDragStart=input.Position
        panelStartPos=panel.AbsolutePosition
    end
end)
UIS.InputChanged:Connect(function(input)
    if panelDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-panelDragStart
        panel.Position=UDim2.new(0,panelStartPos.X+delta.X,0,panelStartPos.Y+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if panelDragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        panelDragging=false
    end
end)

local islandDragging=false
local islandDragStart=nil
local islandStartPos=nil
local islandDragMoved=false
island.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        islandDragging=true
        islandDragStart=input.Position
        islandStartPos=island.AbsolutePosition
        islandDragMoved=false
    end
end)
UIS.InputChanged:Connect(function(input)
    if islandDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-islandDragStart
        if delta.Magnitude>12 then islandDragMoved=true end
        island.Position=UDim2.new(0,islandStartPos.X+delta.X,0,islandStartPos.Y+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if islandDragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        islandDragging=false
        islandDragMoved=false
    end
end)

island.MouseButton1Click:Connect(function()
    if scriptClosed then return end
    if panel.Visible then animatePanel(false) else showPage(curPage);animatePanel(true) end
end)

closeBtn.MouseButton1Click:Connect(function()
    scriptClosed=true
    st.fly=false; st.aim=false; st.silent=false; st.esp=false
    gui:Destroy()
    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local hum=player.Character.Humanoid
            hum.PlatformStand=false
            hum.WalkSpeed=baseWalkSpeed
        end
    end)
end)

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.Insert then
        if scriptClosed then return end
        if panel.Visible then animatePanel(false) else showPage(curPage);animatePanel(true) end
    end
end)

-- ==================== 飞行UI ====================
local flyContainer=Instance.new("Frame",gui)
flyContainer.Size=UDim2.new(0,190,0,110)
flyContainer.Position=UDim2.new(0.02,0,0.7,0)
flyContainer.BackgroundTransparency=1
flyContainer.BorderSizePixel=0
flyContainer.Visible=false
flyContainer.ZIndex=200

local flyControlUI=Instance.new("Frame",flyContainer)
flyControlUI.Size=UDim2.new(1,0,1,0)
flyControlUI.BackgroundColor3=Color3.new(0,0,0)
flyControlUI.BackgroundTransparency=0.25
flyControlUI.BorderSizePixel=0
flyControlUI.ZIndex=200
local flyUICorner=Instance.new("UICorner",flyControlUI)
flyUICorner.CornerRadius=UDim.new(0,6)
local flyUIStroke=Instance.new("UIStroke",flyControlUI)
flyUIStroke.Color=Color3.fromRGB(0,200,255)
flyUIStroke.Thickness=1
flyUIStroke.Transparency=0.3

local flySpeedLabel=Instance.new("TextLabel",flyControlUI)
flySpeedLabel.Size=UDim2.new(0,90,0,20)
flySpeedLabel.Position=UDim2.new(0,40,0,4)
flySpeedLabel.BackgroundTransparency=1
flySpeedLabel.Text="50"
flySpeedLabel.TextColor3=Color3.new(1,1,1)
flySpeedLabel.Font=Enum.Font.SourceSansBold
flySpeedLabel.TextSize=15
flySpeedLabel.ZIndex=201

local flyMinimizeBtn=Instance.new("TextButton",flyControlUI)
flyMinimizeBtn.Size=UDim2.new(0,20,0,20)
flyMinimizeBtn.Position=UDim2.new(0,4,0,4)
flyMinimizeBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
flyMinimizeBtn.Text="-"
flyMinimizeBtn.TextColor3=Color3.new(1,1,1)
flyMinimizeBtn.Font=Enum.Font.SourceSansBold
flyMinimizeBtn.TextSize=16
flyMinimizeBtn.AutoLocalize=false
flyMinimizeBtn.ZIndex=203

local flyCloseUI=Instance.new("TextButton",flyControlUI)
flyCloseUI.Size=UDim2.new(0,20,0,20)
flyCloseUI.Position=UDim2.new(1,-24,0,4)
flyCloseUI.BackgroundColor3=Color3.fromRGB(180,50,50)
flyCloseUI.Text="×"
flyCloseUI.TextColor3=Color3.new(1,1,1)
flyCloseUI.Font=Enum.Font.SourceSansBold
flyCloseUI.TextSize=14
flyCloseUI.AutoLocalize=false
flyCloseUI.ZIndex=203
flyCloseUI.MouseButton1Click:Connect(function()
    st.fly=false
    flyContainer.Visible=false
    for _,btn in ipairs(pages[3]:GetChildren()) do
        if btn:IsA("TextButton") and string.find(btn.Text,"飞行") then
            btn.Text="飞行：关"
            btn.BackgroundColor3=Color3.fromRGB(110,110,110)
        end
    end
end)

local flyAccelBtn=Instance.new("TextButton",flyControlUI)
flyAccelBtn.Size=UDim2.new(0,76,0,28)
flyAccelBtn.Position=UDim2.new(0,4,0,28)
flyAccelBtn.BackgroundColor3=Color3.fromRGB(80,130,200)
flyAccelBtn.Text="加速"
flyAccelBtn.TextColor3=Color3.new(1,1,1)
flyAccelBtn.Font=Enum.Font.SourceSansBold
flyAccelBtn.TextSize=13
flyAccelBtn.AutoLocalize=false
flyAccelBtn.ZIndex=202
flyAccelBtn.MouseButton1Click:Connect(function()
    st.flyspeed=math.min(1500,st.flyspeed+50)
    flySpeedLabel.Text=tostring(st.flyspeed)
end)

local flyDecelBtn=Instance.new("TextButton",flyControlUI)
flyDecelBtn.Size=UDim2.new(0,76,0,28)
flyDecelBtn.Position=UDim2.new(0,84,0,28)
flyDecelBtn.BackgroundColor3=Color3.fromRGB(200,80,80)
flyDecelBtn.Text="减速"
flyDecelBtn.TextColor3=Color3.new(1,1,1)
flyDecelBtn.Font=Enum.Font.SourceSansBold
flyDecelBtn.TextSize=13
flyDecelBtn.AutoLocalize=false
flyDecelBtn.ZIndex=202
flyDecelBtn.MouseButton1Click:Connect(function()
    st.flyspeed=math.max(10,st.flyspeed-50)
    flySpeedLabel.Text=tostring(st.flyspeed)
end)

local flyToggleBtn=Instance.new("TextButton",flyControlUI)
flyToggleBtn.Size=UDim2.new(0,76,0,28)
flyToggleBtn.Position=UDim2.new(0,4,0,60)
flyToggleBtn.BackgroundColor3=Color3.fromRGB(255,100,100)
flyToggleBtn.Text="停止飞行"
flyToggleBtn.TextColor3=Color3.new(1,1,1)
flyToggleBtn.Font=Enum.Font.SourceSansBold
flyToggleBtn.TextSize=12
flyToggleBtn.AutoLocalize=false
flyToggleBtn.ZIndex=202
flyToggleBtn.MouseButton1Click:Connect(function()
    st.fly=not st.fly
    if st.fly then
        flyToggleBtn.Text="停止飞行"
        flyToggleBtn.BackgroundColor3=Color3.fromRGB(255,100,100)
    else
        flyToggleBtn.Text="开始飞行"
        flyToggleBtn.BackgroundColor3=Color3.fromRGB(0,200,0)
        flyProtectUntil=os.clock()+2
    end
    for _,btn in ipairs(pages[3]:GetChildren()) do
        if btn:IsA("TextButton") and string.find(btn.Text,"飞行") then
            btn.Text="飞行："..(st.fly and "开" or "关")
            btn.BackgroundColor3=st.fly and Color3.fromRGB(80,230,80) or Color3.fromRGB(110,110,110)
        end
    end
end)

local flyNoclipBtn=Instance.new("TextButton",flyControlUI)
flyNoclipBtn.Size=UDim2.new(0,76,0,28)
flyNoclipBtn.Position=UDim2.new(0,84,0,60)
flyNoclipBtn.BackgroundColor3=Color3.fromRGB(110,110,110)
flyNoclipBtn.Text="穿墙"
flyNoclipBtn.TextColor3=Color3.new(1,1,1)
flyNoclipBtn.Font=Enum.Font.SourceSansBold
flyNoclipBtn.TextSize=13
flyNoclipBtn.AutoLocalize=false
flyNoclipBtn.ZIndex=202
flyNoclipBtn.MouseButton1Click:Connect(function()
    st.flyNoclip=not st.flyNoclip
    flyNoclipBtn.BackgroundColor3=st.flyNoclip and Color3.fromRGB(0,200,0) or Color3.fromRGB(110,110,110)
end)

local flyMiniBtn=Instance.new("TextButton",flyContainer)
flyMiniBtn.Size=UDim2.new(0,80,0,40)
flyMiniBtn.BackgroundColor3=Color3.new(0,0,0)
flyMiniBtn.BackgroundTransparency=0.25
flyMiniBtn.Text="停止飞行"
flyMiniBtn.TextColor3=Color3.new(1,1,1)
flyMiniBtn.Font=Enum.Font.SourceSansBold
flyMiniBtn.TextSize=13
flyMiniBtn.AutoLocalize=false
flyMiniBtn.Visible=false
flyMiniBtn.ZIndex=200
local flyMiniCorner=Instance.new("UICorner",flyMiniBtn)
flyMiniCorner.CornerRadius=UDim.new(0,6)
local flyMiniStroke=Instance.new("UIStroke",flyMiniBtn)
flyMiniStroke.Color=Color3.fromRGB(0,200,255)
flyMiniStroke.Thickness=1
flyMiniStroke.Transparency=0.3

local flyRestoreBtn = Instance.new("TextButton", flyContainer)
flyRestoreBtn.Size = UDim2.new(0,20,0,20)
flyRestoreBtn.Position = UDim2.new(0,-24,0,0)
flyRestoreBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
flyRestoreBtn.Text = "+"
flyRestoreBtn.TextColor3 = Color3.new(1,1,1)
flyRestoreBtn.Font = Enum.Font.SourceSansBold
flyRestoreBtn.TextSize = 16
flyRestoreBtn.AutoLocalize = false
flyRestoreBtn.Visible = false
flyRestoreBtn.ZIndex = 200
local restoreCorner = Instance.new("UICorner", flyRestoreBtn)
restoreCorner.CornerRadius = UDim.new(0,4)

local function updateMiniBtnText()
    if st.fly then
        flyMiniBtn.Text="停止飞行"
        flyMiniBtn.BackgroundColor3=Color3.fromRGB(200,60,60)
    else
        flyMiniBtn.Text="开始飞行"
        flyMiniBtn.BackgroundColor3=Color3.fromRGB(0,140,60)
    end
end

flyMinimizeBtn.MouseButton1Click:Connect(function()
    flyControlUI.Visible=false
    flyMiniBtn.Visible=true
    flyRestoreBtn.Visible=true
    updateMiniBtnText()
end)

flyRestoreBtn.MouseButton1Click:Connect(function()
    flyControlUI.Visible=true
    flyMiniBtn.Visible=false
    flyRestoreBtn.Visible=false
end)

local miniDragging=false
local miniDragStart=nil
local miniStartPos=nil
local miniDragMoved=false
flyMiniBtn.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        miniDragging=true
        miniDragStart=input.Position
        miniStartPos=flyContainer.AbsolutePosition
        miniDragMoved=false
    end
end)
UIS.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-miniDragStart
        if delta.Magnitude>10 then miniDragMoved=true end
        flyContainer.Position=UDim2.new(0,miniStartPos.X+delta.X,0,miniStartPos.Y+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if miniDragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        miniDragging=false
    end
end)
flyMiniBtn.MouseButton1Click:Connect(function()
    if miniDragMoved then
        miniDragMoved=false
        return
    end
    st.fly=not st.fly
    updateMiniBtnText()
    if not st.fly then flyProtectUntil=os.clock()+2 end
    for _,btn in ipairs(pages[3]:GetChildren()) do
        if btn:IsA("TextButton") and string.find(btn.Text,"飞行") then
            btn.Text="飞行："..(st.fly and "开" or "关")
            btn.BackgroundColor3=st.fly and Color3.fromRGB(80,230,80) or Color3.fromRGB(110,110,110)
        end
    end
end)

local flyUIDragging=false
local flyUIDragStart=nil
local flyUIStartPos=nil
flyControlUI.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        flyUIDragging=true
        flyUIDragStart=input.Position
        flyUIStartPos=flyContainer.AbsolutePosition
    end
end)
UIS.InputChanged:Connect(function(input)
    if flyUIDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-flyUIDragStart
        flyContainer.Position=UDim2.new(0,flyUIStartPos.X+delta.X,0,flyUIStartPos.Y+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if flyUIDragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        flyUIDragging=false
    end
end)

-- ==================== 加速UI ====================
local speedControlUI=Instance.new("Frame",gui)
speedControlUI.Size=UDim2.new(0,120,0,40)
speedControlUI.Position=UDim2.new(0.02,0,0.85,0)
speedControlUI.BackgroundColor3=Color3.fromRGB(0,0,0)
speedControlUI.BackgroundTransparency=0.2
speedControlUI.BorderSizePixel=0
speedControlUI.Visible=false
speedControlUI.ZIndex=200
local speedToggleUI=Instance.new("TextButton",speedControlUI)
speedToggleUI.Size=UDim2.new(1,0,1,0)
speedToggleUI.BackgroundColor3=Color3.fromRGB(80,130,200)
speedToggleUI.Text="加速：开"
speedToggleUI.TextColor3=Color3.new(1,1,1)
speedToggleUI.Font=Enum.Font.SourceSansBold
speedToggleUI.TextSize=14
speedToggleUI.AutoLocalize=false
speedToggleUI.MouseButton1Click:Connect(function()
    st.speed=not st.speed
    speedToggleUI.Text=st.speed and "加速：开" or "加速：关"
    speedToggleUI.BackgroundColor3=st.speed and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,130,200)
end)
local speedUIDragging=false
local speedUIDragStart=nil
local speedUIStartPos=nil
speedControlUI.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        speedUIDragging=true
        speedUIDragStart=input.Position
        speedUIStartPos=speedControlUI.AbsolutePosition
    end
end)
UIS.InputChanged:Connect(function(input)
    if speedUIDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-speedUIDragStart
        speedControlUI.Position=UDim2.new(0,speedUIStartPos.X+delta.X,0,speedUIStartPos.Y+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if speedUIDragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        speedUIDragging=false
    end
end)

-- ==================== 玩家列表 ====================
local playerListPanel=Instance.new("Frame",gui)
playerListPanel.Size=UDim2.new(0,180,0,240)
playerListPanel.Position=UDim2.new(0.75,-90,0.3,-100)
playerListPanel.BackgroundColor3=Color3.fromRGB(25,25,25)
playerListPanel.BorderSizePixel=2
playerListPanel.BorderColor3=Color3.fromRGB(255,0,0)
playerListPanel.Visible=false
playerListPanel.ZIndex=500
local playerListTitleBar=Instance.new("Frame",playerListPanel)
playerListTitleBar.Size=UDim2.new(1,0,0,24)
playerListTitleBar.BackgroundColor3=Color3.fromRGB(45,45,45)
playerListTitleBar.BorderSizePixel=0
local playerListTitle=Instance.new("TextLabel",playerListTitleBar)
playerListTitle.Size=UDim2.new(1,0,1,0)
playerListTitle.Position=UDim2.new(0,5,0,0)
playerListTitle.BackgroundTransparency=1
playerListTitle.Text="选择玩家"
playerListTitle.TextColor3=Color3.new(1,1,1)
playerListTitle.Font=Enum.Font.SourceSansBold
playerListTitle.TextSize=13
playerListTitle.TextXAlignment=Enum.TextXAlignment.Left
local playerListContainer=Instance.new("ScrollingFrame",playerListPanel)
playerListContainer.Size=UDim2.new(1,-4,1,-28)
playerListContainer.Position=UDim2.new(0,2,0,26)
playerListContainer.BackgroundTransparency=1
playerListContainer.BorderSizePixel=0
playerListContainer.ScrollBarThickness=4
playerListContainer.CanvasSize=UDim2.new(0,0,0,0)
playerListContainer.ZIndex=501
local function refreshPlayerList()
    for _,child in ipairs(playerListContainer:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    local yPos=0
    local found=false
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player then
            local btn=Instance.new("TextButton")
            btn.Size=UDim2.new(1,-6,0,26)
            btn.Position=UDim2.new(0,3,0,yPos)
            btn.BackgroundColor3=(selectedTarget==p) and Color3.fromRGB(0,200,0) or Color3.fromRGB(80,80,80)
            btn.Text=p.Name
            btn.TextColor3=Color3.new(1,1,1)
            btn.Font=Enum.Font.SourceSansBold
            btn.TextSize=13
            btn.AutoLocalize=false
            btn.ZIndex=502
            btn.Parent=playerListContainer
            btn.MouseButton1Click:Connect(function()
                if selectedTarget==p then selectedTarget=nil;st.trackPlayer=false
                else selectedTarget=p;st.trackPlayer=true end
                refreshPlayerList()
            end)
            yPos=yPos+30
            found=true
        end
    end
    if not found then
        local emptyLabel=Instance.new("TextLabel")
        emptyLabel.Size=UDim2.new(1,-6,0,30)
        emptyLabel.Position=UDim2.new(0,3,0,0)
        emptyLabel.BackgroundTransparency=1
        emptyLabel.Text="暂无其他玩家"
        emptyLabel.TextColor3=Color3.new(1,1,1)
        emptyLabel.Font=Enum.Font.SourceSansBold
        emptyLabel.TextSize=13
        emptyLabel.TextXAlignment=Enum.TextXAlignment.Center
        emptyLabel.ZIndex=502
        emptyLabel.Parent=playerListContainer
    end
    playerListContainer.CanvasSize=UDim2.new(0,0,0,math.max(yPos+10,30))
end
local playerListDragging=false
local playerListDragStart=nil
local playerListStartPos=nil
playerListTitleBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        playerListDragging=true
        playerListDragStart=input.Position
        playerListStartPos=playerListPanel.AbsolutePosition
    end
end)
UIS.InputChanged:Connect(function(input)
    if playerListDragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-playerListDragStart
        playerListPanel.Position=UDim2.new(0,playerListStartPos.X+delta.X,0,playerListStartPos.Y+delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if playerListDragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
        playerListDragging=false
    end
end)
Players.PlayerAdded:Connect(function() refreshPlayerList() end)
Players.PlayerRemoving:Connect(function(p)
    if selectedTarget==p then selectedTarget=nil;st.trackPlayer=false end
    refreshPlayerList()
end)
refreshPlayerList()

-- ==================== 多坐标系统 ====================
local savedLocations={}
local coordPanel=Instance.new("Frame",gui)
coordPanel.Size=UDim2.new(0,200,0,260)
coordPanel.Position=UDim2.new(0.5,-100,0.5,-130)
coordPanel.BackgroundColor3=Color3.fromRGB(25,25,25)
coordPanel.BorderSizePixel=2
coordPanel.BorderColor3=Color3.fromRGB(0,200,255)
coordPanel.Visible=false
coordPanel.ZIndex=510
local coordTitle=Instance.new("TextLabel",coordPanel)
coordTitle.Size=UDim2.new(1,0,0,24)
coordTitle.BackgroundColor3=Color3.fromRGB(45,45,45)
coordTitle.Text="坐标管理"
coordTitle.TextColor3=Color3.new(1,1,1)
coordTitle.Font=Enum.Font.SourceSansBold
coordTitle.TextSize=13
local coordList=Instance.new("ScrollingFrame",coordPanel)
coordList.Size=UDim2.new(1,-4,1,-60)
coordList.Position=UDim2.new(0,2,0,26)
coordList.BackgroundTransparency=1
coordList.BorderSizePixel=0
coordList.ScrollBarThickness=4
coordList.CanvasSize=UDim2.new(0,0,0,0)
coordList.ZIndex=511
local function refreshCoordList()
    for _,child in ipairs(coordList:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
    local y=0
    for i,data in ipairs(savedLocations) do
        local f=Instance.new("Frame",coordList)
        f.Size=UDim2.new(1,-6,0,30)
        f.Position=UDim2.new(0,3,0,y)
        f.BackgroundColor3=Color3.fromRGB(50,50,50)
        f.ZIndex=512
        local lbl=Instance.new("TextLabel",f)
        lbl.Size=UDim2.new(1,-80,1,0)
        lbl.BackgroundTransparency=1
        lbl.Text=data.name
        lbl.TextColor3=Color3.new(1,1,1)
        lbl.TextSize=12
        lbl.TextXAlignment=Enum.TextXAlignment.Left
        lbl.ZIndex=513
        local tpBtn=Instance.new("TextButton",f)
        tpBtn.Size=UDim2.new(0,35,0,20)
        tpBtn.Position=UDim2.new(1,-75,0.5,-10)
        tpBtn.BackgroundColor3=Color3.fromRGB(0,150,0)
        tpBtn.Text="传送"
        tpBtn.TextSize=11
        tpBtn.TextColor3=Color3.new(1,1,1)
        tpBtn.ZIndex=513
        tpBtn.MouseButton1Click:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame=data.cframe
                notif("已传送至 "..data.name)
            end
        end)
        local delBtn=Instance.new("TextButton",f)
        delBtn.Size=UDim2.new(0,30,0,20)
        delBtn.Position=UDim2.new(1,-35,0.5,-10)
        delBtn.BackgroundColor3=Color3.fromRGB(200,50,50)
        delBtn.Text="删"
        delBtn.TextSize=11
        delBtn.TextColor3=Color3.new(1,1,1)
        delBtn.ZIndex=513
        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedLocations,i)
            refreshCoordList()
        end)
        y=y+34
    end
    coordList.CanvasSize=UDim2.new(0,0,0,math.max(y+10,30))
end
local addCoordBtn=Instance.new("TextButton",coordPanel)
addCoordBtn.Size=UDim2.new(1,-10,0,26)
addCoordBtn.Position=UDim2.new(0,5,1,-30)
addCoordBtn.BackgroundColor3=Color3.fromRGB(0,150,200)
addCoordBtn.Text="保存当前坐标为 坐标"..(#savedLocations+1)
addCoordBtn.TextSize=12
addCoordBtn.TextColor3=Color3.new(1,1,1)
addCoordBtn.ZIndex=512
addCoordBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        table.insert(savedLocations,{name="坐标"..(#savedLocations+1),cframe=player.Character.HumanoidRootPart.CFrame})
        refreshCoordList()
        addCoordBtn.Text="保存当前坐标为 坐标"..(#savedLocations+1)
        notif("坐标已保存")
    end
end)

-- ==================== 按钮与滑条生成 ====================
local function addButton(parent,text,key,x,y)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,100,0,35)
    b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=st[key] and Color3.fromRGB(80,230,80) or Color3.fromRGB(110,110,110)
    b.Text=text.."："..(st[key] and "开" or "关")
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.SourceSansBold
    b.TextSize=13
    b.AutoLocalize=false
    b.ZIndex=80
    b.MouseButton1Click:Connect(function()
        st[key]=not st[key]
        b.BackgroundColor3=st[key] and Color3.fromRGB(80,230,80) or Color3.fromRGB(110,110,110)
        b.Text=text.."："..(st[key] and "开" or "关")
        if key=="fly" then
            flyContainer.Visible=true
            if st.fly then
                flyControlUI.Visible=true
                flyMiniBtn.Visible=false
                flyRestoreBtn.Visible=false
                flyToggleBtn.Text="停止飞行"
                flyToggleBtn.BackgroundColor3=Color3.fromRGB(255,100,100)
                updateMiniBtnText()
            else
                flyToggleBtn.Text="开始飞行"
                flyToggleBtn.BackgroundColor3=Color3.fromRGB(0,200,0)
                flyProtectUntil=os.clock()+2
                updateMiniBtnText()
            end
        end
        if key=="speed" then speedControlUI.Visible=st.speed end
        if key=="showTargetList" then
            playerListPanel.Visible=st.showTargetList
            if st.showTargetList then refreshPlayerList() end
        end
        if key=="savepos" then
            coordPanel.Visible=st.savepos
            if st.savepos then refreshCoordList() end
        end
    end)
end

local function addWideSlider(parent,text,key,minv,maxv,x,y,w)
    local frame=Instance.new("Frame",parent)
    frame.Size=UDim2.new(0,w or 280,0,40)
    frame.Position=UDim2.new(0,x,0,y)
    frame.BackgroundTransparency=1
    frame.ZIndex=80
    local lbl=Instance.new("TextLabel",frame)
    lbl.Size=UDim2.new(1,0,0,16)
    lbl.BackgroundTransparency=1
    lbl.Text=text..": "..st[key]
    lbl.TextColor3=Color3.new(1,1,1)
    lbl.Font=Enum.Font.SourceSansBold
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    local bg=Instance.new("Frame",frame)
    bg.Size=UDim2.new(1,0,0,8)
    bg.Position=UDim2.new(0,0,0,22)
    bg.BackgroundColor3=Color3.fromRGB(70,70,70)
    bg.BorderSizePixel=0
    local fill=Instance.new("Frame",bg)
    fill.Size=UDim2.new((st[key]-minv)/(maxv-minv),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(80,160,240)
    fill.BorderSizePixel=0
    local knob=Instance.new("TextButton",bg)
    knob.Size=UDim2.new(0,16,0,16)
    knob.Position=UDim2.new((st[key]-minv)/(maxv-minv),-8,0.5,-8)
    knob.BackgroundColor3=Color3.new(1,1,1)
    knob.Text=""
    knob.BorderSizePixel=0
    local dragging=false
    local function updateFromX(absoluteX)
        local relX=absoluteX-bg.AbsolutePosition.X
        local percent=math.clamp(relX/bg.AbsoluteSize.X,0,1)
        local raw=minv+percent*(maxv-minv)
        if minv==math.floor(minv) and maxv==math.floor(maxv) then st[key]=math.floor(raw)
        else st[key]=math.floor(raw*100+0.5)/100 end
        fill.Size=UDim2.new(percent,0,1,0)
        knob.Position=UDim2.new(percent,-8,0.5,-8)
        lbl.Text=text..": "..st[key]
    end
    bg.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true;updateFromX(input.Position.X)
        end
    end)
    knob.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true;updateFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then dragging=false end
    end)
end

local function addSlider(parent,text,key,minv,maxv,x,y)
    addWideSlider(parent,text,key,minv,maxv,x,y,100)
end

local function addTargetButton(parent,text,x,y)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,100,0,35)
    b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=Color3.fromRGB(110,110,110)
    b.Text=text
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.SourceSansBold
    b.TextSize=13
    b.AutoLocalize=false
    b.ZIndex=80
    b.MouseButton1Click:Connect(function()
        targetList={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=player then table.insert(targetList,p) end
        end
        if #targetList==0 then selectedTarget=nil;notif("没有可跟踪的玩家");return end
        targetIndex=targetIndex%#targetList+1
        selectedTarget=targetList[targetIndex]
        st.trackPlayer=true
        notif("选中: "..selectedTarget.Name)
        refreshPlayerList()
    end)
end

-- ==================== 页面填充 ====================
-- 1 自瞄
addButton(pages[1],"自瞄","aim",10,25)
addButton(pages[1],"锁头","lockh",120,25)
addButton(pages[1],"静默自瞄","silent",230,25)
addButton(pages[1],"墙体检测","wallcheck",10,70)
addButton(pages[1],"队伍过滤","teamcheck",120,70)
addSlider(pages[1],"自瞄范围","aimrange",50,500,230,70)
addButton(pages[1],"碰撞放大","hitbox",10,115)
addSlider(pages[1],"放大倍率","hitboxSize",1,5,120,115)
addButton(pages[1],"自瞄圈","aimCircle",230,115)
addSlider(pages[1],"圈大小","aimCircleSize",50,300,10,160)
addSlider(pages[1],"平滑度","aimSmooth",0.01,1,120,160)

local aimColorBtn=Instance.new("TextButton",pages[1])
aimColorBtn.Size=UDim2.new(0,100,0,35)
aimColorBtn.Position=UDim2.new(0,230,0,160)
aimColorBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
aimColorBtn.Text="圈颜色"
aimColorBtn.TextColor3=aimColorList[aimColorIndex]
aimColorBtn.Font=Enum.Font.SourceSansBold
aimColorBtn.TextSize=13
aimColorBtn.AutoLocalize=false
aimColorBtn.ZIndex=80
aimColorBtn.MouseButton1Click:Connect(function()
    aimColorIndex=aimColorIndex%#aimColorList+1
    aimColorBtn.TextColor3=aimColorList[aimColorIndex]
    aimCircleStroke.Color=aimColorList[aimColorIndex]
end)

-- 2 透视
addButton(pages[2],"透视","esp",10,25)
addButton(pages[2],"方框透视","espBox",120,25)
addButton(pages[2],"骨骼透视","espBones",230,25)
addButton(pages[2],"显示名字","espn",10,70)
addButton(pages[2],"显示距离","espd",120,70)
addButton(pages[2],"显示血量","esphp",230,70)
addButton(pages[2],"显示血条","espHpBar",10,115)
addButton(pages[2],"队伍过滤","espTeamcheck",120,115)
addButton(pages[2],"检测NPC","espnpc",230,115)
addSlider(pages[2],"透视范围","espRange",100,1000,10,160)
addButton(pages[2],"被看提醒","watchedAlert",230,160)

local espColorBtn=Instance.new("TextButton",pages[2])
espColorBtn.Size=UDim2.new(0,100,0,35)
espColorBtn.Position=UDim2.new(0,10,0,205)
espColorBtn.BackgroundColor3=Color3.fromRGB(80,80,80)
espColorBtn.Text="框颜色"
espColorBtn.TextColor3=espColorList[espColorIndex]
espColorBtn.Font=Enum.Font.SourceSansBold
espColorBtn.TextSize=13
espColorBtn.AutoLocalize=false
espColorBtn.ZIndex=80
espColorBtn.MouseButton1Click:Connect(function()
    espColorIndex=espColorIndex%#espColorList+1
    espColorBtn.TextColor3=espColorList[espColorIndex]
end)

-- 3 通用
addButton(pages[3],"飞行","fly",10,25)
addButton(pages[3],"穿墙","noclip",120,25)
addButton(pages[3],"关闭玩家碰撞","noplayercol",230,25)
addButton(pages[3],"视野缩放","zoom",10,70)
addButton(pages[3],"低画质模式","lowGraphics",120,70)
addButton(pages[3],"自由视角","freeCam",230,70)
addButton(pages[3],"第三人称","third",10,115)
addButton(pages[3],"夜视","night",120,115)

-- 4 移动
addButton(pages[4],"速度","speed",10,25)
addWideSlider(pages[4],"移速数值","walkspeed",16,3000,10,60,310)
addButton(pages[4],"高跳","jumpboost",10,105)
addSlider(pages[4],"跳跃力度","jumppower",50,200,120,105)
addButton(pages[4],"自动连跳","autobhop",230,105)

-- 5 武器
addButton(pages[5],"屏蔽闪光","antiflash",10,25)
addButton(pages[5],"屏蔽烟雾","antismoke",120,25)
addButton(pages[5],"防抖画面","antishake",230,25)

-- 6 娱乐
addButton(pages[6],"游泳加速","swimBoost",10,25)
addButton(pages[6],"水上行走","waterWalk",120,25)
addButton(pages[6],"锁定目标","trackPlayer",230,25)
addTargetButton(pages[6],"切换目标",10,70)
addButton(pages[6],"显示目标列表","showTargetList",120,70)

-- 7 其他
addButton(pages[7],"坐标管理","savepos",10,25)

-- 8 更多
addButton(pages[8],"身体旋转","spin",10,25)
local spinMinus=Instance.new("TextButton",pages[8])
spinMinus.Size=UDim2.new(0,100,0,35)
spinMinus.Position=UDim2.new(0,120,0,25)
spinMinus.BackgroundColor3=Color3.fromRGB(110,110,110)
spinMinus.Text="速度-"..st.spinSpeed
spinMinus.TextColor3=Color3.new(1,1,1)
spinMinus.Font=Enum.Font.SourceSansBold
spinMinus.TextSize=13
spinMinus.AutoLocalize=false
spinMinus.ZIndex=80
spinMinus.MouseButton1Click:Connect(function()
    st.spinSpeed=math.max(1,st.spinSpeed-10)
    spinMinus.Text="速度-"..st.spinSpeed
end)
local spinPlus=Instance.new("TextButton",pages[8])
spinPlus.Size=UDim2.new(0,100,0,35)
spinPlus.Position=UDim2.new(0,230,0,25)
spinPlus.BackgroundColor3=Color3.fromRGB(110,110,110)
spinPlus.Text="速度+"..st.spinSpeed
spinPlus.TextColor3=Color3.new(1,1,1)
spinPlus.Font=Enum.Font.SourceSansBold
spinPlus.TextSize=13
spinPlus.AutoLocalize=false
spinPlus.ZIndex=80
spinPlus.MouseButton1Click:Connect(function()
    st.spinSpeed=math.min(200,st.spinSpeed+10)
    spinPlus.Text="速度+"..st.spinSpeed
end)
addButton(pages[8],"一键交互","fastInteract",10,70)

-- 9 外部脚本
local piButton=Instance.new("TextButton",pages[9])
piButton.Size=UDim2.new(0,100,0,35)
piButton.Position=UDim2.new(0,10,0,25)
piButton.BackgroundColor3=Color3.fromRGB(80,130,200)
piButton.Text="皮脚本"
piButton.TextColor3=Color3.new(1,1,1)
piButton.Font=Enum.Font.SourceSansBold
piButton.TextSize=13
piButton.AutoLocalize=false
piButton.ZIndex=80
piButton.MouseButton1Click:Connect(function()
    pcall(function()
        getgenv().XiaoPi="皮脚本QQ群894995244"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
    end)
end)
local yeButton=Instance.new("TextButton",pages[9])
yeButton.Size=UDim2.new(0,100,0,35)
yeButton.Position=UDim2.new(0,120,0,25)
yeButton.BackgroundColor3=Color3.fromRGB(80,130,200)
yeButton.Text="叶脚本"
yeButton.TextColor3=Color3.new(1,1,1)
yeButton.Font=Enum.Font.SourceSansBold
yeButton.TextSize=13
yeButton.AutoLocalize=false
yeButton.ZIndex=80
yeButton.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
    end)
end)
local translateButton=Instance.new("TextButton",pages[9])
translateButton.Size=UDim2.new(0,100,0,35)
translateButton.Position=UDim2.new(0,230,0,25)
translateButton.BackgroundColor3=Color3.fromRGB(80,130,200)
translateButton.Text="翻译脚本"
translateButton.TextColor3=Color3.new(1,1,1)
translateButton.Font=Enum.Font.SourceSansBold
translateButton.TextSize=13
translateButton.AutoLocalize=false
translateButton.ZIndex=80
translateButton.MouseButton1Click:Connect(function()
    pcall(function()
        TX="TX Script";Script="全自动翻译"
        loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()
    end)
end)
local bloxButton=Instance.new("TextButton",pages[9])
bloxButton.Size=UDim2.new(0,100,0,35)
bloxButton.Position=UDim2.new(0,10,0,65)
bloxButton.BackgroundColor3=Color3.fromRGB(80,130,200)
bloxButton.Text="blox战利品需要卡密英文"
bloxButton.TextColor3=Color3.new(1,1,1)
bloxButton.Font=Enum.Font.SourceSansBold
bloxButton.TextSize=13
bloxButton.AutoLocalize=false
bloxButton.ZIndex=80
bloxButton.MouseButton1Click:Connect(function()
    pcall(function()
        loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/aa8d71d17a46266cef7223aba0e9d4066a653f03ba06bb8ac8364e42ab0ace63/download"))()
    end)
end)

-- ==================== 启动流程 ====================
local function finishIntro()
    introFinished=true
    pcall(function()
        hackOverlay.Visible=false
        rainFrame.Visible=false
        blur.Enabled=false
        welcomeOverlay.Visible=false
        welcomeText.TextTransparency=1
        welcomeSub.TextTransparency=1
        welcomeStroke.Transparency=1
        scanLine.Visible=false
        if isDev and skipButton then skipButton.Visible=false end
        island.Visible=true
    end)
end

if isDev and skipButton then
    skipButton.MouseButton1Click:Connect(function()
        pcall(function()
            if introCoroutine then task.cancel(introCoroutine) end
        end)
        introCoroutine=nil
        finishIntro()
    end)
end

task.delay(60,function()
    if not introFinished then
        pcall(function()
            if introCoroutine then task.cancel(introCoroutine) end
        end)
        introCoroutine=nil
        finishIntro()
    end
end)

local function colorToRich(c)
    return string.format('<font color="rgb(%d,%d,%d)">',math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
end

local function lineToRich(line)
    return colorToRich(line.color)..line.text..'</font>'
end

task.spawn(function()
    introCoroutine=task.spawn(function()
        pcall(function()
            blur.Enabled=true
            hackOverlay.BackgroundTransparency=0.6
            termText.Text=""
            local historyLines={}
            local maxLines=8

            local function typeText(text,color,speed)
                if introFinished then return end
                local currentText=""
                for i=1,#text do
                    if introFinished then return end
                    currentText=string.sub(text,1,i)
                    local display=""
                    for _,line in ipairs(historyLines) do
                        display=display..lineToRich(line)
                    end
                    display=display..colorToRich(color)..currentText.."█</font>"
                    termText.Text=display
                    task.wait(speed)
                end
                table.insert(historyLines,{text=text,color=color})
                while #historyLines>maxLines do
                    table.remove(historyLines,1)
                end
                local display=""
                for _,line in ipairs(historyLines) do
                    display=display..lineToRich(line)
                end
                termText.Text=display
                task.wait(0.05)
            end

            typeText("> OS: ROBLOX_EXPLOIT v3.0\n",Color3.new(0,1,0),0.04)
            typeText("> Kernel: injected\n",Color3.new(0,1,0),0.04)
            typeText("> Memory: OK\n",Color3.fromRGB(0,200,255),0.04)
            typeText("> Target: ROBLOX_SERVER_01\n",Color3.new(0,1,0),0.04)
            typeText("> IP: 192.168.1.7\n",Color3.fromRGB(0,200,255),0.04)
            
            local redLines={
                "0x7F3A9C20 inject...",
                "bypass check...",
                "loading modules...",
                "hooking functions...",
                "decrypting data...",
                "preparing access...",
                "bypassing firewall...",
                "establishing connection...",
                "tracing routes...",
                "spoofing signature..."
            }
            for _,line in ipairs(redLines) do
                if introFinished then return end
                typeText("> "..line.."\n",Color3.new(1,0.2,0.2),0.03)
            end
            
            typeText("> ACCESS DENIED\n",Color3.new(1,0.2,0.2),0.04)
            typeText("> RETRY WITH ROOT...\n",Color3.fromRGB(255,200,0),0.04)
            typeText("> ACCESS GRANTED\n",Color3.new(0,1,0),0.05)
            typeText("> 加载完成\n",Color3.new(0,1,0),0.05)
            typeText("> 用户名："..player.Name.."\n",Color3.new(0,1,0),0.04)
            typeText("> 权限校验完成\n",Color3.fromRGB(0,200,255),0.05)
            typeText("> 作者：Dsfhy8\n",Color3.new(0,1,0),0.04)
            typeText("> 脚本版本：v3.0\n",Color3.new(0,1,0),0.04)

            if introFinished then return end

            progressFrame.Visible=true
            local p1 = math.random(20, 45)
            local p2 = math.random(60, 85)
            
            progressText.Text="> Loading core... 0%"
            local t1 = TweenService:Create(progressFill, TweenInfo.new(0.8), {Size = UDim2.new(p1/100, 0, 1, 0)})
            t1:Play()
            for i=1,p1 do progressText.Text="> Loading core... "..i.."%"; task.wait(0.8/p1) end
            
            progressText.Text="> Loading core... "..p1.."% [STALL]"
            task.wait(0.5)
            
            progressText.Text="> Bypassing firewall... "..p1.."%"
            local t2 = TweenService:Create(progressFill, TweenInfo.new(0.6), {Size = UDim2.new(p2/100, 0, 1, 0)})
            t2:Play()
            for i=p1,p2 do progressText.Text="> Bypassing firewall... "..i.."%"; task.wait(0.6/(p2-p1)) end
            
            progressText.Text="> Bypassing firewall... "..p2.."% [CRITICAL]"
            task.wait(1)
            
            progressText.Text="> Injection successful! 100%"
            local t3 = TweenService:Create(progressFill, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, 0)})
            t3:Play()
            task.wait(0.2)
            task.wait(0.4)

            if introFinished then return end

            hackOverlay.Visible=false
            rainFrame.Visible=false
            blur.Enabled=false

            welcomeOverlay.Visible=true
            welcomeOverlay.BackgroundTransparency=1
            welcomeText.TextTransparency=1
            welcomeSub.TextTransparency=1
            welcomeStroke.Transparency=1

            scanLine.Visible=true
            scanLine.Size=UDim2.new(0,0,0,4)
            scanLine.Position=UDim2.new(0.5,0,0.5,0)
            
            local scanTween1 = TweenService:Create(scanLine, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(1.5,0,0,4)})
            scanTween1:Play()
            task.wait(0.3)

            local fadeInA=TweenService:Create(welcomeOverlay,TweenInfo.new(0.6),{BackgroundTransparency=0.1})
            local fadeInB=TweenService:Create(welcomeText,TweenInfo.new(0.6),{TextTransparency=0})
            local fadeInC=TweenService:Create(welcomeSub,TweenInfo.new(0.6),{TextTransparency=0})
            local fadeInD=TweenService:Create(welcomeStroke,TweenInfo.new(0.6),{Transparency=0})
            fadeInA:Play()
            fadeInB:Play()
            fadeInC:Play()
            fadeInD:Play()
            
            -- 每2秒闪一次，总共6秒（闪3次）
            local origPos = welcomeText.Position
            for i=1,3 do
                task.wait(2)
                if introFinished then break end
                
                -- 故障风抖动+变色
                for j=1,4 do
                    welcomeText.Position = origPos + UDim2.new(0, math.random(-5,5), 0, math.random(-5,5))
                    welcomeText.TextColor3 = (j%2==0) and Color3.fromRGB(0,255,100) or Color3.fromRGB(255,0,0)
                    task.wait(0.05)
                end
                welcomeText.Position = origPos
                welcomeText.TextColor3 = Color3.fromRGB(0,255,100)
            end
            
            if introFinished then return end
            
            StarterGui:SetCore("SendNotification", {
                Title = "机械脚本 v3.0",
                Text = "欢迎使用机械脚本，祝你游戏愉快！",
                Duration = 5
            })

            local fadeOutA=TweenService:Create(welcomeOverlay,TweenInfo.new(0.5),{BackgroundTransparency=1})
            local fadeOutB=TweenService:Create(welcomeText,TweenInfo.new(0.5),{TextTransparency=1})
            local fadeOutC=TweenService:Create(welcomeSub,TweenInfo.new(0.5),{TextTransparency=1})
            local fadeOutD=TweenService:Create(welcomeStroke,TweenInfo.new(0.5),{Transparency=1})
            local fadeOutScan=TweenService:Create(scanLine,TweenInfo.new(0.5),{BackgroundTransparency=1})
            fadeOutA:Play()
            fadeOutB:Play()
            fadeOutC:Play()
            fadeOutD:Play()
            fadeOutScan:Play()
            
            task.wait(0.5)
            scanLine.Visible=false
            welcomeOverlay.Visible=false
            if introFinished then return end

            finishIntro()
        end)
    end)
end)

-- ==================== 灵动岛/自瞄圈/ESP ====================
local hue2=0
task.spawn(function()
    while true do
        hue2=(hue2+0.02)%1
        borderGradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(hue2,1,1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue2+0.3)%1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue2+0.6)%1,1,1))
        })
        titleGradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(hue2,1,1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue2+0.3)%1,1,1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue2+0.6)%1,1,1))
        })
        task.wait(0.1)
    end
end)

local aimCircleGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
aimCircleGui.Name="AimCircleGui"
aimCircleGui.IgnoreGuiInset=true
aimCircleGui.ResetOnSpawn=false
local aimCircleFrame=Instance.new("Frame",aimCircleGui)
aimCircleFrame.Size=UDim2.new(0,st.aimCircleSize*2,0,st.aimCircleSize*2)
aimCircleFrame.Position=UDim2.new(0.5,-st.aimCircleSize,0.5,-st.aimCircleSize)
aimCircleFrame.BackgroundTransparency=1
aimCircleFrame.BorderSizePixel=0
aimCircleFrame.Visible=st.aimCircle
aimCircleFrame.ZIndex=9999
local aimCircleCorner=Instance.new("UICorner",aimCircleFrame)
aimCircleCorner.CornerRadius=UDim.new(1,0)
local aimCircleStroke=Instance.new("UIStroke",aimCircleFrame)
aimCircleStroke.Thickness=2
aimCircleStroke.Color=aimColorList[aimColorIndex]
local function updateAimCircle()
    if aimCircleFrame then
        aimCircleFrame.Size=UDim2.new(0,st.aimCircleSize*2,0,st.aimCircleSize*2)
        aimCircleFrame.Position=UDim2.new(0.5,-st.aimCircleSize,0.5,-st.aimCircleSize)
        aimCircleFrame.Visible=st.aimCircle
        aimCircleStroke.Color=aimColorList[aimColorIndex]
    end
end

local espGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
espGui.Name="EspGui"
espGui.IgnoreGuiInset=true
espGui.ResetOnSpawn=false
local MAX_ESP=30
local BONE_LINES=20
local espObjects={}
for i=1,MAX_ESP do
    local obj={}
    obj.topLine=Instance.new("Frame",espGui); obj.topLine.BorderSizePixel=0; obj.topLine.Visible=false; obj.topLine.ZIndex=10000
    obj.bottomLine=Instance.new("Frame",espGui); obj.bottomLine.BorderSizePixel=0; obj.bottomLine.Visible=false; obj.bottomLine.ZIndex=10000
    obj.leftLine=Instance.new("Frame",espGui); obj.leftLine.BorderSizePixel=0; obj.leftLine.Visible=false; obj.leftLine.ZIndex=10000
    obj.rightLine=Instance.new("Frame",espGui); obj.rightLine.BorderSizePixel=0; obj.rightLine.Visible=false; obj.rightLine.ZIndex=10000
    obj.hpBg=Instance.new("Frame",espGui); obj.hpBg.BackgroundColor3=Color3.fromRGB(30,30,30); obj.hpBg.BorderSizePixel=0; obj.hpBg.Visible=false; obj.hpBg.ZIndex=10001
    local hpBgCorner=Instance.new("UICorner",obj.hpBg); hpBgCorner.CornerRadius=UDim.new(0,2)
    local hpBgStroke=Instance.new("UIStroke",obj.hpBg); hpBgStroke.Color=Color3.fromRGB(100,100,100); hpBgStroke.Thickness=1
    obj.hpFill=Instance.new("Frame",obj.hpBg); obj.hpFill.BackgroundColor3=Color3.fromRGB(0,255,0); obj.hpFill.BorderSizePixel=0; obj.hpFill.Size=UDim2.new(1,0,1,0); obj.hpFill.ZIndex=10002
    local hpFillCorner=Instance.new("UICorner",obj.hpFill); hpFillCorner.CornerRadius=UDim.new(0,2)
    obj.nameText=Instance.new("TextLabel",espGui); obj.nameText.BackgroundTransparency=1; obj.nameText.Font=Enum.Font.SourceSansBold; obj.nameText.TextSize=13; obj.nameText.TextXAlignment=Enum.TextXAlignment.Left; obj.nameText.TextYAlignment=Enum.TextYAlignment.Top; obj.nameText.Visible=false; obj.nameText.ZIndex=10000
    obj.distText=Instance.new("TextLabel",espGui); obj.distText.BackgroundTransparency=1; obj.distText.Font=Enum.Font.SourceSansBold; obj.distText.TextSize=13; obj.distText.TextXAlignment=Enum.TextXAlignment.Left; obj.distText.TextYAlignment=Enum.TextYAlignment.Top; obj.distText.Visible=false; obj.distText.ZIndex=10000
    obj.hpText=Instance.new("TextLabel",espGui); obj.hpText.BackgroundTransparency=1; obj.hpText.TextColor3=Color3.fromRGB(255,60,60); obj.hpText.Font=Enum.Font.SourceSansBold; obj.hpText.TextSize=13; obj.hpText.TextXAlignment=Enum.TextXAlignment.Left; obj.hpText.TextYAlignment=Enum.TextYAlignment.Top; obj.hpText.Visible=false; obj.hpText.ZIndex=10000
    obj.bones={}
    for b=1,BONE_LINES do
        local line=Instance.new("Frame",espGui)
        line.AnchorPoint=Vector2.new(0.5,0.5)
        line.BorderSizePixel=0
        line.Visible=false
        line.ZIndex=10000
        obj.bones[b]=line
    end
    espObjects[i]=obj
end

local BONE_PAIRS_R6={ {"Head","Torso"}, {"Torso","Left Arm"}, {"Torso","Right Arm"}, {"Torso","Left Leg"}, {"Torso","Right Leg"} }
local BONE_PAIRS_R15={
    {"Head","UpperTorso"}, {"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"}, {"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"}, {"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"}, {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"}, {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"}
}
local function getBonePairs(char)
    if char:FindFirstChild("UpperTorso") then return BONE_PAIRS_R15 end
    if char:FindFirstChild("Torso") then return BONE_PAIRS_R6 end
    return nil
end

local function getAimEnemies()
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then
            local sameTeam=(player.Team and p.Team and player.Team==p.Team)
            if not (st.teamcheck and sameTeam) then table.insert(list,p.Character) end
        end
    end
    if st.espnpc then
        for _,obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                local hum=obj:FindFirstChild("Humanoid")
                if hum and hum.Health>0 then table.insert(list,obj) end
            end
        end
    end
    return list
end

local function getEspEnemies()
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then
            local sameTeam=(player.Team and p.Team and player.Team==p.Team)
            if not (st.espTeamcheck and sameTeam) then table.insert(list,p.Character) end
        end
    end
    if st.espnpc then
        for _,obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                local hum=obj:FindFirstChild("Humanoid")
                if hum and hum.Health>0 then table.insert(list,obj) end
            end
        end
    end
    return list
end

local function losCheck(origin,targetPos,targetChar)
    if not st.wallcheck then return true end
    local direction=targetPos-origin
    local distance=direction.Magnitude
    if distance<=0.01 then return true end
    direction=direction.Unit
    local ignoreList={}
    if player.Character then
        for _,v in ipairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then table.insert(ignoreList,v) end end
    end
    if targetChar then
        for _,v in ipairs(targetChar:GetDescendants()) do if v:IsA("BasePart") then table.insert(ignoreList,v) end end
    end
    local success,result=pcall(function()
        local params=RaycastParams.new()
        params.FilterDescendantsInstances=ignoreList
        params.FilterType=Enum.RaycastFilterType.Blacklist
        return workspace:Raycast(origin,direction*distance,params)
    end)
    if success then return result==nil
    else
        local ray=Ray.new(origin,direction*distance)
        local hit=workspace:FindPartOnRayWithIgnoreList(ray,ignoreList)
        return hit==nil
    end
end

-- 被看雷达UI
local watchGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
watchGui.Name = "WatchAlertGui"
watchGui.IgnoreGuiInset = true
watchGui.ResetOnSpawn = false

local function createAlertArrow(name, pos, size)
    local arrow = Instance.new("TextLabel", watchGui)
    arrow.Name = name
    arrow.Size = size
    arrow.Position = pos
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = Color3.fromRGB(255, 50, 50)
    arrow.Font = Enum.Font.SourceSansBold
    arrow.TextSize = 40
    arrow.Text = ""
    arrow.Visible = false
    arrow.ZIndex = 100
    return arrow
end

local arrowFront = createAlertArrow("Front", UDim2.new(0.5, -50, 0, 50), UDim2.new(0, 100, 0, 50))
arrowFront.Text = "▲"
local arrowBack = createAlertArrow("Back", UDim2.new(0.5, -50, 1, -100), UDim2.new(0, 100, 0, 50))
arrowBack.Text = "▼"
local arrowLeft = createAlertArrow("Left", UDim2.new(0, 20, 0.5, -25), UDim2.new(0, 50, 0, 50))
arrowLeft.Text = "◀"
local arrowRight = createAlertArrow("Right", UDim2.new(1, -70, 0.5, -25), UDim2.new(0, 50, 0, 50))
arrowRight.Text = "▶"

local function checkWatched()
    if not st.watchedAlert then
        arrowFront.Visible = false; arrowBack.Visible = false
        arrowLeft.Visible = false; arrowRight.Visible = false
        return
    end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        arrowFront.Visible = false; arrowBack.Visible = false
        arrowLeft.Visible = false; arrowRight.Visible = false
        return
    end
    
    local myRoot = player.Character.HumanoidRootPart
    local myPos = myRoot.Position
    local myLook = myRoot.CFrame.LookVector
    local myRight = myRoot.CFrame.RightVector
    
    local lookers = {Front=false, Back=false, Left=false, Right=false}
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local targetRoot = p.Character.HumanoidRootPart
            local targetPos = targetRoot.Position
            local dist = (targetPos - myPos).Magnitude
            
            if dist <= 300 then
                local enemyLook = targetRoot.CFrame.LookVector
                local toMe = (myPos - targetPos).Unit
                
                if enemyLook:Dot(toMe) > 0.8 then
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    local ignore = {}
                    if player.Character then table.insert(ignore, player.Character) end
                    if p.Character then table.insert(ignore, p.Character) end
                    params.FilterDescendantsInstances = ignore
                    
                    local hit = workspace:Raycast(targetPos, (myPos - targetPos), params)
                    if not hit then
                        local toEnemy = (targetPos - myPos).Unit
                        local dotF = myLook:Dot(toEnemy)
                        local dotR = myRight:Dot(toEnemy)
                        
                        if math.abs(dotF) > math.abs(dotR) then
                            if dotF > 0 then lookers.Front = true else lookers.Back = true end
                        else
                            if dotR > 0 then lookers.Right = true else lookers.Left = true end
                        end
                    end
                end
            end
        end
    end
    
    arrowFront.Visible = lookers.Front
    arrowBack.Visible = lookers.Back
    arrowLeft.Visible = lookers.Left
    arrowRight.Visible = lookers.Right
end

-- ==================== 主循环 ====================
local lowGraphicsActive=false
local originalLighting={}
local originalCameraType=cam.CameraType

RS.RenderStepped:Connect(function()
    if scriptClosed then return end

    pcall(function() updateAimCircle() end)

    -- 自瞄
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        if st.aim or st.silent then
            local targets=getAimEnemies()
            local bestTarget=nil
            local bestDist=math.huge
            
            for _,tarChar in ipairs(targets) do
                local aimPart
                if st.lockh then aimPart=tarChar:FindFirstChild("Head") or tarChar:FindFirstChild("HumanoidRootPart")
                else aimPart=tarChar:FindFirstChild("HumanoidRootPart") end
                if aimPart then
                    local dist=(aimPart.Position-cam.CFrame.Position).Magnitude
                    if dist<=st.aimrange then
                        local canLock=true
                        if st.aimCircle then
                            local screenPos,onScreen=cam:WorldToScreenPoint(aimPart.Position)
                            if onScreen and screenPos then
                                local screenDist=(Vector2.new(screenPos.X,screenPos.Y)-Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)).Magnitude
                                if screenDist>st.aimCircleSize then canLock=false end
                            else canLock=false end
                        end
                        if canLock and losCheck(cam.CFrame.Position,aimPart.Position,tarChar) then
                            if dist<bestDist then bestDist=dist;bestTarget=aimPart end
                        end
                    end
                end
            end
            
            if bestTarget then
                local look=CFrame.lookAt(cam.CFrame.Position,bestTarget.Position)
                cam.CFrame=cam.CFrame:Lerp(look,st.aimSmooth)
            end
        end
    end)

    -- 碰撞放大 (修复 R6)
    pcall(function()
        if st.hitbox then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local partsToGrow = {"Head"}
                    if p.Character:FindFirstChild("UpperTorso") then
                        table.insert(partsToGrow, "HumanoidRootPart")
                    elseif p.Character:FindFirstChild("Torso") then
                        table.insert(partsToGrow, "Torso")
                    end
                    
                    for _, partName in ipairs(partsToGrow) do
                        local part = p.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") then
                            if not part:GetAttribute("OrigSize") then
                                part:SetAttribute("OrigSize", part.Size)
                                part:SetAttribute("OrigTrans", part.Transparency)
                                part:SetAttribute("OrigCollide", part.CanCollide)
                            end
                            part.Size = part:GetAttribute("OrigSize") * st.hitboxSize
                            part.Transparency = 0.5
                            part.CanCollide = false
                        end
                    end
                end
            end
        else
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    for _, partName in ipairs({"Head", "HumanoidRootPart", "Torso"}) do
                        local part = p.Character:FindFirstChild(partName)
                        if part and part:IsA("BasePart") and part:GetAttribute("OrigSize") then
                            part.Size = part:GetAttribute("OrigSize")
                            part.Transparency = part:GetAttribute("OrigTrans")
                            part.CanCollide = part:GetAttribute("OrigCollide")
                        end
                    end
                end
            end
        end
    end)

    -- 透视
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local curColor=espColorList[espColorIndex]
        for i=1,MAX_ESP do
            local obj=espObjects[i]
            obj.topLine.Visible=false;obj.bottomLine.Visible=false
            obj.leftLine.Visible=false;obj.rightLine.Visible=false
            obj.hpBg.Visible=false
            obj.nameText.Visible=false;obj.distText.Visible=false;obj.hpText.Visible=false
            for b=1,BONE_LINES do obj.bones[b].Visible=false end
        end

        if st.esp then
            local targets=getEspEnemies()
            local vpSize=cam.ViewportSize
            local idx=0
            for _,tarChar in ipairs(targets) do
                local root=tarChar:FindFirstChild("HumanoidRootPart")
                local hum=tarChar:FindFirstChild("Humanoid")
                local head=tarChar:FindFirstChild("Head")
                if root and hum and head then
                    local dist=(root.Position-cam.CFrame.Position).Magnitude
                    if dist<=st.espRange and dist > 4 then
                        local topPosition=head.Position+Vector3.new(0,0.6,0)
                        
                        local _, cSize = tarChar:GetBoundingBox()
                        local bottomPosition = root.Position - Vector3.new(0, cSize.Y / 2, 0)
                        
                        local topScreen=cam:WorldToViewportPoint(topPosition)
                        local bottomScreen=cam:WorldToViewportPoint(bottomPosition)
                        if topScreen.Z>0 or bottomScreen.Z>0 then
                            local centerX=(topScreen.X+bottomScreen.X)/2
                            if centerX>-100 and centerX<vpSize.X+100 then
                                idx=idx+1
                                if idx>MAX_ESP then break end
                                local obj=espObjects[idx]

                                local y1=math.min(topScreen.Y,bottomScreen.Y)-2
                                local y2=math.max(topScreen.Y,bottomScreen.Y)+2
                                local height=math.min(y2-y1, 800)
                                local width=math.max(height*0.6,10)
                                local x1=centerX-width/2
                                local x2=centerX+width/2

                                if st.espBox then
                                    obj.topLine.BackgroundColor3=curColor
                                    obj.topLine.Position=UDim2.new(0,x1,0,y1)
                                    obj.topLine.Size=UDim2.new(0,width,0,1)
                                    obj.topLine.Visible=true
                                    obj.bottomLine.BackgroundColor3=curColor
                                    obj.bottomLine.Position=UDim2.new(0,x1,0,y2)
                                    obj.bottomLine.Size=UDim2.new(0,width,0,1)
                                    obj.bottomLine.Visible=true
                                    obj.leftLine.BackgroundColor3=curColor
                                    obj.leftLine.Position=UDim2.new(0,x1,0,y1)
                                    obj.leftLine.Size=UDim2.new(0,1,0,height)
                                    obj.leftLine.Visible=true
                                    obj.rightLine.BackgroundColor3=curColor
                                    obj.rightLine.Position=UDim2.new(0,x2,0,y1)
                                    obj.rightLine.Size=UDim2.new(0,1,0,height)
                                    obj.rightLine.Visible=true
                                end

                                if st.espHpBar then
                                    local hpRatio=math.clamp(hum.Health/hum.MaxHealth,0,1)
                                    obj.hpBg.Position=UDim2.new(0,x1,0,y1-8)
                                    obj.hpBg.Size=UDim2.new(0,width,0,5)
                                    obj.hpBg.Visible=true
                                    obj.hpFill.Size=UDim2.new(hpRatio,0,1,0)
                                    if hpRatio>0.6 then
                                        obj.hpFill.BackgroundColor3=Color3.fromRGB(0,255,0)
                                    elseif hpRatio>0.3 then
                                        obj.hpFill.BackgroundColor3=Color3.fromRGB(255,220,0)
                                    else
                                        obj.hpFill.BackgroundColor3=Color3.fromRGB(255,50,50)
                                    end
                                end

                                local name=""
                                local plr=Players:GetPlayerFromCharacter(tarChar)
                                if plr then name=plr.Name else name=tarChar.Name end

                                if st.espn then
                                    obj.nameText.Text=name
                                    obj.nameText.TextColor3=curColor
                                    obj.nameText.Position=UDim2.new(0,x1,0,y1-22)
                                    obj.nameText.Visible=true
                                end
                                if st.espd then
                                    obj.distText.Text=string.format("%.0f m",dist)
                                    obj.distText.TextColor3=curColor
                                    obj.distText.Position=UDim2.new(0,x1,0,y2+4)
                                    obj.distText.Visible=true
                                end
                                if st.esphp then
                                    obj.hpText.Text="HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                                    obj.hpText.TextColor3=Color3.fromRGB(255,60,60)
                                    obj.hpText.Position=UDim2.new(0,x1,0,y2+18)
                                    obj.hpText.Visible=true
                                end

                                if st.espBones then
                                    local pairs=getBonePairs(tarChar)
                                    if pairs then
                                        local boneIdx=0
                                        for _,pair in ipairs(pairs) do
                                            local partA=tarChar:FindFirstChild(pair[1])
                                            local partB=tarChar:FindFirstChild(pair[2])
                                            if partA and partB then
                                                local posA,onA=cam:WorldToViewportPoint(partA.Position)
                                                local posB,onB=cam:WorldToViewportPoint(partB.Position)
                                                if posA.Z>0 or posB.Z>0 then
                                                    boneIdx=boneIdx+1
                                                    if boneIdx>BONE_LINES then break end
                                                    local line=obj.bones[boneIdx]
                                                    local dx=posB.X-posA.X
                                                    local dy=posB.Y-posA.Y
                                                    local len=math.sqrt(dx*dx+dy*dy)
                                                    if len>0.1 then
                                                        local ang=math.deg(math.atan2(dy,dx))
                                                        line.BackgroundColor3=curColor
                                                        local midX=(posA.X+posB.X)/2
                                                        local midY=(posA.Y+posB.Y)/2
                                                        line.Position=UDim2.new(0,midX,0,midY)
                                                        line.Size=UDim2.new(0,len,0,1.5) 
                                                        line.Rotation=ang
                                                        line.Visible=true
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    pcall(function() checkWatched() end)

    -- 低画质模式
    pcall(function()
        if st.lowGraphics and not lowGraphicsActive then
            lowGraphicsActive=true
            originalLighting.GlobalShadows=Lighting.GlobalShadows
            originalLighting.FogEnd=Lighting.FogEnd
            originalLighting.EnvironmentDiffuseScale=Lighting.EnvironmentDiffuseScale
            originalLighting.EnvironmentSpecularScale=Lighting.EnvironmentSpecularScale
            Lighting.GlobalShadows=false
            Lighting.FogEnd=100000
            Lighting.EnvironmentDiffuseScale=0
            Lighting.EnvironmentSpecularScale=0
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled=false
                end
            end
        elseif not st.lowGraphics and lowGraphicsActive then
            lowGraphicsActive=false
            Lighting.GlobalShadows=originalLighting.GlobalShadows
            Lighting.FogEnd=originalLighting.FogEnd
            Lighting.EnvironmentDiffuseScale=originalLighting.EnvironmentDiffuseScale
            Lighting.EnvironmentSpecularScale=originalLighting.EnvironmentSpecularScale
        end
    end)

    -- 自由视角 / 第三人称 (每帧强行锁死，防止被游戏服务器覆盖)
    pcall(function()
        if st.freeCam then
            if cam.CameraType ~= Enum.CameraType.Scriptable then
                originalCameraType = cam.CameraType
                cam.CameraType = Enum.CameraType.Scriptable
            end
        else
            if cam.CameraType == Enum.CameraType.Scriptable then
                cam.CameraType = originalCameraType
            end
        end
        
        if st.third then
            if player.CameraMode ~= Enum.CameraMode.Classic then
                player.CameraMode = Enum.CameraMode.Classic
            end
            if player.CameraMaxZoomDistance ~= 12 then
                player.CameraMaxZoomDistance = 12
            end
        end
    end)

    -- 防闪/烟/抖动
    pcall(function()
        if st.antiflash or st.antismoke or st.antishake then
            for _,v in ipairs(WS:GetDescendants()) do
                if st.antiflash and (v.Name:lower():find("flash") or v.Name:lower():find("blind")) and v:IsA("Light") then
                    v.Enabled = false
                end
                if st.antismoke and (v.Name:lower():find("smoke") or v.Name:lower():find("fog")) and v:IsA("ParticleEmitter") then
                    v.Enabled = false
                end
            end
            if st.antishake and cam then
                cam.CFrame = cam.CFrame
            end
        end
    end)

    -- 其他功能
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local myRoot=player.Character.HumanoidRootPart
        local hum=player.Character:FindFirstChild("Humanoid")
        if not hum then return end

        if hum~=watchedHumanoid then
            watchedHumanoid=hum
            bindHealthProtection(hum)
        end

        -- 飞行
        if st.fly then
            if not bodyGyro or not bodyGyro.Parent then
                if bodyGyro then bodyGyro:Destroy() end
                bodyGyro=Instance.new("BodyGyro",myRoot)
                bodyGyro.P=90000; bodyGyro.D=500; bodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
            end
            if not bodyVel or not bodyVel.Parent then
                if bodyVel then bodyVel:Destroy() end
                bodyVel=Instance.new("BodyVelocity",myRoot)
                bodyVel.MaxForce=Vector3.new(9e9,9e9,9e9); bodyVel.P=10000
            end
            if not hum.PlatformStand then hum.PlatformStand=true end
            pcall(function()
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Landed,false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
            end)
            if hum.Health<hum.MaxHealth then hum.Health=hum.MaxHealth end

            local moveDir=hum.MoveDirection
            local camForward=cam.CFrame.LookVector
            local camRight=cam.CFrame.RightVector
            local lookFlat=Vector3.new(camForward.X,0,camForward.Z)
            if lookFlat.Magnitude<0.01 then lookFlat=Vector3.new(0,0,-1) end
            lookFlat=lookFlat.Unit

            local forwardInput=moveDir.X*lookFlat.X+moveDir.Z*lookFlat.Z
            local rightInput=moveDir.X*camRight.X+moveDir.Z*camRight.Z

            local flyDir=Vector3.new(0,0,0)
            if math.abs(forwardInput)>0.1 then flyDir+=lookFlat*math.sign(forwardInput) end
            if math.abs(rightInput)>0.1 then flyDir+=camRight*math.sign(rightInput) end
            if math.abs(forwardInput)>0.1 then flyDir+=Vector3.new(0,camForward.Y*math.sign(forwardInput),0) end

            if flyDir.Magnitude>0 then flyDir=flyDir.Unit end
            bodyVel.Velocity=flyDir*st.flyspeed
            bodyGyro.CFrame=CFrame.new(myRoot.Position,myRoot.Position+lookFlat)
        else
            if bodyGyro then bodyGyro:Destroy();bodyGyro=nil end
            if bodyVel then bodyVel:Destroy();bodyVel=nil end
            pcall(function()
                hum.PlatformStand=false
                hum:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Landed,true)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
            end)
        end

        if st.trackPlayer and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tarRoot=selectedTarget.Character.HumanoidRootPart
            local offset=tarRoot.CFrame.LookVector*(-3)+Vector3.new(0,2,0)
            myRoot.CFrame=CFrame.new(tarRoot.Position+offset)
            hum.PlatformStand=true
        end

        if st.noplayercol then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=player and p.Character then
                    for _,part in ipairs(p.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide=false end
                    end
                end
            end
        end

        if st.speed then hum.WalkSpeed=st.walkspeed; appliedWalkSpeed=st.walkspeed
        else
            if appliedWalkSpeed and hum.WalkSpeed==appliedWalkSpeed then hum.WalkSpeed=baseWalkSpeed end
            appliedWalkSpeed=nil
        end
        if st.jumpboost then hum.JumpPower=st.jumppower; appliedJumpPower=st.jumppower
        else
            if appliedJumpPower and hum.JumpPower==appliedJumpPower then hum.JumpPower=baseJumpPower end
            appliedJumpPower=nil
        end

        if st.autobhop and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        if st.noclip then
            for _,part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide=false end
            end
        end

        if st.waterWalk then
            local ray=workspace:Raycast(myRoot.Position,Vector3.new(0,-3,0))
            if ray and ray.Instance:IsA("Terrain") and ray.Material==Enum.Material.Water then
                if not bodyFloat then
                    bodyFloat=Instance.new("BodyVelocity",myRoot)
                    bodyFloat.MaxForce=Vector3.new(0,9e9,0)
                    bodyFloat.Velocity=Vector3.new(0,20,0)
                end
            else
                if bodyFloat then bodyFloat:Destroy();bodyFloat=nil end
            end
        else
            if bodyFloat then bodyFloat:Destroy();bodyFloat=nil end
        end

        if st.spin then
            if not bodySpin then
                bodySpin=Instance.new("BodyAngularVelocity",myRoot)
                bodySpin.MaxTorque=Vector3.new(0,9e9,0)
            end
            bodySpin.AngularVelocity=Vector3.new(0,st.spinSpeed*0.5,0)
        else
            if bodySpin then bodySpin:Destroy();bodySpin=nil end
        end

        if st.night then Lighting.Brightness=3 else Lighting.Brightness=1 end
        if st.nofall then hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end
        if st.zoom then cam.FieldOfView=30 else cam.FieldOfView=70 end
    end)
end)

UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.End then
        pcall(function()
            if introCoroutine then task.cancel(introCoroutine) end
        end)
        introCoroutine=nil
        finishIntro()
        return
    end
    if scriptClosed then return end
    if input.KeyCode==Enum.KeyCode.F1 then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(savedLocations,{name="快捷坐标"..(#savedLocations+1),cframe=player.Character.HumanoidRootPart.CFrame})
            refreshCoordList()
            notif("已保存快捷坐标")
        end
    end
end)
