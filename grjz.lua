local function CleanOldUI()
    local parents = {}
    pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
    pcall(function() table.insert(parents, game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")) end)
    local killNames = {
        ["AnimeFloatBall"] = true, ["WindUI"] = true,
        ["WindUI/Notifications"] = true, ["WindUI/Dropdowns"] = true,
        ["WindUI/Tooltips"] = true, ["LogBoard"] = true, ["AnimeGlassLog"] = true,
    }
    for _, parent in ipairs(parents) do
        if parent then
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("ScreenGui") and killNames[child.Name] then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
    pcall(function()
        local W = getgenv and getgenv().AnimeWindow
        if W and W.Destroy then W:Destroy() end
    end)
    pcall(function() if getgenv then getgenv().AnimeWindow = nil end end)
end

CleanOldUI()
task.wait(0.15)

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

local Folder = "AnimeUI"
local ICON_URL = "https://raw.githubusercontent.com/xiaomeng0930/QWQ/main/zgr.jpg"
local ICON_PATH = Folder .. "/float_icon.jpg"

if not isfolder(Folder) then makefolder(Folder) end
if not isfile(ICON_PATH) then
    local ok, data = pcall(function()
        if syn and syn.request then return syn.request({Url=ICON_URL,Method="GET"}).Body
        elseif http_request then return http_request({Url=ICON_URL,Method="GET"}).Body
        else return game:HttpGet(ICON_URL) end
    end)
    if ok and data and #data > 100 then writefile(ICON_PATH, data) end
end

local iconAsset
local ok2, id = pcall(function() return getcustomasset(ICON_PATH) end)
if ok2 then iconAsset = id else iconAsset = "rbxassetid://10709791437" end

local function BuildTheme(h1, h2, h3)
    return {
        Name = "AnimeGlass",
        Accent = WindUI:Gradient({ ["0"] = {Color=Color3.fromHex(h1),Transparency=0}, ["100"] = {Color=Color3.fromHex(h2),Transparency=0} }, {Rotation=45}),
        Dialog = Color3.fromHex("#1a1a2e"),
        Outline = Color3.fromHex("#ffffff"),
        Text = Color3.fromHex("#ffffff"),
        Placeholder = Color3.fromHex("#a1a1aa"),
        Background = Color3.fromHex("#0f0f1a"),
        Icon = Color3.fromHex("#ffffff"),
        Button = WindUI:Gradient({ ["0"] = {Color=Color3.fromHex(h1),Transparency=0.1}, ["100"] = {Color=Color3.fromHex(h2),Transparency=0.1} }, {Rotation=45}),
        Toggle = Color3.fromHex(h3), Slider = Color3.fromHex(h3), Checkbox = Color3.fromHex(h3),
        ToggleBar = Color3.fromHex("#ffffff"),
        CheckboxIcon = Color3.fromHex("#ffffff"),
        CheckboxBorder = Color3.fromHex("#ffffff"),
        CheckboxBorderTransparency = 0.6,
        SliderThumb = Color3.fromHex("#ffffff"),
        SliderIcon = Color3.fromHex("#ffffff"),
        ElementBackground = Color3.fromHex("#ffffff"),
        ElementBackgroundTransparency = 0.88,
        PanelBackground = Color3.fromHex("#ffffff"),
        PanelBackgroundTransparency = 0.94,
        LabelBackground = Color3.fromHex("#ffffff"),
        LabelBackgroundTransparency = 0.9,
        TabBackground = Color3.fromHex("#0f0f1a"),
        TabBackgroundHover = Color3.fromHex("#0f0f1a"),
        TabBackgroundHoverTransparency = 1,
        TabBackgroundActive = Color3.fromHex(h3),
        TabBackgroundActiveTransparency = 0.85,
        TabBorder = Color3.fromHex("#ffffff"),
        TabBorderTransparency = 0.9,
        TabBorderTransparencyActive = 0.6,
        TabText = Color3.fromHex("#ffffff"),
        TabTextTransparency = 0.3,
        TabTextTransparencyActive = 0,
        TabTitle = Color3.fromHex("#ffffff"),
        TabIcon = Color3.fromHex("#ffffff"),
        TabIconTransparency = 0.4,
        TabIconTransparencyActive = 0.1,
        ElementTitle = Color3.fromHex("#ffffff"),
        ElementDesc = Color3.fromHex("#a1a1aa"),
        ElementIcon = Color3.fromHex("#ffffff"),
        PopupBackground = Color3.fromHex("#0f0f1a"),
        PopupTitle = Color3.fromHex("#ffffff"),
        PopupContent = Color3.fromHex("#a1a1aa"),
        PopupIcon = Color3.fromHex(h3),
        DialogBackground = Color3.fromHex("#0f0f1a"),
        DialogTitle = Color3.fromHex("#ffffff"),
        DialogContent = Color3.fromHex("#a1a1aa"),
        DialogIcon = Color3.fromHex(h3),
        Notification = Color3.fromHex("#0f0f1a"),
        NotificationTitle = Color3.fromHex("#ffffff"),
        NotificationContent = Color3.fromHex("#a1a1aa"),
        SearchBarBorder = Color3.fromHex("#ffffff"),
        SearchBarBorderTransparency = 0.7,
        DropdownBackground = Color3.fromHex("#1a1a2e"),
        DropdownTabBackground = Color3.fromHex("#ffffff"),
        DropdownTabBorder = Color3.fromHex("#ffffff"),
        AcrylicMain = Color3.fromHex("#ffffff"),
        AcrylicNoise = 0.9,
    }
end

WindUI:AddTheme(BuildTheme("#ff6ec7", "#7873f5", "#ff6ec7"))
WindUI:SetTheme("AnimeGlass")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Window = WindUI:CreateWindow({
    Title = "国人捐赠HUB",
    Author = "by.小梦",
    Folder = Folder,
    Size = UDim2.new(0, 620, 0, 460),
    Theme = "AnimeGlass",
    Acrylic = true,
    Transparent = true,
    Radius = 20,
    ElementsRadius = 24,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    SideBarWidth = 180,
    Topbar = { Height = 52, ButtonsType = "Default" },
    OpenButton = { Enabled = false },
    User = { Enabled = true },
})

if getgenv then getgenv().AnimeWindow = Window end
WindUI:SetNotificationLower(true)

task.spawn(function()
    while not Window or not Window.UIElements or not Window.UIElements.Main do task.wait(0.1) end
    task.wait(0.6)
    pcall(function() Window:DisableTopbarButtons({"Close", "Minimize", "Fullscreen"}) end)
    pcall(function()
        local bg = Window.UIElements.Main:FindFirstChild("Background")
        if bg then
            for _, c in ipairs(bg:GetChildren()) do
                if c:IsA("ImageLabel") and c.Name ~= "Blur" then
                    c.Image = "" c.ImageTransparency = 1 c.Visible = false
                end
                if c:IsA("VideoFrame") then c:Destroy() end
            end
        end
        if Window.UIElements.BackgroundGradient then
            Window.UIElements.BackgroundGradient:Destroy()
            Window.UIElements.BackgroundGradient = nil
        end
    end)
    pcall(function()
        if Window.OpenButtonMain and Window.OpenButtonMain.Button then
            Window.OpenButtonMain.Button.Visible = false
        end
    end)
end)

local BALL_SIZE = 38

local ballGui = Instance.new("ScreenGui")
ballGui.Name = "AnimeFloatBall"
ballGui.ResetOnSpawn = false
ballGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ballGui.IgnoreGuiInset = true
pcall(function() ballGui.Parent = game:GetService("CoreGui") end)
if not ballGui.Parent then
    ballGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local ball = Instance.new("ImageLabel")
ball.Name = "Ball"
ball.Size = UDim2.fromOffset(BALL_SIZE, BALL_SIZE)
ball.Position = UDim2.new(0, 30, 0.5, -BALL_SIZE / 2)
ball.BackgroundColor3 = Color3.fromHex("#0f0f1a")
ball.BackgroundTransparency = 0.05
ball.Image = iconAsset
ball.ScaleType = Enum.ScaleType.Crop
ball.ZIndex = 10
ball.Active = true
ball.Parent = ballGui

local ballCorner = Instance.new("UICorner")
ballCorner.CornerRadius = UDim.new(1, 0)
ballCorner.Parent = ball

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Color = Color3.fromHex("#ff6ec7")
stroke.Transparency = 0.15
stroke.Parent = ball

local strokeGrad = Instance.new("UIGradient")
strokeGrad.Rotation = 45
strokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromHex("#ff6ec7")),
    ColorSequenceKeypoint.new(0.5, Color3.fromHex("#7873f5")),
    ColorSequenceKeypoint.new(1, Color3.fromHex("#ff6ec7")),
})
strokeGrad.Parent = stroke

