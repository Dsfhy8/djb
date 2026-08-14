local player=game.Players.LocalPlayer
local cam=workspace.CurrentCamera
local Players=game.Players
local RS=game:GetService("RunService")
local WS=workspace
local UIS=game:GetService("UserInputService")

-- 状态存储
local state={
    -- 自瞄类
    aimbotOn=false,
    aimLockHead=true,
    aimLockChest=false,
    aimbotRange=200,
    smoothness=0.12,
    FOV_Angle=25,
    wallCheck=true,
    teamCheck=true,
    autoShoot=false,
    autoRecoilControl=false,
    -- 透视类
    espOn=false,
    espBox=false,
    espName=false,
    espDistance=false,
    espHealth=false,
    espWeapon=false,
    espNPC=true,
    espLine=false,
    espIgnoreTeam=true,
    espIgnoreNPC=false,
    espRange=300,
    -- 武器类
    noRecoil=false,
    fastReload=false,
    noSpread=false,
    noBulletDrop=false,
    infiniteAmmo=false,
    autoFire=false,
    rapidFire=false,
    increaseRange=false,
    quickMelee=false,
    muzzleFlash=false,
    -- 移动类
    speedBoost=false,
    jumpBoost=false,
    autoBhop=false,
    thirdPerson=false,
    silentFootstep=false,
    noFallDamage=false,
    noclip=false,
    infiniteJump=false,
    swimBoost=false,
    crouchBoost=false,
    -- 生存类
    godMode=false,
    infStamina=false,
    fastRegen=false,
    nightVision=false,
    antiFlash=false,
    antiSmoke=false,
    antiShake=false,
    autoHeal=false,
    fallDamage=false,
    footstep=false,
    -- 杂项
    bulletTrace=false,
    autoPickup=false,
    crosshairSpread=false,
    longRangeKill=false,
    seeMonster=false,
    antiBlind=false,
}

-- UI
local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
gui.Name="FPS脚本中心"
gui.ResetOnSpawn=false

local win=Instance.new("Frame",gui)
win.Size=UDim2.new(0,520,0,480)
win.Position=UDim2.new(0.5,-260,0.5,-240)
win.BackgroundColor3=Color3.fromRGB(20,20,20)
win.Visible=false
win.ZIndex=50
Instance.new("UICorner",win).CornerRadius=UDim.new(0,10)

local titleBar=Instance.new("Frame",win)
titleBar.Size=UDim2.new(1,0,0,32)
titleBar.BackgroundColor3=Color3.fromRGB(30,30,30)
Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,10)
local titleLabel=Instance.new("TextLabel",titleBar)
titleLabel.Size=UDim2.new(1,-30,1,0)
titleLabel.Position=UDim2.new(0,10,0,0)
titleLabel.BackgroundTransparency=1
titleLabel.Text="FPS脚本中心"
titleLabel.TextColor3=Color3.new(1,1,1)
titleLabel.Font=Enum.Font.SourceSansBold
titleLabel.TextSize=16
titleLabel.TextXAlignment=Enum.TextXAlignment.Left
local closeBtn=Instance.new("TextButton",titleBar)
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.Position=UDim2.new(1,-28,0,4)
closeBtn.BackgroundColor3=Color3.fromRGB(200,60,60)
closeBtn.Text="X"
closeBtn.TextColor3=Color3.new(1,1,1)
closeBtn.Font=Enum.Font.SourceSansBold
closeBtn.TextSize=12
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,4)
closeBtn.MouseButton1Click:Connect(function() win.Visible=false end)

local sidebar=Instance.new("Frame",win)
sidebar.Size=UDim2.new(0,120,1,-32)
sidebar.Position=UDim2.new(0,0,0,32)
sidebar.BackgroundColor3=Color3.fromRGB(35,35,35)
sidebar.BorderSizePixel=0

local content=Instance.new("Frame",win)
content.Size=UDim2.new(1,-120,1,-32)
content.Position=UDim2.new(0,120,0,32)
content.BackgroundColor3=Color3.fromRGB(25,25,25)
content.BorderSizePixel=0

