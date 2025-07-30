-- 🌿 Pixiemo Hub – Draggable Minimized Button + Corrected Logic + Integrated Features
-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Utility Functions
local function applyUICorner(inst, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = radius or UDim.new(0, 10)
	corner.Parent = inst
end

local function applyUIStroke(inst, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.new(0, 0, 0)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.Parent = inst
end

local function addTextShadow(label)
	-- Ensure we don't create duplicates if already styled
	if label:FindFirstChild("Shadow") then return end

	local shadow = Instance.new("TextLabel") -- Create new TextLabel for shadow
	shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
	shadow.TextTransparency = 0.3
	shadow.Position = UDim2.new(0, 2, 0, 2)
	shadow.ZIndex = label.ZIndex - 1
	shadow.TextStrokeTransparency = 1
	shadow.Name = "Shadow"
	shadow.Font = label.Font -- Inherit font
	shadow.Text = label.Text -- Inherit text
	shadow.TextSize = label.TextSize -- Inherit text size
	shadow.TextXAlignment = label.TextXAlignment -- Inherit text alignment
	shadow.TextYAlignment = label.TextYAlignment -- Inherit text alignment
	shadow.Size = label.Size -- Inherit size
	shadow.BackgroundTransparency = 1 -- Keep background transparent
	shadow.Parent = label -- Parent directly to the label to keep it contained
end

local function applyStyledText(label)
	label.Font = Enum.Font.FredokaOne
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 1
	addTextShadow(label)
end

local function addBounceHoverEffect(button)
	local originalSize = button.Size
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = originalSize + UDim2.new(0, 5, 0, 3)}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = originalSize}):Play()
	end)
end

-- Init GUI
local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):FindFirstChild("PixiemoGUI")
if gui then gui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PixiemoGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Loading Progress Bar (Cartoonish Animated)
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 300, 0, 120) -- Increased height to 120
loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -60) -- Adjusted position for new height
loadingFrame.BackgroundColor3 = Color3.fromRGB(195, 235, 185)
loadingFrame.Parent = screenGui
applyUICorner(loadingFrame, UDim.new(0, 15))
applyUIStroke(loadingFrame, Color3.fromRGB(150, 190, 130), 3, 0)

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Size = UDim2.new(1, 0, 0, 30)
welcomeLabel.Position = UDim2.new(0.5, 0, 0, 15) -- Centered horizontally, 15px from top
welcomeLabel.AnchorPoint = Vector2.new(0.5, 0)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Font = Enum.Font.FredokaOne
welcomeLabel.Text = "Welcome to Pixiemo Hub"
welcomeLabel.TextSize = 24
welcomeLabel.TextColor3 = Color3.fromRGB(80, 110, 70)
welcomeLabel.Parent = loadingFrame
-- Only apply shadow once, applyStyledText handles it
welcomeLabel.Font = Enum.Font.FredokaOne -- Set font before adding shadow
welcomeLabel.TextColor3 = Color3.fromRGB(80, 110, 70) -- Set color before adding shadow
welcomeLabel.TextStrokeTransparency = 1
addTextShadow(welcomeLabel)


