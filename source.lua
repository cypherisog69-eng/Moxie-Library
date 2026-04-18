local Moxie = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local Themes = {
    Dark = {Main = Color3.fromRGB(16,16,16), Secondary = Color3.fromRGB(24,24,24), Accent = Color3.fromRGB(138,43,226), Text = Color3.fromRGB(255,255,255), DarkText = Color3.fromRGB(170,170,170), Gradient = nil},
    Lunar = {Main = Color3.fromRGB(10,10,30), Secondary = Color3.fromRGB(18,18,45), Accent = Color3.fromRGB(100,149,237), Text = Color3.fromRGB(220,220,255), DarkText = Color3.fromRGB(140,140,200), Gradient = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(10,10,30)),ColorSequenceKeypoint.new(1,Color3.fromRGB(30,10,60))}},
    Crimson = {Main = Color3.fromRGB(18,8,8), Secondary = Color3.fromRGB(30,12,12), Accent = Color3.fromRGB(220,20,60), Text = Color3.fromRGB(255,220,220), DarkText = Color3.fromRGB(180,130,130), Gradient = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(18,8,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(40,10,10))}},
    Ocean = {Main = Color3.fromRGB(5,20,35), Secondary = Color3.fromRGB(8,30,50), Accent = Color3.fromRGB(0,200,255), Text = Color3.fromRGB(200,240,255), DarkText = Color3.fromRGB(120,180,210), Gradient = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(5,20,35)),ColorSequenceKeypoint.new(1,Color3.fromRGB(5,40,80))}},
    Sunset = {Main = Color3.fromRGB(20,10,20), Secondary = Color3.fromRGB(30,15,30), Accent = Color3.fromRGB(255,100,50), Text = Color3.fromRGB(255,230,210), DarkText = Color3.fromRGB(200,160,140), Gradient = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(20,10,20)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(40,15,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(60,20,10))}},
    Mint = {Main = Color3.fromRGB(8,20,18), Secondary = Color3.fromRGB(12,30,26), Accent = Color3.fromRGB(0,230,150), Text = Color3.fromRGB(210,255,240), DarkText = Color3.fromRGB(130,190,170), Gradient = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(8,20,18)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,40,34))}},
    Rose = {Main = Color3.fromRGB(22,10,16), Secondary = Color3.fromRGB(34,14,24), Accent = Color3.fromRGB(255,105,180), Text = Color3.fromRGB(255,220,235), DarkText = Color3.fromRGB(200,150,175), Gradient = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(22,10,16)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(40,10,30)),ColorSequenceKeypoint.new(1,Color3.fromRGB(55,10,40))}},
}

local ActiveTheme = Themes.Dark
local Notifications = {}
local Config = {
    Name = "Moxie",
    Logo = "M",
    Loading = true,
    KeySystem = false,
    Keys = {},
    KeyFile = "MoxieKey.txt",
    Discord = "",
    KeyTitle = "Moxie | Key System",
    KeyNote = "Enter your key to continue.",
}

local function Tween(obj, prop, goal, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.25, Enum.EasingStyle.Quad), {[prop] = goal}):Play()
end

local function ApplyGradient(frame)
    if ActiveTheme.Gradient then
        local existing = frame:FindFirstChildOfClass("UIGradient")
        if existing then existing:Destroy() end
        local g = Instance.new("UIGradient")
        g.Color = ActiveTheme.Gradient
        g.Rotation = 135
        g.Parent = frame
    end
end

local function MakeDraggable(dragFrame, targetFrame)
    local dragging = false
    local dragStart, startPos
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Moxie:SetTheme(theme)
    if Themes[theme] then ActiveTheme = Themes[theme] end
end

function Moxie:SetName(name)
    Config.Name = name or "Moxie"
end

function Moxie:SetLogo(logo)
    Config.Logo = logo or "M"
end

function Moxie:EnableLoading(bool)
    Config.Loading = bool
end

function Moxie:EnableKeySystem(options)
    Config.KeySystem = options.Enabled or false
    Config.Keys = options.Keys or {}
    Config.KeyFile = options.File or "MoxieKey.txt"
    Config.Discord = options.Discord or ""
    Config.KeyTitle = options.Title or Config.Name .. " | Key System"
    Config.KeyNote = options.Note or "Enter your key to continue."
end