local pages={}
local function showPage(name)
    for pn,page in pairs(pages) do
        page.Visible=(pn==name)
    end
    for _,btn in ipairs(sidebar:GetChildren()) do
        if btn:IsA("TextButton") then
            btn.BackgroundColor3=(btn.Text==name) and Color3.fromRGB(80,130,200) or Color3.fromRGB(55,55,55)
        end
    end
end

local function addSideButton(text,pageName)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-10,0,40)
    btn.Position=UDim2.new(0,5,0,#sidebar:GetChildren()*45+5)
    btn.BackgroundColor3=Color3.fromRGB(55,55,55)
    btn.Text=text
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.SourceSansBold
    btn.TextSize=14
    btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.Parent=sidebar
    btn.MouseButton1Click:Connect(function() showPage(pageName) end)
end

local function addToggle(parent,text,stateKey,yPos)
    local scroll=parent:FindFirstChild("Scroll")
    if not scroll then return end
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,36)
    btn.Position=UDim2.new(0,10,0,yPos)
    btn.BackgroundColor3=state[stateKey] and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
    btn.Text=text.."："..(state[stateKey] and "开" or "关")
    btn.TextColor3=Color3.new(1,1,1)
    btn.Font=Enum.Font.SourceSansBold
    btn.TextSize=13
    btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.Parent=scroll
    btn.MouseButton1Click:Connect(function()
        state[stateKey]=not state[stateKey]
        btn.BackgroundColor3=state[stateKey] and Color3.fromRGB(100,255,100) or Color3.fromRGB(255,100,100)
        btn.Text=text.."："..(state[stateKey] and "开" or "关")
    end)
end

local function addSlider(parent,text,stateKey,minVal,maxVal,yPos)
    local scroll=parent:FindFirstChild("Scroll")
    if not scroll then return end
    local frame=Instance.new("Frame")
    frame.Size=UDim2.new(1,-20,0,40)
    frame.Position=UDim2.new(0,10,0,yPos)
    frame.BackgroundTransparency=1
    frame.Parent=scroll

    local lbl=Instance.new("TextLabel",frame)
    lbl.Size=UDim2.new(0,100,0,20)
    lbl.Position=UDim2.new(0,0,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text=text..": "..state[stateKey]
    lbl.TextColor3=Color3.new(1,1,1)
    lbl.Font=Enum.Font.SourceSansBold
    lbl.TextSize=12
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local sliderBg=Instance.new("Frame",frame)
    sliderBg.Size=UDim2.new(1,0,0,8)
    sliderBg.Position=UDim2.new(0,0,0,22)
    sliderBg.BackgroundColor3=Color3.fromRGB(80,80,80)
    Instance.new("UICorner",sliderBg).CornerRadius=UDim.new(0,4)

    local fill=Instance.new("Frame",sliderBg)
    fill.Size=UDim2.new((state[stateKey]-minVal)/(maxVal-minVal),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(80,130,200)
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,4)

    local knob=Instance.new("TextButton",sliderBg)
    knob.Size=UDim2.new(0,16,0,16)
    knob.Position=UDim2.new((state[stateKey]-minVal)/(maxVal-minVal),-8,0.5,-8)
    knob.BackgroundColor3=Color3.new(1,1,1)
    knob.Text=""
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local dragging=false
    local function update(input)
        local relX=input.Position.X-sliderBg.AbsolutePosition.X
        local percent=math.clamp(relX/sliderBg.AbsoluteSize.X,0,1)
        local value=math.floor(minVal+percent*(maxVal-minVal))
        state[stateKey]=value
        fill.Size=UDim2.new(percent,0,1,0)
        knob.Position=UDim2.new(percent,-8,0.5,-8)
        lbl.Text=text..": "..value
    end
    knob.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    knob.InputEnded:Connect(function() dragging=false end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseMovement) then update(input) end
    end)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then update(input); dragging=true end
    end)
    sliderBg.InputEnded:Connect(function() dragging=false end)
end

