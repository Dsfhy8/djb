local player=game.Players.LocalPlayer
local cam=workspace.CurrentCamera
local Players=game.Players
local RS=game:GetService("RunService")
local WS=workspace
local UIS=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local TweenService=game:GetService("TweenService")
local Lighting=game:GetService("Lighting")

-- 状态
local st={
aim=false,lockh=false,silent=false,wallcheck=false,teamcheck=true,aimrange=200,
esp=false,espn=false,espd=false,esphp=false,espnpc=false,
norecoil=false,fastrel=false,nospread=false,infammo=false,rapid=false,autofire=false,
speed=false,walkspeed=16,jumpboost=false,jumppower=50,autobhop=false,third=false,
god=false,stamina=false,regen=false,night=false,nofall=false,nofoot=false,
fly=false,flyspeed=50,noclip=false,noplayercol=false,frontpush=false,zoom=false,
savepos=false,tpto=false,
swimBoost=false,waterWalk=false,invisible=false,fakeDeath=false,
trackPlayer=false,
spin=false,spinSpeed=50,
fastInteract=false
}

local aimSmooth = 0.12
local savedPos=nil
local bodyGyro,bodyVel,bodyFloat,bodySpin
local selectedTarget=nil
local targetList={}
local targetIndex=0
local scaleFactor=1
local originalSizes={}

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

-- 全屏遮罩（超大覆盖）
local hackOverlay=Instance.new("Frame",gui)
hackOverlay.Size=UDim2.new(3,0,3,0)
hackOverlay.Position=UDim2.new(-1,0,-1,0)
hackOverlay.BackgroundColor3=Color3.fromRGB(0,0,0)
hackOverlay.BackgroundTransparency=0.6
hackOverlay.BorderSizePixel=0
hackOverlay.ZIndex=300
hackOverlay.Visible=true

-- 数字雨（全屏铺满）
local rainFrame=Instance.new("Frame",hackOverlay)
rainFrame.Size=UDim2.new(1,0,1,0)
rainFrame.Position=UDim2.new(0,0,0,0)
rainFrame.BackgroundTransparency=1
rainFrame.ZIndex=298
rainFrame.ClipsDescendants=true

local rainLabels={}
local rainCount=25
for i=1,rainCount do
    local label=Instance.new("TextLabel",rainFrame)
    label.Size=UDim2.new(0,18,0,120)
    -- 均匀分布在整个屏幕宽度
    local xPercent=(i-1)/(rainCount-1)
    label.Position=UDim2.new(xPercent,0,0,math.random(-300,0))
    label.BackgroundTransparency=1
    label.TextColor3=Color3.fromRGB(0,255,0)
    label.Font=Enum.Font.SourceSansBold
    label.TextSize=14
    label.Text=""
    table.insert(rainLabels,label)
end

-- 数字雨更新
task.spawn(function()
    while true do
        for _,label in ipairs(rainLabels) do
            local y=label.Position.Y.Offset
            y=y+8
            if y>500 then y=-150; label.Position=UDim2.new(label.Position.X.Scale,label.Position.X.Offset,0,math.random(-200,0)) end
            label.Position=UDim2.new(label.Position.X.Scale,label.Position.X.Offset,0,y)
            local str=""
            for _=1,10 do str=str..string.char(math.random(48,57)).."\n" end
            label.Text=str
        end
        wait(0.1)
    end
end)

-- 终端框
local terminal=Instance.new("Frame",hackOverlay)
terminal.Size=UDim2.new(0,380,0,320)
terminal.Position=UDim2.new(0.5,-190,0.5,-160)
terminal.BackgroundColor3=Color3.fromRGB(10,12,14)
terminal.BackgroundTransparency=0
terminal.BorderSizePixel=2
terminal.BorderColor3=Color3.fromRGB(0,255,0)
terminal.ZIndex=301

-- 终端标题栏
local termTitle=Instance.new("TextLabel",terminal)
termTitle.Size=UDim2.new(1,0,0,22)
termTitle.Position=UDim2.new(0,0,0,0)
termTitle.BackgroundColor3=Color3.fromRGB(0,30,0)
termTitle.Text="ROBLOX_EXPLOIT_CONSOLE"
termTitle.TextColor3=Color3.fromRGB(0,255,0)
termTitle.Font=Enum.Font.SourceSansBold
termTitle.TextSize=12
termTitle.TextXAlignment=Enum.TextXAlignment.Center
termTitle.ZIndex=302