function Moxie:KeySystem()
    if not Config.KeySystem then return true end
    if isfile and isfile(Config.KeyFile) then
        local saved = readfile(Config.KeyFile)
        for _, k in ipairs(Config.Keys) do
            if saved == k then return true end
        end
    end
    local result = false
    local done = false
    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxieKey"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game.CoreGui
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    bg.Parent = gui
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0,420,0,280)
    panel.Position = UDim2.new(0.5,-210,0.5,-140)
    panel.BackgroundColor3 = ActiveTheme.Main
    panel.BorderSizePixel = 0
    panel.Parent = gui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0,18)
    ApplyGradient(panel)
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1,0,0,50)
    topBar.BackgroundColor3 = ActiveTheme.Secondary
    topBar.BorderSizePixel = 0
    topBar.Parent = panel
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0,18)
    local topTitle = Instance.new("TextLabel")
    topTitle.Size = UDim2.new(1,-20,1,0)
    topTitle.Position = UDim2.new(0,15,0,0)
    topTitle.BackgroundTransparency = 1
    topTitle.Text = Config.KeyTitle
    topTitle.TextColor3 = ActiveTheme.Text
    topTitle.Font = Enum.Font.GothamBold
    topTitle.TextSize = 16
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.Parent = topBar
    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1,-30,0,30)
    note.Position = UDim2.new(0,15,0,58)
    note.BackgroundTransparency = 1
    note.Text = Config.KeyNote
    note.TextColor3 = ActiveTheme.DarkText
    note.Font = Enum.Font.Gotham
    note.TextSize = 13
    note.TextWrapped = true
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Parent = panel
    local inputBg = Instance.new("Frame")
    inputBg.Size = UDim2.new(1,-30,0,40)
    inputBg.Position = UDim2.new(0,15,0,98)
    inputBg.BackgroundColor3 = ActiveTheme.Secondary
    inputBg.BorderSizePixel = 0
    inputBg.Parent = panel
    Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0,10)
    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1,-20,1,0)
    input.Position = UDim2.new(0,10,0,0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = "Enter your key here..."
    input.TextColor3 = ActiveTheme.Text
    input.PlaceholderColor3 = ActiveTheme.DarkText
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = inputBg
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,-30,0,20)
    status.Position = UDim2.new(0,15,0,145)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255,80,80)
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = panel
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(1,-30,0,40)
    submitBtn.Position = UDim2.new(0,15,0,172)
    submitBtn.BackgroundColor3 = ActiveTheme.Accent
    submitBtn.Text = "Submit Key"
    submitBtn.TextColor3 = Color3.fromRGB(255,255,255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 14
    submitBtn.Parent = panel
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0,10)
    local discord = Instance.new("TextLabel")
    discord.Size = UDim2.new(1,-30,0,20)
    discord.Position = UDim2.new(0,15,0,220)
    discord.BackgroundTransparency = 1
    discord.Text = Config.Discord ~= "" and "Get a key: " .. Config.Discord or ""
    discord.TextColor3 = ActiveTheme.DarkText
    discord.Font = Enum.Font.Gotham
    discord.TextSize = 12
    discord.TextXAlignment = Enum.TextXAlignment.Center
    discord.Parent = panel
    submitBtn.MouseButton1Click:Connect(function()
        local entered = input.Text
        local valid = false
        for _, k in ipairs(Config.Keys) do
            if entered == k then valid = true break end
        end
        if valid then
            if writefile then writefile(Config.KeyFile, entered) end
            status.TextColor3 = Color3.fromRGB(0,230,100)
            status.Text = "Key accepted!"
            Tween(submitBtn, "BackgroundColor3", Color3.fromRGB(0,200,80), 0.3)
            task.wait(1)
            result = true
            done = true
            gui:Destroy()
        else
            status.Text = "Invalid key."
            Tween(inputBg, "BackgroundColor3", Color3.fromRGB(80,20,20), 0.1)
            task.delay(0.3, function() Tween(inputBg, "BackgroundColor3", ActiveTheme.Secondary, 0.3) end)
        end
    end)
    repeat task.wait() until done
    return result
end

