local player=game.Players.LocalPlayer
local cam=workspace.CurrentCamera
local Players=game:GetService("Players")
local RS=game:GetService("RunService")
local WS=workspace
local UIS=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local TweenService=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")

-- 状态
local st={
    aim=false,lockh=false,silent=false,wallcheck=false,teamcheck=false,aimrange=200,
    aimCircle=false,aimCircleSize=100,aimSmooth=0.12,
    esp=false,espn=false,espd=false,esphp=false,espnpc=true,espRange=500,
    norecoil=false,fastrel=false,nospread=false,infammo=false,rapid=false,autofire=false,
    speed=false,walkspeed=16,jumpboost=false,jumppower=50,autobhop=false,third=false,
    god=false,stamina=false,regen=false,night=false,nofall=false,nofoot=false,
    fly=false,flyspeed=50,flyNoclip=false,noclip=false,noplayercol=false,frontpush=false,zoom=false,
    savepos=false,tpto=false,
    swimBoost=false,waterWalk=false,
    trackPlayer=false,
    spin=false,spinSpeed=50,
    fastInteract=false,
    watchedAlert=false
}

local savedPos=nil
local bodyGyro,bodyVel,bodyFloat,bodySpin
local selectedTarget=nil
local targetList={}
local targetIndex=0

-- 通知
local function notif(text)
    pcall(function()
        StarterGui:SetCore("SendNotification",{Title="机械脚本",Text=text,Duration=3})
    end)
end

-- UI根
local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
gui.Name="机械脚本"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling

-- 全屏模糊
local blur=Instance.new("BlurEffect",Lighting)
blur.Name="HackBlur"
blur.Size=60
blur.Enabled=false

-- 全屏遮罩
local hackOverlay=Instance.new("Frame",gui)
hackOverlay.Size=UDim2.new(3,0,3,0)
hackOverlay.Position=UDim2.new(-1,0,-1,0)
hackOverlay.BackgroundColor3=Color3.new(0,0,0)
hackOverlay.BackgroundTransparency=0.6
hackOverlay.BorderSizePixel=0
hackOverlay.ZIndex=300
hackOverlay.Visible=true

-- 数字雨
local rainFrame=Instance.new("Frame",hackOverlay)
rainFrame.Size=UDim2.new(1,0,1,0)
rainFrame.Position=UDim2.new(0,0,0,0)
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
            local y=label.Position.Y.Offset
            y=y+8
            if y>500 then y=-150;label.Position=UDim2.new(label.Position.X.Scale,label.Position.X.Offset,0,math.random(-200,0)) end
            label.Position=UDim2.new(label.Position.X.Scale,label.Position.X.Offset,0,y)
            local str=""
            for _=1,10 do str=str..string.char(math.random(48,57)).."\n" end
            label.Text=str
        end
        task.wait(0.1)
    end
end)

-- 终端框
local terminal=Instance.new("Frame",hackOverlay)
terminal.Size=UDim2.new(0,380,0,320)
terminal.Position=UDim2.new(0.5,-190,0.5,-160)
terminal.BackgroundColor3=Color3.new(10/255,12/255,14/255)
terminal.BackgroundTransparency=0
terminal.BorderSizePixel=2
terminal.BorderColor3=Color3.new(0,1,0)
terminal.ZIndex=301

local termTitle=Instance.new("TextLabel",terminal)
termTitle.Size=UDim2.new(1,0,0,22)
termTitle.Position=UDim2.new(0,0,0,0)
termTitle.BackgroundColor3=Color3.new(0,30/255,0)
termTitle.Text="ROBLOX_EXPLOIT_CONSOLE"
termTitle.TextColor3=Color3.new(0,1,0)
termTitle.Font=Enum.Font.SourceSansBold
termTitle.TextSize=12
termTitle.TextXAlignment=Enum.TextXAlignment.Center
termTitle.ZIndex=302

local termText=Instance.new("TextLabel",terminal)
termText.Size=UDim2.new(1,-20,0,220)
termText.Position=UDim2.new(0,10,0,30)
termText.BackgroundTransparency=1
termText.Text=""
termText.TextColor3=Color3.new(1,0,0)
termText.Font=Enum.Font.SourceSansBold
termText.TextSize=14
termText.TextXAlignment=Enum.TextXAlignment.Left
termText.TextYAlignment=Enum.TextYAlignment.Top
termText.RichText=true

-- 跳过按钮（左侧）
local skipButton = Instance.new("TextButton", hackOverlay)
skipButton.Size = UDim2.new(0, 80, 0, 32)
skipButton.Position = UDim2.new(0, 10, 0, 10)
skipButton.BackgroundColor3 = Color3.new(80/255, 130/255, 200/255)
skipButton.Text = "跳过"
skipButton.TextColor3 = Color3.new(1,1,1)
skipButton.Font = Enum.Font.SourceSansBold
skipButton.TextSize = 14
skipButton.AutoLocalize = false
skipButton.ZIndex = 400
skipButton.Visible = true

-- 灵动岛
local island=Instance.new("TextButton",gui)
island.Size=UDim2.new(0,160,0,32)
island.Position=UDim2.new(0.5,-80,0.02,0)
island.BackgroundColor3=Color3.new(30/255,0,40/255)
island.BorderSizePixel=2
island.BorderColor3=Color3.new(1,0,0)
island.Text="机械脚本"
island.TextColor3=Color3.new(1,1,1)
island.Font=Enum.Font.SourceSansBold
island.TextSize=14
island.AutoLocalize=false
island.ZIndex=160
island.Visible=false
local uiCorner=Instance.new("UICorner",island)
uiCorner.CornerRadius=UDim.new(1,0)

-- 主面板
local panel=Instance.new("Frame",gui)
panel.Size=UDim2.new(0,340,0,260)
panel.Position=UDim2.new(0.5,-170,0.5,-130)
panel.BackgroundColor3=Color3.new(22/255,22/255,22/255)
panel.BorderSizePixel=3
panel.BorderColor3=Color3.new(1,0,0)
panel.Visible=false
panel.ZIndex=50