-- 终端文字区域
local termText=Instance.new("TextLabel",terminal)
termText.Size=UDim2.new(1,-20,0,220)
termText.Position=UDim2.new(0,10,0,30)
termText.BackgroundTransparency=1
termText.Text=""
termText.TextColor3=Color3.fromRGB(255,0,0)
termText.Font=Enum.Font.SourceSansBold
termText.TextSize=14
termText.TextXAlignment=Enum.TextXAlignment.Left
termText.TextYAlignment=Enum.TextYAlignment.Top
termText.RichText=true

-- 悬浮球
local ball=Instance.new("TextButton",gui)
ball.Size=UDim2.new(0,60,0,60)
ball.Position=UDim2.new(1,-70,0.5,-30)
ball.BackgroundColor3=Color3.fromRGB(0,180,255)
ball.Text="机械"
ball.TextColor3=Color3.new(1,1,1)
ball.Font=Enum.Font.SourceSansBold
ball.TextSize=16
ball.AutoButtonColor=false
ball.ZIndex=150
ball.Visible=false

-- 主面板
local panel=Instance.new("Frame",gui)
panel.Size=UDim2.new(0,340,0,260)
panel.Position=UDim2.new(0.5,-170,0.5,-130)
panel.BackgroundColor3=Color3.fromRGB(22,22,22)
panel.BackgroundTransparency=0
panel.BorderSizePixel=3
panel.BorderColor3=Color3.fromRGB(255,0,0)
panel.Visible=false
panel.ZIndex=50

-- 标题栏
local titleBar=Instance.new("Frame",panel)
titleBar.Size=UDim2.new(1,0,0,30)
titleBar.BackgroundColor3=Color3.fromRGB(35,35,35)
titleBar.BorderSizePixel=0
local titleText=Instance.new("TextLabel",titleBar)
titleText.Size=UDim2.new(1,-30,1,0)
titleText.Position=UDim2.new(0,10,0,0)
titleText.BackgroundTransparency=1
titleText.Text="机械脚本"
titleText.TextColor3=Color3.fromRGB(255,255,255)
titleText.Font=Enum.Font.SourceSansBold
titleText.TextSize=17
titleText.TextXAlignment=Enum.TextXAlignment.Left

local closeBtn=Instance.new("TextButton",titleBar)
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.Position=UDim2.new(1,-28,0,3)
closeBtn.BackgroundColor3=Color3.fromRGB(220,50,50)
closeBtn.Text="X"
closeBtn.TextColor3=Color3.new(1,1,1)
closeBtn.Font=Enum.Font.SourceSansBold
closeBtn.TextSize=12
closeBtn.AutoButtonColor=false
closeBtn.MouseButton1Click:Connect(function() panel.Visible=false end)

-- 页面容器（9页）
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
    h.TextColor3=Color3.fromRGB(255,225,90)
    h.Font=Enum.Font.SourceSansBold
    h.TextSize=14
    h.TextXAlignment=Enum.TextXAlignment.Left
    pages[i]=p
end

local curPage=1
local prevBtn=Instance.new("TextButton",panel)
prevBtn.Size=UDim2.new(0,60,0,24)
prevBtn.Position=UDim2.new(0,10,1,-30)
prevBtn.BackgroundColor3=Color3.fromRGB(100,100,100)
prevBtn.Text="上一页"
prevBtn.TextColor3=Color3.new(1,1,1)
prevBtn.Font=Enum.Font.SourceSansBold
prevBtn.TextSize=11
prevBtn.AutoButtonColor=false
prevBtn.ZIndex=70
prevBtn.Visible=false

local nextBtn=Instance.new("TextButton",panel)
nextBtn.Size=UDim2.new(0,60,0,24)
nextBtn.Position=UDim2.new(0,270,1,-30)
nextBtn.BackgroundColor3=Color3.fromRGB(100,100,100)
nextBtn.Text="下一页"
nextBtn.TextColor3=Color3.new(1,1,1)
nextBtn.Font=Enum.Font.SourceSansBold
nextBtn.TextSize=11
nextBtn.AutoButtonColor=false
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

