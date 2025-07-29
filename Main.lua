local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Workspace = game:GetService("Workspace")

local HIGHLIGHT_COLOR = Color3.fromRGB(0, 255, 255)
local HIGHLIGHT_TRANSPARENCY_FILL = 0.3
local HIGHLIGHT_TRANSPARENCY_OUTLINE = 0.5

local RANDOMIZE_COOLDOWN_TIME = 5
local AUTO_RANDOMIZE_INTERVAL = 5
local PET_LEVEL_UP_COOLDOWN_TIME = 5
local MUTATION_MANUAL_RANDOMIZE_COOLDOWN = 5

local MIN_KG = 7.0
local MAX_KG = 9.0

local highlightingEnabled = false
local autoRandomizeEnabled = false
local stopOnRarestEnabled = false
local playerFarm = nil
local highlightedObjects = {}
local activeConnections = {}
local lastRandomizeTime = 0
local lastPetLevelUpTime = 0
local lastMutationManualRandomizeTime = 0
local autoRandomizeLoop = nil
local isMinimized = false

local mutationESPToggleEnabled = false
local petMutationMachinePoofPart = nil
local mutationBillboardGui = nil
local mutationTextLabel = nil
local currentMutationEffectTask = nil

local EGG_CONTENTS = {
    ["Anti Bee Egg"] = {
        {name = "Wasp", chance = 55},
        {name = "Tarantula Hawk", chance = 30},
        {name = "Moth", chance = 13.75},
        {name = "Butterfly", chance = 1},
        {name = "Disco Bee", chance = 0.25},
    },
    ["Bee Egg"] = {
        {name = "Bee", chance = 65},
        {name = "Honey Bee", chance = 25},
        {name = "Bear Bee", chance = 5},
        {name = "Petal Bee", chance = 4},
        {name = "Queen Bee", chance = 1},
    },
    ["Bug Egg"] = {
        {name = "Snail", chance = 40},
        {name = "Giant Ant", chance = 30},
        {name = "Caterpillar", chance = 25},
        {name = "Praying Mantis", chance = 4},
        {name = "Dragonfly", chance = 1},
    },
    ["Common Egg"] = {
        {name = "Golden Lab", chance = 33.33},
        {name = "Dog", chance = 33.33},
        {name = "Bunny", chance = 33.33},
    },
    ["Common Summer Egg"] = {
        {name = "Starfish", chance = 50},
        {name = "Seagull", chance = 25},
        {name = "Crab", chance = 25},
    },
    ["Dinosaur Egg"] = {
        {name = "Raptor", chance = 35},
        {name = "Triceratops", chance = 32.5},
        {name = "Stegosaurus", chance = 28},
        {name = "Pterodactyl", chance = 3},
        {name = "Brontosaurus", chance = 1},
        {name = "T-Rex", chance = 0.5},
    },
    ["Exotic Bug Egg"] = { {name = "Unknown Exotic Bug Pet", chance = 100} },
    ["Legendary Egg"] = {
        {name = "Cow", chance = 42.55},
        {name = "Silver Monkey", chance = 42.55},
        {name = "Sea Otter", chance = 10.64},
        {name = "Turtle", chance = 2.13},
        {name = "Polar Bear", chance = 2.13},
    },
    ["Mythical Egg"] = {
        {name = "Grey Mouse", chance = 35.71},
        {name = "Brown Mouse", chance = 26.79},
        {name = "Squirrel", chance = 26.79},
        {name = "Red Giant Ant", chance = 8.93},
        {name = "Red Fox", chance = 1.79},
    },
    ["Night Egg"] = {
        {name = "Hedgehog", chance = 49},
        {name = "Mole", chance = 22},
        {name = "Frog", chance = 14},
        {name = "Echo Frog", chance = 10},
        {name = "Night Owl", chance = 4},
        {name = "Raccoon", chance = 1},
    },
    ["Oasis Egg"] = {
        {name = "Meerkat", chance = 45},
        {name = "Sand Snake", chance = 34.5},
        {name = "Axolotl", chance = 15},
        {name = "Hyacinth Macaw", chance = 5},
        {name = "Fennec Fox", chance = 0.5},
    },
    ["Paradise Egg"] = {
        {name = "Ostrich", chance = 40},
        {name = "Peacock", chance = 30},
        {name = "Capybara", chance = 21},
        {name = "Scarlet Macaw", chance = 8},
        {name = "Mimic Octopus", chance = 1},
    },
    ["Premium Anti Bee Egg"] = {
        {name = "Wasp", chance = 55},
        {name = "Tarantula Hawk", chance = 30},
        {name = "Moth", chance = 13.75},
        {name = "Butterfly", chance = 1},
        {name = "Disco Bee", chance = 0.25},
    },
    ["Premium Night Egg"] = {
        {name = "Hedgehog", chance = 49},
        {name = "Mole", chance = 22},
        {name = "Frog", chance = 14},
        {name = "Echo Frog", chance = 10},
        {name = "Night Owl", chance = 4},
        {name = "Raccoon", chance = 1},
    },
    ["Premium Oasis Egg"] = {
        {name = "Meerkat", chance = 45},
        {name = "Sand Snake", chance = 34.5},
        {name = "Axolotl", chance = 15},
        {name = "Hyacinth Macaw", chance = 5},
        {name = "Fennec Fox", chance = 0.5},
    },
    ["Premium Primal Egg"] = {
        {name = "Parasaurolophus", chance = 34},
        {name = "Iguanodon", chance = 32.5},
        {name = "Pachycephalosaurus", chance = 28},
        {name = "Dilophosaurus", chance = 3},
        {name = "Ankylosaurus", chance = 1},
        {name = "Spinosaurus", chance = 0.5},
    },
    ["Primal Egg"] = {
        {name = "Parasaurolophus", chance = 34},
        {name = "Iguanodon", chance = 32.5},
        {name = "Pachycephalosaurus", chance = 28},
        {name = "Dilophosaurus", chance = 3},
        {name = "Ankylosaurus", chance = 1},
        {name = "Spinosaurus", chance = 0.5},
    },
    ["Rainbow Premium Primal Egg"] = {
        {name = "Parasaurolophus", chance = 34},
        {name = "Iguanodon", chance = 32.5},
        {name = "Pachycephalosaurus", chance = 28},
        {name = "Dilophosaurus", chance = 3},
        {name = "Ankylosaurus", chance = 1},
        {name = "Spinosaurus", chance = 0.5},
    },
    ["Rare Egg"] = {
        {name = "Orange Tabby", chance = 33.33},
        {name = "Spotted Deer", chance = 25},
        {name = "Pig", chance = 16.67},
        {name = "Rooster", chance = 16.67},
        {name = "Monkey", chance = 8.33},
    },
    ["Rare Summer Egg"] = {
        {name = "Sea Turtle", chance = 33.33},
        {name = "Flamingo", chance = 16.67},
        {name = "Toucan", chance = 25},
        {name = "Seal", chance = 10},
        {name = "Orangutan", chance = 4},
    },
    ["Uncommon Egg"] = {
        {name = "Black Bunny", chance = 25},
        {name = "Chicken", chance = 25},
        {name = "Cat", chance = 25},
        {name = "Deer", chance = 25},
    },
    ["Zen Egg"] = {
        {name = "Shiba Inu", chance = 40},
        {name = "Nihonzaru", chance = 31},
        {name = "Tanuki", chance = 20.82},
        {name = "Tanchozuru", chance = 4.6},
        {name = "Kappa", chance = 3.5},
        {name = "Kitsune", chance = 0.08},
    },
}