--标题栏
local titleBar=Instance.new("Frame",panel)
titleBar.Size=UDim2.new(1,0,0,30)
titleBar.BackgroundColor3=Color3.new(35/255,35/255,35/255)
titleBar.BorderSizePixel=0

local titleText=Instance.new("TextLabel",titleBar)
titleText.Size=UDim2.new(1,-30,1,0)
titleText.Position=UDim2.new(0,10,0,0)
titleText.BackgroundTransparency=1
titleText.Text="机械脚本"
titleText.TextColor3=Color3.new(1,1,1)
titleText.Font=Enum.Font.SourceSansBold
titleText.TextSize=17
titleText.TextXAlignment=Enum.TextXAlignment.Left

local closeBtn=Instance.new("TextButton",titleBar)
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.Position=UDim2.new(1,-28,0,3)
closeBtn.BackgroundColor3=Color3.new(220/255,50/255,50/255)
closeBtn.Text="X"
closeBtn.TextColor3=Color3.new(1,1,1)
closeBtn.Font=Enum.Font.SourceSansBold
closeBtn.TextSize=12
closeBtn.AutoLocalize=false
closeBtn.MouseButton1Click:Connect(function() panel.Visible=false end)

--页面容器9页
local pages={}
local names={"自瞄合集","透视合集","武器合集","移动合集","生存合集","通用合集","娱乐合集","其他合集","更多合集"}
for i=1,9 do
    local p=Instance.new("Frame",panel)
    p.Size=UDim2.new(1,0,1,-50)
    p.Position=UDim2.new(0,0,0,30)
    p.BackgroundTransparency=1
    p.ZIndex=60
    p.Visible=(i==1)
    local h=Instance.new("TextLabel",p)
    h.Size=UDim2.new(1,0,0,20)
    h.Position=UDim2.new(0,0,0,0)
    h.BackgroundTransparency=1
    h.Text=names[i]
    h.TextColor3=Color3.new(255/255,225/255,90/255)
    h.Font=Enum.Font.SourceSansBold
    h.TextSize=14
    h.TextXAlignment=Enum.TextXAlignment.Left
    pages[i]=p
end

local curPage=1
local prevBtn=Instance.new("TextButton",panel)
prevBtn.Size=UDim2.new(0,60,0,24)
prevBtn.Position=UDim2.new(0,10,1,-30)
prevBtn.BackgroundColor3=Color3.new(100/255,100/255,100/255)
prevBtn.Text="上一页"
prevBtn.TextColor3=Color3.new(1,1,1)
prevBtn.Font=Enum.Font.SourceSansBold
prevBtn.TextSize=11
prevBtn.AutoLocalize=false
prevBtn.ZIndex=70
prevBtn.Visible=false

local nextBtn=Instance.new("TextButton",panel)
nextBtn.Size=UDim2.new(0,60,0,24)
nextBtn.Position=UDim2.new(0,270,1,-30)
nextBtn.BackgroundColor3=Color3.new(100/255,100/255,100/255)
nextBtn.Text="下一页"
nextBtn.TextColor3=Color3.new(1,1,1)
nextBtn.Font=Enum.Font.SourceSansBold
nextBtn.TextSize=11
nextBtn.AutoLocalize=false
nextBtn.ZIndex=70

local pageLabel=Instance.new("TextLabel",panel)
pageLabel.Size=UDim2.new(0,80,0,20)
pageLabel.Position=UDim2.new(0.5,-40,1,-28)
pageLabel.BackgroundTransparency=1
pageLabel.Text="第1/9页"
pageLabel.TextColor3=Color3.new(1,1,1)
pageLabel.Font=Enum.Font.SourceSansBold
pageLabel.TextSize=11
pageLabel.ZIndex=70
pageLabel.TextXAlignment=Enum.TextXAlignment.Center

local function showPage(p)
    for i=1,9 do pages[i].Visible=(i==p) end
    prevBtn.Visible=(p>1)
    nextBtn.Visible=(p<9)
    pageLabel.Text="第"..p.."/9页"
    curPage=p
end
prevBtn.MouseButton1Click:Connect(function() showPage(curPage-1) end)
nextBtn.MouseButton1Click:Connect(function() showPage(curPage+1) end)

island.MouseButton1Click:Connect(function()
    pcall(function()
        panel.Visible = not panel.Visible
        if panel.Visible then showPage(curPage) end
    end)
end)