local statusLabel = Instance.new("TextLabel") -- Renamed from loadingLabel to statusLabel for general use
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0.5, 0, 0, 45) -- Centered horizontally, 45px from top
statusLabel.AnchorPoint = Vector2.new(0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.FredokaOne
statusLabel.Text = "Loading Scripts..."
statusLabel.TextSize = 18
statusLabel.TextColor3 = Color3.fromRGB(80, 110, 70)
statusLabel.Parent = loadingFrame
-- Only apply shadow once, applyStyledText handles it
statusLabel.Font = Enum.Font.FredokaOne -- Set font before adding shadow
statusLabel.TextColor3 = Color3.fromRGB(80, 110, 70) -- Set color before adding shadow
statusLabel.TextStrokeTransparency = 1
addTextShadow(statusLabel)

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(1, -20, 0, 25) -- Adjusted size to fit within the loadingFrame with padding
progressBar.Position = UDim2.new(0.5, 0, 0, 85) -- Centered horizontally, 85px from top
progressBar.AnchorPoint = Vector2.new(0.5, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(134, 185, 112)
progressBar.Parent = loadingFrame -- Now parented to loadingFrame
applyUICorner(progressBar, UDim.new(0, 12))

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0) -- Starts at 0 width
progressFill.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
progressFill.Parent = progressBar
applyUICorner(progressFill, UDim.new(0, 12))

-- Minimized Button
local minimizedButton = Instance.new("TextButton")
minimizedButton.Name = "MinimizedButton"
minimizedButton.Text = "Pixiemo Hub"
minimizedButton.Size = UDim2.new(0, 160, 0, 32)
minimizedButton.Position = UDim2.new(1, -170, 0, 10)
minimizedButton.Visible = false
minimizedButton.BackgroundColor3 = Color3.fromRGB(134, 185, 112)
minimizedButton.TextSize = 18
minimizedButton.Parent = screenGui
minimizedButton.AutoButtonColor = false -- Prevents color change on click while dragging
applyUICorner(minimizedButton, UDim.new(1, 0))
applyUIStroke(minimizedButton, Color3.fromRGB(80, 110, 70), 2, 0)
applyStyledText(minimizedButton)

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 330) -- Increased height to 330
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(195, 235, 185)
mainFrame.Parent = screenGui
mainFrame.Visible = false -- Initially hidden
applyUICorner(mainFrame, UDim.new(0, 25))
applyUIStroke(mainFrame, Color3.fromRGB(150, 190, 130), 3, 0)

-- Container for scale animation
local scaleContainer = Instance.new("Frame")
scaleContainer.Size = UDim2.new(1, 0, 1, 0)
scaleContainer.BackgroundTransparency = 1
scaleContainer.Parent = mainFrame

local scale = Instance.new("UIScale")
scale.Scale = 1
scale.Parent = scaleContainer

-- Header
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 35)
headerFrame.BackgroundColor3 = Color3.fromRGB(134, 185, 112)
headerFrame.Parent = scaleContainer
headerFrame.BorderSizePixel = 0
headerFrame.Active = true -- Make it responsive to input
applyUICorner(headerFrame, UDim.new(0, 25))

local header = Instance.new("TextLabel")
header.Text = "🥚 Egg Randomizer"
header.TextSize = 22
header.Size = UDim2.new(1, 0, 1, 0)
header.BackgroundTransparency = 1
header.Parent = headerFrame
applyStyledText(header)

-- Minimize Button
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 22, 0, 22)
minimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
minimizeBtn.Position = UDim2.new(1, -12, 0.5, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 212, 59)
minimizeBtn.Text = ""
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = headerFrame
applyUICorner(minimizeBtn, UDim.new(1, 0))

local minus = Instance.new("Frame")
minus.Size = UDim2.new(0.6, 0, 0.15, 0)
minus.Position = UDim2.new(0.5, 0, 0.5, 0)
minus.AnchorPoint = Vector2.new(0.5, 0.5)
minus.BackgroundColor3 = Color3.new(1, 1, 1)
minus.BorderSizePixel = 0
minus.Parent = minimizeBtn
applyUICorner(minus, UDim.new(1, 0))

-- Pages Container & Pages
local pagesContainer = Instance.new("Frame")
pagesContainer.Size = UDim2.new(1, 0, 1, -55) -- Adjusted height to account for header and version label
pagesContainer.Position = UDim2.new(0, 0, 0, 35)
pagesContainer.BackgroundTransparency = 1
pagesContainer.Parent = scaleContainer

local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, 0)
mainPage.BackgroundTransparency = 1
mainPage.Parent = pagesContainer

local otherScriptsPage = Instance.new("Frame")
otherScriptsPage.Size = UDim2.new(1, 0, 1, 0)
otherScriptsPage.BackgroundTransparency = 1
otherScriptsPage.Visible = false
otherScriptsPage.Parent = pagesContainer

local mutationPage = Instance.new("Frame")
mutationPage.Size = UDim2.new(1, 0, 1, 0)
mutationPage.BackgroundTransparency = 1
mutationPage.Visible = false
mutationPage.Parent = pagesContainer

local helpPage = Instance.new("Frame")
helpPage.Size = UDim2.new(1, 0, 1, 0)
helpPage.BackgroundTransparency = 1
helpPage.Visible = false
helpPage.Parent = pagesContainer