local MUTATION_CONTENTS = {
    {name = "Shiny", chance = 31.15, color = Color3.fromRGB(170, 255, 255)},
    {name = "Inverted", chance = 15.58, color = Color3.fromRGB(150, 150, 150)},
    {name = "Windy", chance = 9.35, color = Color3.fromRGB(100, 150, 255)},
    {name = "Galaxy", chance = 8.5, color = Color3.fromRGB(150, 0, 200)},
    {name = "Lava", chance = 7.7, color = Color3.fromRGB(255, 80, 0)},
    {name = "Glitched", chance = 6.9, color = Color3.fromRGB(255, 0, 255)},
    {name = "Void", chance = 6.0, color = Color3.fromRGB(0, 0, 0)},
    {name = "Toxic", chance = 5.0, color = Color3.fromRGB(0, 200, 0)},
    {name = "Ice", chance = 4.0, color = Color3.fromRGB(0, 200, 255)},
    {name = "Rainbow", chance = 1.0, color = Color3.fromRGB(255, 255, 0)},
    {name = "Cosmic", chance = 0.3, color = Color3.fromRGB(200, 0, 200)},
}

local mainGui = Instance.new("ScreenGui")
mainGui.Name = "CoolEggESPGUI"
mainGui.ResetOnSpawn = false
mainGui.Parent = PlayerGui
mainGui.Enabled = true

local frame = Instance.new("Frame")
frame.Name = "ControlFrame"
frame.Size = UDim2.new(0, 300, 0, 500)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = mainGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 15)
uiCorner.Parent = frame

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
}
uiGradient.Rotation = 90
uiGradient.Parent = frame

local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.fromRGB(60, 60, 60)
uiStroke.Thickness = 2
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.Text = "Pixiemo Hub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.TextSize = 28
titleLabel.BackgroundTransparency = 1
titleLabel.Parent = frame

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -35, 0, 5)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeButton.Font = Enum.Font.FredokaOne
minimizeButton.TextSize = 20
minimizeButton.Parent = frame

local minimizeButtonCorner = Instance.new("UICorner")
minimizeButtonCorner.CornerRadius = UDim.new(0, 5)
minimizeButtonCorner.Parent = minimizeButton

local minimizeButtonStroke = Instance.new("UIStroke")
minimizeButtonStroke.Color = Color3.fromRGB(50, 50, 50)
minimizeButtonStroke.Thickness = 1.5
minimizeButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
minimizeButtonStroke.Parent = minimizeButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 40)
statusLabel.Position = UDim2.new(0, 0, 0, titleLabel.Size.Y.Offset)
statusLabel.Text = "Status:\nINACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 16
statusLabel.TextWrapped = true
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = frame
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

local contentFrameYOffset = titleLabel.Size.Y.Offset + statusLabel.Size.Y.Offset
local contentFrameHeightOffset = -(titleLabel.Size.Y.Offset + statusLabel.Size.Y.Offset + 80)

local mainControlsContainer = Instance.new("Frame")
mainControlsContainer.Name = "MainControlsContainer"
mainControlsContainer.Size = UDim2.new(1, 0, 1, contentFrameHeightOffset)
mainControlsContainer.Position = UDim2.new(0, 0, 0, contentFrameYOffset)
mainControlsContainer.BackgroundTransparency = 1
mainControlsContainer.Parent = frame

local mainControlsListLayout = Instance.new("UIListLayout")
mainControlsListLayout.FillDirection = Enum.FillDirection.Vertical
mainControlsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mainControlsListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
mainControlsListLayout.Padding = UDim.new(0, 10)
mainControlsListLayout.Parent = mainControlsContainer

local mainControlsUiPadding = Instance.new("UIPadding")
mainControlsUiPadding.PaddingTop = UDim.new(0, 20)
mainControlsUiPadding.PaddingBottom = UDim.new(0, 20)
mainControlsUiPadding.PaddingLeft = UDim.new(0, 20)
mainControlsUiPadding.PaddingRight = UDim.new(0, 20)
mainControlsUiPadding.Parent = mainControlsContainer

local function createStyledButton(name, text, bgColor, strokeColor)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 45)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = bgColor
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = strokeColor
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button

    return button
end

local TOGGLE_WIDTH = 260
local TOGGLE_HEIGHT = 45
local THUMB_SIZE = 35
local TOGGLE_PADDING = 5

local TOGGLE_ON_COLOR = Color3.fromRGB(0, 200, 0)
local TOGGLE_OFF_COLOR = Color3.fromRGB(150, 0, 0)
local TOGGLE_THUMB_COLOR = Color3.fromRGB(255, 255, 255)
local TOGGLE_STROKE_COLOR_ON = Color3.fromRGB(0, 150, 0)
local TOGGLE_STROKE_COLOR_OFF = Color3.fromRGB(100, 0, 0)

local function createToggleSwitch(name, text, defaultState)
    local toggleBase = Instance.new("Frame")
    toggleBase.Name = name
    toggleBase.Size = UDim2.new(0, TOGGLE_WIDTH, 0, TOGGLE_HEIGHT)
    toggleBase.BackgroundColor3 = defaultState and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
    toggleBase.BackgroundTransparency = 0.1
    toggleBase.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, TOGGLE_HEIGHT / 2)
    corner.Parent = toggleBase

    local stroke = Instance.new("UIStroke")
    stroke.Color = defaultState and TOGGLE_STROKE_COLOR_ON or TOGGLE_STROKE_COLOR_OFF
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = toggleBase

    local toggleText = Instance.new("TextLabel")
    toggleText.Name = "ToggleText"
    toggleText.Size = UDim2.new(1, -(THUMB_SIZE + TOGGLE_PADDING * 2), 1, 0)
    toggleText.Position = defaultState and UDim2.new(0, TOGGLE_PADDING, 0, 0) or UDim2.new(0, THUMB_SIZE + TOGGLE_PADDING, 0, 0)
    toggleText.Text = text .. (defaultState and ": ON" or ": OFF")
    toggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleText.Font = Enum.Font.GothamBold
    toggleText.TextSize = 16
    toggleText.TextXAlignment = defaultState and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    toggleText.BackgroundTransparency = 1
    toggleText.Parent = toggleBase

    local toggleThumb = Instance.new("Frame")
    toggleThumb.Name = "ToggleThumb"
    toggleThumb.Size = UDim2.new(0, THUMB_SIZE, 0, THUMB_SIZE)
    toggleThumb.BackgroundColor3 = TOGGLE_THUMB_COLOR
    toggleThumb.BorderSizePixel = 0
    toggleThumb.Position = defaultState and UDim2.new(1, -THUMB_SIZE - TOGGLE_PADDING, 0.5, -THUMB_SIZE/2) or UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
    toggleThumb.Parent = toggleBase

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, THUMB_SIZE / 2)
    thumbCorner.Parent = toggleThumb

    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.Active = true
    clickDetector.Parent = toggleBase

    return toggleBase, toggleThumb, toggleText, clickDetector