-- 创建按钮
local function addButton(parent,text,key,x,y)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,100,0,35)
    b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=st[key] and Color3.fromRGB(80,230,80) or Color3.fromRGB(110,110,110)
    b.Text=text.."："..(st[key] and "开" or "关")
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.SourceSansBold
    b.TextSize=13
    b.AutoButtonColor=false
    b.ZIndex=80
    b.MouseButton1Click:Connect(function()
        st[key]=not st[key]
        b.BackgroundColor3=st[key] and Color3.fromRGB(80,230,80) or Color3.fromRGB(110,110,110)
        b.Text=text.."："..(st[key] and "开" or "关")
    end)
end

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
    bg.BackgroundColor3=Color3.fromRGB(70,70,70)
    bg.BorderSizePixel=0
    local fill=Instance.new("Frame",bg)
    fill.Size=UDim2.new((st[key]-minv)/(maxv-minv),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(80,160,240)
    fill.BorderSizePixel=0
    local knob=Instance.new("TextButton",bg)
    knob.Size=UDim2.new(0,14,0,14)
    knob.Position=UDim2.new((st[key]-minv)/(maxv-minv),-7,0.5,-7)
    knob.BackgroundColor3=Color3.new(1,1,1)
    knob.Text=""
    knob.BorderSizePixel=0
    local dragging=false
    local function update(input)
        local relX=input.Position.X-bg.AbsolutePosition.X
        local percent=math.clamp(relX/bg.AbsoluteSize.X,0,1)
        st[key]=math.floor(minv+percent*(maxv-minv))
        fill.Size=UDim2.new(percent,0,1,0)
        knob.Position=UDim2.new(percent,-7,0.5,-7)
        lbl.Text=text..": "..st[key]
    end
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    knob.InputEnded:Connect(function() dragging=false end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then update(i) end end)
    bg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then update(i); dragging=true end end)
    bg.InputEnded:Connect(function() dragging=false end)
end

-- 切换目标按钮
local function addTargetButton(parent,text,x,y)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(0,100,0,35)
    b.Position=UDim2.new(0,x,0,y)
    b.BackgroundColor3=Color3.fromRGB(110,110,110)
    b.Text=text
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.SourceSansBold
    b.TextSize=13
    b.AutoButtonColor=false
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

-- 第1页 自瞄
addButton(pages[1],"自瞄","aim",10,25); addButton(pages[1],"锁头","lockh",120,25); addButton(pages[1],"静默自瞄","silent",230,25)
addButton(pages[1],"墙壁检测","wallcheck",10,70); addButton(pages[1],"队伍检测","teamcheck",120,70); addSlider(pages[1],"自瞄范围","aimrange",50,500,230,70)

-- 第2页 透视
addButton(pages[2],"透视","esp",10,25); addButton(pages[2],"显示名字","espn",120,25); addButton(pages[2],"显示距离","espd",230,25)
addButton(pages[2],"显示血量","esphp",10,70); addButton(pages[2],"检测人机","espnpc",120,70)

-- 第3页 武器
addButton(pages[3],"无后坐力","norecoil",10,25); addButton(pages[3],"快速换弹","fastrel",120,25); addButton(pages[3],"无扩散","nospread",230,25)
addButton(pages[3],"无限子弹","infammo",10,70); addButton(pages[3],"快速射速","rapid",120,70); addButton(pages[3],"自动射击","autofire",230,70)

-- 第4页 移动
addButton(pages[4],"移动加速","speed",10,25); addSlider(pages[4],"走路速度","walkspeed",16,100,120,25); addButton(pages[4],"跳跃增强","jumpboost",230,25)
addSlider(pages[4],"跳跃高度","jumppower",50,200,10,70); addButton(pages[4],"自动连跳","autobhop",120,70); addButton(pages[4],"第三人称","third",230,70)

-- 第5页 生存
addButton(pages[5],"无敌","god",10,25); addButton(pages[5],"无限体力","stamina",120,25); addButton(pages[5],"快速回血","regen",230,25)
addButton(pages[5],"夜视","night",10,70); addButton(pages[5],"防摔落","nofall",120,70); addButton(pages[5],"消除脚步声","nofoot",230,70)