-- Version Label for Main Frame
local versionLabel = Instance.new("TextLabel")
versionLabel.Name = "VersionLabel"
versionLabel.Size = UDim2.new(1, 0, 0, 20)
versionLabel.Position = UDim2.new(0.5, 0, 1, -20) -- Position at the bottom, 20px from bottom edge
versionLabel.AnchorPoint = Vector2.new(0.5, 1) -- Anchor to the bottom-center
versionLabel.BackgroundTransparency = 1
versionLabel.Font = Enum.Font.FredokaOne
versionLabel.Text = "Made by Pixiemo - V3.09" -- Renamed text
versionLabel.TextSize = 14
versionLabel.TextColor3 = Color3.fromRGB(80, 110, 70)
versionLabel.Parent = mainFrame
-- Only apply shadow once, applyStyledText handles it
versionLabel.Font = Enum.Font.FredokaOne -- Set font before adding shadow
versionLabel.TextColor3 = Color3.fromRGB(80, 110, 70) -- Set color before adding shadow
versionLabel.TextStrokeTransparency = 1
addTextShadow(versionLabel)


-- --- START OF INTEGRATED FUNCTIONALITY ---

-- Global Variables from the provided script
local HIGHLIGHT_COLOR = Color3.fromRGB(0, 255, 255)
local HIGHLIGHT_TRANSPARENCY_FILL = 0.3
local HIGHLIGHT_TRANSPARENCY_OUTLINE = 0.5

local RANDOMIZE_COOLDOWN_TIME = 5
local AUTO_RANDOMIZE_INTERVAL = 5
local PET_LEVEL_UP_COOLDOWN_TIME = 5
local MUTATION_MANUAL_RANDOMIZE_COOLDOWN = 5

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

local mutationESPToggleEnabled = false
local petMutationMachinePoofPart = nil
local mutationBillboardGui = nil
local mutationTextLabel = nil
local currentMutationEffectTask = nil

local EGG_CONTENTS = { --
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

-- UPDATED MUTATION_CONTENTS with new colors and "Corrupted"
local MUTATION_CONTENTS = {
    {name = "Shiny", chance = 31.15, color = Color3.fromRGB(170, 255, 255)},
    {name = "Inverted", chance = 15.58, color = Color3.fromRGB(150, 150, 150)},
    {name = "Windy", chance = 9.35, color = Color3.fromRGB(100, 150, 255)},
    {name = "Frozen", chance = 9.35, color = Color3.fromRGB(0, 200, 255)},
    {name = "Golden", chance = 6.23, color = Color3.fromRGB(255, 215, 0)},
    {name = "Tiny", chance = 6.23, color = Color3.fromRGB(100, 255, 100)},
    {name = "Mega", chance = 6.23, color = Color3.fromRGB(255, 100, 100)},
    {name = "Tranquil", chance = 3.12, color = Color3.fromRGB(150, 255, 200)},
    {name = "IronSkin", chance = 3.12, color = Color3.fromRGB(120, 120, 120)},
    {name = "Radiant", chance = 3.12, color = Color3.fromRGB(255, 255, 0)},
    {name = "Shocked", chance = 3.12, color = Color3.fromRGB(200, 200, 0)},
    {name = "Rainbow", chance = 3.12, color = Color3.fromRGB(255, 255, 0)}, -- Still uses yellow as placeholder, effect is handled in updateMutationText
    {name = "Ascended", chance = 0.31, color = Color3.fromRGB(255, 200, 255)},
    {name = "Corrupted", chance = 0.10, color = Color3.fromRGB(150, 0, 0)}, -- Dark Red as requested
}


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
            -- Update UI for Auto Randomize toggle to OFF state
            autoRandomizeToggle.Text = "OFF"
            autoRandomizeToggle.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            autoRandomizeToggle.TextTransparency = 0 -- Reset transparency if it was affected by auto mode

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
        end)) -- Added this missing 'end))'
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


-- Contents Functions (adapted to use our `createToggle` and `createButton`)
local manualButton -- Forward declaration