local pulseRing = Instance.new("Frame")
pulseRing.Name = "PulseRing"
pulseRing.Size = UDim2.fromOffset(BALL_SIZE, BALL_SIZE)
pulseRing.Position = UDim2.new(ball.Position.X.Scale, ball.Position.X.Offset + BALL_SIZE / 2, ball.Position.Y.Scale, ball.Position.Y.Offset + BALL_SIZE / 2)
pulseRing.AnchorPoint = Vector2.new(0.5, 0.5)
pulseRing.BackgroundTransparency = 1
pulseRing.ZIndex = 8
pulseRing.Active = false
pulseRing.Parent = ballGui

local pulseCorner = Instance.new("UICorner")
pulseCorner.CornerRadius = UDim.new(1, 0)
pulseCorner.Parent = pulseRing

local pulseStroke = Instance.new("UIStroke")
pulseStroke.Thickness = 1.2
pulseStroke.Color = Color3.fromHex("#ff6ec7")
pulseStroke.Transparency = 0.3
pulseStroke.Parent = pulseRing

local currentBallSize = BALL_SIZE

task.spawn(function()
    local t = 0
    while pulseRing.Parent do
        local dt = task.wait(0.03)
        t = t + dt
        strokeGrad.Rotation = (t * 60) % 360
        local phase = (t * 1.2) % 1
        local size = currentBallSize + phase * 14
        pulseRing.Size = UDim2.fromOffset(size, size)
        pulseRing.Position = UDim2.new(
            ball.Position.X.Scale, ball.Position.X.Offset + currentBallSize / 2,
            ball.Position.Y.Scale, ball.Position.Y.Offset + currentBallSize / 2
        )
        pulseStroke.Transparency = phase * 0.85
        pulseStroke.Color = Color3.fromHSV(((t * 0.12) % 1), 0.7, 1)
    end
end)

local dragging = false
local dragStart, startPos
local clickStartTime, clickStartPos
local hasDragged = false
local originalMouseBehavior = UserInputService.MouseBehavior

ball.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasDragged = false
        dragStart = input.Position
        startPos = ball.Position
        clickStartTime = tick()
        clickStartPos = input.Position
        originalMouseBehavior = UserInputService.MouseBehavior
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then hasDragged = true end
        ball.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            UserInputService.MouseBehavior = originalMouseBehavior
            if not hasDragged and clickStartPos then
                local moved = (input.Position - clickStartPos).Magnitude
                local elapsed = tick() - clickStartTime
                if moved < 8 and elapsed < 0.5 then
                    if Window.Closed then Window:Open() else Window:Close() end
                end
            end
            clickStartPos = nil
        end
    end
end)

task.spawn(function()
    while not Window or not Window.TabModule do task.wait(0.1) end
    task.wait(0.5)
    local tabModule = Window.TabModule
    local function FixTabs()
        if not tabModule or not tabModule.Tabs then return end
        for _, tab in pairs(tabModule.Tabs) do
            if tab.UIElements and tab.UIElements.Main and not tab.Selected then
                pcall(function()
                    local t = WindUI.Themes["AnimeGlass"]
                    if typeof(t.TabBackground) == "Color3" then
                        tab.UIElements.Main.ImageColor3 = t.TabBackground
                    end
                end)
            end
        end
    end
    task.spawn(function()
        while Window and not Window.Destroyed do
            task.wait(0.12)
            FixTabs()
        end
    end)
end)