UIS.InputBegan:Connect(function(input,gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        pcall(function()
            panel.Visible = not panel.Visible
            if panel.Visible then showPage(curPage) end
        end)
    end
end)

-- 飞行独立UI
local flyControlUI=Instance.new("Frame",gui)
flyControlUI.Size=UDim2.new(0,150,0,80)
flyControlUI.Position=UDim2.new(0.7,-75,0.75,-40)
flyControlUI.BackgroundColor3=Color3.new(0,0,0)
flyControlUI.BackgroundTransparency=0.2
flyControlUI.BorderSizePixel=0
flyControlUI.Visible=false
flyControlUI.ZIndex=200

local flySpeedLabel=Instance.new("TextLabel",flyControlUI)
flySpeedLabel.Size=UDim2.new(0,60,0,20)
flySpeedLabel.Position=UDim2.new(0.5,-30,0.5,-10)
flySpeedLabel.BackgroundTransparency=1
flySpeedLabel.Text="50"
flySpeedLabel.TextColor3=Color3.new(1,1,1)
flySpeedLabel.Font=Enum.Font.SourceSansBold
flySpeedLabel.TextSize=16
flySpeedLabel.TextXAlignment=Enum.TextXAlignment.Center
flySpeedLabel.TextYAlignment=Enum.TextYAlignment.Center
flySpeedLabel.ZIndex=201

local flyAccelBtn=Instance.new("TextButton",flyControlUI)
flyAccelBtn.Size=UDim2.new(0,70,0,35)
flyAccelBtn.Position=UDim2.new(0,5,0,5)
flyAccelBtn.BackgroundColor3=Color3.new(80/255,130/255,200/255)
flyAccelBtn.Text="加速"
flyAccelBtn.TextColor3=Color3.new(1,1,1)
flyAccelBtn.Font=Enum.Font.SourceSansBold
flyAccelBtn.TextSize=14
flyAccelBtn.AutoLocalize=false
flyAccelBtn.ZIndex=202
flyAccelBtn.MouseButton1Click:Connect(function()
    st.flyspeed=math.min(200,st.flyspeed+10)
    flySpeedLabel.Text=tostring(st.flyspeed)
end)

local flyDecelBtn=Instance.new("TextButton",flyControlUI)
flyDecelBtn.Size=UDim2.new(0,70,0,35)
flyDecelBtn.Position=UDim2.new(0,75,0,5)
flyDecelBtn.BackgroundColor3=Color3.new(200/255,80/255,80/255)
flyDecelBtn.Text="减速"
flyDecelBtn.TextColor3=Color3.new(1,1,1)
flyDecelBtn.Font=Enum.Font.SourceSansBold
flyDecelBtn.TextSize=14
flyDecelBtn.AutoLocalize=false
flyDecelBtn.ZIndex=202
flyDecelBtn.MouseButton1Click:Connect(function()
    st.flyspeed=math.max(10,st.flyspeed-10)
    flySpeedLabel.Text=tostring(st.flyspeed)
end)

local flyCloseBtn=Instance.new("TextButton",flyControlUI)
flyCloseBtn.Size=UDim2.new(0,70,0,35)
flyCloseBtn.Position=UDim2.new(0,5,0,40)
flyCloseBtn.BackgroundColor3=Color3.new(255/255,100/255,100/255)
flyCloseBtn.Text="关闭"
flyCloseBtn.TextColor3=Color3.new(1,1,1)
flyCloseBtn.Font=Enum.Font.SourceSansBold
flyCloseBtn.TextSize=14
flyCloseBtn.AutoLocalize=false
flyCloseBtn.ZIndex=202
flyCloseBtn.MouseButton1Click:Connect(function()
    st.fly=false
    flyControlUI.Visible=false
    for _,btn in ipairs(pages[6]:GetChildren()) do
        if btn:IsA("TextButton") and string.find(btn.Text,"飞行") then
            btn.Text="飞行：关"
            btn.BackgroundColor3=Color3.new(110/255,110/255,110/255)
        end
    end
end)

local flyNoclipBtn=Instance.new("TextButton",flyControlUI)
flyNoclipBtn.Size=UDim2.new(0,70,0,35)
flyNoclipBtn.Position=UDim2.new(0,75,0,40)
flyNoclipBtn.BackgroundColor3=Color3.new(110/255,110/255,110/255)
flyNoclipBtn.Text="穿墙"
flyNoclipBtn.TextColor3=Color3.new(1,1,1)
flyNoclipBtn.Font=Enum.Font.SourceSansBold
flyNoclipBtn.TextSize=14
flyNoclipBtn.AutoLocalize=false
flyNoclipBtn.ZIndex=202
flyNoclipBtn.MouseButton1Click:Connect(function()
    st.flyNoclip=not st.flyNoclip
    flyNoclipBtn.BackgroundColor3=st.flyNoclip and Color3.new(0,200/255,0) or Color3.new(110/255,110/255,110/255)
end)

-- 飞行UI拖拽
local flyUIDragging=false
local flyUIDragStart=nil
local flyUIStartPos=nil
flyControlUI.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        flyUIDragging=true
        flyUIDragStart=input.Position
        flyUIStartPos=flyControlUI.AbsolutePosition
    end
end)
flyControlUI.InputChanged:Connect(function(input)
    if flyUIDragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=input.Position-flyUIDragStart
        flyControlUI.Position=UDim2.new(0,flyUIStartPos.X+delta.X,0,flyUIStartPos.Y+delta.Y)
    end
end)
flyControlUI.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then flyUIDragging=false end
end)

-- 加速独立UI
local speedControlUI=Instance.new("Frame",gui)
speedControlUI.Size=UDim2.new(0,120,0,40)
speedControlUI.Position=UDim2.new(0.02,0,0.75,0)
speedControlUI.BackgroundColor3=Color3.new(0,0,0)
speedControlUI.BackgroundTransparency=0.2
speedControlUI.BorderSizePixel=0
speedControlUI.Visible=false
speedControlUI.ZIndex=200

local speedToggleUI=Instance.new("TextButton",speedControlUI)
speedToggleUI.Size=UDim2.new(1,0,1,0)
speedToggleUI.BackgroundColor3=Color3.new(80/255,130/255,200/255)
speedToggleUI.Text="加速：开"
speedToggleUI.TextColor3=Color3.new(1,1,1)
speedToggleUI.Font=Enum.Font.SourceSansBold
speedToggleUI.TextSize=14
speedToggleUI.AutoLocalize=false
speedToggleUI.MouseButton1Click:Connect(function()
    st.speed=not st.speed
    speedToggleUI.Text=st.speed and "加速：开" or "加速：关"
    speedToggleUI.BackgroundColor3=st.speed and Color3.new(0,200/255,0) or Color3.new(80/255,130/255,200/255)
end)

-- 加速UI拖拽
local speedUIDragging=false
local speedUIDragStart=nil
local speedUIStartPos=nil
speedControlUI.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        speedUIDragging=true
        speedUIDragStart=input.Position
        speedUIStartPos=speedControlUI.AbsolutePosition
    end
end)
speedControlUI.InputChanged:Connect(function(input)
    if speedUIDragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local delta=input.Position-speedUIDragStart
        speedControlUI.Position=UDim2.new(0,speedUIStartPos.X+delta.X,0,speedUIStartPos.Y+delta.Y)
    end
end)
speedControlUI.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then speedUIDragging=false end
end)