local function createPage(name)
    local page=Instance.new("Frame",content)
    page.Size=UDim2.new(1,0,1,0)
    page.BackgroundTransparency=1
    page.Visible=false
    local scroll=Instance.new("ScrollingFrame",page)
    scroll.Name="Scroll"
    scroll.Size=UDim2.new(1,0,1,0)
    scroll.Position=UDim2.new(0,0,0,0)
    scroll.BackgroundTransparency=1
    scroll.ScrollBarThickness=6
    scroll.ScrollingDirection=Enum.ScrollingDirection.Y
    scroll.CanvasSize=UDim2.new(0,0,0,600)
    scroll.BottomImage="rbxassetid://0"
    scroll.TopImage="rbxassetid://0"
    scroll.ClipsDescendants=true
    scroll.TouchEnabled=true
    scroll.TouchPanSpeed=30
    pages[name]=page
    return page
end

local aimPage=createPage("自瞄")
local espPage=createPage("透视")
local weaponPage=createPage("武器")
local movePage=createPage("移动")
local survivalPage=createPage("生存")
local miscPage=createPage("杂项")

-- 自瞄页
local y=10
addToggle(aimPage,"平滑自瞄","aimbotOn",y); y+=45
addToggle(aimPage,"锁头","aimLockHead",y); y+=45
addToggle(aimPage,"锁胸","aimLockChest",y); y+=45
addSlider(aimPage,"自瞄范围","aimbotRange",50,500,y); y+=45
addSlider(aimPage,"平滑度","smoothness",0,1,y); y+=45
addSlider(aimPage,"FOV角度","FOV_Angle",5,180,y); y+=45
addToggle(aimPage,"墙壁检测","wallCheck",y); y+=45
addToggle(aimPage,"队伍检测","teamCheck",y); y+=45
addToggle(aimPage,"自动射击","autoShoot",y); y+=45
addToggle(aimPage,"自动压枪","autoRecoilControl",y); y+=45

-- 透视页
y=10
addToggle(espPage,"透视总开关","espOn",y); y+=45
addToggle(espPage,"玩家方框","espBox",y); y+=45
addToggle(espPage,"玩家名字","espName",y); y+=45
addToggle(espPage,"玩家距离","espDistance",y); y+=45
addToggle(espPage,"玩家血量","espHealth",y); y+=45
addToggle(espPage,"玩家武器","espWeapon",y); y+=45
addToggle(espPage,"检测人机","espNPC",y); y+=45
addToggle(espPage,"射线指示","espLine",y); y+=45
addToggle(espPage,"忽略队友","espIgnoreTeam",y); y+=45
addToggle(espPage,"忽略人机","espIgnoreNPC",y); y+=45

-- 武器页
y=10
addToggle(weaponPage,"无后坐力","noRecoil",y); y+=45
addToggle(weaponPage,"快速换弹","fastReload",y); y+=45
addToggle(weaponPage,"无扩散","noSpread",y); y+=45
addToggle(weaponPage,"无子弹下坠","noBulletDrop",y); y+=45
addToggle(weaponPage,"无限子弹","infiniteAmmo",y); y+=45
addToggle(weaponPage,"自动射击","autoFire",y); y+=45
addToggle(weaponPage,"快速射速","rapidFire",y); y+=45
addToggle(weaponPage,"增加射程","increaseRange",y); y+=45
addToggle(weaponPage,"近战加速","quickMelee",y); y+=45
addToggle(weaponPage,"枪口无火焰","muzzleFlash",y); y+=45

-- 移动页
y=10
addToggle(movePage,"移动加速","speedBoost",y); y+=45
addToggle(movePage,"跳跃增强","jumpBoost",y); y+=45
addToggle(movePage,"自动连跳","autoBhop",y); y+=45
addToggle(movePage,"第三人称","thirdPerson",y); y+=45
addToggle(movePage,"静步","silentFootstep",y); y+=45
addToggle(movePage,"防摔落","noFallDamage",y); y+=45
addToggle(movePage,"穿墙","noclip",y); y+=45
addToggle(movePage,"无限跳跃","infiniteJump",y); y+=45
addToggle(movePage,"游泳加速","swimBoost",y); y+=45
addToggle(movePage,"蹲下加速","crouchBoost",y); y+=45