local function createToggle(parent, labelText, posY, onToggleCallback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 360, 0, 40)
	frame.Position = UDim2.new(0.5, -180, 0, posY)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.FredokaOne
	label.Text = labelText
	label.TextSize = 20
	label.TextColor3 = Color3.fromRGB(80, 110, 70)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
	addTextShadow(label)

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0.25, 0, 0.7, 0)
	toggle.Position = UDim2.new(0.75, 0, 0.15, 0)
	toggle.Text = "OFF"
	toggle.Font = Enum.Font.FredokaOne
	toggle.TextSize = 18
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
	toggle.Parent = frame
	applyUICorner(toggle)
	addBounceHoverEffect(toggle)

	toggle.MouseButton1Click:Connect(function()
		local newState = toggle.Text == "OFF"
		toggle.Text = newState and "ON" or "OFF"
		toggle.BackgroundColor3 = newState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(120, 120, 120)
		if onToggleCallback then onToggleCallback(newState, toggle) end -- Pass toggle object for UI updates
	end)
	return toggle
end

local function createButton(parent, text, posY, onClick)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 360, 0, 40)
	button.Position = UDim2.new(0.5, -180, 0, posY)
	button.BackgroundColor3 = Color3.fromRGB(134, 185, 112)
	button.Text = text
	button.TextSize = 20
	button.Parent = parent
	applyUICorner(button)
	applyUIStroke(button, Color3.fromRGB(80, 110, 70), 2, 0)
	applyStyledText(button)
	addBounceHoverEffect(button)
	if onClick then button.MouseButton1Click:Connect(onClick) end
	return button
end

-- Populating Pages
-- Main Page
local eggEspToggle = createToggle(mainPage, "🥚 EGG ESP", 15, function(state, toggleBtn)
    highlightingEnabled = state
    if highlightingEnabled then
        statusLabel.Text = "Status: EGG ESP ACTIVE!"
        statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
        if playerFarm then
            for _, instance in ipairs(playerFarm:GetDescendants()) do
                processInstance(instance)
            end
        end
    else
        statusLabel.Text = "Status: EGG ESP INACTIVE"
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
            -- Force auto randomize toggle OFF
            autoRandomizeToggle.Text = "OFF"
            autoRandomizeToggle.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
            autoRandomizeToggle.TextTransparency = 0 -- Reset transparency if it was affected by auto mode
        end
    end
end)

local autoStopRarestToggle = createToggle(mainPage, "💎 Auto Stop at Rarest", 65, function(state, toggleBtn)
    stopOnRarestEnabled = state
    if stopOnRarestEnabled then
        statusLabel.Text = "Status: Auto-Stop on Rarest ACTIVE!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        statusLabel.Text = "Status: Auto-Stop on Rarest INACTIVE."
        statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
    end
end)

local autoRandomizeToggle = createToggle(mainPage, "🎲 Auto Randomize", 115, function(state, toggleBtn)
    if not highlightingEnabled then
        statusLabel.Text = "Status: Enable EGG ESP first to Auto-Randomize!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        toggleBtn.Text = "OFF" -- Keep toggle OFF
        toggleBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
        return
    end

    autoRandomizeEnabled = state
    manualButton.AutoButtonColor = not state -- Disable manual button when auto is on
    manualButton.TextTransparency = state and 0.5 or 0

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
end)

manualButton = createButton(mainPage, "🎯 Randomize Manual", 165, function()
	if not autoRandomizeEnabled then
        local currentTime = tick()
        if currentTime - lastRandomizeTime >= RANDOMIZE_COOLDOWN_TIME then
            lastRandomizeTime = currentTime
            performRandomization()
            task.spawn(function()
                manualButton.Active = false
                local originalText = manualButton.Text
                local originalBgColor = manualButton.BackgroundColor3
                local originalStrokeColor = manualButton.UIStroke.Color
                for i = RANDOMIZE_COOLDOWN_TIME, 1, -1 do
                    manualButton.Text = string.format("Cooldown: %02d:%02d", 0, i)
                    manualButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    manualButton.UIStroke.Color = Color3.fromRGB(30, 30, 30)
                    task.wait(1)
                end
                manualButton.Active = true
                manualButton.Text = originalText
                manualButton.BackgroundColor3 = originalBgColor
                manualButton.UIStroke.Color = originalStrokeColor
                statusLabel.Text = "Status: Ready to Randomize!"
                statusLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
            end)
        else
            local timeLeft = math.ceil(RANDOMIZE_COOLDOWN_TIME - (currentTime - lastRandomizeTime))
            statusLabel.Text = "Status: Manual Randomize Cooldown! Wait " .. timeLeft .. "s"
            statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
        end
    else
        statusLabel.Text = "Status: Auto Randomize is ON. Manual disabled."
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
    end
end)