-- 生成开关按钮
local function addButton(parent,text,key,x,y)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,100,0,35)
    b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=st[key] and Color3.new(80/255,230/255,80/255) or Color3.new(110/255,110/255,110/255)
    b.Text=text.."："..(st[key] and "开" or "关")
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.SourceSansBold
    b.TextSize=13
    b.AutoLocalize=false
    b.ZIndex=80
    b.MouseButton1Click:Connect(function()
        st[key]=not st[key]
        b.BackgroundColor3=st[key] and Color3.new(80/255,230/255,80/255) or Color3.new(110/255,110/255,110/255)
        b.Text=text.."："..(st[key] and "开" or "关")
        if key=="fly" then flyControlUI.Visible=st.fly end
        if key=="speed" then speedControlUI.Visible=st.speed end
    end)
end

-- 滑条（修复小数）
local function addSlider(parent,text,key,minv,maxv,x,y)
    local frame=Instance.new("Frame",parent)
    frame.Size=UDim2.new(0,100,0,40)
    frame.Position=UDim2.new(0,x,0,y)
    frame.BackgroundTransparency=1
    frame.ZIndex=80

    local lbl=Instance.new("TextLabel",frame)
    lbl.Size=UDim2.new(1,0,0,16)
    lbl.Position=UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=text..": "..st[key]
    lbl.TextColor3=Color3.new(1,1,1)
    lbl.Font=Enum.Font.SourceSansBold
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local bg=Instance.new("Frame",frame)
    bg.Size=UDim2.new(1,0,0,6)
    bg.Position=UDim2.new(0,0,0,22)
    bg.BackgroundColor3=Color3.new(70/255,70/255,70/255)
    bg.BorderSizePixel=0

    local fill=Instance.new("Frame",bg)
    fill.Size=UDim2.new((st[key]-minv)/(maxv-minv),0,1,0)
    fill.Position=UDim2.new(0,0,0,0)
    fill.BackgroundColor3=Color3.new(80/255,160/255,240/255)
    fill.BorderSizePixel=0

    local knob=Instance.new("TextButton",bg)
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=UDim2.new((st[key]-minv)/(maxv-minv),-7,0.5,-7)
    knob.BackgroundColor3=Color3.new(1,1,1)
    knob.Text=""
    knob.BorderSizePixel=0

    local dragging=false
    local function updateFromX(absoluteX)
        local relX=absoluteX-bg.AbsolutePosition.X
        local percent=math.clamp(relX/bg.AbsoluteSize.X,0,1)
        local raw = minv + percent * (maxv - minv)
        if minv == math.floor(minv) and maxv == math.floor(maxv) then
            st[key] = math.floor(raw)
        else
            st[key] = math.floor(raw * 100 + 0.5) / 100
        end
        fill.Size=UDim2.new(percent,0,1,0)
        knob.Position=UDim2.new(percent,-7,0.5,-7)
        lbl.Text=text..": "..st[key]
    end

    bg.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            updateFromX(input.Position.X)
        end
    end)

    knob.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            updateFromX(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
            dragging=false
        end
    end)
end

local function addTargetButton(parent,text,x,y)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,100,0,35)
    b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=Color3.new(110/255,110/255,110/255)
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
        if #targetList==0 then
            selectedTarget=nil
            notif("没有可跟踪的玩家")
            return
        end
        targetIndex=targetIndex%#targetList+1
        selectedTarget=targetList[targetIndex]
        notif("选中: "..selectedTarget.Name)
    end)
end

-- ========== 自瞄页 ==========
addButton(pages[1],"自瞄","aim",10,25)
addButton(pages[1],"锁头","lockh",120,25)
addButton(pages[1],"静默自瞄","silent",230,25)
addButton(pages[1],"墙体检测","wallcheck",10,70)
addButton(pages[1],"队伍过滤","teamcheck",120,70)
addSlider(pages[1],"自瞄范围","aimrange",50,500,230,70)
addButton(pages[1],"自瞄圈","aimCircle",10,115)
addSlider(pages[1],"圈大小","aimCircleSize",50,300,120,115)
addSlider(pages[1],"平滑度","aimSmooth",0.01,1,230,115)

-- ========== 透视页 ==========
addButton(pages[2],"透视","esp",10,25)
addButton(pages[2],"显示名字","espn",120,25)
addButton(pages[2],"显示距离","espd",230,25)
addButton(pages[2],"显示血量","esphp",10,70)
addButton(pages[2],"检测NPC","espnpc",120,70)
addSlider(pages[2],"透视范围","espRange",100,1000,230,70)

-- ========== 武器页 ==========
addButton(pages[3],"无后坐","norecoil",10,25)
addButton(pages[3],"快速换弹","fastrel",120,25)
addButton(pages[3],"无散布","nospread",230,25)
addButton(pages[3],"无限弹药","infammo",10,70)
addButton(pages[3],"射速增强","rapid",120,70)
addButton(pages[3],"自动开火","autofire",230,70)

-- ========== 移动页 ==========
addButton(pages[4],"速度","speed",10,25)
addSlider(pages[4],"移速数值","walkspeed",16,100,120,25)
addButton(pages[4],"高跳","jumpboost",230,25)
addSlider(pages[4],"跳跃力度","jumppower",50,200,10,70)
addButton(pages[4],"自动连跳","autobhop",120,70)
addButton(pages[4],"第三人称","third",230,70)

-- ========== 生存页 ==========
addButton(pages[5],"无敌","god",10,25)
addButton(pages[5],"无限体力","stamina",120,25)
addButton(pages[5],"自动回血","regen",230,25)
addButton(pages[5],"夜视","night",10,70)
addButton(pages[5],"防摔伤","nofall",120,70)
addButton(pages[5],"消脚步声","nofoot",230,70)
addButton(pages[5],"被看提醒","watchedAlert",10,115)

-- ========== 通用页 ==========
addButton(pages[6],"飞行","fly",10,25)
addSlider(pages[6],"飞行速度","flyspeed",10,200,120,25)
addButton(pages[6],"穿墙","noclip",230,25)
addButton(pages[6],"关闭玩家碰撞","noplayercol",10,70)
addButton(pages[6],"撞击弹飞","frontpush",120,70)
addButton(pages[6],"视野缩放","zoom",230,70)