end

local espToggleBase, espToggleThumb, espToggleText, espClickDetector
    = createToggleSwitch("ESPToggle", "EGG ESP", highlightingEnabled)
espToggleText.TextXAlignment = Enum.TextXAlignment.Center
espToggleBase.Parent = mainControlsContainer

local autoRandomizeToggleBase, autoRandomizeToggleThumb, autoRandomizeToggleText, autoRandomizeClickDetector
    = createToggleSwitch("AutoRandomizeToggle", "Auto Randomize", autoRandomizeEnabled)
autoRandomizeToggleBase.Parent = mainControlsContainer

local rarestPetStopToggleBase, rarestPetStopToggleThumb, rarestPetStopToggleText, rarestPetStopClickDetector
    = createToggleSwitch("RarestStopToggle", "Auto Stop on Rarest", stopOnRarestEnabled)
rarestPetStopToggleBase.Parent = mainControlsContainer

local randomizeButton = createStyledButton("RandomizeButton", "Randomize Egg Pets (Manual)", Color3.fromRGB(255, 100, 0), Color3.fromRGB(200, 80, 0))
randomizeButton.Parent = mainControlsContainer

local otherScriptsButton = createStyledButton("OtherScriptsButton", "Other Scripts", Color3.fromRGB(60, 60, 60), Color3.fromRGB(40, 40, 40))
otherScriptsButton.Parent = mainControlsContainer

local otherScriptsContentFrame = Instance.new("Frame")
otherScriptsContentFrame.Name = "OtherScriptsContentFrame"
otherScriptsContentFrame.Size = UDim2.new(1, 0, 1, contentFrameHeightOffset)
otherScriptsContentFrame.Position = UDim2.new(1, 0, 0, contentFrameYOffset)
otherScriptsContentFrame.BackgroundTransparency = 1
otherScriptsContentFrame.BorderSizePixel = 0
otherScriptsContentFrame.Visible = false
otherScriptsContentFrame.Parent = frame

local otherScriptsListLayout = Instance.new("UIListLayout")
otherScriptsListLayout.FillDirection = Enum.FillDirection.Vertical
otherScriptsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
otherScriptsListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
otherScriptsListLayout.Padding = UDim.new(0, 10)
otherScriptsListLayout.Parent = otherScriptsContentFrame

local otherScriptsUiPadding = Instance.new("UIPadding")
otherScriptsUiPadding.PaddingTop = UDim.new(0, 20)
otherScriptsUiPadding.PaddingBottom = UDim.new(0, 20)
otherScriptsUiPadding.PaddingLeft = UDim.new(0, 20)
otherScriptsUiPadding.PaddingRight = UDim.new(0, 20)
otherScriptsUiPadding.Parent = otherScriptsContentFrame

local comingSoon1Button = createStyledButton("ComingSoon1Button", "Level Up Pet to 50", Color3.fromRGB(0, 150, 100), Color3.fromRGB(0, 100, 70))
comingSoon1Button.Parent = otherScriptsContentFrame

local comingSoon2Button = createStyledButton("ComingSoon2Button", "Mutation Scripts", Color3.fromRGB(100, 0, 150), Color3.fromRGB(70, 0, 100))
comingSoon2Button.Parent = otherScriptsContentFrame

local backToMainButton = createStyledButton("BackToMainButton", "Back to Main", Color3.fromRGB(0, 100, 150), Color3.fromRGB(0, 70, 100))
backToMainButton.Parent = otherScriptsContentFrame

local mutationScriptsContentFrame = Instance.new("Frame")
mutationScriptsContentFrame.Name = "MutationScriptsContentFrame"
mutationScriptsContentFrame.Size = UDim2.new(1, 0, 1, contentFrameHeightOffset)
mutationScriptsContentFrame.Position = UDim2.new(1, 0, 0, contentFrameYOffset)
mutationScriptsContentFrame.BackgroundTransparency = 1
mutationScriptsContentFrame.BorderSizePixel = 0
mutationScriptsContentFrame.Visible = false
mutationScriptsContentFrame.Parent = frame

local mutationScriptsListLayout = Instance.new("UIListLayout")
mutationScriptsListLayout.FillDirection = Enum.FillDirection.Vertical
mutationScriptsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
mutationScriptsListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
mutationScriptsListLayout.Padding = UDim.new(0, 10)
mutationScriptsListLayout.Parent = mutationScriptsContentFrame

local mutationScriptsUiPadding = Instance.new("UIPadding")
mutationScriptsUiPadding.PaddingTop = UDim.new(0, 20)
mutationScriptsUiPadding.PaddingBottom = UDim.new(0, 20)
mutationScriptsUiPadding.PaddingLeft = UDim.new(0, 20)
mutationScriptsUiPadding.PaddingRight = UDim.new(0, 20)
mutationScriptsUiPadding.Parent = mutationScriptsContentFrame

local mutationESPToggleBase, mutationESPToggleThumb, mutationESPToggleText, mutationESPClickDetector
    = createToggleSwitch("MutationESPToggle", "Mutation ESP", mutationESPToggleEnabled)
mutationESPToggleBase.Parent = mutationScriptsContentFrame

local manualMutationRandomizeButton = createStyledButton("ManualMutationRandomizeButton", "Randomize Mutation", Color3.fromRGB(150, 50, 200), Color3.fromRGB(100, 30, 150))
manualMutationRandomizeButton.Parent = mutationScriptsContentFrame

local backToOtherScriptsButton = createStyledButton("BackToOtherScriptsButton", "Back to Other Scripts", Color3.fromRGB(0, 100, 150), Color3.fromRGB(0, 70, 100))
backToOtherScriptsButton.Parent = mutationScriptsContentFrame

local bottomInfoContainer = Instance.new("Frame")
bottomInfoContainer.Name = "BottomInfoContainer"
bottomInfoContainer.Size = UDim2.new(1, 0, 0, 80)
bottomInfoContainer.Position = UDim2.new(0, 0, 1, -80)
bottomInfoContainer.AnchorPoint = Vector2.new(0, 0)
bottomInfoContainer.BackgroundTransparency = 1
bottomInfoContainer.Parent = frame

local bottomListLayout = Instance.new("UIListLayout")
bottomListLayout.FillDirection = Enum.FillDirection.Vertical
bottomListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bottomListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
bottomListLayout.Padding = UDim.new(0, 5)
bottomListLayout.Parent = bottomInfoContainer