-- ==========================================
-- 标签页1：主页
-- ==========================================
local MainTab = Window:Tab({ Title = "主页", Icon = "home" })

local lblPoints = MainTab:Paragraph({ Title = "当前积分", Desc = "读取中..." })
local lblRobux = MainTab:Paragraph({ Title = "总取出 rubux", Desc = "读取中..." })
local lblDaily = MainTab:Paragraph({ Title = "今日已取出", Desc = "读取中..." })
local lblStatus = MainTab:Paragraph({ Title = "状态", Desc = "读取中..." })
local lblPing = MainTab:Paragraph({ Title = "Ping", Desc = "读取中..." })
local lblJobId = MainTab:Paragraph({ Title = "服务器 ID", Desc = "读取中..." })

task.spawn(function()
    while not lblJobId or not lblJobId.UIElements or not lblJobId.UIElements.Main do task.wait(0.1) end
    task.wait(0.5)
    if lblJobId.UIElements.Main then
        lblJobId.UIElements.Main.Active = true
        lblJobId.UIElements.Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                pcall(function() setclipboard(game.JobId) end)
                WindUI:Notify({ Title = "已复制", Content = "服务器 ID 已复制到剪贴板", Duration = 2 })
            end
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not player or not player.Parent then break end
        
        pcall(function()
            local points = player:GetAttribute("Points") or player:GetAttribute("积分")
            local robux = player:GetAttribute("Robux") or player:GetAttribute("罗宝")
            
            local ls = player:FindFirstChild("leaderstats")
            if ls then
                if ls:FindFirstChild("Points") then points = ls.Points.Value end
                if ls:FindFirstChild("Robux") then robux = ls.Robux.Value end
            end

            if points then lblPoints:SetDesc(tostring(points)) end
            if robux then lblRobux:SetDesc(tostring(robux)) end
            
            local ping = player:GetNetworkPing() * 1000
            lblPing:SetDesc(string.format("%.0f ms", ping))
            
            lblJobId:SetDesc(game.JobId)
            
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local hud = playerGui:FindFirstChild("HUD")
                if hud then
                    local menus = hud:FindFirstChild("Menus")
                    if menus then
                        local takeout = menus:FindFirstChild("Takeout")
                        if takeout then
                            local rewardPanel = takeout:FindFirstChild("RewardPanel")
                            if rewardPanel then
                                local pointsLabel = rewardPanel:FindFirstChild("PointsLabel")
                                if pointsLabel then
                                    local curPoints = string.match(pointsLabel.Text, "积分：([%d%.]+)")
                                    lblPoints:SetDesc(curPoints or "0")
                                end
                                local applesLabel = rewardPanel:FindFirstChild("ApplesLabel")
                                if applesLabel then
                                    local curRobux = string.match(applesLabel.Text, "罗宝：([%d]+)")
                                    lblRobux:SetDesc(curRobux or "0")
                                end
                                local dailyLabel = rewardPanel:FindFirstChild("DailyLabel")
                                if dailyLabel then
                                    local dailyTaken, dailyLimit = string.match(dailyLabel.Text, "今日已取出：([%d]+)%s*/%s*([%d]+)")
                                    if dailyTaken and dailyLimit then
                                        lblDaily:SetDesc(dailyTaken .. " / " .. dailyLimit)
                                    else
                                        lblDaily:SetDesc("0 / 0")
                                    end
                                end
                                local statusLabel = rewardPanel:FindFirstChild("StatusLabel")
                                if statusLabel then
                                    lblStatus:SetDesc(statusLabel.Text)
                                end
                            else
                                lblDaily:SetDesc("未打开面板")
                                lblStatus:SetDesc("未打开面板")
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ==========================================
-- 标签页2：角色
-- ==========================================
local PlayerTab = Window:Tab({ Title = "角色", Icon = "user" })

local sprintEnabled = false
RunService.Heartbeat:Connect(function()
    if not sprintEnabled then return end
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health > 0 and hum.MoveDirection.Magnitude > 0 then
        if hum.WalkSpeed ~= 23 then hum.WalkSpeed = 23 end
    end
end)

PlayerTab:Toggle({
    Title = "移动加速",
    Desc = "增加跑步速度",
    Default = false,
    Callback = function(state)
        sprintEnabled = state
        WindUI:Notify({ Title = "移动加速", Content = state and "已开启" or "已关闭", Duration = 2 })
    end
})

local noclipEnabled = false
local noclipConnection = nil

PlayerTab:Toggle({
    Title = "穿墙",
    Desc = "无视墙壁碰撞",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            noclipConnection = RunService.Stepped:Connect(function()
                if not noclipEnabled then return end
                local char = player.Character
                if not char then return end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end)
            WindUI:Notify({ Title = "穿墙", Content = "已开启", Duration = 2 })
        else
            if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
            WindUI:Notify({ Title = "穿墙", Content = "已关闭", Duration = 2 })
        end
    end
})

PlayerTab:Button({
    Title = "重置角色",
    Desc = "原地阵亡并重生",
    Callback = function() if player.Character then player.Character:BreakJoints() end end
})

-- ==========================================
-- 标签页3：积分
-- ==========================================
local PointsTab = Window:Tab({ Title = "积分", Icon = "coins" })

local function fireTargets(targets, hrp)
    for i, v in ipairs(targets) do
        pcall(function()
            firetouchinterest(hrp, v, 0)
            firetouchinterest(hrp, v, 1)
        end)
        if i % 50 == 0 then task.wait() end
    end
end

PointsTab:Button({
    Title = "一键领积分 (Beta)",
    Desc = "【实战未测试】尝试吃掉全图所有可领取的积分",
    Callback = function()
        task.spawn(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local pointTargets = {}
            local deathTargets = {}
            local rainFolders = {"20Points", "50Points", "100Points", "250Points", "500Points"}

            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local parentName = v.Parent and v.Parent.Name or ""
                    local isPoint = false
                    
                    if table.find(rainFolders, parentName) then
                        isPoint = true
                    elseif parentName == "Points Daily Reward Chest" and v.Name == "ClaimTrigger" then
                        isPoint = true
                    elseif parentName == "Items" and v.Name == "Apple" then
                        isPoint = true
                    end

                    if isPoint then table.insert(pointTargets, v) end
                    if v.Name == "KillPart" or v.Name == "KillBrick" then table.insert(deathTargets, v) end
                end
            end

            if #pointTargets == 0 then
                WindUI:Notify({ Title = "一键领积分", Content = "当前没有可领取的积分", Duration = 3 })
                return
            end

            local allTargets = {}
            for _, v in ipairs(pointTargets) do table.insert(allTargets, v) end
            for _, v in ipairs(deathTargets) do table.insert(allTargets, v) end

            fireTargets(allTargets, hrp)
            WindUI:Notify({ Title = "一键领积分", Content = "领取完成", Duration = 3 })
        end)
    end
})

PointsTab:Button({
    Title = "积分雨收割 (Beta)",
    Desc = "【实战未测试】只收割玩家购买特效产生的积分雨",
    Callback = function()
        task.spawn(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local pointTargets = {}
            local deathTargets = {}
            local rainFolders = {"20Points", "50Points", "100Points", "250Points", "500Points"}

            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    local parentName = v.Parent and v.Parent.Name or ""
                    
                    if table.find(rainFolders, parentName) then
                        table.insert(pointTargets, v)
                    end
                    if v.Name == "KillPart" or v.Name == "KillBrick" then 
                        table.insert(deathTargets, v) 
                    end
                end
            end

            if #pointTargets == 0 then
                WindUI:Notify({ Title = "积分雨收割", Content = "当前没有积分雨", Duration = 3 })
                return
            end

            local allTargets = {}
            for _, v in ipairs(pointTargets) do table.insert(allTargets, v) end
            for _, v in ipairs(deathTargets) do table.insert(allTargets, v) end

            fireTargets(allTargets, hrp)
            WindUI:Notify({ Title = "积分雨收割", Content = "收割完成", Duration = 3 })
        end)
    end
})

PointsTab:Button({
    Title = "解锁秘密基地成就 (Beta)",
    Desc = "【实战未测试】传送到隐藏区域并尝试触发成就",
    Callback = function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local showArea = workspace:FindFirstChild("ShowArea")
        local nukePlatform = showArea and showArea:FindFirstChild("NukePlatform")
        local secretArea = nukePlatform and nukePlatform:FindFirstChild("SecretArea")

        if not secretArea then return WindUI:Notify({ Title = "提示", Content = "未找到秘密基地区域", Duration = 3 }) end

        local targetPart = nil
        if secretArea:IsA("BasePart") then targetPart = secretArea
        else
            local touchInterest = secretArea:FindFirstChild("TouchInterest", true)
            if touchInterest and touchInterest.Parent and touchInterest.Parent:IsA("BasePart") then targetPart = touchInterest.Parent
            else targetPart = secretArea:FindFirstChildWhichIsA("BasePart", true) end
        end

        if not targetPart then return WindUI:Notify({ Title = "提示", Content = "未找到可触碰部件", Duration = 3 }) end

        hrp.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
        task.wait(0.5)
        for _ = 1, 5 do
            firetouchinterest(hrp, targetPart, 0)
            task.wait(0.1)
            firetouchinterest(hrp, targetPart, 1)
            task.wait(0.2)
        end
        WindUI:Notify({ Title = "完成", Content = "已尝试触发秘密基地成就", Duration = 3 })
    end
})

-- ==========================================
-- 标签页4：传送
-- ==========================================
local TeleportTab = Window:Tab({ Title = "传送", Icon = "map-pin" })

TeleportTab:Section({ Title = "我的摊位" })
TeleportTab:Button({
    Title = "传送到我的摊位",
    Desc = "瞬间移动到自己的摊位前方",
    Callback = function()
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local booths = workspace:FindFirstChild("NewLobby") and workspace.NewLobby:FindFirstChild("Booths")
        if not booths then return WindUI:Notify({ Title = "提示", Content = "未找到摊位区域", Duration = 3 }) end

        local myBooth = nil
        for _, booth in ipairs(booths:GetChildren()) do
            if booth:IsA("Model") then
                local ownerName = booth:GetAttribute("OwnerName") or booth:GetAttribute("Owner")
                local ownerId = booth:GetAttribute("OwnerUserId") or booth:GetAttribute("OwnerId")
                if ownerName == player.Name or ownerId == player.UserId then myBooth = booth break end
                local signGui = booth:FindFirstChild("SignPart") and booth.SignPart:FindFirstChild("BoothSignGui")
                if signGui and signGui:FindFirstChild("Background") then
                    local textLabel = signGui.Background:FindFirstChild("BoothText")
                    if textLabel and string.find(textLabel.Text, player.Name) then myBooth = booth break end
                end
            end
        end

        if not myBooth then return WindUI:Notify({ Title = "提示", Content = "你还没有摆放摊位", Duration = 3 }) end
        local success, pivot = pcall(function() return myBooth:GetPivot() end)
        if not success or not pivot then return WindUI:Notify({ Title = "提示", Content = "无法获取摊位位置", Duration = 3 }) end

        hrp.CFrame = CFrame.new(pivot.Position + Vector3.new(0, 3, 0))
        WindUI:Notify({ Title = "完成", Content = "已传送到你的摊位面前", Duration = 3 })
    end
})

local teleportData = {
    {Name = "展示区", Places = {
        {Name = "福利🤑", Pos = Vector3.new(-263, 485, -502)},
        {Name = "服务器动态", Pos = Vector3.new(-201, 481, -591)},
        {Name = "个人取出记录", Pos = Vector3.new(-188, 482, -605)},
        {Name = "待审批清单", Pos = Vector3.new(-171, 484, -588)},
        {Name = "创作者UGC", Pos = Vector3.new(-172, 481, -570)},
        {Name = "粉丝创作", Pos = Vector3.new(-155, 482, -570)},
        {Name = "游玩时长榜单", Pos = Vector3.new(-173, 481, -525)},
        {Name = "总理诸务", Pos = Vector3.new(-78, 488, -646)},
        {Name = "德业芳流", Pos = Vector3.new(-106, 489.5, -647.5)},
        {Name = "核弹基地", Pos = Vector3.new(-244, 484, -491)},
    }},
    {Name = "娱乐区", Places = {
        {Name = "宠物商店", Pos = Vector3.new(-392, 483, -809)},
        {Name = "每日积分", Pos = Vector3.new(-417, 483, -835)},
        {Name = "咖啡店", Pos = Vector3.new(-421, 484, -810)},
        {Name = "滑滑梯", Pos = Vector3.new(-514, 631, -771)},
        {Name = "积分抽奖", Pos = Vector3.new(-423.8, 483.2, -841.2)},
    }},
    {Name = "跑酷区", Places = {
        {Name = "长途跋涉", Pos = Vector3.new(-448, 481, -666)},
        {Name = "简单跑酷", Pos = Vector3.new(-451, 484, -633)},
        {Name = "困难跑酷", Pos = Vector3.new(-439, 484, -600)},
        {Name = "极限跑酷", Pos = Vector3.new(-395, 485, -560)},
        {Name = "玻璃桥", Pos = Vector3.new(-330, 485, -548)},
    }},
    {Name = "游戏区", Places = {
        {Name = "扳手腕", Pos = Vector3.new(-244, 484, -830)},
        {Name = "石头剪刀布", Pos = Vector3.new(-211, 484, -806)},
        {Name = "AI问答赛", Pos = Vector3.new(-178, 485, -784)},
        {Name = "脉冲锁定桌", Pos = Vector3.new(-164, 484, -752)},
        {Name = "薯片炸弹", Pos = Vector3.new(-162, 488, -766)},
        {Name = "猜猜谁扇的", Pos = Vector3.new(-112, 486, -774)},
        {Name = "巴掌读心", Pos = Vector3.new(-203, 486, -841)},
        {Name = "剑斗竞技场(混斗)", Pos = Vector3.new(-241, 484, -847)},
        {Name = "剑斗竞技场(独斗)", Pos = Vector3.new(-145, 483, -734)},
        {Name = "管理员小游戏", Pos = Vector3.new(-179, 487, -817)},
    }}
}

for _, group in ipairs(teleportData) do
    TeleportTab:Section({ Title = group.Name })
    for _, place in ipairs(group.Places) do
        TeleportTab:Button({
            Title = "传送到 " .. place.Name,
            Desc = "瞬间移动到该地点",
            Callback = function()
                local char = player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                hrp.CFrame = CFrame.new(place.Pos + Vector3.new(0, 3, 0))
                WindUI:Notify({ Title = "传送完成", Content = "已传送到 " .. place.Name, Duration = 2 })
            end
        })
    end
end

-- ==========================================
-- 标签页5：跑酷
-- ==========================================
local ObbyTab = Window:Tab({ Title = "跑酷", Icon = "footprints" })

local bridgeESP = false
local bridgeConnections = {}

local function colorGlass(glass)
    if not glass or not glass:IsA("BasePart") then return end
    local safe = glass:GetAttribute("Safe")
    local broken = glass:GetAttribute("Broken")
    if broken then
        glass.Color = Color3.fromRGB(80, 80, 80)
        glass.Material = Enum.Material.Glass
        glass.Transparency = 0.8
    elseif safe then
        glass.Color = Color3.fromRGB(0, 255, 0)
        glass.Material = Enum.Material.Neon
        glass.Transparency = 0
    else
        glass.Color = Color3.fromRGB(255, 0, 0)
        glass.Material = Enum.Material.Neon
        glass.Transparency = 0
    end
end

local function setupGlassWatch()
    if not bridgeESP then return end
    local area = Workspace:FindFirstChild("ObbyArea")
    if area then
        local bridge = area:FindFirstChild("GlassBridgeChallenge")
        if bridge and bridge:FindFirstChild("Rows") then
            for _, row in ipairs(bridge.Rows:GetChildren()) do
                for _, glass in ipairs(row:GetChildren()) do
                    if glass.Name == "LeftGlass" or glass.Name == "RightGlass" then
                        colorGlass(glass)
                        local conn1 = glass:GetAttributeChangedSignal("Broken"):Connect(function() colorGlass(glass) end)
                        local conn2 = glass:GetAttributeChangedSignal("Safe"):Connect(function() colorGlass(glass) end)
                        table.insert(bridgeConnections, conn1)
                        table.insert(bridgeConnections, conn2)
                    end
                end
            end
        end
    end
end

Workspace.DescendantAdded:Connect(function(desc)
    if bridgeESP and (desc.Name == "LeftGlass" or desc.Name == "RightGlass") then
        task.wait(0.1)
        colorGlass(desc)
        local conn1 = desc:GetAttributeChangedSignal("Broken"):Connect(function() colorGlass(desc) end)
        local conn2 = desc:GetAttributeChangedSignal("Safe"):Connect(function() colorGlass(desc) end)
        table.insert(bridgeConnections, conn1)
        table.insert(bridgeConnections, conn2)
    end
end)

local function claimObbyReward(obbyRegionName)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local area = Workspace:FindFirstChild("ObbyArea")
    if not area then return end

    local targetRegion = area:FindFirstChild(obbyRegionName)
    if not targetRegion then return WindUI:Notify({ Title = "提示", Content = "地图未加载，请先传送到起点", Duration = 3 }) end

    local startZone = targetRegion:FindFirstChild("StartZone") or targetRegion:FindFirstChild("StartPart")
    if startZone then
        local startPart = startZone:IsA("BasePart") and startZone or startZone:FindFirstChildWhichIsA("BasePart", true)
        if startPart then
            for _ = 1, 3 do
                firetouchinterest(hrp, startPart, 0)
                task.wait(0.1)
                firetouchinterest(hrp, startPart, 1)
                task.wait(0.1)
            end
            task.wait(0.5)
        end
    end

    local targetPad = nil
    local padModel = targetRegion:FindFirstChild("ThreePointRewardPad")
    if padModel then targetPad = padModel:FindFirstChild("RewardPad") end
    if not targetPad then
        for _, obj in ipairs(targetRegion:GetDescendants()) do
            if obj:IsA("BasePart") and string.find(obj.Name, "RewardPad") then targetPad = obj break end
        end
    end
    if not targetPad then return WindUI:Notify({ Title = "提示", Content = "未找到终点版（可能太远了）", Duration = 3 }) end

    local dist = (hrp.Position - targetPad.Position).Magnitude
    if dist > 800 then return WindUI:Notify({ Title = "距离过远", Content = "未找到终点版（可能太远了）", Duration = 4 }) end

    hrp.CFrame = CFrame.new(targetPad.Position + Vector3.new(0, 3, 0))
    task.wait(0.3)
    for _ = 1, 3 do
        firetouchinterest(hrp, targetPad, 0)
        task.wait(0.1)
        firetouchinterest(hrp, targetPad, 1)
        task.wait(0.2)
    end
    WindUI:Notify({ Title = "完成", Content = "奖励已尝试领取", Duration = 3 })
end

ObbyTab:Section({ Title = "终点领奖 (Beta)" })
local obbyMap = {
    {Name = "长途跋涉 (需靠近)", Region = "LongWalk"}, {Name = "简单跑酷", Region = "EazyObby"},
    {Name = "困难跑酷", Region = "HardObby"}, {Name = "极限跑酷", Region = "InsaneObby"},
    {Name = "玻璃桥", Region = "GlassBridgeChallenge"},
}
for _, data in ipairs(obbyMap) do
    ObbyTab:Button({
        Title = "领取【"..data.Name.."】奖励",
        Desc = "【实战未测试】起点原地触发，终点传送触碰",
        Callback = function() claimObbyReward(data.Region) end
    })
end

ObbyTab:Divider()
ObbyTab:Toggle({
    Title = "玻璃桥透视",
    Desc = "实时显示玻璃桥安全与危险区域",
    Default = false,
    Callback = function(state)
        bridgeESP = state
        if state then
            setupGlassWatch()
            WindUI:Notify({ Title = "透视", Content = "玻璃桥透视已开启", Duration = 2 })
        else
            for _, conn in ipairs(bridgeConnections) do pcall(function() conn:Disconnect() end) end
            bridgeConnections = {}
            WindUI:Notify({ Title = "透视", Content = "玻璃桥透视已关闭", Duration = 2 })
        end
    end
})

-- ==========================================
-- 标签页6：小游戏
-- ==========================================
local MinigameTab = Window:Tab({ Title = "小游戏", Icon = "gamepad-2" })

MinigameTab:Section({ Title = "123木头人 (Beta)" })

local redLightEnabled = false
local redLightConnection = nil

MinigameTab:Toggle({
    Title = "123木头人助手",
    Desc = "【实战未测试】红灯秒停，绿灯恢复",
    Default = false,
    Callback = function(state)
        redLightEnabled = state
        
        if state then
            local savedWalkSpeed = 16
            local savedJumpPower = 50
            local isCurrentlyRed = false
            
            redLightConnection = RunService.RenderStepped:Connect(function()
                if not redLightEnabled then return end
                pcall(function()
                    local char = player.Character
                    if not char then return end
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not hum then return end

                    local playerGui = player:FindFirstChild("PlayerGui")
                    if not playerGui then return end
                    
                    local gameGui = playerGui:FindFirstChild("RedLightGameGui")
                    if not gameGui then 
                        if isCurrentlyRed then
                            isCurrentlyRed = false
                            hum.WalkSpeed = savedWalkSpeed
                            hum.JumpPower = savedJumpPower
                        end
                        return 
                    end
                    
                    local titleLabel = gameGui:FindFirstChild("Title")
                    local turnLabel = gameGui:FindFirstChild("Turn")
                    
                    local currentText = ""
                    if titleLabel and titleLabel:IsA("TextLabel") then currentText = titleLabel.Text end
                    if currentText == "" and turnLabel and turnLabel:IsA("TextLabel") then currentText = turnLabel.Text end

                    local isRed = string.find(currentText, "🟥") or string.find(currentText, "红灯")
                    
                    if isRed then
                        if not isCurrentlyRed then
                            isCurrentlyRed = true
                            savedWalkSpeed = hum.WalkSpeed
                            savedJumpPower = hum.JumpPower
                            hum.WalkSpeed = 0
                            hum.JumpPower = 0
                        end
                        hum:Move(Vector3.zero)
                    else
                        if isCurrentlyRed then
                            isCurrentlyRed = false
                            hum.WalkSpeed = savedWalkSpeed
                            hum.JumpPower = savedJumpPower
                        end
                    end
                end)
            end)
            WindUI:Notify({ Title = "123木头人助手", Content = "已开启，推着摇杆即可！", Duration = 3 })
        else
            if redLightConnection then
                redLightConnection:Disconnect()
                redLightConnection = nil
            end
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                end
            end
            WindUI:Notify({ Title = "123木头人助手", Content = "已关闭", Duration = 3 })
        end
    end
})

MinigameTab:Section({ Title = "数学对战 (Beta)" })

local mathAutoEnabled = false
local mathConnection = nil

MinigameTab:Toggle({
    Title = "自动秒答",
    Desc = "【实战未测试】自动读取题目并瞬间提交答案",
    Default = false,
    Callback = function(state)
        mathAutoEnabled = state
        
        if state then
            local answerReq = nil
            task.spawn(function()
                while not answerReq do
                    task.wait(1)
                    local remotes = ReplicatedStorage:FindFirstChild("DataRemotes")
                    if remotes then
                        local roulette = remotes:FindFirstChild("RouletteSkill")
                        if roulette and roulette:FindFirstChild("AnswerRequest") then
                            answerReq = roulette.AnswerRequest
                        end
                    end
                end
            end)

            local function solveMath(exprStr)
                if not exprStr or exprStr == "" then return nil end
                local cleanExpr = exprStr:gsub("=?", ""):gsub("%s+", "")
                local loadFunc = loadstring or load
                if loadFunc then
                    local func = loadFunc("return " .. cleanExpr)
                    if func then
                        local success, result = pcall(func)
                        if success and tonumber(result) then return math.floor(result) end
                    end
                end
                local a, op, b = cleanExpr:match("(%d+)([%+%-%*%/])(%d+)")
                if a and op and b then
                    a, b = tonumber(a), tonumber(b)
                    if op == "+" then return a + b
                    elseif op == "-" then return a - b
                    elseif op == "*" then return a * b
                    elseif op == "/" then return math.floor(a / b) end
                end
                return nil
            end

            local lastQuestion = ""
            mathConnection = RunService.Heartbeat:Connect(function()
                if not mathAutoEnabled then return end
                pcall(function()
                    local gui = player:FindFirstChild("PlayerGui")
                    local minigameGui = gui and gui:FindFirstChild("MinigameGui")
                    local mathGui = minigameGui and minigameGui:FindFirstChild("MathBattleGui")
                    
                    if mathGui and mathGui.Visible then
                        local panel = mathGui:FindFirstChild("BattlePanel")
                        local expression = panel and panel:FindFirstChild("Expression")
                        local answerBox = panel and panel:FindFirstChild("AnswerBox")
                        
                        if expression and expression:IsA("TextLabel") and answerBox then
                            local currentQuestion = expression.Text
                            if currentQuestion ~= lastQuestion and currentQuestion ~= "" and currentQuestion:find("=") then
                                lastQuestion = currentQuestion
                                local answer = solveMath(currentQuestion)
                                if answer and answerReq then
                                    pcall(function() answerBox.Text = tostring(answer) end)
                                    task.wait(0.01)
                                    pcall(function() answerReq:FireServer(tostring(answer)) end)
                                end
                            end
                        end
                    else
                        lastQuestion = ""
                    end
                end)
            end)
            WindUI:Notify({ Title = "数学自动秒答", Content = "已开启", Duration = 3 })
        else
            if mathConnection then
                mathConnection:Disconnect()
                mathConnection = nil
            end
            WindUI:Notify({ Title = "数学自动秒答", Content = "已关闭", Duration = 3 })
        end
    end
})

MinigameTab:Section({ Title = "扳手腕 (Beta)" })

local armClickEnabled = false
local armQteEnabled = false
local armClickConn, armQteConn = nil, nil

MinigameTab:Toggle({
    Title = "自动点击发力",
    Desc = "【实战未测试】每秒38次点击，碾压对手",
    Default = false,
    Callback = function(state)
        armClickEnabled = state
        if state then
            local clickReq = nil
            task.spawn(function()
                while not clickReq do
                    task.wait(1)
                    local remotes = ReplicatedStorage:FindFirstChild("DataRemotes")
                    if remotes then
                        local arm = remotes:FindFirstChild("ArmWrestling")
                        if arm and arm:FindFirstChild("ClickRequest") then clickReq = arm.ClickRequest end
                    end
                end
            end)

            armClickConn = RunService.Heartbeat:Connect(function()
                if not armClickEnabled or not clickReq then return end
                pcall(function()
                    local gui = player:FindFirstChild("PlayerGui")
                    local minigameGui = gui and gui:FindFirstChild("MinigameGui")
                    local armGui = minigameGui and minigameGui:FindFirstChild("ArmWrestlingGui")
                    if armGui and armGui.Visible then
                        clickReq:FireServer()
                    end
                end)
            end)
            WindUI:Notify({ Title = "自动点击发力", Content = "已开启", Duration = 3 })
        else
            if armClickConn then armClickConn:Disconnect() armClickConn = nil end
            WindUI:Notify({ Title = "自动点击发力", Content = "已关闭", Duration = 3 })
        end
    end
})

MinigameTab:Toggle({
    Title = "自动QTE",
    Desc = "【实战未测试】自动完成滑块判定（部分环境可能无效）",
    Default = false,
    Callback = function(state)
        armQteEnabled = state
        if state then
            local chalRes = nil
            task.spawn(function()
                while not chalRes do
                    task.wait(1)
                    local remotes = ReplicatedStorage:FindFirstChild("DataRemotes")
                    if remotes then
                        local arm = remotes:FindFirstChild("ArmWrestling")
                        if arm and arm:FindFirstChild("ChallengeResponse") then chalRes = arm.ChallengeResponse end
                    end
                end
            end)

            armQteConn = RunService.Heartbeat:Connect(function()
                if not armQteEnabled or not chalRes then return end
                pcall(function()
                    local gui = player:FindFirstChild("PlayerGui")
                    local minigameGui = gui and gui:FindFirstChild("MinigameGui")
                    local armGui = minigameGui and minigameGui:FindFirstChild("ArmWrestlingGui")
                    if armGui then
                        local panel = armGui:FindFirstChild("Panel")
                        local sliderChallenge = panel and panel:FindFirstChild("SliderChallenge")
                        if sliderChallenge and sliderChallenge.Visible then
                            chalRes:FireServer()
                            task.wait(0.3)
                        end
                    end
                end)
            end)
            WindUI:Notify({ Title = "自动QTE", Content = "已开启", Duration = 3 })
        else
            if armQteConn then armQteConn:Disconnect() armQteConn = nil end
            WindUI:Notify({ Title = "自动QTE", Content = "已关闭", Duration = 3 })
        end
    end
})

-- ==========================================
-- 标签页7：设置
-- ==========================================
local SettingsTab = Window:Tab({ Title = "设置", Icon = "settings" })

SettingsTab:Slider({
    Title = "悬浮球大小", Desc = "像素尺寸",
    Icon = "circle",
    Value = { Min = 24, Max = 80, Default = currentBallSize },
    Step = 1,
    Callback = function(v)
        currentBallSize = v
        ball.Size = UDim2.fromOffset(v, v)
    end,
})

SettingsTab:Dropdown({
    Title = "悬浮球形状", Desc = "圆球或方形",
    Icon = "square",
    Values = { "圆形", "圆角方形", "方形" },
    Value = "圆形",
    Callback = function(v)
        local c
        if v == "圆形" then c = UDim.new(1, 0)
        elseif v == "圆角方形" then c = UDim.new(0, 10)
        else c = UDim.new(0, 0) end
        ballCorner.CornerRadius = c
        pulseCorner.CornerRadius = c
    end,
})

SettingsTab:Divider()

local themePresets = {
    ["🌸 樱花粉紫"] = { "#ff6ec7", "#7873f5", "#ff6ec7" },
    ["🌊 海洋蓝青"] = { "#00d4ff", "#0066ff", "#00d4ff" },
    ["🍀 森林翠绿"] = { "#4ade80", "#16a34a", "#4ade80" },
    ["🌙 魔法深紫"] = { "#b57edc", "#6a0dad", "#b57edc" },
    ["🔥 火焰红橙"] = { "#ff4500", "#ffb347", "#ff4500" },
    ["❄️ 冷淡白灰"] = { "#e0e0e0", "#888888", "#cccccc" },
    ["🌌 赛博霓虹"] = { "#ff0055", "#00f5ff", "#ff00ff" },
    ["🍊 日落橙黄"] = { "#ff8c42", "#ffd23f", "#ff8c42" },
    ["🍇 葡萄深紫"] = { "#a855f7", "#6b21a8", "#a855f7" },
    ["💚 薄荷绿" ] = { "#34d399", "#059669", "#34d399" },
}

SettingsTab:Dropdown({
    Title = "主题预设", Desc = "选择配色方案",
    Icon = "palette",
    Values = { "🌸 樱花粉紫", "🌊 海洋蓝青", "🍀 森林翠绿", "🌙 魔法深紫", "🔥 火焰红橙", "❄️ 冷淡白灰", "🌌 赛博霓虹", "🍊 日落橙黄", "🍇 葡萄深紫", "💚 薄荷绿" },
    Value = "🌸 樱花粉紫",
    Callback = function(v)
        local preset = themePresets[v]
        if not preset then return end
        WindUI.Themes["AnimeGlass"] = BuildTheme(preset[1], preset[2], preset[3])
        WindUI:SetTheme("AnimeGlass")
        strokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex(preset[1])),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex(preset[2])),
            ColorSequenceKeypoint.new(1, Color3.fromHex(preset[1])),
        })
        WindUI:Notify({ Title = "🎨 主题", Content = "已切换到 " .. v, Duration = 2 })
    end,
})

