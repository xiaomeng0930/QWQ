if not getgenv().TSB_AntilagLoaded then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/HaTapLamScript/MAMBO-PROJECT/refs/heads/main/Script/TSB/Antilag.lua"))()
    getgenv().TSB_AntilagLoaded = true
end

local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local plr = Players.LocalPlayer

if getgenv().TSB_Cleanup then pcall(getgenv().TSB_Cleanup) end

local CONFIG = {
    OffsetX = -5.17,
    OffsetY = -6,      
    OffsetZ = 0.84,
    AutoDoor = true,
    AutoCandy = true,
    AutoPumpkin = false,
    SkillCd = 5
}

local isPaused = false
local ui = nil
local mainThread = nil
local listenThread = nil
local timerThread = nil
local promptConnection = nil
local lockConnection = nil
local lockedCFrame = nil 
local statsLabel = nil
local timeLabel = nil
local mainFrame = nil
local isMinimized = false

local TotalCandies = 0
local TargetCandyLabel = nil 
local LastKnownValue = 0 
local IgnoredCandies = {} 
local StartTime = tick() 

local isSwitching = false
local skillCooldowns = {0, 0, 0, 0}
local lastAttackTime = 0
local lastDeathTime = 0
local skillNames = {"Bullet Barrage", "Vanishing Kick", "Whirlwind Drop", "Head First"}

local function checkIsPurple()
    local char = plr.Character
    local bp = plr:FindFirstChild("Backpack")
    if char and (char:FindFirstChild("Bullet Barrage") or char:FindFirstChild("Vanishing Kick")) then return true end
    if bp and (bp:FindFirstChild("Bullet Barrage") or bp:FindFirstChild("Vanishing Kick")) then return true end
    return false
end

local function switchToPurple()
    local char = plr.Character
    local comm = char and char:FindFirstChild("Communicate")
    if comm then
        pcall(function()
            comm:FireServer({Goal = "Change Character", Character = "Purple"})
        end)
    end
end

local function getGuiParent()
    if gethui then
        local ok, res = pcall(gethui)
        if ok and res then return res end
    end
    if syn and syn.protect_gui then
        local newGui = Instance.new("ScreenGui")
        syn.protect_gui(newGui)
        newGui.Parent = game:GetService("CoreGui")
        return newGui
    end
    return game:GetService("CoreGui")
end

local function DestroyAll()
    isPaused = true
    lockedCFrame = nil
    if mainThread then pcall(task.cancel, mainThread); mainThread = nil end
    if listenThread then pcall(task.cancel, listenThread); listenThread = nil end
    if timerThread then pcall(task.cancel, timerThread); timerThread = nil end
    if promptConnection then promptConnection:Disconnect(); promptConnection = nil end
    if lockConnection then lockConnection:Disconnect(); lockConnection = nil end
    if ui then ui:Destroy(); ui = nil end
end
getgenv().TSB_Cleanup = DestroyAll