local authorLabel = Instance.new("TextLabel")
authorLabel.Name = "AuthorLabel"
authorLabel.Size = UDim2.new(1, 0, 0, 20)
authorLabel.Text = "by @Pixiemo"
authorLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
authorLabel.Font = Enum.Font.FredokaOne
authorLabel.TextSize = 16
authorLabel.BackgroundTransparency = 1
authorLabel.Parent = bottomInfoContainer

local versionLabel = Instance.new("TextLabel")
versionLabel.Name = "VersionLabel"
versionLabel.Size = UDim2.new(1, 0, 0, 20)
versionLabel.Text = "v2.15"
versionLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
versionLabel.Font = Enum.Font.FredokaOne
versionLabel.TextSize = 14
versionLabel.BackgroundTransparency = 1
versionLabel.Parent = bottomInfoContainer

espToggleBase.LayoutOrder = 1
autoRandomizeToggleBase.LayoutOrder = 2
rarestPetStopToggleBase.LayoutOrder = 3
randomizeButton.LayoutOrder = 4
otherScriptsButton.LayoutOrder = 5

local function addConnection(connection)
    table.insert(activeConnections, connection)
end

local function unhighlightInstance(instanceToUnhighlight)
    local highlightComponents = highlightedObjects[instanceToUnhighlight]
    if highlightComponents then
        local highlightObject = highlightComponents[1]
        if highlightObject and highlightObject.Parent then
            highlightObject:Destroy()
        end
        local billboardGui = highlightComponents[2]
        if billboardGui and billboardGui.Parent then
            billboardGui:Destroy()
        end
        highlightedObjects[instanceToUnhighlight] = nil
    end
end

local function getRandomPetFromEgg(eggType)
    local contents = EGG_CONTENTS[eggType]
    if not contents then
        return "???"
    end

    local totalChance = 0
    for _, petInfo in ipairs(contents) do
        totalChance = totalChance + petInfo.chance
    end

    local randomNumber = math.random() * totalChance

    local cumulativeChance = 0
    for _, petInfo in ipairs(contents) do
        cumulativeChance = cumulativeChance + petInfo.chance
        if randomNumber <= cumulativeChance then
            return petInfo.name
        end
    end

    return contents[1].name
end

local function getMostCommonPet(eggType)
    local contents = EGG_CONTENTS[eggType]
    if not contents or #contents == 0 then
        return "???"
    end

    local mostCommon = contents[1]
    for i = 2, #contents do
        if contents[i].chance > mostCommon.chance then
            mostCommon = contents[i]
        end
    end
    return mostCommon.name
end

local function getRarestPet(eggType)
    local contents = EGG_CONTENTS[eggType]
    if not contents or #contents == 0 then
        return nil
    end

    local rarest = contents[1]
    for i = 2, #contents do
        if contents[i].chance < rarest.chance then
            rarest = contents[i]
        end
    end
    return rarest.name
end

local function highlightInstance(instanceToHighlight)
    if not highlightingEnabled then
        return
    end
    if highlightedObjects[instanceToHighlight] then
        return
    end

    if instanceToHighlight:IsA("BasePart") or instanceToHighlight:IsA("Model") then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = HIGHLIGHT_COLOR
        highlight.OutlineColor = HIGHLIGHT_COLOR
        highlight.FillTransparency = HIGHLIGHT_TRANSPARENCY_FILL
        highlight.OutlineTransparency = HIGHLIGHT_TRANSPARENCY_OUTLINE
        highlight.Adornee = instanceToHighlight
        highlight.Parent = instanceToHighlight

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Adornee = instanceToHighlight
        billboardGui.AlwaysOnTop = true
        billboardGui.Size = UDim2.new(0, 200, 0, 30)

        local verticalOffset = 1
        if instanceToHighlight:IsA("BasePart") then
            verticalOffset = instanceToHighlight.Size.Y / 2 + 1
        elseif instanceToHighlight:IsA("Model") then
            local success, extentsSize = pcall(function() return instanceToHighlight:GetExtentsSize() end)
            if success and extentsSize then
                verticalOffset = extentsSize.Y / 2 + 1
            else
                local primaryPart = instanceToHighlight.PrimaryPart
                if primaryPart and primaryPart:IsA("BasePart") then
                    verticalOffset = primaryPart.Size.Y / 2 + 1
                end
            end
        end
        billboardGui.StudsOffset = Vector3.new(0, verticalOffset, 0)

        local textLabel = Instance.new("TextLabel")

        local originalName = instanceToHighlight.Name
        local displayName = originalName
        local petNameSuffix = ""

        if string.lower(string.sub(displayName, 1, 3)) == "pet" then
            if string.lower(displayName) == "petegg" then
                displayName = "Egg"
            else
                displayName = string.gsub(displayName, "^[Pp]et", "")
                displayName = string.gsub(displayName, "^%s*(.-)%s*$", "%1")
            end
        end

        local eggSuffixPattern = "[Ee][Gg][Gg]$"

        if string.find(displayName, eggSuffixPattern) and string.lower(displayName) ~= "egg" then
            local prefix = string.gsub(displayName, eggSuffixPattern, "")
            prefix = string.gsub(prefix, "%s*$", "")
            if prefix ~= "" then
                displayName = prefix .. " Egg"
            else
                displayName = "Egg"
            end
        end

        local formattedEggName = displayName
        local eggContents = EGG_CONTENTS[formattedEggName]
        if eggContents then
            petNameSuffix = " (" .. getMostCommonPet(formattedEggName) .. ")"
        else
            petNameSuffix = " (Unknown Pet)"
        end

        local fullText = formattedEggName .. " 🥚" .. petNameSuffix
        textLabel.Text = fullText
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.2
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.FredokaOne
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Parent = billboardGui

        billboardGui.Parent = instanceToHighlight

        highlightedObjects[instanceToHighlight] = {highlight, billboardGui, fullText, textLabel, formattedEggName}
    else
    end
end

local function processInstance(instance)
    if not instance or not instance.Parent then
        unhighlightInstance(instance)
        return
    end

    local lowerCaseName = string.lower(instance.Name)
    local isPotentialEgg = false

    if string.find(lowerCaseName, "egg") and lowerCaseName ~= "egg" and lowerCaseName ~= "petegg" then
        isPotentialEgg = true
    end

    local formattedEggName = lowerCaseName
    if string.lower(string.sub(formattedEggName, 1, 3)) == "pet" then
        formattedEggName = string.gsub(formattedEggName, "^[Pp]et", "")
        formattedEggName = string.gsub(formattedEggName, "^%s*(.-)%s*$", "%1")
    end
    formattedEggName = string.gsub(formattedEggName, "[Ee][Gg][Gg]$", " 🥚")
    formattedEggName = string.gsub(formattedEggName, "%s*$", "")

    local isKnownEggType = EGG_CONTENTS[formattedEggName] ~= nil
    if isKnownEggType then
    end

    if (isPotentialEgg or isKnownEggType) and (instance:IsA("BasePart") or instance:IsA("Model")) then
        local isChildOfHighlightedEgg = false
        local currentParent = instance.Parent
        while currentParent and currentParent ~= Workspace and currentParent ~= playerFarm do
            if highlightedObjects[currentParent] then
                isChildOfHighlightedEgg = true
                break
            end
            currentParent = currentParent.Parent
        end

        if not isChildOfHighlightedEgg then
            if highlightingEnabled then
                highlightInstance(instance)
            else
                unhighlightInstance(instance)
            end
        else
            unhighlightInstance(instance)
        end
    else
        unhighlightInstance(instance)
    end