-- 生存页
y=10
addToggle(survivalPage,"无敌","godMode",y); y+=45
addToggle(survivalPage,"无限体力","infStamina",y); y+=45
addToggle(survivalPage,"快速回血","fastRegen",y); y+=45
addToggle(survivalPage,"夜视","nightVision",y); y+=45
addToggle(survivalPage,"防闪光","antiFlash",y); y+=45
addToggle(survivalPage,"防烟雾","antiSmoke",y); y+=45
addToggle(survivalPage,"防震屏","antiShake",y); y+=45
addToggle(survivalPage,"自动吃药","autoHeal",y); y+=45
addToggle(survivalPage,"免疫跌落伤害","fallDamage",y); y+=45
addToggle(survivalPage,"消除脚步声","footstep",y); y+=45

-- 杂项
y=10
addToggle(miscPage,"子弹追踪","bulletTrace",y); y+=45
addToggle(miscPage,"自动拾取","autoPickup",y); y+=45
addToggle(miscPage,"准星扩散","crosshairSpread",y); y+=45
addToggle(miscPage,"远距离击杀","longRangeKill",y); y+=45
addToggle(miscPage,"透视怪物","seeMonster",y); y+=45
addToggle(miscPage,"防致盲","antiBlind",y); y+=45

addSideButton("自瞄","自瞄")
addSideButton("透视","透视")
addSideButton("武器","武器")
addSideButton("移动","移动")
addSideButton("生存","生存")
addSideButton("杂项","杂项")

showPage("自瞄")

local ball=Instance.new("TextButton",gui)
ball.Size=UDim2.new(0,50,0,100)
ball.Position=UDim2.new(1,-50,0.5,-50)
ball.BackgroundColor3=Color3.fromRGB(70,130,200)
ball.Text="菜单"
ball.TextColor3=Color3.new(1,1,1)
ball.Font=Enum.Font.SourceSansBold
ball.TextSize=14
ball.BorderSizePixel=0
ball.AutoButtonColor=false
ball.ZIndex=80
Instance.new("UICorner",ball).CornerRadius=UDim.new(0,8)
ball.MouseButton1Click:Connect(function() win.Visible=not win.Visible end)