lockConnection = RunService.Heartbeat:Connect(function()
    if isPaused then return end
    if not CONFIG.AutoCandy and not CONFIG.AutoDoor and not CONFIG.AutoPumpkin then return end
    
    local char = plr.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            if lockedCFrame then
                hrp.CFrame = lockedCFrame
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

local function ParseNumber(text)
    if not text or text == "" then return 0 end
    text = string.gsub(text, ",", "")
    text = string.upper(text)
    local k = string.match(text, "([%d%.]+)K")
    if k then return tonumber(k) * 1000 end
    local m = string.match(text, "([%d%.]+)M")
    if m then return tonumber(m) * 1000000 end
    return tonumber(text) or 0
end

local function InitTargetLabel()
    local PlayerGui = plr:FindFirstChild("PlayerGui")
    if PlayerGui then
        local CandyCounter = PlayerGui:FindFirstChild("CandyCounter")
        if CandyCounter then
            local Counter = CandyCounter:FindFirstChild("Counter")
            if Counter then
                local Row = Counter:FindFirstChild("Row")
                if Row then
                    TargetCandyLabel = Row:FindFirstChild("Count")
                    if TargetCandyLabel then
                        LastKnownValue = ParseNumber(TargetCandyLabel.Text)
                    end
                end
            end
        end
    end
end

local function UpdateStatsUI()
    if statsLabel and statsLabel.Parent then
        if TargetCandyLabel and TargetCandyLabel.Parent then
            statsLabel.Text = string.format("已拾取糖果: %d", TotalCandies)
            statsLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        else
            statsLabel.Text = "等待读取数据..."
            statsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        end
    end
end

local function BuildUI()
    if ui then ui:Destroy() end
    ui = Instance.new("ScreenGui")
    ui.Name = "TSB_Candy_Farm"
    ui.ResetOnSpawn = false
    ui.DisplayOrder = 999
    ui.Parent = getGuiParent()

    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 220, 0, 215)
    mainFrame.Position = UDim2.new(0, 50, 0.5, -107)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = ui

    local uiCorner = Instance.new("UICorner", mainFrame); uiCorner.CornerRadius = UDim.new(0, 8)
    local uiStroke = Instance.new("UIStroke", mainFrame); uiStroke.Color = Color3.fromRGB(60, 60, 65); uiStroke.Thickness = 1.5

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    local titleCorner = Instance.new("UICorner", titleBar); titleCorner.CornerRadius = UDim.new(0, 8)

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -70, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "  TSB刷糖果 | by.小梦"
    titleText.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 14
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    local foldBtn = Instance.new("TextButton")
    foldBtn.Size = UDim2.new(0, 30, 0, 30)
    foldBtn.Position = UDim2.new(1, -65, 0, 3)
    foldBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    foldBtn.Text = "-"
    foldBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    foldBtn.Font = Enum.Font.GothamBold
    foldBtn.TextSize = 18
    foldBtn.Parent = titleBar
    local foldCorner = Instance.new("UICorner", foldBtn); foldCorner.CornerRadius = UDim.new(0, 4)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 3)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(DestroyAll)

    foldBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 220, 0, 36) or UDim2.new(0, 220, 0, 215)
        TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        foldBtn.Text = isMinimized and "+" or "-"
    end)

    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = mainFrame.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(1, -20, 0, 20)
    statsLabel.Position = UDim2.new(0, 10, 0, 42)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Text = "等待读取数据..."
    statsLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextSize = 13
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = mainFrame

    timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -20, 0, 16)
    timeLabel.Position = UDim2.new(0, 10, 0, 62)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = "已运行: 00:00:00"
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.Font = Enum.Font.GothamMedium
    timeLabel.TextSize = 12
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = mainFrame

    local function createToggle(name, yPos, defaultState, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 30); btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = defaultState and Color3.fromRGB(40, 150, 90) or Color3.fromRGB(50, 50, 55)
        btn.Text = "  " .. name .. (defaultState and " [开启]" or " [关闭]")
        btn.TextColor3 = Color3.fromRGB(240, 240, 240); btn.Font = Enum.Font.Gotham; btn.TextSize = 13; btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = mainFrame
        local c = Instance.new("UICorner", btn); c.CornerRadius = UDim.new(0, 6)
        local state = defaultState
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(40, 150, 90) or Color3.fromRGB(50, 50, 55)
            btn.Text = "  " .. name .. (state and " [开启]" or " [关闭]")
            callback(state)
        end)
    end

    createToggle("自动敲门", 85, CONFIG.AutoDoor, function(s) 
        CONFIG.AutoDoor = s 
        if not s and not CONFIG.AutoCandy and not CONFIG.AutoPumpkin then lockedCFrame = nil end
    end)
    createToggle("全图捡糖", 120, CONFIG.AutoCandy, function(s) 
        CONFIG.AutoCandy = s 
        if not s and not CONFIG.AutoDoor and not CONFIG.AutoPumpkin then lockedCFrame = nil end
    end)
    createToggle("自动打南瓜人", 155, CONFIG.AutoPumpkin, function(s) 
        CONFIG.AutoPumpkin = s 
        if not s and not CONFIG.AutoCandy and not CONFIG.AutoDoor then lockedCFrame = nil end
        if s then
            isSwitching = false
            lastDeathTime = 0
        end
    end)
end

promptConnection = ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
    if prompt.Name == "TrickOrTreat" and prompt:IsDescendantOf(workspace:FindFirstChild("HalloweenDoorTrees") or game) then
        prompt.HoldDuration = 0
    end
end)