end

local function monitorContainerForEggs(container)
    if not container then return end

    if highlightingEnabled then
        for _, instance in ipairs(container:GetDescendants()) do
            processInstance(instance)
        end
    end

    addConnection(container.DescendantAdded:Connect(function(descendant)
        processInstance(descendant)
        if descendant:IsA("BasePart") or descendant:IsA("Model") then
            addConnection(descendant.Changed:Connect(function(property)
                if property == "Name" then
                    processInstance(descendant)
                end
            end))
        end
    end))

    addConnection(container.DescendantRemoving:Connect(function(descendant)
        unhighlightInstance(descendant)
    end))

    for _, instance in ipairs(container:GetDescendants()) do
        if instance:IsA("BasePart") or instance:IsA("Model") then
            addConnection(instance.Changed:Connect(function(property)
                if property == "Name" then
                    processInstance(instance)
                end
            end))
        end
    end
end

local function isPlayerFarm(instance)
    if not instance or (not instance:IsA("Model") and not instance:IsA("Folder")) then
        return false
    end

    local importantFolder = instance:FindFirstChild("Important")
    if not importantFolder or (not importantFolder:IsA("Model") and not importantFolder:IsA("Folder")) then
        return false
    end

    local dataFolder = importantFolder:FindFirstChild("Data")
    if not dataFolder or (not dataFolder:IsA("Model") and not dataFolder:IsA("Folder")) then
        return false
    end

    local ownerValue = dataFolder:FindFirstChild("Owner") or dataFolder:FindFirstChild("FarmOwner")

    if ownerValue and ownerValue:IsA("StringValue") and ownerValue.Value == LocalPlayer.Name then
        return true
    end

    return false
end

local function findAndMonitorPlayerFarm()
    local workspace = game:GetService("Workspace")
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if isPlayerFarm(descendant) then
            playerFarm = descendant
            break
        end
    end

    if not playerFarm then
        local startTime = tick()
        repeat
            for _, descendant in ipairs(workspace:GetDescendants()) do
                if isPlayerFarm(descendant) then
                    playerFarm = descendant
                    break
                end
            end
        until playerFarm or (tick() - startTime > 5)
    end

    if playerFarm then
        monitorContainerForEggs(playerFarm)
    else
        addConnection(workspace.DescendantAdded:Connect(function(descendant)
            if isPlayerFarm(descendant) then
                playerFarm = descendant
                monitorContainerForEggs(playerFarm)
            end
        end))
    end
end

local function performRandomization()
    local eggsRandomized = 0
    local foundRarest = false
    local rarestPetFoundName = ""

    for instance, components in pairs(highlightedObjects) do
        local textLabel = components[4]
        local formattedEggName = components[5]
        if textLabel and formattedEggName then
            local randomizedPet = getRandomPetFromEgg(formattedEggName)
            local rarestPet = getRarestPet(formattedEggName)

            textLabel.Text = formattedEggName .. " 🥚 (" .. randomizedPet .. ")"
            eggsRandomized = eggsRandomized + 1

            if randomizedPet == rarestPet then
                textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                if stopOnRarestEnabled then
                    foundRarest = true
                    rarestPetFoundName = randomizedPet
                end
            else
                textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
    end

    if autoRandomizeEnabled then
        if foundRarest and stopOnRarestEnabled then
            autoRandomizeEnabled = false
            if autoRandomizeLoop then
                task.cancel(autoRandomizeLoop)
                autoRandomizeLoop = nil
            end
            local targetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
            local targetBgColor = TOGGLE_OFF_COLOR
            local targetStrokeColor = TOGGLE_STROKE_COLOR_OFF
            local targetText = "Auto Randomize: OFF X"

            TweenService:Create(autoRandomizeToggleThumb, TweenInfo.new(0.2), {Position = targetPosition}):Play()
            TweenService:Create(autoRandomizeToggleBase, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
            TweenService:Create(autoRandomizeToggleBase.UIStroke, TweenInfo.new(0.2), {Color = targetStrokeColor}):Play()
            autoRandomizeToggleText.Text = targetText
            autoRandomizeToggleText.TextXAlignment = Enum.TextXAlignment.Right


            statusLabel.Text = "Status: RAREST PET FOUND: " .. rarestPetFoundName .. "! Auto-Randomize Stopped."
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        else
            statusLabel.Text = "Status: Auto-Randomizing... (" .. eggsRandomized .. " eggs updated)"
            statusLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
        end
    else
        statusLabel.Text = "Status: Randomized " .. eggsRandomized .. " eggs! Checked"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
    end
end

local function startAutoRandomize()
    if autoRandomizeLoop then return end
    autoRandomizeLoop = task.spawn(function()
        while autoRandomizeEnabled do
            performRandomization()
            task.wait(AUTO_RANDOMIZE_INTERVAL)
        end
        autoRandomizeLoop = nil
    end)
end

local function getRandomMutation()
    local totalChance = 0
    for _, mutInfo in ipairs(MUTATION_CONTENTS) do
        totalChance = totalChance + mutInfo.chance
    end

    local randomNumber = math.random() * totalChance
    local cumulativeChance = 0

    for _, mutInfo in ipairs(MUTATION_CONTENTS) do
        cumulativeChance = cumulativeChance + mutInfo.chance
        if randomNumber <= cumulativeChance then
            return mutInfo
        end
    end
    return MUTATION_CONTENTS[1]
end

local function updateMutationText(mutationName, mutationColor)
    if mutationTextLabel then
        mutationTextLabel.Text = "Next Mutation: " .. mutationName
        if mutationName == "Rainbow" then
            if not currentMutationEffectTask then
                currentMutationEffectTask = task.spawn(function()
                    local hue = 0
                    while mutationTextLabel and mutationTextLabel.Parent and mutationESPToggleEnabled do
                        hue = (hue + 0.05) % 1
                        mutationTextLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                        task.wait()
                    end
                    currentMutationEffectTask = nil
                    if not mutationESPToggleEnabled then
                        mutationTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end)
            end
        else
            if currentMutationEffectTask then
                task.cancel(currentMutationEffectTask)
                currentMutationEffectTask = nil
            end
            mutationTextLabel.TextColor3 = mutationColor
        end
    end
end

local function highlightMutationMachine(part)
    if not part or not mutationESPToggleEnabled then return end

    if not mutationBillboardGui then
        mutationBillboardGui = Instance.new("BillboardGui")
        mutationBillboardGui.Name = "MutationESPGUI"
        mutationBillboardGui.Adornee = part
        mutationBillboardGui.AlwaysOnTop = true
        mutationBillboardGui.Size = UDim2.new(0, 250, 0, 40)
        mutationBillboardGui.StudsOffset = Vector3.new(0, part.Size.Y / 2 + 1, 0)

        mutationTextLabel = Instance.new("TextLabel")
        mutationTextLabel.Name = "MutationTextLabel"
        mutationTextLabel.Size = UDim2.new(1, 0, 1, 0)
        mutationTextLabel.BackgroundTransparency = 1
        mutationTextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        mutationTextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        mutationTextLabel.TextStrokeTransparency = 0.2
        mutationTextLabel.Font = Enum.Font.FredokaOne
        mutationTextLabel.TextSize = 20
        mutationTextLabel.TextWrapped = true
        mutationTextLabel.Parent = mutationBillboardGui

        mutationBillboardGui.Parent = part
    end
    local randomMutation = getRandomMutation()
    updateMutationText(randomMutation.name, randomMutation.color)
end

local function unhighlightMutationMachine()
    if mutationBillboardGui then
        if currentMutationEffectTask then
            task.cancel(currentMutationEffectTask)
            currentMutationEffectTask = nil
        end
        mutationBillboardGui:Destroy()
        mutationBillboardGui = nil
        mutationTextLabel = nil
    end
end

local function findPetMutationMachine()
    local findMachine = function()
        for _, descendant in ipairs(Workspace:GetDescendants()) do
            if descendant.Name == "PetMutationMachinePoof" and descendant:IsA("BasePart") then
                petMutationMachinePoofPart = descendant
                break
            end
        end
    end

    findMachine()

    if petMutationMachinePoofPart then
        if mutationESPToggleEnabled then
            highlightMutationMachine(petMutationMachinePoofPart)
        end
    else
        statusLabel.Text = "Status: Waiting for Mutation Machine to load..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)

        addConnection(Workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "PetMutationMachinePoof" and descendant:IsA("BasePart") then
                petMutationMachinePoofPart = descendant
                if mutationESPToggleEnabled then
                    highlightMutationMachine(petMutationMachinePoofPart)
                end
                statusLabel.Text = "Status: Mutation Machine Found!"
                statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
            end
        end))
        addConnection(Workspace.DescendantRemoving:Connect(function(descendant)
            if descendant == petMutationMachinePoofPart then
                petMutationMachinePoofPart = nil
                unhighlightMutationMachine()
                statusLabel.Text = "Status: Mutation Machine Missing!"
                statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end))
    end