createButton(mainPage, "⚙️ Other Scripts", 215, function() -- Adjusted posY to 215 (from 250)
	mainPage.Visible = false
	otherScriptsPage.Visible = true
    statusLabel.Text = "Status: Other Scripts page."
    statusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
end)

-- Other Scripts Page
local instantAgePetButton = createButton(otherScriptsPage, "✨ Instant Age Pet to 50", 65, function()
    local currentTime = tick()
    if currentTime - lastPetLevelUpTime >= PET_LEVEL_UP_COOLDOWN_TIME then
        lastPetLevelUpTime = currentTime
        levelUpEquippedPet()
        task.spawn(function()
            instantAgePetButton.Active = false
            local originalText = instantAgePetButton.Text
            local originalBgColor = instantAgePetButton.BackgroundColor3
            local originalStrokeColor = instantAgePetButton.UIStroke.Color
            for i = PET_LEVEL_UP_COOLDOWN_TIME, 1, -1 do
                instantAgePetButton.Text = string.format("Cooldown: %02d:%02d", 0, i)
                instantAgePetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                instantAgePetButton.UIStroke.Color = Color3.fromRGB(30, 30, 30)
                task.wait(1)
            end
            instantAgePetButton.Active = true
            instantAgePetButton.Text = originalText
            instantAgePetButton.BackgroundColor3 = originalBgColor
            instantAgePetButton.UIStroke.Color = originalStrokeColor
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
end)

local mutationButton = createButton(otherScriptsPage, "🧬 Mutation Randomizer", 115, function()
	otherScriptsPage.Visible = false
	mutationPage.Visible = true
    statusLabel.Text = "Status: Mutation Scripts page."
    statusLabel.TextColor3 = Color3.fromRGB(100, 50, 200)
    findPetMutationMachine()
end)

-- New "Need Help?" button
local helpButton = createButton(otherScriptsPage, "❓ Need Help?", 165, function()
    otherScriptsPage.Visible = false
    helpPage.Visible = true
    statusLabel.Text = "Status: Help page."
    statusLabel.TextColor3 = Color3.fromRGB(150, 200, 50)
end)

local otherScriptsBackBtn = createButton(otherScriptsPage, "← Back", 10, function()
	otherScriptsPage.Visible = false
	mainPage.Visible = true
    statusLabel.Text = "Status: Back to Main Controls."
    statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)
end)
otherScriptsBackBtn.Size = UDim2.new(0, 120, 0, 36)
otherScriptsBackBtn.Position = UDim2.new(0, 20, 0, 10)


-- Mutation Randomizer Page
local mutationEspToggle = createToggle(mutationPage, "🦠 Mutation ESP", 65, function(state, toggleBtn)
    mutationESPToggleEnabled = state
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
end)

local randomizeMutationButton = createButton(mutationPage, "🔀 Randomize Mutation", 115, function()
    local currentTime = tick()
    if currentTime - lastMutationManualRandomizeTime >= MUTATION_MANUAL_RANDOMIZE_COOLDOWN then
        lastMutationManualRandomizeTime = currentTime
        randomizePetMutation()
        task.spawn(function()
            randomizeMutationButton.Active = false
            local originalText = randomizeMutationButton.Text
            local originalBgColor = randomizeMutationButton.BackgroundColor3
            local originalStrokeColor = randomizeMutationButton.UIStroke.Color
            for i = MUTATION_MANUAL_RANDOMIZE_COOLDOWN, 1, -1 do
                randomizeMutationButton.Text = string.format("Cooldown: %02d:%02d", 0, i)
                randomizeMutationButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                randomizeMutationButton.UIStroke.Color = Color3.fromRGB(30, 30, 30)
                task.wait(1)
            end
            randomizeMutationButton.Active = true
            randomizeMutationButton.Text = originalText
            randomizeMutationButton.BackgroundColor3 = originalBgColor
            randomizeMutationButton.UIStroke.Color = originalStrokeColor
            statusLabel.Text = "Status: Ready to Randomize Mutation!"
            statusLabel.TextColor3 = Color3.fromRGB(150, 50, 200)
        end)
    else
        local timeLeft = math.ceil(MUTATION_MANUAL_RANDOMIZE_COOLDOWN - (currentTime - lastMutationManualRandomizeTime))
        statusLabel.Text = "Status: Mutation Randomize Cooldown! Wait " .. timeLeft .. "s"
        statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    end
end)