-- ========== 娱乐页 ==========
addButton(pages[7],"游泳加速","swimBoost",10,25)
addButton(pages[7],"水上行走","waterWalk",120,25)
addButton(pages[7],"锁定目标","trackPlayer",10,70)
addTargetButton(pages[7],"切换目标",230,70)

-- ========== 其他页 ==========
addButton(pages[8],"坐标保存","savepos",10,25)
addButton(pages[8],"传送过去","tpto",120,25)
addButton(pages[8],"屏蔽闪光","antiflash",230,25)
addButton(pages[8],"屏蔽烟雾","antismoke",10,70)
addButton(pages[8],"防抖画面","antishake",120,70)

-- ========== 更多页 ==========
addButton(pages[9],"身体旋转","spin",10,25)
local spinMinus=Instance.new("TextButton",pages[9])
spinMinus.Size=UDim2.new(0,100,0,35)
spinMinus.Position=UDim2.new(0,120,0,25)
spinMinus.BackgroundColor3=Color3.new(110/255,110/255,110/255)
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

local spinPlus=Instance.new("TextButton",pages[9])
spinPlus.Size=UDim2.new(0,100,0,35)
spinPlus.Position=UDim2.new(0,230,0,25)
spinPlus.BackgroundColor3=Color3.new(110/255,110/255,110/255)
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

addButton(pages[9],"一键交互","fastInteract",10,70)

-- 开机动画（保留，增加跳过逻辑）
local introCoroutine = nil
local function finishIntro()
    pcall(function()
        hackOverlay.Visible = false
        rainFrame.Visible = false
        blur.Enabled = false
        island.Visible = true
        skipButton.Visible = false
    end)
end

skipButton.MouseButton1Click:Connect(function()
    if introCoroutine then
        task.cancel(introCoroutine)
        introCoroutine = nil
    end
    finishIntro()
end)