function Moxie:LoadingScreen()
    if not Config.Loading then return end
    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxieLoading"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(8,8,8)
    bg.BorderSizePixel = 0
    bg.Parent = gui
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(8,8,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(25,8,40))}
    bgGrad.Rotation = 135
    bgGrad.Parent = bg
    local particles = {}
    for i = 1, 20 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0,math.random(3,6),0,math.random(3,6))
        p.Position = UDim2.new(math.random(),0,math.random(),0)
        p.BackgroundColor3 = ActiveTheme.Accent
        p.BackgroundTransparency = 0.6
        p.BorderSizePixel = 0
        p.Parent = bg
        Instance.new("UICorner",p).CornerRadius = UDim.new(1,0)
        table.insert(particles, p)
    end
    local ring1 = Instance.new("Frame")
    ring1.Size = UDim2.new(0,200,0,200)
    ring1.Position = UDim2.new(0.5,-100,0.5,-140)
    ring1.BackgroundTransparency = 1
    ring1.Parent = bg
    local ring1Img = Instance.new("ImageLabel")
    ring1Img.Size = UDim2.new(1,0,1,0)
    ring1Img.BackgroundTransparency = 1
    ring1Img.Image = "rbxassetid://7076348532"
    ring1Img.ImageColor3 = ActiveTheme.Accent
    ring1Img.ImageTransparency = 0.3
    ring1Img.Parent = ring1
    local logo = Instance.new("Frame")
    logo.Size = UDim2.new(0,90,0,90)
    logo.Position = UDim2.new(0.5,-45,0.5,-105)
    logo.BackgroundColor3 = ActiveTheme.Accent
    logo.BackgroundTransparency = 0.8
    logo.BorderSizePixel = 0
    logo.Parent = bg
    Instance.new("UICorner",logo).CornerRadius = UDim.new(0,20)
    local logoGrad = Instance.new("UIGradient")
    logoGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,ActiveTheme.Accent)}
    logoGrad.Rotation = 45
    logoGrad.Parent = logo
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1,0,1,0)
    logoText.BackgroundTransparency = 1
    logoText.Text = Config.Logo
    logoText.TextColor3 = Color3.new(1,1,1)
    logoText.Font = Enum.Font.GothamBold
    logoText.TextSize = 48
    logoText.Parent = logo
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0,400,0,55)
    nameLabel.Position = UDim2.new(0.5,-200,0.5,22)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = Config.Name
    nameLabel.TextColor3 = Color3.new(1,1,1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 44
    nameLabel.TextTransparency = 1
    nameLabel.Parent = bg
    local nameGrad = Instance.new("UIGradient")
    nameGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,ActiveTheme.Accent),ColorSequenceKeypoint.new(0.5,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,ActiveTheme.Accent)}
    nameGrad.Parent = nameLabel
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0,340,0,5)
    barBg.Position = UDim2.new(0.5,-170,0.5,120)
    barBg.BackgroundColor3 = Color3.fromRGB(30,30,30)
    barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0
    barBg.Parent = bg
    Instance.new("UICorner",barBg).CornerRadius = UDim.new(1,0)
    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.BackgroundColor3 = ActiveTheme.Accent
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner",barFill).CornerRadius = UDim.new(1,0)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0,340,0,20)
    statusLabel.Position = UDim2.new(0.5,-170,0.5,133)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = ActiveTheme.DarkText
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.TextTransparency = 1
    statusLabel.Parent = bg
    local conn = RunService.RenderStepped:Connect(function(dt)
        ring1.Rotation = ring1.Rotation + 60 * dt
        logo.Rotation = logo.Rotation + 10 * dt
        nameGrad.Offset = Vector2.new(math.sin(tick()) * 0.5, 0)
        for _, p in ipairs(particles) do
            p.Position = UDim2.new(p.Position.X.Scale, 0, p.Position.Y.Scale - 0.0003, 0)
            if p.Position.Y.Scale < -0.05 then
                p.Position = UDim2.new(math.random(), 0, 1.05, 0)
            end
        end
    end)
    local completed = false
    task.spawn(function()
        task.wait(0.3)
        TweenService:Create(nameLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        task.wait(0.5)
        TweenService:Create(barBg, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(statusLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        task.wait(0.5)
        local steps = {
            {text = "Initializing " .. Config.Name .. "...", p = 0.2},
            {text = "Loading Modules...", p = 0.4},
            {text = "Applying Theme...", p = 0.6},
            {text = "Building Interface...", p = 0.85},
            {text = "Ready!", p = 1.0},
        }
        for _, step in ipairs(steps) do
            statusLabel.Text = step.text
            TweenService:Create(barFill, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(step.p,0,1,0)}):Play()
            task.wait(0.45)
        end
        task.wait(0.4)
        TweenService:Create(nameLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(statusLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(logoText, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        TweenService:Create(ring1Img, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(logo, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        TweenService:Create(barBg, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        for _, p in ipairs(particles) do
            TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        end
        task.wait(0.4)
        TweenService:Create(bg, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        task.wait(0.7)
        conn:Disconnect()
        gui:Destroy()
        completed = true
    end)
    repeat task.wait() until completed
end

function Moxie:Notify(title, text, duration)
    duration = duration or 4
    local gui = game.CoreGui:FindFirstChild("MoxieUI") or Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "MoxieUI"
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,300,0,75)
    frame.Position = UDim2.new(1,20,1,-95 - (#Notifications * 85))
    frame.BackgroundColor3 = ActiveTheme.Main
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)
    ApplyGradient(frame)
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0,3,1,-16)
    accent.Position = UDim2.new(0,0,0,8)
    accent.BackgroundColor3 = ActiveTheme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = frame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1,0)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1,-16,0,22)
    t.Position = UDim2.new(0,12,0,8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = ActiveTheme.Accent
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = frame
    local d = Instance.new("TextLabel")
    d.Size = UDim2.new(1,-16,0,36)
    d.Position = UDim2.new(0,12,0,30)
    d.BackgroundTransparency = 1
    d.Text = text
    d.TextColor3 = ActiveTheme.Text
    d.Font = Enum.Font.Gotham
    d.TextSize = 12
    d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Parent = frame
    table.insert(Notifications, frame)
    Tween(frame, "Position", UDim2.new(1,-320,1,-95 - ((#Notifications-1)*85)), 0.5)
    task.delay(duration, function()
        Tween(frame, "Position", UDim2.new(1,20,1,frame.Position.Y.Offset), 0.5)
        task.wait(0.6)
        frame:Destroy()
        table.remove(Notifications, table.find(Notifications, frame))
    end)
end

function Moxie:CreateWindow(title)
    local Window = {}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MoxieUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0,620,0,440)
    Main.Position = UDim2.new(0.5,-310,0.5,-220)
    Main.BackgroundColor3 = ActiveTheme.Main
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)
    ApplyGradient(Main)

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1,0,0,50)
    TitleBar.BackgroundColor3 = ActiveTheme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 5
    TitleBar.Parent = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,14)

    local TitleAccent = Instance.new("Frame")
    TitleAccent.Size = UDim2.new(0,3,0,22)
    TitleAccent.Position = UDim2.new(0,12,0.5,-11)
    TitleAccent.BackgroundColor3 = ActiveTheme.Accent
    TitleAccent.BorderSizePixel = 0
    TitleAccent.ZIndex = 5
    TitleAccent.Parent = TitleBar
    Instance.new("UICorner", TitleAccent).CornerRadius = UDim.new(1,0)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1,-100,1,0)
    TitleLabel.Position = UDim2.new(0,22,0,0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or Config.Name
    TitleLabel.TextColor3 = ActiveTheme.Text
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 5
    TitleLabel.Parent = TitleBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0,28,0,28)
    MinBtn.Position = UDim2.new(1,-66,0.5,-14)
    MinBtn.BackgroundColor3 = ActiveTheme.Main
    MinBtn.Text = "-"
    MinBtn.TextColor3 = ActiveTheme.DarkText
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.ZIndex = 5
    MinBtn.Parent = TitleBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,8)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0,28,0,28)
    CloseBtn.Position = UDim2.new(1,-34,0.5,-14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200,40,40)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.new(1,1,1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.ZIndex = 5
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,8)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, "Size", UDim2.new(0,620,0,0), 0.4)
        task.wait(0.5)
        ScreenGui:Destroy()
    end)

    local Body = Instance.new("Frame")
    Body.Name = "Body"
    Body.Size = UDim2.new(1,0,1,-50)
    Body.Position = UDim2.new(0,0,0,50)
    Body.BackgroundTransparency = 1
    Body.ClipsDescendants = true
    Body.Parent = Main

    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Tween(Main, "Size", minimized and UDim2.new(0,620,0,50) or UDim2.new(0,620,0,440), 0.4)
    end)

    MakeDraggable(TitleBar, Main)

    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Size = UDim2.new(0,155,1,-30)
    TabBar.Position = UDim2.new(0,0,0,30)
    TabBar.BackgroundColor3 = ActiveTheme.Secondary
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 2
    TabBar.CanvasSize = UDim2.new(0,0,0,0)
    TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabBar.Parent = Body

    local TabLayout = Instance.new("UIListLayout", TabBar)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0,4)

    local TabPad = Instance.new("UIPadding", TabBar)
    TabPad.PaddingTop = UDim.new(0,4)
    TabPad.PaddingLeft = UDim.new(0,5)
    TabPad.PaddingRight = UDim.new(0,5)
    TabPad.PaddingBottom = UDim.new(0,4)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0,155,0,26)
    SearchBox.Position = UDim2.new(0,0,0,0)
    SearchBox.BackgroundColor3 = ActiveTheme.Secondary
    SearchBox.BorderSizePixel = 0
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.TextColor3 = ActiveTheme.Text
    SearchBox.PlaceholderColor3 = ActiveTheme.DarkText
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.Parent = Body
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0,6)

    local DropdownHolder = Instance.new("Frame")
    DropdownHolder.Name = "DropdownHolder"
    DropdownHolder.Size = UDim2.new(1,0,1,0)
    DropdownHolder.BackgroundTransparency = 1
    DropdownHolder.ZIndex = 100
    DropdownHolder.Parent = ScreenGui

    Window.CurrentTab = nil
    Window.AllElements = {}

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = SearchBox.Text:lower()
        for _, e in ipairs(Window.AllElements) do
            if e.Instance and e.Name then
                e.Instance.Visible = q == "" or e.Name:lower():find(q) ~= nil
            end
        end
    end)

    function Window:CreateTab(name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1,0,0,36)
        TabBtn.BackgroundColor3 = ActiveTheme.Main
        TabBtn.Text = name
        TabBtn.TextColor3 = ActiveTheme.DarkText
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.TextSize = 13
        TabBtn.Parent = TabBar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1,-163,1,0)
        Page.Position = UDim2.new(0,163,0,0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0,0,0,0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = Body

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0,7)

        local PagePad = Instance.new("UIPadding", Page)
        PagePad.PaddingTop = UDim.new(0,6)
        PagePad.PaddingRight = UDim.new(0,8)
        PagePad.PaddingBottom = UDim.new(0,6)
        PagePad.PaddingLeft = UDim.new(0,4)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Button, "BackgroundColor3", ActiveTheme.Main, 0.2)
                Window.CurrentTab.Button.TextColor3 = ActiveTheme.DarkText
            end
            Page.Visible = true
            Tween(TabBtn, "BackgroundColor3", ActiveTheme.Accent, 0.2)
            TabBtn.TextColor3 = ActiveTheme.Text
            Window.CurrentTab = {Button = TabBtn, Page = Page}
        end)

        if not Window.CurrentTab then
            Page.Visible = true
            Tween(TabBtn, "BackgroundColor3", ActiveTheme.Accent, 0.2)
            TabBtn.TextColor3 = ActiveTheme.Text
            Window.CurrentTab = {Button = TabBtn, Page = Page}
        end

        local Tab = {}

        local function Register(n, inst)
            table.insert(Window.AllElements, {Name = n, Instance = inst})
        end

        function Tab:CreateSection(text)
            local section = Instance.new("Frame")
            section.Size = UDim2.new(1,0,0,22)
            section.BackgroundTransparency = 1
            section.Parent = Page
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1,0,0,1)
            line.Position = UDim2.new(0,0,0.5,0)
            line.BackgroundColor3 = ActiveTheme.Accent
            line.BackgroundTransparency = 0.6
            line.BorderSizePixel = 0
            line.Parent = section
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0,0,1,0)
            label.AutomaticSize = Enum.AutomaticSize.X
            label.Position = UDim2.new(0,6,0,0)
            label.BackgroundColor3 = ActiveTheme.Main
            label.Text = "  " .. text .. "  "
            label.TextColor3 = ActiveTheme.Accent
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.Parent = section
        end

        function Tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1,0,0,30)
            label.BackgroundColor3 = ActiveTheme.Secondary
            label.Text = "  " .. text
            label.TextColor3 = ActiveTheme.DarkText
            label.Font = Enum.Font.Gotham
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BorderSizePixel = 0
            label.Parent = Page
            Instance.new("UICorner", label).CornerRadius = UDim.new(0,8)
            Register(text, label)
            return {Set = function(_, v) label.Text = "  " .. v end}
        end

        function Tab:CreateButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,38)
            btn.BackgroundColor3 = ActiveTheme.Secondary
            btn.Text = text
            btn.TextColor3 = ActiveTheme.Text
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 13
            btn.Parent = Page
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
            Register(text, btn)
            btn.MouseButton1Click:Connect(function()
                Tween(btn, "BackgroundColor3", ActiveTheme.Accent, 0.1)
                task.delay(0.15, function() Tween(btn, "BackgroundColor3", ActiveTheme.Secondary, 0.2) end)
                callback()
            end)
        end

        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(1,0,0,38)
            toggle.BackgroundColor3 = ActiveTheme.Secondary
            toggle.Text = "   " .. text
            toggle.TextXAlignment = Enum.TextXAlignment.Left
            toggle.TextColor3 = ActiveTheme.Text
            toggle.Font = Enum.Font.GothamSemibold
            toggle.TextSize = 13
            toggle.Parent = Page
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)
            Register(text, toggle)
            local switchBg = Instance.new("Frame")
            switchBg.Size = UDim2.new(0,38,0,20)
            switchBg.Position = UDim2.new(1,-48,0.5,-10)
            switchBg.BackgroundColor3 = state and ActiveTheme.Accent or Color3.fromRGB(55,55,55)
            switchBg.BorderSizePixel = 0
            switchBg.Parent = toggle
            Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1,0)
            local dot = Instance.new("Frame")
            dot.Size = UDim2.new(0,14,0,14)
            dot.Position = state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
            dot.BackgroundColor3 = Color3.new(1,1,1)
            dot.BorderSizePixel = 0
            dot.Parent = switchBg
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
            toggle.MouseButton1Click:Connect(function()
                state = not state
                Tween(switchBg, "BackgroundColor3", state and ActiveTheme.Accent or Color3.fromRGB(55,55,55), 0.25)
                Tween(dot, "Position", state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7), 0.25)
                callback(state)
            end)
            return {
                Set = function(_, v)
                    state = v
                    Tween(switchBg, "BackgroundColor3", state and ActiveTheme.Accent or Color3.fromRGB(55,55,55), 0.25)
                    Tween(dot, "Position", state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7), 0.25)
                    callback(state)
                end,
                Get = function() return state end
            }
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local value = default or min
            local sliding = false
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(1,0,0,52)
            slider.BackgroundColor3 = ActiveTheme.Secondary
            slider.Parent = Page
            Instance.new("UICorner", slider).CornerRadius = UDim.new(0,8)
            Register(text, slider)
            local label = Instance.new("TextLabel", slider)
            label.Size = UDim2.new(1,-55,0,20)
            label.Position = UDim2.new(0,10,0,5)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = ActiveTheme.Text
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            local val = Instance.new("TextLabel", slider)
            val.Size = UDim2.new(0,45,0,20)
            val.Position = UDim2.new(1,-50,0,5)
            val.BackgroundTransparency = 1
            val.Text = tostring(value)
            val.TextColor3 = ActiveTheme.Accent
            val.Font = Enum.Font.GothamBold
            val.TextSize = 13
            val.TextXAlignment = Enum.TextXAlignment.Right
            local bar = Instance.new("Frame", slider)
            bar.Size = UDim2.new(1,-20,0,6)
            bar.Position = UDim2.new(0,10,1,-18)
            bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new(max > min and (value-min)/(max-min) or 0,0,1,0)
            fill.BackgroundColor3 = ActiveTheme.Accent
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
            local sdot = Instance.new("Frame", bar)
            sdot.Size = UDim2.new(0,14,0,14)
            sdot.Position = UDim2.new(max > min and (value-min)/(max-min) or 0,-7,0.5,-7)
            sdot.BackgroundColor3 = Color3.new(1,1,1)
            sdot.ZIndex = 5
            sdot.BorderSizePixel = 0
            Instance.new("UICorner", sdot).CornerRadius = UDim.new(1,0)
            local function update(inputPos)
                local absSize = bar.AbsoluteSize.X
                if absSize <= 0 then return end
                local posX = typeof(inputPos) == "Vector2" and inputPos.X or inputPos.X
                local size = math.clamp((posX - bar.AbsolutePosition.X) / absSize, 0, 1)
                value = math.floor(min + (max - min) * size)
                val.Text = tostring(value)
                fill.Size = UDim2.new(size,0,1,0)
                sdot.Position = UDim2.new(size,-7,0.5,-7)
                callback(value)
            end
            bar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    update(inp.Position)
                end
            end)
            sdot.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    update(inp.Position)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            return {
                Set = function(_, v)
                    value = math.clamp(v,min,max)
                    local s = (value-min)/(max-min)
                    val.Text = tostring(value)
                    fill.Size = UDim2.new(s,0,1,0)
                    sdot.Position = UDim2.new(s,-7,0.5,-7)
                    callback(value)
                end,
                Get = function() return value end
            }
        end

        function Tab:CreateDropdown(text, list, default, callback)
            local selected = default or list[1]
            local open = false

            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(1,0,0,38)
            dropdown.BackgroundColor3 = ActiveTheme.Secondary
            dropdown.Text = "   " .. text .. ":  " .. selected
            dropdown.TextXAlignment = Enum.TextXAlignment.Left
            dropdown.TextColor3 = ActiveTheme.Text
            dropdown.Font = Enum.Font.GothamSemibold
            dropdown.TextSize = 13
            dropdown.Parent = Page
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0,8)
            Register(text, dropdown)

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0,25,1,0)
            arrow.Position = UDim2.new(1,-30,0,0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "v"
            arrow.TextColor3 = ActiveTheme.Accent
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 13
            arrow.Parent = dropdown

            local dropFrame = Instance.new("ScrollingFrame")
            dropFrame.Size = UDim2.new(0,0,0,0)
            dropFrame.BackgroundColor3 = ActiveTheme.Secondary
            dropFrame.ClipsDescendants = true
            dropFrame.ScrollBarThickness = 3
            dropFrame.ZIndex = 100
            dropFrame.CanvasSize = UDim2.new(0,0,0,#list * 30)
            dropFrame.Visible = false
            dropFrame.Parent = DropdownHolder
            Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,8)
            Instance.new("UIListLayout", dropFrame).SortOrder = Enum.SortOrder.LayoutOrder

            local function positionDropdown()
                local absPos = dropdown.AbsolutePosition
                local absSize = dropdown.AbsoluteSize
                dropFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                dropFrame.Size = UDim2.new(0, absSize.X, 0, 0)
            end

            dropdown.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    positionDropdown()
                    dropFrame.Visible = true
                    local targetH = math.min(#list * 30, 140)
                    Tween(dropFrame, "Size", UDim2.new(0, dropdown.AbsoluteSize.X, 0, targetH), 0.3)
                else
                    Tween(dropFrame, "Size", UDim2.new(0, dropdown.AbsoluteSize.X, 0, 0), 0.3)
                    task.delay(0.3, function() dropFrame.Visible = false end)
                end
                arrow.Text = open and "^" or "v"
            end)

            for _, option in ipairs(list) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1,0,0,30)
                btn.BackgroundTransparency = 1
                btn.Text = "  " .. option
                btn.TextColor3 = ActiveTheme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.ZIndex = 101
                btn.Parent = dropFrame
                btn.MouseButton1Click:Connect(function()
                    selected = option
                    dropdown.Text = "   " .. text .. ":  " .. selected
                    Tween(dropFrame, "Size", UDim2.new(0, dropdown.AbsoluteSize.X, 0, 0), 0.3)
                    task.delay(0.3, function() dropFrame.Visible = false end)
                    open = false
                    arrow.Text = "v"
                    callback(selected)
                end)
                btn.MouseEnter:Connect(function() btn.TextColor3 = ActiveTheme.Accent end)
                btn.MouseLeave:Connect(function() btn.TextColor3 = ActiveTheme.Text end)
            end

            return {
                Set = function(_, v) selected = v dropdown.Text = "   " .. text .. ":  " .. selected callback(selected) end,
                Get = function() return selected end
            }
        end

        function Tab:CreateInput(text, placeholder, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1,0,0,38)
            holder.BackgroundColor3 = ActiveTheme.Secondary
            holder.BorderSizePixel = 0
            holder.Parent = Page
            Instance.new("UICorner", holder).CornerRadius = UDim.new(0,8)
            Register(text, holder)
            local label = Instance.new("TextLabel", holder)
            label.Size = UDim2.new(0.4,0,1,0)
            label.Position = UDim2.new(0,10,0,0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = ActiveTheme.Text
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            local inputBg = Instance.new("Frame", holder)
            inputBg.Size = UDim2.new(0.55,0,0,26)
            inputBg.Position = UDim2.new(0.43,0,0.5,-13)
            inputBg.BackgroundColor3 = ActiveTheme.Main
            inputBg.BorderSizePixel = 0
            Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0,6)
            local input = Instance.new("TextBox", inputBg)
            input.Size = UDim2.new(1,-10,1,0)
            input.Position = UDim2.new(0,5,0,0)
            input.BackgroundTransparency = 1
            input.Text = ""
            input.PlaceholderText = placeholder or "Type here..."
            input.TextColor3 = ActiveTheme.Text
            input.PlaceholderColor3 = ActiveTheme.DarkText
            input.Font = Enum.Font.Gotham
            input.TextSize = 12
            input.TextXAlignment = Enum.TextXAlignment.Left
            input.FocusLost:Connect(function(enter) if enter then callback(input.Text) end end)
            return {
                Get = function() return input.Text end,
                Set = function(_, v) input.Text = v end
            }
        end

        function Tab:CreateKeybind(text, defaultKey, callback)
            local key = defaultKey or Enum.KeyCode.RightShift
            local listening = false
            local bindBtn = Instance.new("TextButton")
            bindBtn.Size = UDim2.new(1,0,0,38)
            bindBtn.BackgroundColor3 = ActiveTheme.Secondary
            bindBtn.Text = "   " .. text
            bindBtn.TextXAlignment = Enum.TextXAlignment.Left
            bindBtn.TextColor3 = ActiveTheme.Text
            bindBtn.Font = Enum.Font.GothamSemibold
            bindBtn.TextSize = 13
            bindBtn.Parent = Page
            Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0,8)
            Register(text, bindBtn)
            local keyLabel = Instance.new("TextButton")
            keyLabel.Size = UDim2.new(0,60,0,22)
            keyLabel.Position = UDim2.new(1,-70,0.5,-11)
            keyLabel.BackgroundColor3 = ActiveTheme.Main
            keyLabel.Text = key.Name
            keyLabel.TextColor3 = ActiveTheme.Accent
            keyLabel.Font = Enum.Font.GothamBold
            keyLabel.TextSize = 11
            keyLabel.Parent = bindBtn
            Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0,6)
            keyLabel.MouseButton1Click:Connect(function()
                listening = true
                keyLabel.Text = "..."
                keyLabel.TextColor3 = ActiveTheme.DarkText
            end)
            UserInputService.InputBegan:Connect(function(inp)
                if listening and inp.KeyCode ~= Enum.KeyCode.Unknown then
                    key = inp.KeyCode
                    keyLabel.Text = key.Name
                    keyLabel.TextColor3 = ActiveTheme.Accent
                    listening = false
                    callback(key)
                end
            end)
            return {Get = function() return key end}
        end

        function Tab:CreateColorPicker(text, default, callback)
            local color = default or ActiveTheme.Accent
            local open = false
            local pickerHolder = Instance.new("Frame")
            pickerHolder.Size = UDim2.new(1,0,0,38)
            pickerHolder.BackgroundColor3 = ActiveTheme.Secondary
            pickerHolder.ClipsDescendants = false
            pickerHolder.Parent = Page
            Instance.new("UICorner", pickerHolder).CornerRadius = UDim.new(0,8)
            Register(text, pickerHolder)
            local picker = Instance.new("TextButton")
            picker.Size = UDim2.new(1,0,0,38)
            picker.BackgroundTransparency = 1
            picker.Text = "   " .. text
            picker.TextXAlignment = Enum.TextXAlignment.Left
            picker.TextColor3 = ActiveTheme.Text
            picker.Font = Enum.Font.GothamSemibold
            picker.TextSize = 13
            picker.Parent = pickerHolder
            local preview = Instance.new("Frame")
            preview.Size = UDim2.new(0,24,0,24)
            preview.Position = UDim2.new(1,-34,0.5,-12)
            preview.BackgroundColor3 = color
            preview.Parent = pickerHolder
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0,6)
            local colorPanel = Instance.new("Frame")
            colorPanel.Size = UDim2.new(1,0,0,0)
            colorPanel.Position = UDim2.new(0,0,1,4)
            colorPanel.BackgroundColor3 = ActiveTheme.Main
            colorPanel.ClipsDescendants = true
            colorPanel.ZIndex = 50
            colorPanel.Parent = pickerHolder
            Instance.new("UICorner", colorPanel).CornerRadius = UDim.new(0,8)
            local function makeBar(yPos, gradColors)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1,-16,0,12)
                f.Position = UDim2.new(0,8,0,yPos)
                f.BackgroundColor3 = Color3.new(1,1,1)
                f.ZIndex = 51
                f.Parent = colorPanel
                Instance.new("UICorner",f).CornerRadius = UDim.new(1,0)
                local g = Instance.new("UIGradient")
                g.Color = gradColors
                g.Parent = f
                local d = Instance.new("Frame",f)
                d.Size = UDim2.new(0,12,0,12)
                d.Position = UDim2.new(0,-6,0.5,-6)
                d.BackgroundColor3 = Color3.new(1,1,1)
                d.ZIndex = 52
                d.BorderSizePixel = 0
                Instance.new("UICorner",d).CornerRadius = UDim.new(1,0)
                return f, g, d
            end
            local hueBar, hueGrad, hueDot = makeBar(8, ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.166,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.333,Color3.fromRGB(0,255,0)),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.666,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.833,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))})
            local satBar, satGrad, satDot = makeBar(28, ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,color)})
            local valBar, valGrad, valDot = makeBar(48, ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))})
            local h, s, v = Color3.toHSV(color)
            local function updateColor()
                color = Color3.fromHSV(h,s,v)
                preview.BackgroundColor3 = color
                satGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(h,1,1))}
                callback(color)
            end
            local function bindColorBar(bar, barDot, onChange)
                local active = false
                bar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        active = true
                        local val2 = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        barDot.Position = UDim2.new(val2,-6,0.5,-6)
                        onChange(val2)
                        updateColor()
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if active and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        local val2 = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                        barDot.Position = UDim2.new(val2,-6,0.5,-6)
                        onChange(val2)
                        updateColor()
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        active = false
                    end
                end)
            end
            bindColorBar(hueBar, hueDot, function(val2) h = val2 end)
            bindColorBar(satBar, satDot, function(val2) s = val2 end)
            bindColorBar(valBar, valDot, function(val2) v = val2 end)
            picker.MouseButton1Click:Connect(function()
                open = not open
                Tween(colorPanel, "Size", UDim2.new(1,0,0,open and 70 or 0), 0.3)
            end)
            return {
                Get = function() return color end,
                Set = function(_, c) color = c h,s,v = Color3.toHSV(color) preview.BackgroundColor3 = color callback(color) end
            }
        end

        return Tab
    end

    function Window:SaveConfig(name)
        if writefile then
            writefile(name .. ".json", HttpService:JSONEncode({}))
            Moxie:Notify(Config.Name, "Config saved: " .. name, 3)
        end
    end

    function Window:LoadConfig(name)
        if isfile and isfile(name .. ".json") then
            local config = HttpService:JSONDecode(readfile(name .. ".json"))
            Moxie:Notify(Config.Name, "Config loaded: " .. name, 3)
            return config
        else
            Moxie:Notify(Config.Name, "No config found: " .. name, 3)
        end
    end

    return Window
end

return Moxie