-- 第6页 通用
addButton(pages[6],"飞行","fly",10,25); addSlider(pages[6],"飞行速度","flyspeed",10,200,120,25); addButton(pages[6],"穿墙","noclip",230,25)
addButton(pages[6],"关闭玩家碰撞","noplayercol",10,70); addButton(pages[6],"正面碰撞弹飞","frontpush",120,70); addButton(pages[6],"倍镜缩放","zoom",230,70)

-- 第7页 娱乐
addButton(pages[7],"游泳加速","swimBoost",10,25); addButton(pages[7],"水上行走","waterWalk",120,25); addButton(pages[7],"隐身","invisible",230,25)
addButton(pages[7],"假死","fakeDeath",10,70); addButton(pages[7],"跟踪玩家","trackPlayer",120,70); addTargetButton(pages[7],"切换目标",230,70)

-- 第8页 其他
addButton(pages[8],"保存位置","savepos",10,25); addButton(pages[8],"传送到保存点","tpto",120,25)
addButton(pages[8],"防闪光","antiflash",230,25); addButton(pages[8],"防烟雾","antismoke",10,70); addButton(pages[8],"防震屏","antishake",120,70)

-- 第9页 更多合集
addButton(pages[9],"旋转","spin",10,25)

local spinMinus=Instance.new("TextButton",pages[9])
spinMinus.Size=UDim2.new(0,100,0,35)
spinMinus.Position=UDim2.new(0,120,0,25)
spinMinus.BackgroundColor3=Color3.fromRGB(110,110,110)
spinMinus.Text="速度-"..st.spinSpeed
spinMinus.TextColor3=Color3.new(1,1,1)
spinMinus.Font=Enum.Font.SourceSansBold
spinMinus.TextSize=13
spinMinus.AutoButtonColor=false
spinMinus.ZIndex=80
spinMinus.MouseButton1Click:Connect(function()
    st.spinSpeed=math.max(1,st.spinSpeed-10)
    spinMinus.Text="速度-"..st.spinSpeed
end)

local spinPlus=Instance.new("TextButton",pages[9])
spinPlus.Size=UDim2.new(0,100,0,35)
spinPlus.Position=UDim2.new(0,230,0,25)
spinPlus.BackgroundColor3=Color3.fromRGB(110,110,110)
spinPlus.Text="速度+"..st.spinSpeed
spinPlus.TextColor3=Color3.new(1,1,1)
spinPlus.Font=Enum.Font.SourceSansBold
spinPlus.TextSize=13
spinPlus.AutoButtonColor=false
spinPlus.ZIndex=80
spinPlus.MouseButton1Click:Connect(function()
    st.spinSpeed=math.min(200,st.spinSpeed+10)
    spinPlus.Text="速度+"..st.spinSpeed
end)

addButton(pages[9],"快速互动","fastInteract",10,70)

local enlargeBtn=Instance.new("TextButton",pages[9])
enlargeBtn.Size=UDim2.new(0,100,0,35)
enlargeBtn.Position=UDim2.new(0,120,0,70)
enlargeBtn.BackgroundColor3=Color3.fromRGB(110,110,110)
enlargeBtn.Text="变大"
enlargeBtn.TextColor3=Color3.new(1,1,1)
enlargeBtn.Font=Enum.Font.SourceSansBold
enlargeBtn.TextSize=13
enlargeBtn.AutoButtonColor=false
enlargeBtn.ZIndex=80
enlargeBtn.MouseButton1Click:Connect(function()
    scaleFactor=math.min(3, scaleFactor+0.1)
    if player.Character then
        for _,obj in ipairs(player.Character:GetDescendants()) do
            if obj:IsA("BasePart") then
                if not originalSizes[obj] then originalSizes[obj]=obj.Size end
                obj.Size=originalSizes[obj]*scaleFactor
            end
        end
    end
end)