end

local function randomizePetMutation()
    if not petMutationMachinePoofPart or not mutationESPToggleEnabled then
        statusLabel.Text = "Status: Mutation ESP not active or machine not found!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end

    local randomMutation = getRandomMutation()
    updateMutationText(randomMutation.name, randomMutation.color)
    statusLabel.Text = "Status: Manual Mutation Randomized!"
    statusLabel.TextColor3 = Color3.fromRGB(150, 50, 200)
end

local function levelUpEquippedPet()
    local equippedTool = nil

    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then
                equippedTool = item
                break
            end
        end
    end

    if not equippedTool then
        statusLabel.Text = "Status: No tool equipped! Equip a pet."
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end

    local attributes = equippedTool:GetAttributes()
    if attributes["ItemType"] == "Pet" then
        local pattern = "(.-)%s*%[(%d+%.%d+) KG%]%s*%[Age (%d+)%]"
        local baseName = equippedTool.Name
        local extractedName, kgStr, ageStr = equippedTool.Name:match(pattern)

        local currentKG = nil
        local currentAge = nil

        if extractedName then
            baseName = extractedName:gsub("^%s*(.-)%s*$", "%1")
            currentKG = tonumber(kgStr)
            currentAge = tonumber(ageStr)
        end

        local newKG = math.random(700, 1000) / 100.00
        local newAge = 50

        local newName = string.format("%s [%.2f KG] [Age %d]", baseName, newKG, newAge)

        equippedTool.Name = newName
        statusLabel.Text = "Status: Pet Leveled Up! " .. newName
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
    else
        statusLabel.Text = "Status: Equipped tool is not a pet!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
    end
end