local function GetGlobalCandyTarget()
    local folder = workspace:FindFirstChild("CandyVisuals")
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not folder or not hrp then return nil end
    
    local closestCandy = nil
    local minDist = math.huge

    for _, c in ipairs(folder:GetChildren()) do
        if c:IsA("BasePart") and c.Name ~= "Burst" and not IgnoredCandies[c] then
            if c.Transparency < 0.9 then
                if c.Position.Y > -50 and c.Position.Y < 500 then
                    local dist = (Vector3.new(c.Position.X, 0, c.Position.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestCandy = c
                    end
                end
            end
        end
    end
    return closestCandy
end

local function getNextDoor()
    local folder = workspace:FindFirstChild("HalloweenDoorTrees")
    if not folder then return nil end
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local bestDoor, bestDist = nil, math.huge
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Name == "TrickOrTreat" then
            local frame = obj.Parent
            if frame and frame:IsA("BasePart") then
                local dist = (frame.Position - hrp.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestDoor = { prompt = obj, part = frame }
                end
            end
        end
    end
    return bestDoor
end

local function useSkill(index, npcCFrame)
    local char = plr.Character
    local bp = plr:FindFirstChild("Backpack")
    local comm = char and char:FindFirstChild("Communicate")
    if not comm or not bp then return false end
    
    local tool = bp:FindFirstChild(skillNames[index])
    if tool then
        pcall(function()
            comm:FireServer({IsAutoActivate = true, Goal = "Console Move", Tool = tool})
            task.wait(0.05)
            comm:FireServer({Goal = "Auto Use End", Tool = tool})
        end)
        skillCooldowns[index] = tick() + CONFIG.SkillCd
        return true
    end
    return false
end

local function useBasicAttack(npcCFrame)
    local char = plr.Character
    local comm = char and char:FindFirstChild("Communicate")
    if comm then
        pcall(function()
            comm:FireServer({Tick = 1, Mobile = true, Goal = "LeftClick", MousePos = npcCFrame})
            task.wait(0.05)
            comm:FireServer({Mobile = true, Goal = "LeftClickRelease", Tick = 1})
        end)
        lastAttackTime = tick()
    end
end

local function StartListening()
    listenThread = task.spawn(function()
        while not isPaused do
            task.wait(0.05) 
            if not TargetCandyLabel or not TargetCandyLabel.Parent then InitTargetLabel() end
            if TargetCandyLabel and TargetCandyLabel.Parent then
                local currentVal = ParseNumber(TargetCandyLabel.Text)
                if currentVal > LastKnownValue then
                    TotalCandies = TotalCandies + (currentVal - LastKnownValue)
                    UpdateStatsUI()
                end
                LastKnownValue = currentVal 
            end
        end
    end)
end

local function StartTimer()
    timerThread = task.spawn(function()
        while not isPaused do
            task.wait(1)
            if timeLabel and timeLabel.Parent then
                local elapsed = math.floor(tick() - StartTime)
                local hours = math.floor(elapsed / 3600)
                local mins = math.floor((elapsed % 3600) / 60)
                local secs = elapsed % 60
                timeLabel.Text = string.format("已运行: %02d:%02d:%02d", hours, mins, secs)
            end
        end
    end)
end

local function MainLogic()
    InitTargetLabel()
    
    while not isPaused do
        task.wait(0.05)
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then
            local candy = nil
            if CONFIG.AutoCandy then
                candy = GetGlobalCandyTarget()
            end

            if candy then
                local candyPos = candy.Position
                lockedCFrame = CFrame.new(candyPos.X, candyPos.Y + CONFIG.OffsetY, candyPos.Z)
                
                pcall(function()
                    firetouchinterest(hrp, candy, 0)
                    task.wait(0.05)
                    firetouchinterest(hrp, candy, 1)
                end)
                
                task.wait(0.1)
                
                if candy and candy.Parent and candy.Transparency < 0.9 then
                    IgnoredCandies[candy] = true
                end
            else
                local target = nil
                if CONFIG.AutoPumpkin then
                    local live = workspace:FindFirstChild("Live")
                    target = live and live:FindFirstChild("Penyta")
                end

                if target and target.Parent and target:FindFirstChildOfClass("Humanoid") and target.Humanoid.Health > 0 then
                    if not checkIsPurple() then
                        if not isSwitching and tick() - lastDeathTime > 8 then
                            isSwitching = true
                            lastDeathTime = tick()
                            pcall(function() hum.Health = 0 end)
                        end
                        lockedCFrame = nil
                    else
                        isSwitching = false
                        local npcHRP = target:FindFirstChild("HumanoidRootPart")
                        if npcHRP and npcHRP.Parent then
                            local targetPos = npcHRP.Position - npcHRP.CFrame.LookVector * 2.5
                            lockedCFrame = CFrame.lookAt(targetPos, npcHRP.Position)
                            
                            local currentTick = tick()
                            local used = false
                            
                            for i = 1, 4 do
                                if currentTick > skillCooldowns[i] then
                                    if useSkill(i, npcHRP.CFrame) then
                                        used = true
                                        break
                                    end
                                end
                            end
                            
                            if not used and currentTick - lastAttackTime > 0.3 then
                                useBasicAttack(npcHRP.CFrame)
                            end
                        end
                    end
                else
                    if CONFIG.AutoDoor then
                        local door = getNextDoor()
                        if door then
                            local standPos = (door.part.CFrame * CFrame.new(CONFIG.OffsetX, 0, CONFIG.OffsetZ)).Position
                            local doorCFrame = CFrame.new(standPos.X, door.part.Position.Y + CONFIG.OffsetY, standPos.Z)
                            
                            door.prompt.RequiresLineOfSight = false
                            door.prompt.MaxActivationDistance = math.huge
                            door.prompt.HoldDuration = 0
                            door.prompt.Enabled = true

                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("ProximityPrompt") and obj.Name ~= "TrickOrTreat" then
                                    local p = obj.Parent
                                    if p and p:IsA("BasePart") then
                                        if (p.Position - standPos).Magnitude < 20 then
                                            obj.Enabled = false
                                        end
                                    end
                                end
                            end

                            local timeout = os.clock() + 2
                            while os.clock() < timeout and not isPaused do
                                lockedCFrame = doorCFrame
                                hrp.CFrame = doorCFrame
                                
                                if CONFIG.AutoCandy and GetGlobalCandyTarget() then break end
                                if CONFIG.AutoPumpkin then
                                    local live = workspace:FindFirstChild("Live")
                                    local p = live and live:FindFirstChild("Penyta")
                                    if p and p:FindFirstChildOfClass("Humanoid") and p.Humanoid.Health > 0 then break end
                                end
                                if not door.part or not door.part.Parent or not door.prompt or not door.prompt.Parent then break end
                                
                                if door.prompt.Enabled then
                                    if fireproximityprompt then
                                        pcall(fireproximityprompt, door.prompt)
                                    end
                                    pcall(function() 
                                        door.prompt:InputHoldBegin()
                                        task.wait(0.05)
                                        door.prompt:InputHoldEnd() 
                                    end)
                                end
                                task.wait(0.05)
                            end

                            if not isPaused then
                                local waitStart = os.clock()
                                while (os.clock() - waitStart < 1.5) and not isPaused do
                                    if CONFIG.AutoCandy and GetGlobalCandyTarget() then break end
                                    if CONFIG.AutoPumpkin then
                                        local live = workspace:FindFirstChild("Live")
                                        local p = live and live:FindFirstChild("Penyta")
                                        if p and p:FindFirstChildOfClass("Humanoid") and p.Humanoid.Health > 0 then break end
                                    end
                                    task.wait(0.1)
                                end
                            end
                        else
                            lockedCFrame = nil
                        end
                    else
                        lockedCFrame = nil
                    end
                end
            end
        else
            lockedCFrame = nil
            task.wait(0.5)
        end
    end
end

local function StartScript()
    isPaused = false
    IgnoredCandies = {}
    StartTime = tick() 
    BuildUI()
    InitTargetLabel()
    UpdateStatsUI()
    
    StartListening()
    StartTimer()
    mainThread = task.spawn(MainLogic)
end

StartScript()

plr.CharacterAdded:Connect(function(char)
    task.wait(1)
    if CONFIG.AutoPumpkin and not checkIsPurple() then
        switchToPurple()
        task.wait(1)
        if not checkIsPurple() then
            switchToPurple()
        end
    else
        isSwitching = false
    end
    
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        if isPaused then return end
        if not CONFIG.AutoPumpkin then
            DestroyAll()
            task.wait(3)
            StartScript()
        end
    end)
end)