local mutationBackBtn = createButton(mutationPage, "← Back", 10, function()
	mutationPage.Visible = false
	otherScriptsPage.Visible = true
    statusLabel.Text = "Status: Back to Other Scripts."
    statusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
    unhighlightMutationMachine()
    mutationESPToggleEnabled = false -- Ensure the state is reset on back
    -- Also visually reset the toggle for Mutation ESP
    mutationEspToggle.Text = "OFF"
    mutationEspToggle.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
end)
mutationBackBtn.Size = UDim2.new(0, 120, 0, 36)
mutationBackBtn.Position = UDim2.new(0, 20, 0, 10)


-- Help Page Content
local helpTextLabel = Instance.new("TextLabel")
helpTextLabel.Size = UDim2.new(1, -40, 0.7, 0) -- Adjusted size
helpTextLabel.Position = UDim2.new(0.5, 0, 0.5, -20) -- Centered
helpTextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
helpTextLabel.BackgroundTransparency = 1
helpTextLabel.Font = Enum.Font.FredokaOne
helpTextLabel.Text = "If you encountered any bug or needing any help please contact me through my discord: @pixie_mo.\n\nYT Channel for tutorials: @PixiemoHub"
helpTextLabel.TextSize = 18
helpTextLabel.TextColor3 = Color3.fromRGB(80, 110, 70)
helpTextLabel.TextWrapped = true
helpTextLabel.TextXAlignment = Enum.TextXAlignment.Center
helpTextLabel.TextYAlignment = Enum.TextYAlignment.Center
helpTextLabel.Parent = helpPage
-- REMOVED addTextShadow(helpTextLabel) as per user request


local helpBackBtn = createButton(helpPage, "← Back", 10, function()
	helpPage.Visible = false
	otherScriptsPage.Visible = true
    statusLabel.Text = "Status: Back to Other Scripts."
    statusLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
end)
helpBackBtn.Size = UDim2.new(0, 120, 0, 36)
helpBackBtn.Position = UDim2.new(0, 20, 0, 10)


-- ### Dragging Logic ###
local function makeDraggable(guiObject, triggerObject)
    local isCurrentlyDragging = false
    local dragStartPos
    local initialGuiPos

    -- Ensure triggerObject can receive input
    triggerObject.Active = true
    if triggerObject:IsA("TextButton") or triggerObject:IsA("ImageButton") then
        -- Temporarily disable button color change on hover/click to avoid visual interference during drag
        triggerObject.AutoButtonColor = false
    end

    triggerObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isCurrentlyDragging = true
            dragStartPos = input.Position
            initialGuiPos = guiObject.Position

            local inputChangedConnection
            inputChangedConnection = UserInputService.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                    if isCurrentlyDragging then
                        local delta = changedInput.Position - dragStartPos
                        guiObject.Position = UDim2.new(initialGuiPos.X.Scale, initialGuiPos.X.Offset + delta.X,
                                                       initialGuiPos.Y.Scale, initialGuiPos.Y.Offset + delta.Y)
                    end
                end
            end)

            local inputEndedConnection
            inputEndedConnection = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput == input then
                    isCurrentlyDragging = false
                    inputChangedConnection:Disconnect()
                    inputEndedConnection:Disconnect()
                    -- Re-enable AutoButtonColor if it was disabled
                    if triggerObject:IsA("TextButton") or triggerObject:IsA("ImageButton") then
                        triggerObject.AutoButtonColor = true
                    end
                end
            end)
        end
    end)
end

makeDraggable(mainFrame, headerFrame)
makeDraggable(minimizedButton, minimizedButton) -- Make the minimized button itself draggable

-- ### Animation and State Logic ###
local minimized = false
local MIN_DRAG_DISTANCE = 5 -- Minimum pixel distance to consider it a drag, not a click

