local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
if CoreGui:FindFirstChild("majTY_v67") then CoreGui.majTY_v67:Destroy() end

local aimEnabled = false
local flyEnabled = false
local boxesEnabled = false
local noclipEnabled = false
local superSpeedEnabled = false

local aimSpeed = 0.15
local flySpeed = 50
local superSpeed = 100
local boxesRange = 1000
local extendAimRange = false
local ctrlClickTp = false
local bv, bg
local activeHighlights = {}
local noclipConnection

local binds = {
	Aim = Enum.KeyCode.K,
	Fly = Enum.KeyCode.F,
	TP = Enum.KeyCode.P,
	Boxes = Enum.KeyCode.B,
	Noclip = Enum.KeyCode.N,
	SuperSpeed = Enum.KeyCode.M,
	ToggleGUI = Enum.KeyCode.RightShift,
}

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "majTY_v67"

local main = Instance.new("Frame", screenGui)
main.Name = "Main"
main.Size = UDim2.new(0, 350, 0, 135) 
main.Position = UDim2.new(0.5, -175, 0.5, -67)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.Text = "  majTY v6.7 Beta 1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

local settingsBtn = Instance.new("TextButton", title)
settingsBtn.Size = UDim2.new(0, 30, 0, 25)
settingsBtn.Position = UDim2.new(1, -40, 0.5, -12)
settingsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
settingsBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
settingsBtn.Text = "⚙"
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.TextSize = 14
Instance.new("UICorner", settingsBtn).CornerRadius = UDim.new(0, 5)

local contentFrame = Instance.new("Frame", main)
contentFrame.Name = "Content"
contentFrame.Position = UDim2.new(0, 10, 0, 45)
contentFrame.Size = UDim2.new(1, -20, 1, -55)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true

local buttonPage = Instance.new("Frame", contentFrame)
buttonPage.Name = "Buttons"
buttonPage.Size = UDim2.new(1, 0, 1, 0)
buttonPage.Position = UDim2.new(0, 0, 0, 0)
buttonPage.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", buttonPage)
grid.CellSize = UDim2.new(0.235, 0, 0.47, 0) 
grid.CellPadding = UDim2.new(0.015, 0, 0.06, 0)


local settingsPage = Instance.new("ScrollingFrame", contentFrame)
settingsPage.Name = "Settings"
settingsPage.Size = UDim2.new(1, 0, 1, 0)
settingsPage.Position = UDim2.new(1, 20, 0, 0)
settingsPage.BackgroundTransparency = 1
settingsPage.BorderSizePixel = 0
settingsPage.ScrollBarThickness = 3
settingsPage.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
settingsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", settingsPage)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 6)

local pagePadding = Instance.new("UIPadding", settingsPage)
pagePadding.PaddingLeft = UDim.new(0, 5)
pagePadding.PaddingRight = UDim.new(0, 15)
pagePadding.PaddingTop = UDim.new(0, 5)
pagePadding.PaddingBottom = UDim.new(0, 5)


local function createBtn(text)
	local btn = Instance.new("TextButton", buttonPage)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11 
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local aimBtn = createBtn("Aim (" .. binds.Aim.Name .. ")")
local tpBtn = createBtn("TP (" .. binds.TP.Name .. ")")
local flyBtn = createBtn("Fly (" .. binds.Fly.Name .. ")")
local boxBtn = createBtn("Boxes (" .. binds.Boxes.Name .. ")")

local noclipBtn = createBtn("Noclip (" .. binds.Noclip.Name .. ")")
local speedBtn = createBtn("Speed (" .. binds.SuperSpeed.Name .. ")")

local function createCategory(parent, titleText)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, 22)
	container.BackgroundTransparency = 1

	local line = Instance.new("Frame", container)
	line.Size = UDim2.new(1, 0, 0, 1)
	line.Position = UDim2.new(0, 0, 1, -2)
	line.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	line.BorderSizePixel = 0

	local label = Instance.new("TextLabel", container)
	label.Size = UDim2.new(1, 0, 1, -3)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(150, 150, 150)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.Text = titleText:upper()
	label.TextXAlignment = Enum.TextXAlignment.Left
end