-- 辅助函数
local function getEnemies()
    local list={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health>0 then
            if not state.teamCheck or (not player.Team or not p.Team or player.Team~=p.Team) then
                table.insert(list,{char=p.Character,isNPC=false})
            end
        end
    end
    if state.espNPC then
        for _,obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then
                local hum=obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then
                    if not state.teamCheck or (not player.Team or not obj:FindFirstChild("Team") or obj.Team~=player.Team) then
                        table.insert(list,{char=obj,isNPC=true})
                    end
                end
            end
        end
    end
    return list
end

local function los(origin,targetPos,targetChar)
    if not state.wallCheck then return true end
    local ray=Ray.new(origin,(targetPos-origin).Unit*math.min((targetPos-origin).Magnitude,500))
    local hit=WS:FindPartOnRayWithIgnoreList(ray,{player.Character,targetChar})
    return not hit
end

RS.RenderStepped:Connect(function()
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local myRoot=player.Character.HumanoidRootPart
    local hum=player.Character:FindFirstChildOfClass("Humanoid")

    if state.speedBoost and hum then hum.WalkSpeed=50 end
    if state.jumpBoost and hum then hum.JumpPower=100 end
    if state.autoBhop and hum and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    if state.thirdPerson and player.CameraMode~=Enum.CameraMode.Classic then player.CameraMode=Enum.CameraMode.Classic end
    if state.noclip then for _,part in ipairs(player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide=false end end end
    if state.infiniteJump and hum and hum.FloorMaterial~=Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    if state.swimBoost and hum and hum.FloorMaterial==Enum.Material.Water then hum.WalkSpeed=50 end
    if state.crouchBoost and hum and hum.Sit then hum.WalkSpeed=50 end

    if state.godMode and hum then hum.Health=hum.MaxHealth end
    if state.infStamina and hum then hum:SetStateEnabled(Enum.HumanoidStateType.Running,true); hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics,true) end
    if state.fastRegen and hum then hum.Health=math.min(hum.MaxHealth,hum.Health+0.5) end
    if state.nightVision then game:GetService("Lighting").Brightness=3 end
    if state.fallDamage and hum then hum.FallSpeed=0 end

    if state.aimbotOn and not state.autoShoot then
        local targets=getEnemies()
        table.sort(targets,function(a,b)
            local da=(a.char.HumanoidRootPart.Position-myRoot.Position).Magnitude
            local db=(b.char.HumanoidRootPart.Position-myRoot.Position).Magnitude
            return da<db
        end)
        for _,data in ipairs(targets) do
            local tChar=data.char
            local aimPart
            if state.aimLockHead then aimPart=tChar:FindFirstChild("Head") end
            if not aimPart and state.aimLockChest then aimPart=tChar:FindFirstChild("UpperTorso") end
            if not aimPart then aimPart=tChar:FindFirstChild("HumanoidRootPart") end
            if aimPart then
                local dist=(aimPart.Position-cam.CFrame.Position).Magnitude
                if dist<=state.aimbotRange and los(cam.CFrame.Position,aimPart.Position,tChar) then
                    local lookAt=CFrame.lookAt(cam.CFrame.Position,aimPart.Position)
                    cam.CFrame=cam.CFrame:Lerp(lookAt,state.smoothness)
                    break
                end
            end
        end
    end

    if state.noRecoil or state.noSpread or state.fastReload then
        pcall(function()
            for _,tool in ipairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    for _,child in ipairs(tool:GetDescendants()) do
                        if child:IsA("NumberValue") then
                            local n=child.Name:lower()
                            if state.noRecoil and (n:find("recoil") or n:find("kick")) then child.Value=0 end
                            if state.noSpread and n:find("spread") then child.Value=0 end
                            if state.fastReload and n:find("reload") then child.Value=0.1 end
                        end
                    end
                end
            end
        end)
    end

    if state.autoFire then
        pcall(function()
            local targets=getEnemies()
            if #targets>0 then
                local tChar=targets[1].char
                local aimPart=tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart")
                if aimPart and los(cam.CFrame.Position,aimPart.Position,tChar) then
                    local lookAt=CFrame.lookAt(cam.CFrame.Position,aimPart.Position)
                    cam.CFrame=cam.CFrame:Lerp(lookAt,0.3)
                    if player:GetMouse() then
                        player:GetMouse().Button1Down:Fire()
                        player:GetMouse().Button1Up:Fire()
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    while true do
        if state.espOn then
            for _,p in ipairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("ESPTag") then p.Character.ESPTag:Destroy() end end
            for _,obj in ipairs(WS:GetDescendants()) do if obj:IsA("Model") and obj:FindFirstChild("ESPTag") then obj.ESPTag:Destroy() end end
            local myRoot=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _,data in ipairs(getEnemies()) do
                    local tChar=data.char
                    local tRoot=tChar:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        local dist=(tRoot.Position-myRoot.Position).Magnitude
                        if dist<=state.espRange then
                            local tag=tChar:FindFirstChild("ESPTag")
                            if not tag then
                                local bill=Instance.new("BillboardGui",tChar)
                                bill.Name="ESPTag"; bill.AlwaysOnTop=true; bill.Size=UDim2.new(0,120,0,60); bill.StudsOffset=Vector3.new(0,3,0)
                                local label=Instance.new("TextLabel",bill)
                                label.Size=UDim2.new(1,0,1,0); label.BackgroundTransparency=1; label.TextColor3=Color3.new(1,0,0); label.Font=Enum.Font.SourceSansBold; label.TextSize=12
                                tag=bill
                            end
                            local label=tag:FindFirstChild("TextLabel")
                            if label then
                                local lines={}
                                if state.espName then table.insert(lines,data.isNPC and "人机" or Players:GetPlayerFromCharacter(tChar) and Players:GetPlayerFromCharacter(tChar).Name or "未知") end
                                if state.espDistance then table.insert(lines,math.floor(dist).."m") end
                                if state.espHealth then local h=tChar:FindFirstChildOfClass("Humanoid"); if h then table.insert(lines,"HP:"..math.floor(h.Health)) end end
                                if state.espWeapon then local tool=tChar:FindFirstChildOfClass("Tool"); if tool then table.insert(lines,tool.Name) end end
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
        wait(1)
    end
end)