introCoroutine = task.spawn(function()
    blur.Enabled=true
    hackOverlay.BackgroundTransparency=0.6
    termText.Text=""

    local function typeText(text,color,speed)
        termText.TextColor3=color
        for i=1,#text do
            termText.Text = string.sub(text,1,i) .. "█"
            task.wait(speed)
        end
        termText.Text = string.sub(text,1,#text)
        task.wait(0.05)
    end

    typeText("> OS: ROBLOX_EXPLOIT v2.1\n",Color3.new(0,1,0),0.04)
    typeText("> Kernel: injected\n",Color3.new(0,1,0),0.04)
    typeText("> Memory: OK\n",Color3.new(0,1,0),0.04)
    typeText("> 目标服务器：ROBLOX_SERVER_01\n",Color3.new(0,1,0),0.04)
    typeText("> IP: 192.168.1.7\n\n",Color3.new(0,1,0),0.04)

    local redLines = {
        "0x7F3A9C20 inject...",
        "bypass check...",
        "loading modules...",
        "hooking functions...",
        "decrypting data...",
        "preparing access...",
        "bypassing firewall...",
        "establishing connection..."
    }
    for _,line in ipairs(redLines) do
        typeText("> "..line.."\n",Color3.new(1,0,0),0.03)
    end

    typeText("> ACCESS DENIED\n",Color3.new(1,0,0),0.04)
    typeText("> RETRY...\n",Color3.new(1,0,0),0.04)
    typeText("> ACCESS GRANTED\n\n",Color3.new(0,1,0),0.05)

    typeText("> 加载完成\n",Color3.new(0,1,0),0.05)
    typeText("> 用户名：" .. player.Name .. "\n",Color3.new(0,1,0),0.04)
    typeText("> 密码：*******\n",Color3.new(0,1,0),0.04)
    typeText("> 权限校验完成\n",Color3.new(0,1,0),0.05)

    typeText("\n\n\n",Color3.new(0,1,0),0.01)
    typeText("> 作者：Dsfhy8\n",Color3.new(0,1,0),0.04)
    typeText("> 脚本版本：v2.1\n",Color3.new(0,1,0),0.04)

    local progressFrame=Instance.new("Frame",terminal)
    progressFrame.Size=UDim2.new(0,200,0,8)
    progressFrame.Position=UDim2.new(0.5,-100,1,-60)
    progressFrame.BackgroundColor3=Color3.new(0,40/255,0)
    progressFrame.BorderSizePixel=0
    progressFrame.ZIndex=304

    local progressFill=Instance.new("Frame",progressFrame)
    progressFill.Size=UDim2.new(0,0,1,0)
    progressFill.Position=UDim2.new(0,0,0,0)
    progressFill.BackgroundColor3=Color3.new(0,1,0)
    progressFill.BorderSizePixel=0
    progressFill.ZIndex=305

    local percentLabel=Instance.new("TextLabel",terminal)
    percentLabel.Size=UDim2.new(0,200,0,18)
    percentLabel.Position=UDim2.new(0.5,-100,1,-78)
    percentLabel.BackgroundTransparency=1
    percentLabel.Text="Loading... 0%"
    percentLabel.TextColor3=Color3.new(0,1,0)
    percentLabel.Font=Enum.Font.SourceSansBold
    percentLabel.TextSize=12
    percentLabel.TextXAlignment=Enum.TextXAlignment.Center
    percentLabel.ZIndex=305

    for i=0,100,2 do
        percentLabel.Text="Loading... "..i.."%"
        progressFill.Size=UDim2.new(i/100,0,1,0)
        task.wait(0.04)
    end
    percentLabel.Text="Loading... 100%"
    progressFill.Size=UDim2.new(1,0,1,0)
    task.wait(0.5)

    local fadeOut=TweenService:Create(hackOverlay,TweenInfo.new(0.7),{BackgroundTransparency=1})
    local termOut=TweenService:Create(terminal,TweenInfo.new(0.7),{BackgroundTransparency=1})
    local textOut=TweenService:Create(termText,TweenInfo.new(0.7),{TextTransparency=1})
    fadeOut:Play()
    termOut:Play()
    textOut:Play()
    blur.Enabled=false
    task.wait(0.7)
    hackOverlay.Visible=false
    rainFrame.Visible=false

    island.Visible=true
    skipButton.Visible=false
end)

-- 灵动岛彩虹闪烁边框（保留）
local hue2=0
task.spawn(function()
    while true do
        hue2=(hue2+0.02)%1
        island.BorderColor3=Color3.fromHSV(hue2,1,1)
        island.TextColor3=Color3.fromHSV(hue2,1,1)
        task.wait(0.1)
    end
end)

-- ========== 自瞄圈（默认关闭） ==========
local aimCircleGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
aimCircleGui.Name = "AimCircleGui"
aimCircleGui.IgnoreGuiInset = true
aimCircleGui.ResetOnSpawn = false
aimCircleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local aimCircleFrame = Instance.new("Frame", aimCircleGui)
aimCircleFrame.Size = UDim2.new(0, st.aimCircleSize*2, 0, st.aimCircleSize*2)
aimCircleFrame.Position = UDim2.new(0.5, -st.aimCircleSize, 0.5, -st.aimCircleSize)
aimCircleFrame.BackgroundTransparency = 1
aimCircleFrame.BorderSizePixel = 0
aimCircleFrame.Visible = st.aimCircle
aimCircleFrame.ZIndex = 9999

local aimCircleCorner = Instance.new("UICorner", aimCircleFrame)
aimCircleCorner.CornerRadius = UDim.new(1, 0)

local aimCircleStroke = Instance.new("UIStroke", aimCircleFrame)
aimCircleStroke.Thickness = 2
aimCircleStroke.Color = Color3.new(1,1,1)
aimCircleStroke.Transparency = 0

local function updateAimCircle()
    if aimCircleFrame then
        aimCircleFrame.Size = UDim2.new(0, st.aimCircleSize*2, 0, st.aimCircleSize*2)
        aimCircleFrame.Position = UDim2.new(0.5, -st.aimCircleSize, 0.5, -st.aimCircleSize)
        aimCircleFrame.Visible = st.aimCircle
    end
end

-- ========== ESP 原生 UI 对象池 ==========
local espGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
espGui.Name = "EspGui"
espGui.IgnoreGuiInset = true
espGui.ResetOnSpawn = false
espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local espObjects = {}
local MAX_ESP = 20

for i = 1, MAX_ESP do
    local obj = {}

    obj.topLine = Instance.new("Frame", espGui)
    obj.topLine.Size = UDim2.new(0, 0, 0, 1)
    obj.topLine.BackgroundColor3 = Color3.new(1,1,1)
    obj.topLine.BorderSizePixel = 0
    obj.topLine.Visible = false
    obj.topLine.ZIndex = 10000

    obj.bottomLine = Instance.new("Frame", espGui)
    obj.bottomLine.Size = UDim2.new(0, 0, 0, 1)
    obj.bottomLine.BackgroundColor3 = Color3.new(1,1,1)
    obj.bottomLine.BorderSizePixel = 0
    obj.bottomLine.Visible = false
    obj.bottomLine.ZIndex = 10000

    obj.leftLine = Instance.new("Frame", espGui)
    obj.leftLine.Size = UDim2.new(0, 1, 0, 0)
    obj.leftLine.BackgroundColor3 = Color3.new(1,1,1)
    obj.leftLine.BorderSizePixel = 0
    obj.leftLine.Visible = false
    obj.leftLine.ZIndex = 10000

    obj.rightLine = Instance.new("Frame", espGui)
    obj.rightLine.Size = UDim2.new(0, 1, 0, 0)
    obj.rightLine.BackgroundColor3 = Color3.new(1,1,1)
    obj.rightLine.BorderSizePixel = 0
    obj.rightLine.Visible = false
    obj.rightLine.ZIndex = 10000

    obj.nameText = Instance.new("TextLabel", espGui)
    obj.nameText.BackgroundTransparency = 1
    obj.nameText.TextColor3 = Color3.new(1,1,1)
    obj.nameText.Font = Enum.Font.SourceSansBold
    obj.nameText.TextSize = 13
    obj.nameText.TextXAlignment = Enum.TextXAlignment.Left
    obj.nameText.TextYAlignment = Enum.TextYAlignment.Top
    obj.nameText.Visible = false
    obj.nameText.ZIndex = 10000
    obj.nameText.RichText = false

    obj.distText = Instance.new("TextLabel", espGui)
    obj.distText.BackgroundTransparency = 1
    obj.distText.TextColor3 = Color3.new(1,1,1)
    obj.distText.Font = Enum.Font.SourceSansBold
    obj.distText.TextSize = 13
    obj.distText.TextXAlignment = Enum.TextXAlignment.Left
    obj.distText.TextYAlignment = Enum.TextYAlignment.Top
    obj.distText.Visible = false
    obj.distText.ZIndex = 10000
    obj.distText.RichText = false

    obj.hpText = Instance.new("TextLabel", espGui)
    obj.hpText.BackgroundTransparency = 1
    obj.hpText.TextColor3 = Color3.new(1,1,1)
    obj.hpText.Font = Enum.Font.SourceSansBold
    obj.hpText.TextSize = 13
    obj.hpText.TextXAlignment = Enum.TextXAlignment.Left
    obj.hpText.TextYAlignment = Enum.TextYAlignment.Top
    obj.hpText.Visible = false
    obj.hpText.ZIndex = 10000
    obj.hpText.RichText = false

    espObjects[i] = obj
end

local function getEnemies()
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health>0 then
            -- 修复队伍检测：仅当双方都有队伍且相同时才过滤
            if not st.teamcheck or (player.Team and p.Team and player.Team == p.Team) == false then
                table.insert(list,p.Character)
            end
        end
    end
    if st.espnpc then
        for _,obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                local hum=obj:FindFirstChild("Humanoid")
                if hum and hum.Health>0 then
                    table.insert(list,obj)
                end
            end
        end
    end
    return list
end

-- 使用更兼容的射线检测
local function losCheck(origin,targetPos,targetChar)
    if not st.wallcheck then return true end
    local ray = Ray.new(origin, (targetPos - origin).Unit * 500)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {player.Character, targetChar})
    return hit == nil