-- Track mouse down position for click vs. drag detection
local mouseDownPosition = Vector2.new(0,0)
local mouseIsDownOnMinimizedButton = false

minimizedButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mouseDownPosition = input.Position
        mouseIsDownOnMinimizedButton = true
    end
end)

minimizedButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        mouseIsDownOnMinimizedButton = false
        local mouseUpPosition = input.Position
        local distance = (mouseDownPosition - mouseUpPosition).magnitude

        if distance < MIN_DRAG_DISTANCE then -- It's a click, not a drag
            if not minimized then return end -- Should only be clicked when minimized
            minimized = false
            minimizedButton.Visible = false
            mainFrame.Position = minimizedButton.Position -- Start expansion from the minimized button's position
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0,0,0,0)

            local targetPositionX = 0.5
            local targetPositionY = 0.5

            TweenService:Create(scale, TweenInfo.new(0.25), {Scale = 1}):Play()
            TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 420, 0, 330), -- Updated height
                Position = UDim2.new(targetPositionX, 0, targetPositionY, 0) -- Back to center using AnchorPoint 0.5, 0.5
            }):Play()
        end
    end
end)


minimizeBtn.MouseButton1Click:Connect(function()
    if minimized then return end -- Prevent re-minimizing if already minimized
    minimized = true

    local headerAbsolutePosition = headerFrame.AbsolutePosition
    local minimizeBtnRelativePosition = minimizeBtn.Position
    -- Calculate the absolute center of the minimize button for consistent positioning
    local minimizeBtnAbsoluteCenter = Vector2.new(
        headerAbsolutePosition.X + minimizeBtnRelativePosition.X.Offset + (minimizeBtn.AbsoluteSize.X / 2),
        headerAbsolutePosition.Y + minimizeBtnRelativePosition.Y.Offset + (minimizeBtn.AbsoluteSize.Y / 2)
    )

    -- Set minimizedButton's position so its center aligns with minimizeBtnAbsoluteCenter
    -- Need to convert absolute center to relative position for minimizedButton
    local screenGuiAbsoluteSize = screenGui.AbsoluteSize
    local targetXScale = minimizeBtnAbsoluteCenter.X / screenGuiAbsoluteSize.X
    local targetYScale = minimizeBtnAbsoluteCenter.Y / screenGuiAbsoluteSize.Y

    -- Calculate offset to center the minimizedButton's AnchorPoint (0.5, 0.5) at the target coordinates
    local minimizedButtonTargetOffset = Vector2.new(
        minimizedButton.AbsoluteSize.X / 2,
        minimizedButton.AbsoluteSize.Y / 2
    )

    minimizedButton.Position = UDim2.new(targetXScale, -minimizedButtonTargetOffset.X, targetYScale, -minimizedButtonTargetOffset.Y)

    TweenService:Create(scale, TweenInfo.new(0.25), {Scale = 0}):Play()
    local shrinkTween = TweenService:Create(mainFrame, TweenInfo.new(0.25), {
        Size = UDim2.new(0, 0, 0, 0),
        -- Position the mainFrame's center at the minimize button's center for shrinking
        Position = UDim2.new(targetXScale, 0, targetYScale, 0)
    })
    shrinkTween:Play()
    shrinkTween.Completed:Connect(function()
        mainFrame.Visible = false
        minimizedButton.Visible = true
    end)
end)


-- Loading Animation and Initial Setup
local loadingTween = TweenService:Create(progressFill, TweenInfo.new(3, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)}) -- Reduced to 3 seconds
loadingTween:Play()
loadingTween.Completed:Connect(function()
	task.wait(0.2) -- Use task.wait instead of wait
	loadingFrame:Destroy()
	mainFrame.Visible = true
	mainFrame.Size = UDim2.new(0,0,0,0)
	TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 420, 0, 330) }):Play()

    -- Initial setup for functionalities
    highlightingEnabled = false
    mutationESPToggleEnabled = false
    statusLabel.Text = "Status: INACTIVE"
    statusLabel.TextColor3 = Color3.fromRGB(200, 150, 0)

    task.wait(0.5) -- Give GUI a moment to appear
    findAndMonitorPlayerFarm()
    findPetMutationMachine()
end)