local shrinkBtn=Instance.new("TextButton",pages[9])
shrinkBtn.Size=UDim2.new(0,100,0,35)
shrinkBtn.Position=UDim2.new(0,230,0,70)
shrinkBtn.BackgroundColor3=Color3.fromRGB(110,110,110)
shrinkBtn.Text="变小"
shrinkBtn.TextColor3=Color3.new(1,1,1)
shrinkBtn.Font=Enum.Font.SourceSansBold
shrinkBtn.TextSize=13
shrinkBtn.AutoButtonColor=false
shrinkBtn.ZIndex=80
shrinkBtn.MouseButton1Click:Connect(function()
    scaleFactor=math.max(0.3, scaleFactor-0.1)
    if player.Character then
        for _,obj in ipairs(player.Character:GetDescendants()) do
            if obj:IsA("BasePart") then
                if not originalSizes[obj] then originalSizes[obj]=obj.Size end
                obj.Size=originalSizes[obj]*scaleFactor
            end
        end
    end
end)

-- 悬浮球点击：保持当前页码
ball.MouseButton1Click:Connect(function()
    panel.Visible=not panel.Visible
    if panel.Visible then showPage(curPage) end
end)

-- 黑客终端启动动画
task.spawn(function()
    blur.Enabled=true
    hackOverlay.BackgroundTransparency=0.6
    termText.Text=""

    local function typeText(text, color, speed)
        termText.TextColor3=color
        for i=1,#text do
            termText.Text = string.sub(text,1,i) .. "█"
            wait(speed)
        end
        termText.Text = string.sub(text,1,#text)
        wait(0.05)
    end

    -- 系统信息
    typeText("> OS: ROBLOX_EXPLOIT v2.1\n", Color3.fromRGB(0,255,0), 0.04)
    typeText("> Kernel: injected\n", Color3.fromRGB(0,255,0), 0.04)
    typeText("> Memory: OK\n", Color3.fromRGB(0,255,0), 0.04)
    typeText("> 目标服务器：ROBLOX_SERVER_01\n", Color3.fromRGB(0,255,0), 0.04)
    typeText("> IP: 192.168.1.7\n\n", Color3.fromRGB(0,255,0), 0.04)

    -- 红色乱码8行
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
    for _, line in ipairs(redLines) do
        typeText("> "..line.."\n", Color3.fromRGB(255,0,0), 0.03)
    end

    -- 红屏警告
    typeText("> ACCESS DENIED\n", Color3.fromRGB(255,0,0), 0.04)
    typeText("> RETRY...\n", Color3.fromRGB(255,0,0), 0.04)
    typeText("> ACCESS GRANTED\n\n", Color3.fromRGB(0,255,0), 0.05)

    -- 输入完成
    typeText("> 输入完成\n", Color3.fromRGB(0,255,0), 0.05)

    -- 用户名和密码
    typeText("> 用户名：" .. player.Name .. "\n", Color3.fromRGB(0,255,0), 0.04)
    typeText("> 密码：*******\n", Color3.fromRGB(0,255,0), 0.04)

    -- 核验完成
    typeText("> 身份信息核验完成，允许访问\n", Color3.fromRGB(0,255,0), 0.05)

    -- 空三行
    typeText("\n\n\n", Color3.fromRGB(0,255,0), 0.01)

    -- 作者和云更新
    typeText("> 作者：Dsfhy8\n", Color3.fromRGB(0,255,0), 0.04)
    typeText("> 持续云更新（但是很慢）\n", Color3.fromRGB(0,255,0), 0.04)

    -- 横向进度条
    local progressFrame=Instance.new("Frame",terminal)
    progressFrame.Size=UDim2.new(0,200,0,8)
    progressFrame.Position=UDim2.new(0.5,-100,1,-60)
    progressFrame.BackgroundColor3=Color3.fromRGB(0,40,0)
    progressFrame.BorderSizePixel=0
    progressFrame.ZIndex=304

    local progressFill=Instance.new("Frame",progressFrame)
    progressFill.Size=UDim2.new(0,0,1,0)
    progressFill.Position=UDim2.new(0,0,0,0)
    progressFill.BackgroundColor3=Color3.fromRGB(0,255,0)
    progressFill.BorderSizePixel=0
    progressFill.ZIndex=305

    -- 百分比文字
    local percentLabel=Instance.new("TextLabel",terminal)
    percentLabel.Size=UDim2.new(0,200,0,18)
    percentLabel.Position=UDim2.new(0.5,-100,1,-78)
    percentLabel.BackgroundTransparency=1
    percentLabel.Text="Loading... 0%"
    percentLabel.TextColor3=Color3.fromRGB(0,255,0)
    percentLabel.Font=Enum.Font.SourceSansBold
    percentLabel.TextSize=12
    percentLabel.TextXAlignment=Enum.TextXAlignment.Center
    percentLabel.ZIndex=305

    for i=0,100,2 do
        percentLabel.Text="Loading... "..i.."%"
        progressFill.Size=UDim2.new(i/100,0,1,0)
        wait(0.04)
    end
    percentLabel.Text="Loading... 100%"
    progressFill.Size=UDim2.new(1,0,1,0)
    wait(0.5)

    -- 淡出
    local fadeOut=TweenService:Create(hackOverlay,TweenInfo.new(0.7),{BackgroundTransparency=1})
    local termOut=TweenService:Create(terminal,TweenInfo.new(0.7),{BackgroundTransparency=1})
    local textOut=TweenService:Create(termText,TweenInfo.new(0.7),{TextTransparency=1})
    fadeOut:Play()
    termOut:Play()
    textOut:Play()
    blur.Enabled=false
    wait(0.7)
    hackOverlay.Visible=false
    rainFrame.Visible=false

    -- 悬浮球淡入
    ball.Visible=true
    ball.BackgroundTransparency=1
    local ballIn=TweenService:Create(ball,TweenInfo.new(0.5),{BackgroundTransparency=0})
    ballIn:Play()
end)

-- 彩虹边框
local hue=0
task.spawn(function()
    while true do
        hue=(hue+0.01)%1
        local rc=Color3.fromHSV(hue,1,1)
        panel.BorderColor3=rc
        titleText.TextColor3=rc
        wait(0.05)
    end
end)

-- 功能逻辑
local function getEnemies()
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health>0 then
            if not st.teamcheck or (not player.Team or not p.Team or player.Team~=p.Team) then table.insert(list,p.Character) end
        end
    end
    if st.espnpc then
        for _,obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                local hum=obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    if not st.teamcheck or (not player.Team or not obj:FindFirstChild("Team") or obj.Team~=player.Team) then table.insert(list,obj) end
                end
            end
        end
    end
    return list
end

local function los(origin,targetPos,targetChar)
    if not st.wallcheck then return true end
    local ray=Ray.new(origin,(targetPos-origin).Unit*500)
    local hit=WS:FindPartOnRayWithIgnoreList(ray,{player.Character,targetChar})
    return not hit
end

RS.RenderStepped:Connect(function()
    pcall(function()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        local myRoot=player.Character.HumanoidRootPart
        local hum=player.Character:FindFirstChildOfClass("Humanoid")

        -- 自瞄（平滑）
        if st.aim or st.silent then
            local targets=getEnemies()
            table.sort(targets,function(a,b) return (a.HumanoidRootPart.Position-myRoot.Position).Magnitude<(b.HumanoidRootPart.Position-myRoot.Position).Magnitude end)
            for _,tChar in ipairs(targets) do
                local aimPart=st.lockh and tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart")
                if aimPart and los(cam.CFrame.Position,aimPart.Position,tChar) then
                    local lookAt=CFrame.lookAt(cam.CFrame.Position,aimPart.Position)
                    cam.CFrame=cam.CFrame:Lerp(lookAt, aimSmooth)
                    break
                end
            end
        end

        -- 飞行
        if st.fly then
            if not bodyGyro then
                bodyGyro=Instance.new("BodyGyro",myRoot); bodyGyro.P=9e4; bodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9); bodyGyro.CFrame=myRoot.CFrame
                bodyVel=Instance.new("BodyVelocity",myRoot); bodyVel.MaxForce=Vector3.new(9e9,9e9,9e9); bodyVel.Velocity=Vector3.zero
                hum.PlatformStand=true
            end
            local moveDir=hum.MoveDirection
            local camForward=cam.CFrame.LookVector
            local camRight=cam.CFrame.RightVector
            local forwardInput=moveDir.X*camForward.X+moveDir.Z*camForward.Z
            local rightInput=moveDir.X*camRight.X+moveDir.Z*camRight.Z
            local flyDir=Vector3.zero
            if math.abs(forwardInput)>0.1 then flyDir+=camForward*math.sign(forwardInput) end
            if math.abs(rightInput)>0.1 then flyDir+=camRight*math.sign(rightInput) end
            if flyDir.Magnitude>0 then flyDir=flyDir.Unit end
            bodyVel.Velocity=flyDir*st.flyspeed
            bodyGyro.CFrame=CFrame.lookAt(myRoot.Position,myRoot.Position+cam.CFrame.LookVector)
        else
            if bodyGyro then bodyGyro:Destroy(); bodyGyro=nil end
            if bodyVel then bodyVel:Destroy(); bodyVel=nil end
            if not st.trackPlayer then hum.PlatformStand=false end
        end

        -- 跟踪玩家
        if st.trackPlayer and selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot=selectedTarget.Character.HumanoidRootPart
            local offset=targetRoot.CFrame.LookVector*(-3)+Vector3.new(0,2,0)
            myRoot.CFrame=CFrame.new(targetRoot.Position+offset)
            hum.PlatformStand=true
        end

        -- 正面碰撞弹飞
        if st.frontpush then
            local targets=getEnemies()
            for _,tChar in ipairs(targets) do
                local tRoot=tChar:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist=(tRoot.Position-myRoot.Position).Magnitude
                    if dist<5 then
                        local toTarget=(tRoot.Position-myRoot.Position).Unit
                        local dot=myRoot.CFrame.LookVector:Dot(toTarget)
                        if dot>0.3 then tRoot.Velocity=toTarget*200 end
                    end
                end
            end
        end

        -- 关闭玩家碰撞
        if st.noplayercol then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=player and p.Character then
                    for _,part in ipairs(p.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end
                end
            end
        end

        -- 移动
        if st.speed then hum.WalkSpeed=st.walkspeed else hum.WalkSpeed=16 end
        if st.jumpboost then hum.JumpPower=st.jumppower else hum.JumpPower=50 end
        if st.autobhop and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        if st.third and player.CameraMode~=Enum.CameraMode.Classic then player.CameraMode=Enum.CameraMode.Classic end
        if st.noclip then for _,part in ipairs(player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end

        -- 游泳加速
        if st.swimBoost and hum.FloorMaterial==Enum.Material.Water then hum.WalkSpeed=60 end

        -- 水上行走
        if st.waterWalk then
            local ray=Ray.new(myRoot.Position,Vector3.new(0,-3,0))
            local hit=WS:FindPartOnRay(ray)
            if hit and hit.Material==Enum.Material.Water then
                if not bodyFloat then
                    bodyFloat=Instance.new("BodyVelocity")
                    bodyFloat.MaxForce=Vector3.new(0,9e9,0)
                    bodyFloat.Velocity=Vector3.new(0,20,0)
                    bodyFloat.Parent=myRoot
                else
                    bodyFloat.Velocity=Vector3.new(0,20,0)
                end
            else
                if bodyFloat then bodyFloat.Velocity=Vector3.zero end
            end
        else
            if bodyFloat then bodyFloat:Destroy(); bodyFloat=nil end
        end

        -- 假死
        if st.fakeDeath then hum.Sit=true else hum.Sit=false end

        -- 旋转（自身旋转，不影响视角）
        if st.spin then
            if not bodySpin then
                bodySpin=Instance.new("BodyAngularVelocity")
                bodySpin.MaxTorque=Vector3.new(0,9e9,0)
                bodySpin.AngularVelocity=Vector3.new(0,st.spinSpeed*0.5,0)
                bodySpin.Parent=myRoot
            else
                bodySpin.AngularVelocity=Vector3.new(0,st.spinSpeed*0.5,0)
            end
        else
            if bodySpin then bodySpin:Destroy(); bodySpin=nil end
        end

        -- 快速互动
        if st.fastInteract then
            for _,obj in ipairs(WS:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then obj.HoldDuration=0 end
            end
        end

        -- 生存
        if st.god then hum.Health=hum.MaxHealth end
        if st.stamina then hum:SetStateEnabled(Enum.HumanoidStateType.Running,true); hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true) end
        if st.regen then hum.Health=math.min(hum.MaxHealth,hum.Health+0.5) end
        if st.night then Lighting.Brightness=3 else Lighting.Brightness=1 end
        if st.nofall then hum.FallSpeed=0 end

        -- 武器
        if st.norecoil or st.nospread or st.fastrel or st.infammo or st.rapid then
            for _,tool in ipairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    for _,child in ipairs(tool:GetDescendants()) do
                        if child:IsA("NumberValue") then
                            local n=child.Name:lower()
                            if st.norecoil and (n:find("recoil") or n:find("kick")) then child.Value=0 end
                            if st.nospread and n:find("spread") then child.Value=0 end
                            if st.fastrel and n:find("reload") then child.Value=0.1 end
                            if st.infammo and (n:find("ammo") or n:find("clip")) then child.Value=9999 end
                            if st.rapid and n:find("fire") then child.Value=0.01 end
                        end
                    end
                end
            end
        end

        -- 自动射击
        if st.autofire then
            local targets=getEnemies()
            if #targets>0 then
                local tChar=targets[1]
                local aimPart=tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart")
                if aimPart and los(cam.CFrame.Position,aimPart.Position,tChar) then
                    cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,aimPart.Position), 0.3)
                    if player:GetMouse() then player:GetMouse().Button1Down:Fire(); player:GetMouse().Button1Up:Fire() end
                end
            end
        end

        -- 保存传送
        if st.savepos then savedPos=myRoot.Position; st.savepos=false end
        if st.tpto and savedPos then myRoot.CFrame=CFrame.new(savedPos); st.tpto=false end
        if st.zoom then cam.FieldOfView=30 else cam.FieldOfView=70 end
    end)
end)