end

-- 被看提醒屏幕下方文字
local watchedLabel = Instance.new("TextLabel", gui)
watchedLabel.Size = UDim2.new(1,0,0,30)
watchedLabel.Position = UDim2.new(0,0,1,-35)
watchedLabel.BackgroundTransparency = 1
watchedLabel.Text = ""
watchedLabel.TextColor3 = Color3.new(1,0,0)
watchedLabel.Font = Enum.Font.SourceSansBold
watchedLabel.TextSize = 16
watchedLabel.TextXAlignment = Enum.TextXAlignment.Center
watchedLabel.TextYAlignment = Enum.TextYAlignment.Center
watchedLabel.ZIndex = 1500
watchedLabel.Visible = false

-- 方向判断函数
local function getDirection(angle)
    local deg = math.deg(angle)
    if deg >= -22.5 and deg < 22.5 then return "前方"
    elseif deg >= 22.5 and deg < 67.5 then return "右前方"
    elseif deg >= 67.5 and deg < 112.5 then return "右侧"
    elseif deg >= 112.5 and deg < 157.5 then return "右后方"
    elseif deg >= 157.5 or deg < -157.5 then return "后方"
    elseif deg >= -157.5 and deg < -112.5 then return "左后方"
    elseif deg >= -112.5 and deg < -67.5 then return "左侧"
    else return "左前方"
    end
end

-- 被看提醒检测函数
local function checkWatched()
    if not st.watchedAlert then
        watchedLabel.Visible = false
        return
    end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        watchedLabel.Visible = false
        return
    end
    local myRoot = player.Character.HumanoidRootPart
    local myPos = myRoot.Position
    local lookers = {}

    -- 检查真人玩家
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
            local targetRoot = p.Character.HumanoidRootPart
            local targetPos = targetRoot.Position
            local dist = (targetPos - myPos).Magnitude
            if dist <= 200 then
                local lookVector = p.Character.HumanoidRootPart.CFrame.LookVector
                local toMe = (myPos - targetPos).Unit
                local angle = math.acos(math.clamp(lookVector:Dot(toMe), -1, 1))
                if angle <= math.rad(25) then
                    table.insert(lookers, {pos = targetPos, angle = angle})
                end
            end
        end
    end

    -- 检查NPC
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
            local targetRoot = obj.HumanoidRootPart
            local targetPos = targetRoot.Position
            local dist = (targetPos - myPos).Magnitude
            if dist <= 200 then
                local lookVector = targetRoot.CFrame.LookVector
                local toMe = (myPos - targetPos).Unit
                local angle = math.acos(math.clamp(lookVector:Dot(toMe), -1, 1))
                if angle <= math.rad(25) then
                    table.insert(lookers, {pos = targetPos, angle = angle})
                end
            end
        end
    end

    if #lookers > 0 then
        -- 选择最近的一个威胁
        table.sort(lookers, function(a,b) return (a.pos - myPos).Magnitude < (b.pos - myPos).Magnitude end)
        local nearest = lookers[1]
        local directionVector = (nearest.pos - myPos).Unit
        local forward = myRoot.CFrame.LookVector
        local relativeAngle = math.atan2(directionVector.Z, directionVector.X) - math.atan2(forward.Z, forward.X)
        watchedLabel.Text = getDirection(relativeAngle) .. "有人看你"
        watchedLabel.Visible = true
    else
        watchedLabel.Visible = false
    end
end