addConnection(espClickDetector.MouseButton1Click:Connect(function()
    highlightingEnabled = not highlightingEnabled

    local targetPosition
    local targetBgColor = highlightingEnabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
    local targetStrokeColor = highlightingEnabled and TOGGLE_STROKE_COLOR_ON or TOGGLE_STROKE_COLOR_OFF
    local targetText = "EGG ESP" .. (highlightingEnabled and ": ON" or ": OFF")
    local targetTextXAlignment

    if highlightingEnabled then
        targetPosition = UDim2.new(1, -THUMB_SIZE - TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
        targetTextXAlignment = Enum.TextXAlignment.Left
    else
        targetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
        targetTextXAlignment = Enum.TextXAlignment.Right
    end

    TweenService:Create(espToggleThumb, TweenInfo.new(0.2), {Position = targetPosition}):Play()
    TweenService:Create(espToggleBase, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
    TweenService:Create(espToggleBase.UIStroke, TweenInfo.new(0.2), {Color = targetStrokeColor}):Play()
    espToggleText.Text = targetText
    espToggleText.TextXAlignment = targetTextXAlignment

    if highlightingEnabled then
        statusLabel.Text = "Status: ACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
        if playerFarm then
            for _, instance in ipairs(playerFarm:GetDescendants()) do
                processInstance(instance)
            end
        else
        end
    else
        statusLabel.Text = "Status: INACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
        for instance, _ in pairs(highlightedObjects) do
            unhighlightInstance(instance)
        end
        highlightedObjects = {}
        if autoRandomizeEnabled then
            autoRandomizeEnabled = false
            if autoRandomizeLoop then
                task.cancel(autoRandomizeLoop)
                autoRandomizeLoop = nil
            end
            local arTargetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
            local arTargetBgColor = TOGGLE_OFF_COLOR
            local arTargetStrokeColor = TOGGLE_STROKE_COLOR_OFF
            local arTargetText = "Auto Randomize: OFF"

            TweenService:Create(autoRandomizeToggleThumb, TweenInfo.new(0.2), {Position = arTargetPosition}):Play()
            TweenService:Create(autoRandomizeToggleBase, TweenInfo.new(0.2), {BackgroundColor3 = arTargetBgColor}):Play()
            TweenService:Create(autoRandomizeToggleBase.UIStroke, TweenInfo.new(0.2), {Color = arTargetStrokeColor}):Play()
            autoRandomizeToggleText.Text = arTargetText
            autoRandomizeToggleText.TextXAlignment = Enum.TextXAlignment.Right
        end
    end
end))

addConnection(randomizeButton.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastRandomizeTime >= RANDOMIZE_COOLDOWN_TIME then
        lastRandomizeTime = currentTime
        performRandomization()
        task.spawn(function()
            randomizeButton.Active = false
            local originalText = randomizeButton.Text
            local originalBgColor = randomizeButton.BackgroundColor3
            local originalStrokeColor = randomizeButton.UIStroke.Color
            for i = RANDOMIZE_COOLDOWN_TIME, 1, -1 do
                randomizeButton.Text = string.format("Cooldown: %02d:%02d", 0, i)
                randomizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                randomizeButton.UIStroke.Color = Color3.fromRGB(30, 30, 30)
                task.wait(1)
            end
            randomizeButton.Active = true
            randomizeButton.Text = originalText
            randomizeButton.BackgroundColor3 = originalBgColor
            randomizeButton.UIStroke.Color = originalStrokeColor
            statusLabel.Text = "Status: Ready to Randomize!"
            statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
        end)
    else
        local timeLeft = math.ceil(RANDOMIZE_COOLDOWN_TIME - (currentTime - lastRandomizeTime))
        statusLabel.Text = "Status: Manual Randomize Cooldown! Wait " .. timeLeft .. "s"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end
end))

addConnection(autoRandomizeClickDetector.MouseButton1Click:Connect(function()
    if not highlightingEnabled then
        statusLabel.Text = "Status: Enable EGG ESP first to Auto-Randomize!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        return
    end

    autoRandomizeEnabled = not autoRandomizeEnabled
    local targetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
    local targetBgColor = TOGGLE_OFF_COLOR
    local targetStrokeColor = TOGGLE_STROKE_COLOR_OFF
    local targetText = "Auto Randomize: OFF"
    local targetTextXAlignment = Enum.TextXAlignment.Right

    if autoRandomizeEnabled then
        targetPosition = UDim2.new(1, -THUMB_SIZE - TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
        targetBgColor = TOGGLE_ON_COLOR
        targetStrokeColor = TOGGLE_STROKE_COLOR_ON
        targetText = "Auto Randomize: ON"
        targetTextXAlignment = Enum.TextXAlignment.Left
    end

    TweenService:Create(autoRandomizeToggleThumb, TweenInfo.new(0.2), {Position = targetPosition}):Play()
    TweenService:Create(autoRandomizeToggleBase, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
    TweenService:Create(autoRandomizeToggleBase.UIStroke, TweenInfo.new(0.2), {Color = targetStrokeColor}):Play()
    autoRandomizeToggleText.Text = targetText
    autoRandomizeToggleText.TextXAlignment = targetTextXAlignment

    if autoRandomizeEnabled then
        statusLabel.Text = "Status: Auto-Randomize ACTIVE!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
        startAutoRandomize()
    else
        if autoRandomizeLoop then
            task.cancel(autoRandomizeLoop)
            autoRandomizeLoop = nil
        end
        statusLabel.Text = "Status: Auto-Randomize INACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
    end
end))

addConnection(rarestPetStopClickDetector.MouseButton1Click:Connect(function()
    stopOnRarestEnabled = not stopOnRarestEnabled
    local targetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
    local targetBgColor = TOGGLE_OFF_COLOR
    local targetStrokeColor = TOGGLE_STROKE_COLOR_OFF
    local targetText = "Auto Stop on Rarest: OFF"
    local targetTextXAlignment = Enum.TextXAlignment.Right

    if stopOnRarestEnabled then
        targetPosition = UDim2.new(1, -THUMB_SIZE - TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
        targetBgColor = TOGGLE_ON_COLOR
        targetStrokeColor = TOGGLE_STROKE_COLOR_ON
        targetText = "Auto Stop on Rarest: ON"
        targetTextXAlignment = Enum.TextXAlignment.Left
    end

    TweenService:Create(rarestPetStopToggleThumb, TweenInfo.new(0.2), {Position = targetPosition}):Play()
    TweenService:Create(rarestPetStopToggleBase, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
    TweenService:Create(rarestPetStopToggleBase.UIStroke, TweenInfo.new(0.2), {Color = targetStrokeColor}):Play()
    rarestPetStopToggleText.Text = targetText
    rarestPetStopToggleText.TextXAlignment = targetTextXAlignment

    if stopOnRarestEnabled then
        statusLabel.Text = "Status: Auto-Stop on Rarest ACTIVE!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        statusLabel.Text = "Status: Auto-Stop on Rarest INACTIVE."
        statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
    end
end))

addConnection(otherScriptsButton.MouseButton1Click:Connect(function()
    mainControlsContainer.Visible = false
    mainControlsContainer.Position = UDim2.new(1, 0, 0, contentFrameYOffset)

    otherScriptsContentFrame.Visible = true
    otherScriptsContentFrame.Position = UDim2.new(0, 0, 0, contentFrameYOffset)

    statusLabel.Text = "Status: Other Scripts page."
    statusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
end))

addConnection(backToMainButton.MouseButton1Click:Connect(function()
    otherScriptsContentFrame.Visible = false
    otherScriptsContentFrame.Position = UDim2.new(1, 0, 0, contentFrameYOffset)

    mainControlsContainer.Visible = true
    mainControlsContainer.Position = UDim2.new(0, 0, 0, contentFrameYOffset)

    statusLabel.Text = "Status: Back to Main Controls."
    statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
end))

addConnection(comingSoon1Button.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastPetLevelUpTime >= PET_LEVEL_UP_COOLDOWN_TIME then
        lastPetLevelUpTime = currentTime
        levelUpEquippedPet()
        task.spawn(function()
            comingSoon1Button.Active = false
            local originalText = comingSoon1Button.Text
            local originalBgColor = comingSoon1Button.BackgroundColor3
            local originalStrokeColor = comingSoon1Button.UIStroke.Color
            for i = PET_LEVEL_UP_COOLDOWN_TIME, 1, -1 do
                comingSoon1Button.Text = string.format("Cooldown: %02d:%02d", 0, i)
                comingSoon1Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                comingSoon1Button.UIStroke.Color = Color3.fromRGB(30, 30, 30)
                task.wait(1)
            end
            comingSoon1Button.Active = true
            comingSoon1Button.Text = originalText
            comingSoon1Button.BackgroundColor3 = originalBgColor
            comingSoon1Button.UIStroke.Color = originalStrokeColor
            if string.find(statusLabel.Text, "Pet Leveled Up!") then
            else
                 statusLabel.Text = "Status: Ready to Level Up Pet!"
                 statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
            end
        end)
    else
        local timeLeft = math.ceil(PET_LEVEL_UP_COOLDOWN_TIME - (currentTime - lastPetLevelUpTime))
        statusLabel.Text = "Status: Pet Level Up Cooldown! Wait " .. timeLeft .. "s"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end
end))

addConnection(comingSoon2Button.MouseButton1Click:Connect(function()
    otherScriptsContentFrame.Visible = false
    otherScriptsContentFrame.Position = UDim2.new(1, 0, 0, contentFrameYOffset)

    mutationScriptsContentFrame.Visible = true
    mutationScriptsContentFrame.Position = UDim2.new(0, 0, 0, contentFrameYOffset)

    statusLabel.Text = "Status: Mutation Scripts page."
    statusLabel.TextColor3 = Color3.fromRGB(100, 50, 200)
    findPetMutationMachine()
end))

addConnection(mutationESPClickDetector.MouseButton1Click:Connect(function()
    mutationESPToggleEnabled = not mutationESPToggleEnabled

    local targetPosition
    local targetBgColor = mutationESPToggleEnabled and TOGGLE_ON_COLOR or TOGGLE_OFF_COLOR
    local targetStrokeColor = mutationESPToggleEnabled and TOGGLE_STROKE_COLOR_ON or TOGGLE_STROKE_COLOR_OFF
    local targetText = "Mutation ESP" .. (mutationESPToggleEnabled and ": ON" or ": OFF")
    local targetTextXAlignment

    if mutationESPToggleEnabled then
        targetPosition = UDim2.new(1, -THUMB_SIZE - TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
        targetTextXAlignment = Enum.TextXAlignment.Left
    else
        targetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
        targetTextXAlignment = Enum.TextXAlignment.Right
    end

    TweenService:Create(mutationESPToggleThumb, TweenInfo.new(0.2), {Position = targetPosition}):Play()
    TweenService:Create(mutationESPToggleBase, TweenInfo.new(0.2), {BackgroundColor3 = targetBgColor}):Play()
    TweenService:Create(mutationESPToggleBase.UIStroke, TweenInfo.new(0.2), {Color = targetStrokeColor}):Play()
    mutationESPToggleText.Text = targetText
    mutationESPToggleText.TextXAlignment = targetTextXAlignment

    if mutationESPToggleEnabled then
        statusLabel.Text = "Status: Mutation ESP ACTIVE!"
        statusLabel.TextColor3 = Color3.fromRGB(150, 0, 200)
        findPetMutationMachine()
        if petMutationMachinePoofPart then
            highlightMutationMachine(petMutationMachinePoofPart)
        end
    else
        statusLabel.Text = "Status: Mutation ESP INACTIVE"
        statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
        unhighlightMutationMachine()
    end
end))

addConnection(manualMutationRandomizeButton.MouseButton1Click:Connect(function()
    local currentTime = tick()
    if currentTime - lastMutationManualRandomizeTime >= MUTATION_MANUAL_RANDOMIZE_COOLDOWN then
        lastMutationManualRandomizeTime = currentTime
        randomizePetMutation()
        task.spawn(function()
            manualMutationRandomizeButton.Active = false
            local originalText = manualMutationRandomizeButton.Text
            local originalBgColor = manualMutationRandomizeButton.BackgroundColor3
            local originalStrokeColor = manualMutationRandomizeButton.UIStroke.Color
            for i = MUTATION_MANUAL_RANDOMIZE_COOLDOWN, 1, -1 do
                manualMutationRandomizeButton.Text = string.format("Cooldown: %02d:%02d", 0, i)
                manualMutationRandomizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                manualMutationRandomizeButton.UIStroke.Color = Color3.fromRGB(30, 30, 30)
                task.wait(1)
            end
            manualMutationRandomizeButton.Active = true
            manualMutationRandomizeButton.Text = originalText
            manualMutationRandomizeButton.BackgroundColor3 = originalBgColor
            manualMutationRandomizeButton.UIStroke.Color = originalStrokeColor
            statusLabel.Text = "Status: Ready to Randomize Mutation!"
            statusLabel.TextColor3 = Color3.fromRGB(150, 50, 200)
        end)
    else
        local timeLeft = math.ceil(MUTATION_MANUAL_RANDOMIZE_COOLDOWN - (currentTime - lastMutationManualRandomizeTime))
        statusLabel.Text = "Status: Mutation Randomize Cooldown! Wait " .. timeLeft .. "s"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end
end))

addConnection(backToOtherScriptsButton.MouseButton1Click:Connect(function()
    mutationScriptsContentFrame.Visible = false
    mutationScriptsContentFrame.Position = UDim2.new(1, 0, 0, contentFrameYOffset)

    otherScriptsContentFrame.Visible = true
    otherScriptsContentFrame.Position = UDim2.new(0, 0, 0, contentFrameYOffset)

    statusLabel.Text = "Status: Back to Other Scripts."
    statusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    unhighlightMutationMachine()
    mutationESPToggleEnabled = false
    local targetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
    local targetBgColor = TOGGLE_OFF_COLOR
    local targetStrokeColor = TOGGLE_STROKE_COLOR_OFF
    local targetText = "Mutation ESP: OFF"
    local targetTextXAlignment = Enum.TextXAlignment.Right

    mutationESPToggleThumb.Position = targetPosition
    mutationESPToggleBase.BackgroundColor3 = targetBgColor
    mutationESPToggleBase.UIStroke.Color = targetStrokeColor
    mutationESPToggleText.Text = targetText
    mutationESPToggleText.TextXAlignment = targetTextXAlignment
end))

addConnection(minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainControlsContainer.Visible = false
        otherScriptsContentFrame.Visible = false
        mutationScriptsContentFrame.Visible = false
        bottomInfoContainer.Visible = false
        statusLabel.Visible = false
        frame:TweenSize(UDim2.new(0, 300, 0, titleLabel.Size.Y.Offset + 10), "Out", "Quad", 0.3, true)
        minimizeButton.Text = "+"
    else
        if mainControlsContainer.Position.X.Scale == 0 then
            mainControlsContainer.Visible = true
        elseif otherScriptsContentFrame.Position.X.Scale == 0 then
            otherScriptsContentFrame.Visible = true
        elseif mutationScriptsContentFrame.Position.X.Scale == 0 then
            mutationScriptsContentFrame.Visible = true
        end
        bottomInfoContainer.Visible = true
        statusLabel.Visible = true
        frame:TweenSize(UDim2.new(0, 300, 0, 500), "Out", "Quad", 0.3, true)
        minimizeButton.Text = "-"
    end
end))

task.wait(2)
findAndMonitorPlayerFarm()
findPetMutationMachine()

highlightingEnabled = false
mutationESPToggleEnabled = false

local initialESPTargetPosition = UDim2.new(0, TOGGLE_PADDING, 0.5, -THUMB_SIZE/2)
local initialESPTargetBgColor = TOGGLE_OFF_COLOR
local initialESPTargetStrokeColor = TOGGLE_STROKE_COLOR_OFF
local initialESPTargetText = "EGG ESP: OFF"
local initialESPTargetTextXAlignment = Enum.TextXAlignment.Right

espToggleThumb.Position = initialESPTargetPosition
espToggleBase.BackgroundColor3 = initialESPTargetBgColor
espToggleBase.UIStroke.Color = initialESPTargetStrokeColor
espToggleText.Text = initialESPTargetText
espToggleText.TextXAlignment = initialESPTargetTextXAlignment

mutationESPToggleThumb.Position = initialESPTargetPosition
mutationESPToggleBase.BackgroundColor3 = initialESPTargetBgColor
mutationESPToggleBase.UIStroke.Color = initialESPTargetStrokeColor
mutationESPToggleText.Text = "Mutation ESP: OFF"
mutationESPToggleText.TextXAlignment = initialESPTargetTextXAlignment

statusLabel.Text = "Status: INACTIVE"
statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
