local Moxie = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Themes = {
    Dark = {
        Main = Color3.fromRGB(16, 16, 16),
        Secondary = Color3.fromRGB(24, 24, 24),
        Accent = Color3.fromRGB(138, 43, 226),
        Text = Color3.fromRGB(255, 255, 255),
        DarkText = Color3.fromRGB(170, 170, 170),
        Gradient = nil,
    },
    Lunar = {
        Main = Color3.fromRGB(10, 10, 30),
        Secondary = Color3.fromRGB(18, 18, 45),
        Accent = Color3.fromRGB(100, 149, 237),
        Text = Color3.fromRGB(220, 220, 255),
        DarkText = Color3.fromRGB(140, 140, 200),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 10, 60)),
        }),
    },
    Crimson = {
        Main = Color3.fromRGB(18, 8, 8),
        Secondary = Color3.fromRGB(30, 12, 12),
        Accent = Color3.fromRGB(220, 20, 60),
        Text = Color3.fromRGB(255, 220, 220),
        DarkText = Color3.fromRGB(180, 130, 130),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 8, 8)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 10, 10)),
        }),
    },
    Ocean = {
        Main = Color3.fromRGB(5, 20, 35),
        Secondary = Color3.fromRGB(8, 30, 50),
        Accent = Color3.fromRGB(0, 200, 255),
        Text = Color3.fromRGB(200, 240, 255),
        DarkText = Color3.fromRGB(120, 180, 210),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 20, 35)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 40, 80)),
        }),
    },
    Sunset = {
        Main = Color3.fromRGB(20, 10, 20),
        Secondary = Color3.fromRGB(30, 15, 30),
        Accent = Color3.fromRGB(255, 100, 50),
        Text = Color3.fromRGB(255, 230, 210),
        DarkText = Color3.fromRGB(200, 160, 140),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 20)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 15, 20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 20, 10)),
        }),
    },
    Mint = {
        Main = Color3.fromRGB(8, 20, 18),
        Secondary = Color3.fromRGB(12, 30, 26),
        Accent = Color3.fromRGB(0, 230, 150),
        Text = Color3.fromRGB(210, 255, 240),
        DarkText = Color3.fromRGB(130, 190, 170),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 20, 18)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 40, 34)),
        }),
    },
    Rose = {
        Main = Color3.fromRGB(22, 10, 16),
        Secondary = Color3.fromRGB(34, 14, 24),
        Accent = Color3.fromRGB(255, 105, 180),
        Text = Color3.fromRGB(255, 220, 235),
        DarkText = Color3.fromRGB(200, 150, 175),
        Gradient = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 10, 16)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 10, 30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 10, 40)),
        }),
    },
}

local ActiveTheme = Themes.Dark
local Notifications = {}
local Config = {
    LibraryName = "Moxie",
    LibraryLogo = "M",
    LoadingEnabled = true,
    KeySystemEnabled = false,
    ValidKeys = {},
    KeyFilename = "MoxieKey.txt",
}

local function Tween(obj, prop, goal, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad), {[prop] = goal}):Play()
end

local function ApplyGradient(frame, theme)
    if theme.Gradient then
        local existing = frame:FindFirstChildOfClass("UIGradient")
        if existing then existing:Destroy() end
        local gradient = Instance.new("UIGradient")
        gradient.Color = theme.Gradient
        gradient.Rotation = 135
        gradient.Parent = frame
    end
end

function Moxie:SetTheme(themeName)
    if Themes[themeName] then
        ActiveTheme = Themes[themeName]
    end
end

function Moxie:SetLibraryName(name)
    Config.LibraryName = name or "Moxie"
end

function Moxie:SetLibraryLogo(logo)
    Config.LibraryLogo = logo or "M"
end

function Moxie:SetLoadingEnabled(bool)
    Config.LoadingEnabled = bool
end

function Moxie:SetKeySystem(options)
    Config.KeySystemEnabled = options.Enabled or false
    Config.ValidKeys = options.Keys or {}
    Config.KeyFilename = options.FileName or "MoxieKey.txt"
    Config.KeyDiscord = options.Discord or ""
    Config.KeyNote = options.Note or "Enter your key to continue."
    Config.KeyTitle = options.Title or Config.LibraryName .. " Key System"
end