-- 主循环
RS.RenderStepped:Connect(function()
    -- 更新自瞄圈
    pcall(function()
        updateAimCircle()
    end)

    -- 自瞄逻辑
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        if st.aim or st.silent then
            local targets = getEnemies()
            local screenCenter = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            local bestTarget = nil
            local bestDist = math.huge
            for _, tarChar in ipairs(targets) do
                local aimPart
                if st.lockh then
                    aimPart = tarChar:FindFirstChild("Head") or tarChar:FindFirstChild("HumanoidRootPart")
                else
                    aimPart = tarChar:FindFirstChild("HumanoidRootPart")
                end
                if aimPart then
                    local dist = (aimPart.Position - cam.CFrame.Position).Magnitude
                    if dist <= st.aimrange then
                        local canLock = true
                        if st.aimCircle then
                            local screenPos, onScreen = cam:WorldToScreenPoint(aimPart.Position)
                            if onScreen and screenPos then
                                local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                                if screenDist > st.aimCircleSize then
                                    canLock = false
                                end
                            else
                                canLock = false
                            end
                        end
                        if canLock and losCheck(cam.CFrame.Position, aimPart.Position, tarChar) then
                            if dist < bestDist then
                                bestDist = dist
                                bestTarget = aimPart
                            end
                        end
                    end
                end
            end
            if bestTarget then
                local look = CFrame.lookAt(cam.CFrame.Position, bestTarget.Position)
                cam.CFrame = cam.CFrame:Lerp(look, st.aimSmooth)
            end
        end
    end)

    -- 透视逻辑
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        if st.esp then
            local targets = getEnemies()
            for i=1, MAX_ESP do
                local obj=espObjects[i]
                obj.topLine.Visible = false
                obj.bottomLine.Visible = false
                obj.leftLine.Visible = false
                obj.rightLine.Visible = false
                obj.nameText.Visible = false
                obj.distText.Visible = false
                obj.hpText.Visible = false
            end

            local idx = 0
            for _, tarChar in ipairs(targets) do
                local root = tarChar:FindFirstChild("HumanoidRootPart")
                local hum = tarChar:FindFirstChild("Humanoid")
                local head = tarChar:FindFirstChild("Head")
                if root and hum and head then
                    local dist = (root.Position - cam.CFrame.Position).Magnitude
                    if dist <= st.espRange then
                        local topPosition = head.Position + Vector3.new(0,0.6,0)
                        local bottomPosition = root.Position - Vector3.new(0,1.8,0)

                        local topScreen = cam:WorldToViewportPoint(topPosition)
                        local bottomScreen = cam:WorldToViewportPoint(bottomPosition)

                        if topScreen.Z > 0 or bottomScreen.Z > 0 then
                            idx = idx + 1
                            if idx > MAX_ESP then break end
                            local obj = espObjects[idx]

                            local y1 = math.min(topScreen.Y, bottomScreen.Y) - 2
                            local y2 = math.max(topScreen.Y, bottomScreen.Y) + 2
                            local height = y2 - y1
                            local width = math.max(height * 0.6, 10)
                            local centerX = (topScreen.X + bottomScreen.X) / 2
                            local x1 = centerX - width/2
                            local x2 = centerX + width/2

                            obj.topLine.Position = UDim2.new(0, x1, 0, y1)
                            obj.topLine.Size = UDim2.new(0, width, 0, 1)
                            obj.topLine.Visible = true

                            obj.bottomLine.Position = UDim2.new(0, x1, 0, y2)
                            obj.bottomLine.Size = UDim2.new(0, width, 0, 1)
                            obj.bottomLine.Visible = true

                            obj.leftLine.Position = UDim2.new(0, x1, 0, y1)
                            obj.leftLine.Size = UDim2.new(0, 1, 0, height)
                            obj.leftLine.Visible = true

                            obj.rightLine.Position = UDim2.new(0, x2, 0, y1)
                            obj.rightLine.Size = UDim2.new(0, 1, 0, height)
                            obj.rightLine.Visible = true

                            local name=""
                            local plr=Players:GetPlayerFromCharacter(tarChar)
                            if plr then name=plr.Name else name=tarChar.Name end

                            if st.espn then
                                obj.nameText.Text = name
                                obj.nameText.Position = UDim2.new(0, x1, 0, y1-15)
                                obj.nameText.Visible = true
                            end

                            if st.espd then
                                obj.distText.Text = string.format("%.0f m", dist)
                                obj.distText.Position = UDim2.new(0, x1, 0, y2+5)
                                obj.distText.Visible = true
                            end

                            if st.esphp then
                                obj.hpText.Text = "HP: "..math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                                obj.hpText.Position = UDim2.new(0, x1, 0, y2+20)
                                obj.hpText.Visible = true
                            end
                        end
                    end
                end
            end
        else
            for i=1, MAX_ESP do
                local obj=espObjects[i]
                obj.topLine.Visible = false
                obj.bottomLine.Visible = false
                obj.leftLine.Visible = false
                obj.rightLine.Visible = false
                obj.nameText.Visible = false
                obj.distText.Visible = false
                obj.hpText.Visible = false
            end
        end
    end)

    -- 被看提醒
    pcall(function()
        checkWatched()
    end)

    -- 其他功能逻辑
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local myRoot=player.Character.HumanoidRootPart
        local hum=player.Character:FindFirstChild("Humanoid")
        if not hum then return end

        if st.fly then
            if not bodyGyro then
                bodyGyro=Instance.new("BodyGyro",myRoot)
                bodyGyro.P=90000
                bodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
                bodyVel=Instance.new("BodyVelocity",myRoot)
                bodyVel.MaxForce=Vector3.new(9e9,9e9,9e9)
                hum.PlatformStand=true
            end
            local moveDir=hum.MoveDirection
            local camForward=cam.CFrame.LookVector
            local camRight=cam.CFrame.RightVector
            local forwardInput=moveDir.X*camForward.X+moveDir.Z*camForward.Z
            local rightInput=moveDir.X*camRight.X+moveDir.Z*camRight.Z
            local flyDir=Vector3.new(0,0,0)
            if math.abs(forwardInput)>0.1 then flyDir+=camForward*math.sign(forwardInput) end
            if math.abs(rightInput)>0.1 then flyDir+=camRight*math.sign(rightInput) end
            if flyDir.Magnitude>0 then flyDir=flyDir.Unit end
            bodyVel.Velocity=flyDir*st.flyspeed
            bodyGyro.CFrame=CFrame.new(myRoot.Position,myRoot.Position+camForward)
            if st.flyNoclip then
                for _,part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide=false end
                end
            end
        else
            if bodyGyro then bodyGyro:Destroy();bodyGyro=nil end
            if bodyVel then bodyVel:Destroy();bodyVel=nil end
            hum.PlatformStand=false
        end

        if st.trackPlayer and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local tarRoot=selectedTarget.Character.HumanoidRootPart
            local offset=tarRoot.CFrame.LookVector*(-3)+Vector3.new(0,2,0)
            myRoot.CFrame=CFrame.new(tarRoot.Position+offset)
            hum.PlatformStand=true
        end

        if st.frontpush then
            local targets=getEnemies()
            for _,tChar in ipairs(targets) do
                local tRoot=tChar:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist=(tRoot.Position-myRoot.Position).Magnitude
                    if dist<8 then
                        local dir=(tRoot.Position-myRoot.Position).Unit
                        tRoot.Velocity=dir*1000
                        tRoot.AssemblyLinearVelocity=dir*1000
                    end
                end
            end
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

        if st.speed then hum.WalkSpeed=st.walkspeed else hum.WalkSpeed=16 end
        if st.jumpboost then hum.JumpPower=st.jumppower else hum.JumpPower=50 end
        if st.autobhop and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        if st.third and cam.CameraSubject~=hum then cam.CameraSubject=hum end
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
        if st.god then hum.Health=hum.MaxHealth end
        if st.regen then hum.Health=math.min(hum.MaxHealth,hum.Health+0.5) end

        if st.zoom then cam.FieldOfView=30 else cam.FieldOfView=70 end
    end)
end)

-- F1保存坐标 F2传送
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            savedPos = player.Character.HumanoidRootPart.CFrame
            notif("已保存坐标")
        end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        if savedPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = savedPos
            notif("传送至保存点")
        end
    end
end)