SettingsTab:Divider()

SettingsTab:Slider({
    Title = "元素透明度", Desc = "组件背景透明程度",
    Icon = "blend",
    Value = { Min = 0, Max = 0.95, Default = 0.88 },
    Step = 0.01,
    Callback = function(v)
        WindUI.Themes["AnimeGlass"].ElementBackgroundTransparency = v
        WindUI.Themes["AnimeGlass"].PanelBackgroundTransparency = math.min(v + 0.06, 0.98)
        WindUI.Themes["AnimeGlass"].LabelBackgroundTransparency = math.min(v + 0.02, 0.98)
        WindUI:SetTheme("AnimeGlass")
    end,
})

SettingsTab:Slider({
    Title = "面板透明度", Desc = "右侧面板背景透明度",
    Icon = "layers",
    Value = { Min = 0, Max = 0.98, Default = 0.94 },
    Step = 0.01,
    Callback = function(v)
        WindUI.Themes["AnimeGlass"].PanelBackgroundTransparency = v
        WindUI:SetTheme("AnimeGlass")
    end,
})

SettingsTab:Slider({
    Title = "整体缩放", Desc = "窗口大小缩放",
    Icon = "maximize",
    Value = { Min = 0.5, Max = 1.5, Default = 1 },
    Step = 0.05,
    Callback = function(v) pcall(function() Window:SetUIScale(v) end) end,
})