function Moxie:KeySystem()
    if not Config.KeySystemEnabled then return true end

    if isfile(Config.KeyFilename) then
        local saved = readfile(Config.KeyFilename)
        for _, k in ipairs(Config.ValidKeys) do
            if saved == k then return true end
        end
    end

    local result = false
    local done = false

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxieKeySystem"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.4
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(0, 460, 0, 280)
    panel.Position = UDim2.new(0.5, -230, 0.5, -140)
    panel.BackgroundColor3 = ActiveTheme.Main
    panel.BorderSizePixel = 0
    panel.Parent = gui
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 18)
    ApplyGradient(panel, ActiveTheme)

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 55)
    topBar.BackgroundColor3 = ActiveTheme.Secondary
    topBar.BorderSizePixel = 0
    topBar.Parent = panel
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 18)

    local topTitle = Instance.new("TextLabel")
    topTitle.Size = UDim2.new(1, -20, 1, 0)
    topTitle.Position = UDim2.new(0, 15, 0, 0)
    topTitle.BackgroundTransparency = 1
    topTitle.Text = Config.KeyTitle
    topTitle.TextColor3 = ActiveTheme.Text
    topTitle.Font = Enum.Font.GothamBold
    topTitle.TextSize = 17
    topTitle.TextXAlignment = Enum.TextXAlignment.Left
    topTitle.Parent = topBar

    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1, -30, 0, 35)
    note.Position = UDim2.new(0, 15, 0, 62)
    note.BackgroundTransparency = 1
    note.Text = Config.KeyNote
    note.TextColor3 = ActiveTheme.DarkText
    note.Font = Enum.Font.Gotham
    note.TextSize = 13
    note.TextWrapped = true
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Parent = panel

    local inputBox = Instance.new("Frame")
    inputBox.Size = UDim2.new(1, -30, 0, 46)
    inputBox.Position = UDim2.new(0, 15, 0, 108)
    inputBox.BackgroundColor3 = ActiveTheme.Secondary
    inputBox.BorderSizePixel = 0
    inputBox.Parent = panel
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 10)

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1, -20, 1, 0)
    input.Position = UDim2.new(0, 10, 0, 0)
    input.BackgroundTransparency = 1
    input.Text = ""
    input.PlaceholderText = "Enter your key here..."
    input.TextColor3 = ActiveTheme.Text
    input.PlaceholderColor3 = ActiveTheme.DarkText
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.Parent = inputBox

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -30, 0, 20)
    statusLabel.Position = UDim2.new(0, 15, 0, 160)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = panel

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 180, 0, 44)
    submitBtn.Position = UDim2.new(0.5, -90, 0, 190)
    submitBtn.BackgroundColor3 = ActiveTheme.Accent
    submitBtn.Text = "Submit Key"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 15
    submitBtn.Parent = panel
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 10)

    local discordLabel = Instance.new("TextLabel")
    discordLabel.Size = UDim2.new(1, -30, 0, 20)
    discordLabel.Position = UDim2.new(0, 15, 0, 248)
    discordLabel.BackgroundTransparency = 1
    discordLabel.Text = Config.KeyDiscord ~= "" and "Get a key at: " .. Config.KeyDiscord or ""
    discordLabel.TextColor3 = ActiveTheme.DarkText
    discordLabel.Font = Enum.Font.Gotham
    discordLabel.TextSize = 12
    discordLabel.TextXAlignment = Enum.TextXAlignment.Center
    discordLabel.Parent = panel

    panel.Position = UDim2.new(0.5, -230, 0.5, -80)
    panel.BackgroundTransparency = 1
    Tween(panel, "BackgroundTransparency", 0, 0.5)
    Tween(panel, "Position", UDim2.new(0.5, -230, 0.5, -140), 0.5)

    submitBtn.MouseButton1Click:Connect(function()
        local entered = input.Text
        local valid = false
        for _, k in ipairs(Config.ValidKeys) do
            if entered == k then
                valid = true
                break
            end
        end
        if valid then
            writefile(Config.KeyFilename, entered)
            statusLabel.TextColor3 = Color3.fromRGB(0, 230, 100)
            statusLabel.Text = "Key accepted! Loading..."
            Tween(submitBtn, "BackgroundColor3", Color3.fromRGB(0, 200, 80), 0.3)
            task.wait(1)
            result = true
            done = true
            Tween(panel, "BackgroundTransparency", 1, 0.4)
            Tween(bg, "BackgroundTransparency", 1, 0.4)
            task.wait(0.5)
            gui:Destroy()
        else
            statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            statusLabel.Text = "Invalid key. Please try again."
            Tween(inputBox, "BackgroundColor3", Color3.fromRGB(80, 20, 20), 0.1)
            task.delay(0.3, function() Tween(inputBox, "BackgroundColor3", ActiveTheme.Secondary, 0.3) end)
        end
    end)

    repeat task.wait() until done
    return result
end