local function createSlider(parent, text, min, max, default, callback, customDisplay)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Size = UDim2.new(0.45, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left

	local sliderBg = Instance.new("Frame", container)
	sliderBg.Size = UDim2.new(0.5, 0, 0, 6)
	sliderBg.Position = UDim2.new(0.5, 0, 0.5, -3)
	sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	sliderBg.BorderSizePixel = 0
	Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

	local sliderFill = Instance.new("Frame", sliderBg)
	sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	sliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 127)
	sliderFill.BorderSizePixel = 0
	Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

	local handle = Instance.new("TextButton", sliderBg)
	handle.Size = UDim2.new(0, 12, 0, 12)
	handle.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.BorderSizePixel = 0
	handle.Text = ""
	Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)

	local initialVal = customDisplay and customDisplay(default) or tostring(default)
	label.Text = text .. ": " .. initialVal

	local dragging = false
	local function update(input)
		local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		sliderFill.Size = UDim2.new(pos, 0, 1, 0)
		handle.Position = UDim2.new(pos, -6, 0.5, -6)
		local value = math.floor((min + (max - min) * pos) * 100) / 100
		local displayText = customDisplay and customDisplay(value) or tostring(value)
		label.Text = text .. ": " .. displayText
		callback(value)
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)
end

local function createCheckbox(parent, text, default, callback)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Size = UDim2.new(0.8, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Gotham
	label.TextSize = 10 
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true

	local box = Instance.new("TextButton", container)
	box.Size = UDim2.new(0, 18, 0, 18)
	box.Position = UDim2.new(1, -18, 0.5, -9)
	box.BackgroundColor3 = default and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(40, 40, 40)
	box.Text = ""
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

	local checked = default
	box.MouseButton1Click:Connect(function()
		checked = not checked
		box.BackgroundColor3 = checked and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(40, 40, 40)
		callback(checked)
	end)
end

local function createKeybind(parent, text, actionName)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1

	local label = Instance.new("TextLabel", container)
	label.Size = UDim2.new(0.6, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", container)
	btn.Size = UDim2.new(0.35, 0, 0, 22)
	btn.Position = UDim2.new(0.65, 0, 0.5, -11)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.Text = binds[actionName].Name
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	local listening = false
	btn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		btn.Text = "..."
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 127)

		local connection
		connection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				local key = input.KeyCode
				if key ~= Enum.KeyCode.Unknown and key ~= Enum.KeyCode.Escape then
					binds[actionName] = key
					btn.Text = key.Name

					if actionName == "Aim" then aimBtn.Text = "Aim (" .. key.Name .. ")"
					elseif actionName == "Fly" then flyBtn.Text = "Fly (" .. key.Name .. ")"
					elseif actionName == "TP" then tpBtn.Text = "TP (" .. key.Name .. ")"
					elseif actionName == "Boxes" then boxBtn.Text = "Boxes (" .. key.Name .. ")"
					elseif actionName == "Noclip" then noclipBtn.Text = "Noclip (" .. key.Name .. ")"
					elseif actionName == "SuperSpeed" then speedBtn.Text = "Speed (" .. key.Name .. ")"
					end
				end
				listening = false
				btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
				connection:Disconnect()
			end
		end)
	end)
end

createCategory(settingsPage, "Aim Lock")
createSlider(settingsPage, "Aim Smoothness", 0.01, 1, aimSpeed, function(val) aimSpeed = val end)
createCheckbox(settingsPage, "Extend Aim Lock Range to 500 studs", extendAimRange, function(val) extendAimRange = val end)

createCategory(settingsPage, "Movement")
createSlider(settingsPage, "Fly Speed", 10, 200, flySpeed, function(val) flySpeed = val end)
createSlider(settingsPage, "Super Speed Value", 16, 300, superSpeed, function(val) 
	superSpeed = val 
	if superSpeedEnabled and player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		player.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = val
	end
end)
createCheckbox(settingsPage, "Ctrl + Click to TP", ctrlClickTp, function(val) ctrlClickTp = val end)

createCategory(settingsPage, "Visuals")
createSlider(settingsPage, "Boxes Range", 50, 2000, boxesRange, function(val)
	if val >= 2000 then
		boxesRange = math.huge
	else
		boxesRange = val
	end
end, function(val)
	if val >= 2000 then
		return "Inf"
	else
		return tostring(math.floor(val))
	end
end)

createCategory(settingsPage, "Hotkeys")
createKeybind(settingsPage, "Aim Lock", "Aim")
createKeybind(settingsPage, "Teleport", "TP")
createKeybind(settingsPage, "Fly", "Fly")
createKeybind(settingsPage, "Boxes ESP", "Boxes")
createKeybind(settingsPage, "Noclip", "Noclip")
createKeybind(settingsPage, "Super Speed", "SuperSpeed")
createKeybind(settingsPage, "Toggle Menu", "ToggleGUI")

