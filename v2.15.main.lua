-- Executor Detection
local executor = identifyexecutor and identifyexecutor() or "Unknown"

-- Only unsupported executor is Delta
local unsupported = { "delta" }

-- Function to check if executor is unsupported
local function isUnsupported(exe)
	for _, name in pairs(unsupported) do
		if string.lower(exe):find(name) then
			return true
		end
	end
	return false
end

-- Function to display the Pixiemo error message
local function showErrorPopup()
	local CoreGui = game:GetService("CoreGui")

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "PixiemoErrorGUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = CoreGui

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0, 460, 0, 280)
	Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Frame.BorderSizePixel = 0
	Frame.Active = true
	Frame.Draggable = true
	Frame.Parent = ScreenGui

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = Frame

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -20, 0, 40)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "Error Message"
	Title.TextColor3 = Color3.fromRGB(255, 80, 80)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 20
	Title.TextXAlignment = Enum.TextXAlignment.Center
	Title.Parent = Frame

	local Close = Instance.new("TextButton")
	Close.Text = "✕"
	Close.Size = UDim2.new(0, 30, 0, 30)
	Close.Position = UDim2.new(1, -40, 0, 5)
	Close.BackgroundTransparency = 1
	Close.TextColor3 = Color3.fromRGB(200, 200, 200)
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 20
	Close.ZIndex = 2
	Close.Parent = Frame
	Close.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	local Message = Instance.new("TextLabel")
	Message.Size = UDim2.new(1, -60, 0, 150)
	Message.Position = UDim2.new(0, 30, 0, 45)
	Message.BackgroundTransparency = 1
	Message.TextWrapped = true
	Message.TextYAlignment = Enum.TextYAlignment.Top
	Message.TextXAlignment = Enum.TextXAlignment.Center
	Message.Text = [[Your current executor may not fully support this script, which can cause it to not run correctly or behave unexpectedly.

Delta is known to have issues running advanced scripts like this one.

To ensure full compatibility and smooth performance, it's recommended to use a more stable executor such as KRNL.

Pixiemo recommends KRNL for the best experience.

If you have any questions you can message me through Discord: @pixie_mo]]
	Message.TextColor3 = Color3.fromRGB(230, 230, 230)
	Message.Font = Enum.Font.Gotham
	Message.TextSize = 15
	Message.Parent = Frame

	local CopyButton = Instance.new("TextButton")
	CopyButton.Size = UDim2.new(0, 200, 0, 36)
	CopyButton.Position = UDim2.new(0.5, -100, 1, -52)
	CopyButton.BackgroundColor3 = Color3.fromRGB(40, 90, 255)
	CopyButton.Text = "🔗 Copy KRNL Link"
	CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CopyButton.Font = Enum.Font.GothamMedium
	CopyButton.TextSize = 18
	CopyButton.Parent = Frame

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 6)
	BtnCorner.Parent = CopyButton

	CopyButton.MouseButton1Click:Connect(function()
		setclipboard("https://krnl.cat/")
		CopyButton.Text = "✅ Copied!"
		task.wait(1.5)
		CopyButton.Text = "🔗 Copy KRNL Link"
	end)

	local Notify = Instance.new("TextLabel")
	Notify.AnchorPoint = Vector2.new(1, 1)
	Notify.Position = UDim2.new(1, -10, 1, -10)
	Notify.Size = UDim2.new(0, 260, 0, 36)
	Notify.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Notify.TextColor3 = Color3.fromRGB(255, 255, 255)
	Notify.Text = "Unsupported Executor\nUse KRNL for better experience!"
	Notify.TextSize = 14
	Notify.TextWrapped = true
	Notify.TextYAlignment = Enum.TextYAlignment.Top
	Notify.TextXAlignment = Enum.TextXAlignment.Center
	Notify.Font = Enum.Font.Gotham
	Notify.Parent = ScreenGui

	local NotifyCorner = Instance.new("UICorner")
	NotifyCorner.Parent = Notify
end

-- Run detection first
if isUnsupported(executor) then
	showErrorPopup()
else
	-- Executor is supported, proceed to load scripts
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptHubLoader/NoLagHub/refs/heads/main/LoaderV2.lua"))()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/ScriptHubLoader/Pixiemo/refs/heads/main/Main.lua"))()
end