SettingsTab:Toggle({
    Title = "毛玻璃效果", Desc = "开启 3D 模糊背景",
    Icon = "droplet", Value = true,
    Callback = function(v) pcall(function() WindUI:ToggleAcrylic(v) end) end,
})

SettingsTab:Toggle({
    Title = "窗口透明", Desc = "背景本身半透明",
    Icon = "eye", Value = true,
    Callback = function(v) pcall(function() Window:ToggleTransparency(v) end) end,
})

SettingsTab:Divider()

SettingsTab:Button({
    Title = "恢复默认设置", Desc = "点击重置所有设置",
    Icon = "rotate-ccw", Variant = "Secondary",
    Callback = function()
        WindUI.Themes["AnimeGlass"] = BuildTheme("#ff6ec7", "#7873f5", "#ff6ec7")
        WindUI:SetTheme("AnimeGlass")

        currentBallSize = 38
        ball.Size = UDim2.fromOffset(38, 38)
        ballCorner.CornerRadius = UDim.new(1, 0)
        pulseCorner.CornerRadius = UDim.new(1, 0)

        strokeGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#ff6ec7")),
            ColorSequenceKeypoint.new(0.5, Color3.fromHex("#7873f5")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#ff6ec7")),
        })

        pcall(function() WindUI:ToggleAcrylic(true) end)

        WindUI:Notify({ Title = "🔄 重置", Content = "已恢复默认（缩放请到「整体缩放」调）", Duration = 3 })
    end,
})

Window:SelectTab(1)

task.spawn(function()
    task.wait(2)
    local hiddenContainer = gethui and gethui() or game:GetService("CoreGui")
    for _, gui in ipairs(hiddenContainer:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local name = gui.Name
            if string.find(name, "WindUI") or string.find(name, "Anime") then
                gui.Name = "Setting_" .. math.random(100000, 999999)
            end
        end
    end
    local pGui = player:FindFirstChild("PlayerGui")
    if pGui then
        for _, gui in ipairs(pGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (string.find(gui.Name, "Anime") or gui.Name == "AnimeFloatBall") then
                gui.Parent = hiddenContainer
                gui.Name = "Float_" .. math.random(100000, 999999)
            end
        end
    end
end)