-- 角色重生时自动恢复
player.CharacterAdded:Connect(function(char)
    bodyGyro=nil
    bodyVel=nil
    bodyFloat=nil
    bodySpin=nil
    originalSizes={}
    scaleFactor=1
    selectedTarget=nil
    targetList={}
    targetIndex=0
    local hum=char:WaitForChild("Humanoid")
    hum.WalkSpeed=st.speed and st.walkspeed or 16
    hum.JumpPower=st.jumpboost and st.jumppower or 50
end)

-- 透视循环
while true do
    pcall(function()
        if st.esp then
            for _,p in ipairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESPTag") then p.Character.ESPTag:Destroy() end end
            for _,obj in ipairs(WS:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("ESPTag") then obj.ESPTag:Destroy() end end
            local myRoot=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _,tChar in ipairs(getEnemies()) do
                    local tRoot=tChar:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        local dist=(tRoot.Position-myRoot.Position).Magnitude
                        if dist<=st.aimrange then
                            local tag=tChar:FindFirstChild("ESPTag")
                            if not tag then
                                local bill=Instance.new("BillboardGui",tChar)
                                bill.Name="ESPTag"; bill.AlwaysOnTop=true; bill.Size=UDim2.new(0,150,0,60); bill.StudsOffset=Vector3.new(0,3,0)
                                local label=Instance.new("TextLabel",bill)
                                label.Size=UDim2.new(1,0,1,0); label.BackgroundTransparency=1; label.TextColor3=Color3.new(1,0,0); label.Font=Enum.Font.SourceSansBold; label.TextSize=12
                                tag=bill
                            end
                            local label=tag:FindFirstChild("TextLabel")
                            if label then
                                local lines={}
                                if st.espn then table.insert(lines,tChar.Name) end
                                if st.espd then table.insert(lines,math.floor(dist).."m") end
                                if st.esphp then local h=tChar:FindFirstChildOfClass("Humanoid"); if h then table.insert(lines,"HP:"..math.floor(h.Health)) end end
                                label.Text=table.concat(lines,"\n")
                            end
                        end
                    end
                end
            end
        else
            for _,p in ipairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESPTag") then p.Character.ESPTag:Destroy() end end
            for _,obj in ipairs(WS:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("ESPTag") then obj.ESPTag:Destroy() end end
        end
    end)
    wait(0.5)
end