function Moxie:LoadingScreen()
    if not Config.LoadingEnabled then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxieLoading"
    gui.ResetOnSpawn = false
    gui.Parent = game.CoreGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 8, 35)),
    })
    bgGradient.Rotation = 135
    bgGradient.Parent = bg

    local particles = {}
    for i = 1, 25 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        p.Position = UDim2.new(math.random(), 0, math.random(), 0)
        p.BackgroundColor3 = ActiveTheme.Accent
        p.BackgroundTransparency = math.random(5, 9) / 10
        p.BorderSizePixel = 0
        p.Parent = bg
        Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        table.insert(particles, p)
    end

    local ring1 = Instance.new("Frame")
    ring1.Size = UDim2.new(0, 200, 0, 200)
    ring1.Position = UDim2.new(0.5, -100, 0.5, -140)
    ring1.BackgroundTransparency = 1
    ring1.Parent = bg

    local ring1Img = Instance.new("ImageLabel")
    ring1Img.Size = UDim2.new(1, 0, 1, 0)
    ring1Img.BackgroundTransparency = 1
    ring1Img.Image = "rbxassetid://7076348532"
    ring1Img.ImageColor3 = ActiveTheme.Accent
    ring1Img.ImageTransparency = 0.4
    ring1Img.Parent = ring1

    local ring2 = Instance.new("Frame")
    ring2.Size = UDim2.new(0, 150, 0, 150)
    ring2.Position = UDim2.new(0.5, -75, 0.5, -115)
    ring2.BackgroundTransparency = 1
    ring2.Parent = bg

    local ring2Img = Instance.new("ImageLabel")
    ring2Img.Size = UDim2.new(1, 0, 1, 0)
    ring2Img.BackgroundTransparency = 1
    ring2Img.Image = "rbxassetid://7076348532"
    ring2Img.ImageColor3 = ActiveTheme.Accent
    ring2Img.ImageTransparency = 0.6
    ring2Img.Parent = ring2

    local ring3 = Instance.new("Frame")
    ring3.Size = UDim2.new(0, 240, 0, 240)
    ring3.Position = UDim2.new(0.5, -120, 0.5, -160)
    ring3.BackgroundTransparency = 1
    ring3.Parent = bg

    local ring3Img = Instance.new("ImageLabel")
    ring3Img.Size = UDim2.new(1, 0, 1, 0)
    ring3Img.BackgroundTransparency = 1
    ring3Img.Image = "rbxassetid://7076348532"
    ring3Img.ImageColor3 = ActiveTheme.Accent
    ring3Img.ImageTransparency = 0.7
    ring3Img.Parent = ring3

    local logoFrame = Instance.new("Frame")
    logoFrame.Size = UDim2.new(0, 100, 0, 100)
    logoFrame.Position = UDim2.new(0.5, -50, 0.5, -90)
    logoFrame.BackgroundColor3 = ActiveTheme.Accent
    logoFrame.BackgroundTransparency = 0.85
    logoFrame.BorderSizePixel = 0
    logoFrame.Parent = bg
    Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0, 24)

    local logoGlow = Instance.new("UIGradient")
    logoGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, ActiveTheme.Accent),
    })
    logoGlow.Rotation = 45
    logoGlow.Parent = logoFrame

    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(1, 0, 1, 0)
    logoText.BackgroundTransparency = 1
    logoText.Text = Config.LibraryLogo
    logoText.TextColor3 = ActiveTheme.Accent
    logoText.Font = Enum.Font.GothamBold
    logoText.TextSize = 52
    logoText.Parent = logoFrame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 400, 0, 55)
    nameLabel.Position = UDim2.new(0.5, -200, 0.5, 30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = Config.LibraryName
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 46
    nameLabel.TextTransparency = 1
    nameLabel.Parent = bg

    local nameGradient = Instance.new("UIGradient")
    nameGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ActiveTheme.Accent),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, ActiveTheme.Accent),
    })
    nameGradient.Parent = nameLabel

    local subLabel = Instance.new("TextLabel")
    subLabel.Size = UDim2.new(0, 400, 0, 30)
    subLabel.Position = UDim2.new(0.5, -200, 0.5, 82)
    subLabel.BackgroundTransparency = 1
    subLabel.Text = "Loading..."
    subLabel.TextColor3 = ActiveTheme.DarkText
    subLabel.Font = Enum.Font.Gotham
    subLabel.TextSize = 16
    subLabel.TextTransparency = 1
    subLabel.Parent = bg

    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(0, 340, 0, 4)
    barBg.Position = UDim2.new(0.5, -170, 0.5, 128)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0
    barBg.Parent = bg
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = ActiveTheme.Accent
    barFill.BorderSizePixel = 0
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    local barGlow = Instance.new("UIGradient")
    barGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, ActiveTheme.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    barGlow.Parent = barFill

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(0, 340, 0, 20)
    statusLabel.Position = UDim2.new(0.5, -170, 0.5, 140)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = ""
    statusLabel.TextColor3 = ActiveTheme.DarkText
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 13
    statusLabel.TextTransparency = 1
    statusLabel.Parent = bg

    local conn = RunService.RenderStepped:Connect(function(dt)
        ring1.Rotation = ring1.Rotation + 60 * dt
        ring2.Rotation = ring2.Rotation - 40 * dt
        ring3.Rotation = ring3.Rotation + 25 * dt
        logoFrame.Rotation = logoFrame.Rotation + 10 * dt
        nameGradient.Offset = Vector2.new(math.sin(tick()) * 0.5, 0)
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
        TweenService:Create(subLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        task.wait(0.4)
        TweenService:Create(barBg, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        TweenService:Create(statusLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
        task.wait(0.6)

        local steps = {
            {text = "Initializing " .. Config.LibraryName .. "...", progress = 0.2},
            {text = "Loading Modules...", progress = 0.4},
            {text = "Applying Themes...", progress = 0.6},
            {text = "Building Interface...", progress = 0.8},
            {text = "Almost Ready...", progress = 0.95},
            {text = "Done!", progress = 1.0},
        }

        for _, step in ipairs(steps) do
            statusLabel.Text = step.text
            TweenService:Create(barFill, TweenInfo.new(0.55, Enum.EasingStyle.Quint), {Size = UDim2.new(step.progress, 0, 1, 0)}):Play()
            task.wait(0.5)
        end

        task.wait(0.3)

        local fadeTargets = {nameLabel, subLabel, statusLabel, logoText}
        for _, obj in ipairs(fadeTargets) do
            TweenService:Create(obj, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {TextTransparency = 1}):Play()
        end
        TweenService:Create(barBg, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        TweenService:Create(logoFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        TweenService:Create(ring1Img, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(ring2Img, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        TweenService:Create(ring3Img, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
        for _, p in ipairs(particles) do
            TweenService:Create(p, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        end
        task.wait(0.4)
        TweenService:Create(bg, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}):Play()
        task.wait(0.9)
        conn:Disconnect()
        gui:Destroy()
        completed = true
    end)

    repeat task.wait() until completed
end

function Moxie:Notify(title, desc, duration)
    duration = duration or 4
    local gui = game.CoreGui:FindFirstChild("MoxieUI") or Instance.new("ScreenGui", game.CoreGui)
    gui.Name = "MoxieUI"

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 85)
    frame.Position = UDim2.new(1, 30, 1, -110 - (#Notifications * 95))
    frame.BackgroundColor3 = ActiveTheme.Main
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    ApplyGradient(frame, ActiveTheme)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -20)
    accent.Position = UDim2.new(0, 0, 0, 10)
    accent.BackgroundColor3 = ActiveTheme.Accent
    accent.BorderSizePixel = 0
    accent.Parent = frame
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local t = Instance.new("TextLabel", frame)
    t.Size = UDim2.new(1, -30, 0, 26)
    t.Position = UDim2.new(0, 18, 0, 10)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = ActiveTheme.Accent
    t.Font = Enum.Font.GothamBold
    t.TextSize = 15
    t.TextXAlignment = Enum.TextXAlignment.Left

    local d = Instance.new("TextLabel", frame)
    d.Size = UDim2.new(1, -30, 0, 40)
    d.Position = UDim2.new(0, 18, 0, 36)
    d.BackgroundTransparency = 1
    d.Text = desc
    d.TextColor3 = ActiveTheme.Text
    d.Font = Enum.Font.Gotham
    d.TextSize = 13
    d.TextWrapped = true
    d.TextXAlignment = Enum.TextXAlignment.Left

    table.insert(Notifications, frame)
    Tween(frame, "Position", UDim2.new(1, -350, 1, -110 - ((#Notifications-1)*95)), 0.5)

    task.delay(duration, function()
        Tween(frame, "Position", UDim2.new(1, 30, 1, frame.Position.Y.Offset), 0.5)
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
    ScreenGui.Parent = game.CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 720, 0, 540)
    Main.Position = UDim2.new(0.5, -360, 0.5, -270)
    Main.BackgroundColor3 = ActiveTheme.Main
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
    ApplyGradient(Main, ActiveTheme)

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 60)
    TitleBar.BackgroundColor3 = ActiveTheme.Secondary
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 16)

    local TitleAccent = Instance.new("Frame")
    TitleAccent.Size = UDim2.new(0, 4, 0, 30)
    TitleAccent.Position = UDim2.new(0, 15, 0.5, -15)
    TitleAccent.BackgroundColor3 = ActiveTheme.Accent
    TitleAccent.BorderSizePixel = 0
    TitleAccent.Parent = TitleBar
    Instance.new("UICorner", TitleAccent).CornerRadius = UDim.new(1, 0)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Position = UDim2.new(0, 26, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = title or Config.LibraryName
    Title.TextColor3 = ActiveTheme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 36, 0, 36)
    MinimizeBtn.Position = UDim2.new(1, -90, 0, 12)
    MinimizeBtn.BackgroundColor3 = ActiveTheme.Main
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = ActiveTheme.DarkText
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 18
    MinimizeBtn.Parent = TitleBar
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 8)

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 36, 0, 36)
    Close.Position = UDim2.new(1, -48, 0, 12)
    Close.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    Close.Text = "✕"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.Font = Enum.Font.GothamBold
    Close.TextSize = 18
    Close.Parent = TitleBar
    Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
    Close.MouseButton1Click:Connect(function()
        Tween(Main, "Size", UDim2.new(0, 720, 0, 0), 0.4)
        Tween(Main, "BackgroundTransparency", 1, 0.4)
        task.wait(0.5)
        ScreenGui:Destroy()
    end)

    local minimized = false
    local originalSize = Main.Size
    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, "Size", UDim2.new(0, 720, 0, 60), 0.4)
        else
            Tween(Main, "Size", originalSize, 0.4)
        end
    end)

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 180, 1, -60)
    TabBar.Position = UDim2.new(0, 0, 0, 60)
    TabBar.BackgroundColor3 = ActiveTheme.Secondary
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main

    local TabListLayout = Instance.new("UIListLayout", TabBar)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 6)

    local TabPadding = Instance.new("UIPadding", TabBar)
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -30, 0, 34)
    SearchBox.Position = UDim2.new(0, 15, 0, 68)
    SearchBox.BackgroundColor3 = ActiveTheme.Secondary
    SearchBox.Text = ""
    SearchBox.PlaceholderText = "Search..."
    SearchBox.TextColor3 = ActiveTheme.Text
    SearchBox.PlaceholderColor3 = ActiveTheme.DarkText
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 13
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = Main
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.AllElements = {}

    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        for _, elem in ipairs(Window.AllElements) do
            if elem.Instance and elem.Name then
                elem.Instance.Visible = query == "" or elem.Name:lower():find(query) ~= nil
            end
        end
    end)

    function Window:CreateTab(name, icon)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 42)
        TabButton.BackgroundColor3 = ActiveTheme.Main
        TabButton.Text = (icon and icon .. "  " or "") .. name
        TabButton.TextColor3 = ActiveTheme.DarkText
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextSize = 14
        TabButton.Parent = TabBar
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -200, 1, -115)
        Page.Position = UDim2.new(0, 190, 0, 112)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 4
        Page.Visible = false
        Page.Parent = Main

        local Layout = Instance.new("UIListLayout", Page)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 10)

        local Padding = Instance.new("UIPadding", Page)
        Padding.PaddingTop = UDim.new(0, 5)
        Padding.PaddingRight = UDim.new(0, 10)

        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Page.Visible = false
                Tween(Window.CurrentTab.Button, "BackgroundColor3", ActiveTheme.Main, 0.2)
                Window.CurrentTab.Button.TextColor3 = ActiveTheme.DarkText
            end
            Page.Visible = true
            Tween(TabButton, "BackgroundColor3", ActiveTheme.Accent, 0.2)
            TabButton.TextColor3 = ActiveTheme.Text
            Window.CurrentTab = {Button = TabButton, Page = Page}
        end)

        if not Window.CurrentTab then
            Page.Visible = true
            Tween(TabButton, "BackgroundColor3", ActiveTheme.Accent, 0.2)
            TabButton.TextColor3 = ActiveTheme.Text
            Window.CurrentTab = {Button = TabButton, Page = Page}
        end

        local Tab = {}

        local function RegisterElement(name, instance)
            table.insert(Window.AllElements, {Name = name, Instance = instance})
        end

        function Tab:CreateSection(text)
            local section = Instance.new("Frame")
            section.Size = UDim2.new(1, -10, 0, 30)
            section.BackgroundTransparency = 1
            section.Parent = Page

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 0.5, 0)
            line.BackgroundColor3 = ActiveTheme.Accent
            line.BackgroundTransparency = 0.7
            line.BorderSizePixel = 0
            line.Parent = section

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0, 0, 1, 0)
            label.AutomaticSize = Enum.AutomaticSize.X
            label.Position = UDim2.new(0, 8, 0, 0)
            label.BackgroundColor3 = ActiveTheme.Main
            label.Text = "  " .. text .. "  "
            label.TextColor3 = ActiveTheme.Accent
            label.Font = Enum.Font.GothamBold
            label.TextSize = 12
            label.Parent = section
        end

        function Tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 36)
            label.BackgroundColor3 = ActiveTheme.Secondary
            label.Text = "  " .. text
            label.TextColor3 = ActiveTheme.DarkText
            label.Font = Enum.Font.Gotham
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BorderSizePixel = 0
            label.Parent = Page
            Instance.new("UICorner", label).CornerRadius = UDim.new(0, 8)
            RegisterElement(text, label)
            return {
                Set = function(_, newText)
                    label.Text = "  " .. newText
                end
            }
        end

        function Tab:CreateButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 46)
            btn.BackgroundColor3 = ActiveTheme.Secondary
            btn.Text = text
            btn.TextColor3 = ActiveTheme.Text
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 14
            btn.Parent = Page
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
            RegisterElement(text, btn)
            btn.MouseButton1Click:Connect(function()
                Tween(btn, "BackgroundColor3", ActiveTheme.Accent, 0.1)
                task.delay(0.15, function() Tween(btn, "BackgroundColor3", ActiveTheme.Secondary, 0.2) end)
                callback()
            end)
            btn.MouseEnter:Connect(function() Tween(btn, "BackgroundColor3", Color3.fromRGB(ActiveTheme.Secondary.R*255+10, ActiveTheme.Secondary.G*255+10, ActiveTheme.Secondary.B*255+10), 0.15) end)
            btn.MouseLeave:Connect(function() Tween(btn, "BackgroundColor3", ActiveTheme.Secondary, 0.15) end)
        end

        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            local toggle = Instance.new("TextButton")
            toggle.Size = UDim2.new(1, -10, 0, 46)
            toggle.BackgroundColor3 = ActiveTheme.Secondary
            toggle.Text = "   " .. text
            toggle.TextXAlignment = Enum.TextXAlignment.Left
            toggle.TextColor3 = ActiveTheme.Text
            toggle.Font = Enum.Font.GothamSemibold
            toggle.TextSize = 14
            toggle.Parent = Page
            Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 10)
            RegisterElement(text, toggle)

            local switchBg = Instance.new("Frame")
            switchBg.Size = UDim2.new(0, 46, 0, 26)
            switchBg.Position = UDim2.new(1, -58, 0.5, -13)
            switchBg.BackgroundColor3 = state and ActiveTheme.Accent or Color3.fromRGB(55, 55, 55)
            switchBg.BorderSizePixel = 0
            switchBg.Parent = toggle
            Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

            local switchDot = Instance.new("Frame")
            switchDot.Size = UDim2.new(0, 20, 0, 20)
            switchDot.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
            switchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            switchDot.BorderSizePixel = 0
            switchDot.Parent = switchBg
            Instance.new("UICorner", switchDot).CornerRadius = UDim.new(1, 0)

            toggle.MouseButton1Click:Connect(function()
                state = not state
                Tween(switchBg, "BackgroundColor3", state and ActiveTheme.Accent or Color3.fromRGB(55,55,55), 0.25)
                Tween(switchDot, "Position", state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10), 0.25)
                callback(state)
            end)

            return {
                Set = function(_, val)
                    state = val
                    Tween(switchBg, "BackgroundColor3", state and ActiveTheme.Accent or Color3.fromRGB(55,55,55), 0.25)
                    Tween(switchDot, "Position", state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10), 0.25)
                    callback(state)
                end,
                Get = function() return state end
            }
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local value = default or min
            local slider = Instance.new("Frame")
            slider.Size = UDim2.new(1, -10, 0, 62)
            slider.BackgroundColor3 = ActiveTheme.Secondary
            slider.Parent = Page
            Instance.new("UICorner", slider).CornerRadius = UDim.new(0, 10)
            RegisterElement(text, slider)

            local label = Instance.new("TextLabel", slider)
            label.Size = UDim2.new(1, -70, 0, 25)
            label.Position = UDim2.new(0, 15, 0, 8)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = ActiveTheme.Text
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local val = Instance.new("TextLabel", slider)
            val.Size = UDim2.new(0, 55, 0, 25)
            val.Position = UDim2.new(1, -65, 0, 8)
            val.BackgroundTransparency = 1
            val.Text = tostring(value)
            val.TextColor3 = ActiveTheme.Accent
            val.Font = Enum.Font.GothamBold
            val.TextSize = 14
            val.TextXAlignment = Enum.TextXAlignment.Right

            local bar = Instance.new("Frame", slider)
            bar.Size = UDim2.new(1, -30, 0, 8)
            bar.Position = UDim2.new(0, 15, 1, -22)
            bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new(max > min and (value - min)/(max - min) or 0, 0, 1, 0)
            fill.BackgroundColor3 = ActiveTheme.Accent
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

            if ActiveTheme.Gradient then
                local g = Instance.new("UIGradient")
                g.Color = ActiveTheme.Gradient
                g.Rotation = 0
                g.Parent = fill
            end

            local dot = Instance.new("Frame", bar)
            dot.Size = UDim2.new(0, 14, 0, 14)
            dot.Position = UDim2.new(max > min and (value - min)/(max - min) or 0, -7, 0.5, -7)
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            dot.ZIndex = 5
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            local function update(pos)
                local size = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * size)
                val.Text = tostring(value)
                Tween(fill, "Size", UDim2.new(size, 0, 1, 0), 0.05)
                Tween(dot, "Position", UDim2.new(size, -7, 0.5, -7), 0.05)
                callback(value)
            end

            bar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    update(inp)
                    local conn = RunService.RenderStepped:Connect(function() update(UserInputService:GetMouseLocation()) end)
                    local ec
                    ec = UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() ec:Disconnect() end
                    end)
                end
            end)

            return {
                Set = function(_, v)
                    value = math.clamp(v, min, max)
                    local size = (value - min) / (max - min)
                    val.Text = tostring(value)
                    Tween(fill, "Size", UDim2.new(size, 0, 1, 0), 0.2)
                    Tween(dot, "Position", UDim2.new(size, -7, 0.5, -7), 0.2)
                    callback(value)
                end,
                Get = function() return value end
            }
        end

        function Tab:CreateDropdown(text, list, default, callback)
            local selected = default or list[1]
            local open = false

            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -10, 0, 46)
            holder.BackgroundTransparency = 1
            holder.ClipsDescendants = false
            holder.Parent = Page
            RegisterElement(text, holder)

            local dropdown = Instance.new("TextButton")
            dropdown.Size = UDim2.new(1, 0, 0, 46)
            dropdown.BackgroundColor3 = ActiveTheme.Secondary
            dropdown.Text = "   " .. text .. ":  " .. selected
            dropdown.TextXAlignment = Enum.TextXAlignment.Left
            dropdown.TextColor3 = ActiveTheme.Text
            dropdown.Font = Enum.Font.GothamSemibold
            dropdown.TextSize = 14
            dropdown.Parent = holder
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 10)

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 30, 1, 0)
            arrow.Position = UDim2.new(1, -35, 0, 0)
            arrow.BackgroundTransparency = 1
            arrow.Text = "▾"
            arrow.TextColor3 = ActiveTheme.Accent
            arrow.Font = Enum.Font.GothamBold
            arrow.TextSize = 16
            arrow.Parent = dropdown

            local dropFrame = Instance.new("Frame")
            dropFrame.Size = UDim2.new(1, 0, 0, 0)
            dropFrame.Position = UDim2.new(0, 0, 1, 4)
            dropFrame.BackgroundColor3 = ActiveTheme.Secondary
            dropFrame.ClipsDescendants = true
            dropFrame.ZIndex = 20
            dropFrame.Parent = holder
            Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 10)
            Instance.new("UIListLayout", dropFrame).SortOrder = Enum.SortOrder.LayoutOrder

            dropdown.MouseButton1Click:Connect(function()
                open = not open
                Tween(dropFrame, "Size", UDim2.new(1, 0, 0, open and math.min(#list * 34, 170) or 0), 0.3)
                Tween(arrow, "TextTransparency", open and 0 or 0, 0.1)
                arrow.Text = open and "▴" or "▾"
            end)

            for _, option in ipairs(list) do
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 34)
                btn.BackgroundTransparency = 1
                btn.Text = "  " .. option
                btn.TextColor3 = ActiveTheme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.ZIndex = 21
                btn.Parent = dropFrame
                btn.MouseButton1Click:Connect(function()
                    selected = option
                    dropdown.Text = "   " .. text .. ":  " .. selected
                    Tween(dropFrame, "Size", UDim2.new(1, 0, 0, 0), 0.3)
                    open = false
                    arrow.Text = "▾"
                    callback(selected)
                end)
                btn.MouseEnter:Connect(function() btn.TextColor3 = ActiveTheme.Accent end)
                btn.MouseLeave:Connect(function() btn.TextColor3 = ActiveTheme.Text end)
            end

            return {
                Set = function(_, val)
                    selected = val
                    dropdown.Text = "   " .. text .. ":  " .. selected
                    callback(selected)
                end,
                Get = function() return selected end
            }
        end

        function Tab:CreateInput(text, placeholder, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, -10, 0, 46)
            holder.BackgroundColor3 = ActiveTheme.Secondary
            holder.BorderSizePixel = 0
            holder.Parent = Page
            Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 10)
            RegisterElement(text, holder)

            local label = Instance.new("TextLabel", holder)
            label.Size = UDim2.new(0.4, 0, 1, 0)
            label.Position = UDim2.new(0, 12, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = ActiveTheme.Text
            label.Font = Enum.Font.GothamSemibold
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left

            local inputBg = Instance.new("Frame", holder)
            inputBg.Size = UDim2.new(0.55, 0, 0, 30)
            inputBg.Position = UDim2.new(0.43, 0, 0.5, -15)
            inputBg.BackgroundColor3 = ActiveTheme.Main
            inputBg.BorderSizePixel = 0
            Instance.new("UICorner", inputBg).CornerRadius = UDim.new(0, 8)

            local input = Instance.new("TextBox", inputBg)
            input.Size = UDim2.new(1, -10, 1, 0)
            input.Position = UDim2.new(0, 5, 0, 0)
            input.BackgroundTransparency = 1
            input.Text = ""
            input.PlaceholderText = placeholder or "Type here..."
            input.TextColor3 = ActiveTheme.Text
            input.PlaceholderColor3 = ActiveTheme.DarkText
            input.Font = Enum.Font.Gotham
            input.TextSize = 13
            input.TextXAlignment = Enum.TextXAlignment.Left

            input.FocusLost:Connect(function(enter)
                if enter then callback(input.Text) end
            end)

            return {
                Get = function() return input.Text end,
                Set = function(_, val) input.Text = val end
            }
        end

        function Tab:CreateKeybind(text, defaultKey, callback)
            local key = defaultKey or Enum.KeyCode.RightShift
            local bindBtn = Instance.new("TextButton")
            bindBtn.Size = UDim2.new(1, -10, 0, 46)
            bindBtn.BackgroundColor3 = ActiveTheme.Secondary
            bindBtn.Text = "   " .. text
            bindBtn.TextXAlignment = Enum.TextXAlignment.Left
            bindBtn.TextColor3 = ActiveTheme.Text
            bindBtn.Font = Enum.Font.GothamSemibold
            bindBtn.TextSize = 14
            bindBtn.Parent = Page
            Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 10)
            RegisterElement(text, bindBtn)

            local keyLabel = Instance.new("TextButton")
            keyLabel.Size = UDim2.new(0, 80, 0, 28)
            keyLabel.Position = UDim2.new(1, -92, 0.5, -14)
            keyLabel.BackgroundColor3 = ActiveTheme.Main
            keyLabel.Text = key.Name
            keyLabel.TextColor3 = ActiveTheme.Accent
            keyLabel.Font = Enum.Font.GothamBold
            keyLabel.TextSize = 12
            keyLabel.Parent = bindBtn
            Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0, 6)

            local listening = false
            keyLabel.MouseButton1Click:Connect(function()
                listening = true
                keyLabel.Text = "..."
                keyLabel.TextColor3 = ActiveTheme.DarkText
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                    key = input.KeyCode
                    keyLabel.Text = key.Name
                    keyLabel.TextColor3 = ActiveTheme.Accent
                    listening = false
                    callback(key)
                end
            end)

            return {
                Get = function() return key end
            }
        end

        function Tab:CreateColorPicker(text, default, callback)
            local color = default or ActiveTheme.Accent
            local open = false

            local pickerHolder = Instance.new("Frame")
            pickerHolder.Size = UDim2.new(1, -10, 0, 46)
            pickerHolder.BackgroundColor3 = ActiveTheme.Secondary
            pickerHolder.ClipsDescendants = false
            pickerHolder.Parent = Page
            Instance.new("UICorner", pickerHolder).CornerRadius = UDim.new(0, 10)
            RegisterElement(text, pickerHolder)

            local picker = Instance.new("TextButton")
            picker.Size = UDim2.new(1, 0, 0, 46)
            picker.BackgroundTransparency = 1
            picker.Text = "   " .. text
            picker.TextXAlignment = Enum.TextXAlignment.Left
            picker.TextColor3 = ActiveTheme.Text
            picker.Font = Enum.Font.GothamSemibold
            picker.TextSize = 14
            picker.Parent = pickerHolder

            local preview = Instance.new("Frame")
            preview.Size = UDim2.new(0, 32, 0, 32)
            preview.Position = UDim2.new(1, -46, 0.5, -16)
            preview.BackgroundColor3 = color
            preview.Parent = pickerHolder
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 8)

            local colorPanel = Instance.new("Frame")
            colorPanel.Size = UDim2.new(1, 0, 0, 0)
            colorPanel.Position = UDim2.new(0, 0, 1, 6)
            colorPanel.BackgroundColor3 = ActiveTheme.Main
            colorPanel.ClipsDescendants = true
            colorPanel.ZIndex = 10
            colorPanel.Parent = pickerHolder
            Instance.new("UICorner", colorPanel).CornerRadius = UDim.new(0, 10)

            local function makeSliderBar(yPos, gradColors)
                local f = Instance.new("Frame")
                f.Size = UDim2.new(1, -20, 0, 14)
                f.Position = UDim2.new(0, 10, 0, yPos)
                f.BackgroundColor3 = Color3.new(1,1,1)
                f.ZIndex = 11
                f.Parent = colorPanel
                Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
                local g = Instance.new("UIGradient")
                g.Color = gradColors
                g.Parent = f

                local dot = Instance.new("Frame", f)
                dot.Size = UDim2.new(0, 14, 0, 14)
                dot.Position = UDim2.new(0, -7, 0.5, -7)
                dot.BackgroundColor3 = Color3.new(1,1,1)
                dot.ZIndex = 12
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

                return f, g, dot
            end

            local hueBar, hueGrad, hueDot = makeSliderBar(10, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255,255,0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0,0,255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
            }))

            local satBar, satGrad, satDot = makeSliderBar(34, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(1, color),
            }))

            local valBar, valGrad, valDot = makeSliderBar(58, ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(0,0,0)),
                ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
            }))

            local hexInput = Instance.new("TextBox", colorPanel)
            hexInput.Size = UDim2.new(1, -20, 0, 24)
            hexInput.Position = UDim2.new(0, 10, 0, 80)
            hexInput.BackgroundColor3 = ActiveTheme.Secondary
            hexInput.Text = ""
            hexInput.PlaceholderText = "#RRGGBB"
            hexInput.TextColor3 = ActiveTheme.Text
            hexInput.PlaceholderColor3 = ActiveTheme.DarkText
            hexInput.Font = Enum.Font.Gotham
            hexInput.TextSize = 12
            hexInput.ZIndex = 11
            Instance.new("UICorner", hexInput).CornerRadius = UDim.new(0, 6)

            local h, s, v = Color3.toHSV(color)

            local function updateColor()
                color = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = color
                satGrad.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV(h,1,1)),
                })
                hexInput.Text = string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
                callback(color)
            end

            local function bindBar(bar, dot, onChange)
                bar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        local function move(i)
                            local val2 = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                            dot.Position = UDim2.new(val2, -7, 0.5, -7)
                            onChange(val2)
                            updateColor()
                        end
                        move(inp)
                        local conn = RunService.RenderStepped:Connect(function() move(UserInputService:GetMouseLocation()) end)
                        local ec
                        ec = UserInputService.InputEnded:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() ec:Disconnect() end
                        end)
                    end
                end)
            end

            bindBar(hueBar, hueDot, function(val2) h = val2 end)
            bindBar(satBar, satDot, function(val2) s = val2 end)
            bindBar(valBar, valDot, function(val2) v = val2 end)

            hexInput.FocusLost:Connect(function()
                local hex = hexInput.Text:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g2 = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g2 and b then
                        color = Color3.fromRGB(r, g2, b)
                        h, s, v = Color3.toHSV(color)
                        preview.BackgroundColor3 = color
                        callback(color)
                    end
                end
            end)

            picker.MouseButton1Click:Connect(function()
                open = not open
                Tween(colorPanel, "Size", UDim2.new(1, 0, 0, open and 114 or 0), 0.35)
            end)

            return {
                Get = function() return color end,
                Set = function(_, c)
                    color = c
                    h, s, v = Color3.toHSV(color)
                    preview.BackgroundColor3 = color
                    callback(color)
                end
            }
        end

        return Tab
    end

    function Window:SaveConfig(name)
        local config = {}
        writefile(name .. ".json", HttpService:JSONEncode(config))
        Moxie:Notify(Config.LibraryName, "Config saved: " .. name, 3)
    end

    function Window:LoadConfig(name)
        if isfile(name .. ".json") then
            local config = HttpService:JSONDecode(readfile(name .. ".json"))
            Moxie:Notify(Config.LibraryName, "Config loaded: " .. name, 3)
            return config
        else
            Moxie:Notify(Config.LibraryName, "No config found: " .. name, 3)
        end
    end

    return Window
end

return Moxie