local savedSizeBeforeSettings = main.Size
local settingsOpen = false

settingsBtn.MouseButton1Click:Connect(function()
	settingsOpen = not settingsOpen
	local slideTime = 0.3
	local easeStyle = Enum.EasingStyle.Quad

	if settingsOpen then
		savedSizeBeforeSettings = main.Size 
		settingsBtn.Text = "X"
		settingsBtn.BackgroundColor3 = Color3.fromRGB(170, 50, 50)

		local expandedHeight = math.max(250, savedSizeBeforeSettings.Y.Offset + 120)
		local targetSize = UDim2.new(savedSizeBeforeSettings.X.Scale, savedSizeBeforeSettings.X.Offset, savedSizeBeforeSettings.Y.Scale, expandedHeight)

		TweenService:Create(main, TweenInfo.new(slideTime, easeStyle, Enum.EasingDirection.Out), {Size = targetSize}):Play()
		TweenService:Create(buttonPage, TweenInfo.new(slideTime, easeStyle, Enum.EasingDirection.Out), {Position = UDim2.new(-1, -20, 0, 0)}):Play()
		TweenService:Create(settingsPage, TweenInfo.new(slideTime, easeStyle, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	else
		settingsBtn.Text = "⚙"
		settingsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

		TweenService:Create(main, TweenInfo.new(slideTime, easeStyle, Enum.EasingDirection.Out), {Size = savedSizeBeforeSettings}):Play()
		TweenService:Create(buttonPage, TweenInfo.new(slideTime, easeStyle, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		TweenService:Create(settingsPage, TweenInfo.new(slideTime, easeStyle, Enum.EasingDirection.Out), {Position = UDim2.new(1, 20, 0, 0)}):Play()
	end
end)

local function setGuiVisible(visible)
	main.Visible = visible
	if not visible then
		if settingsOpen then
			settingsOpen = false
			settingsBtn.Text = "⚙"
			settingsBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			main.Size = savedSizeBeforeSettings 
			buttonPage.Position = UDim2.new(0, 0, 0, 0)
			settingsPage.Position = UDim2.new(1, 20, 0, 0)
		end
	end
end

local function applyHighlight(char)
	if not boxesEnabled then return end
	if char == player.Character then return end
	if activeHighlights[char] then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "majTY_Highlight"
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
	highlight.OutlineTransparency = 0
	highlight.Adornee = char
	highlight.Parent = char

	activeHighlights[char] = highlight
end

local function removeHighlight(char)
	if activeHighlights[char] then
		activeHighlights[char]:Destroy()
		activeHighlights[char] = nil
	end
end

local function updateHighlights()
	if not boxesEnabled then
		for char, highlight in pairs(activeHighlights) do
			if highlight then highlight:Destroy() end
		end
		table.clear(activeHighlights)
	end
end

local function setupPlayerESP(p)
	p.CharacterRemoving:Connect(function(char)
		removeHighlight(char)
	end)
end

Players.PlayerAdded:Connect(setupPlayerESP)
for _, p in ipairs(Players:GetPlayers()) do
	setupPlayerESP(p)
end

task.spawn(function()
	while true do
		task.wait(0.1)
		if boxesEnabled then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= player and p.Character then
					local pRoot = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChild("Head")
					if pRoot then
						local distance = (pRoot.Position - camera.CFrame.Position).Magnitude
						if distance <= boxesRange then
							applyHighlight(p.Character)
						else
							removeHighlight(p.Character)
						end
					end
				end
			end
		end
	end
end)

local function isVisible(targetPart)
	local char = player.Character
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local ignoreList = {camera}
	if char then table.insert(ignoreList, char) end
	params.FilterDescendantsInstances = ignoreList

	local origin = camera.CFrame.Position
	local direction = targetPart.Position - origin
	local result = workspace:Raycast(origin, direction, params)

	if result then
		return result.Instance:IsDescendantOf(targetPart.Parent) or result.Instance == targetPart
	end
	return true
end

local function getClosestTarget()
	local closest = nil
	local shortestDistance = math.huge
	local mousePos = UserInputService:GetMouseLocation()
	local maxAimRange = extendAimRange and 500 or 200

	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v ~= player.Character then
			local head = v:FindFirstChild("Head")
			local hum = v:FindFirstChildOfClass("Humanoid")

			if head and hum and hum.Health > 0 then
				local studDistance = (head.Position - camera.CFrame.Position).Magnitude
				if studDistance <= maxAimRange then
					local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)

					if onScreen then
						local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
						if distance < shortestDistance then
							if isVisible(head) then
								closest = head
								shortestDistance = distance
							end
						end
					end
				end
			end
		end
	end
	return closest
end

local function startFly()
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:WaitForChild("HumanoidRootPart")
	bv = Instance.new("BodyVelocity", root)
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bg = Instance.new("BodyGyro", root)
	bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bg.P = 15000
end

local function stopFly()
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character:FindFirstChild("Humanoid").PlatformStand = false
	end
end

RunService.RenderStepped:Connect(function()
	if aimEnabled then
		local target = getClosestTarget()
		if target then
			local targetCFrame = CFrame.new(camera.CFrame.Position, target.Position)
			camera.CFrame = camera.CFrame:Lerp(targetCFrame, aimSpeed)
		end
	end

	if flyEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local root = player.Character.HumanoidRootPart
		local dir = Vector3.new(0,0,0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
		bv.Velocity = dir * flySpeed
		bg.CFrame = camera.CFrame
		player.Character:FindFirstChildOfClass("Humanoid").PlatformStand = true
	end
end)

local function toggleAim()
	aimEnabled = not aimEnabled
	aimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(40, 40, 40)
end

local function doTeleport()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
	end
end

local function toggleFly()
	flyEnabled = not flyEnabled
	flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(40, 40, 40)
	if flyEnabled then startFly() else stopFly() end
end

local function toggleBoxes()
	boxesEnabled = not boxesEnabled
	boxBtn.BackgroundColor3 = boxesEnabled and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(40, 40, 40)
	updateHighlights()
end

local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(40, 40, 40)

	if noclipEnabled then
		noclipConnection = RunService.Stepped:Connect(function()
			if player.Character then
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConnection then
			noclipConnection:Disconnect()
			noclipConnection = nil
		end
	end
end

local function toggleSuperSpeed()
	superSpeedEnabled = not superSpeedEnabled
	speedBtn.BackgroundColor3 = superSpeedEnabled and Color3.fromRGB(0, 170, 127) or Color3.fromRGB(40, 40, 40)

	local char = player.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = superSpeedEnabled and superSpeed or 16
		end
	end
end

player.CharacterAdded:Connect(function(char)
	if superSpeedEnabled then
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum.WalkSpeed = superSpeed
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 and ctrlClickTp then
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
			doTeleport()
		end
	end
end)

aimBtn.MouseButton1Click:Connect(toggleAim)
tpBtn.MouseButton1Click:Connect(doTeleport)
flyBtn.MouseButton1Click:Connect(toggleFly)
boxBtn.MouseButton1Click:Connect(toggleBoxes)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
speedBtn.MouseButton1Click:Connect(toggleSuperSpeed)

local resizeContainer = Instance.new("Frame", main)
resizeContainer.Name = "ResizeContainer"
resizeContainer.Size = UDim2.new(0, 15, 0, 15)
resizeContainer.Position = UDim2.new(1, -15, 1, -15)
resizeContainer.BackgroundTransparency = 1
resizeContainer.Active = true

local resizeHandle = Instance.new("Frame", resizeContainer)
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 12, 0, 5)
resizeHandle.Position = UDim2.new(0.5, -4, 0.5, -1) 
resizeHandle.Rotation = -45
resizeHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
resizeHandle.BackgroundTransparency = 0.5
resizeHandle.BorderSizePixel = 0
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(1, 0) 

local isResizing = false
resizeContainer.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isResizing = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then isResizing = false end end)

local dragging, dragStart, startPos
title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = main.Position end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	elseif isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mPos = UserInputService:GetMouseLocation()
		local newX = math.max(350, mPos.X - main.AbsolutePosition.X)
		local newY = math.max(135, (mPos.Y - 36) - main.AbsolutePosition.Y)
		main.Size = UDim2.new(0, newX, 0, newY)

		if not settingsOpen then
			savedSizeBeforeSettings = main.Size
		else
			savedSizeBeforeSettings = UDim2.new(0, newX, 0, savedSizeBeforeSettings.Y.Offset)
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == binds.Aim then toggleAim()
	elseif input.KeyCode == binds.Fly then toggleFly()
	elseif input.KeyCode == binds.TP then doTeleport()
	elseif input.KeyCode == binds.Boxes then toggleBoxes()
	elseif input.KeyCode == binds.Noclip then toggleNoclip()
	elseif input.KeyCode == binds.SuperSpeed then toggleSuperSpeed()
	elseif input.KeyCode == binds.ToggleGUI then setGuiVisible(not main.Visible) end
end)