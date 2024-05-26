local currentCamera = workspace.CurrentCamera
currentCamera.CameraType = Enum.CameraType.Scriptable
local playerService = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local cameraTweenInfo = TweenInfo.new(0.02, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local humanoidRootParts = {}

local xoffset = 0
local yoffset = 2
local zoffset = 40

local camPart = Instance.new("Part")
camPart.Anchored = true
camPart.Name = "camPart"
camPart.Parent = workspace
camPart.Transparency = 1
camPart.CanCollide = false

local function calculateAveragePosition()
	local total = Vector3.new()
	for _, humrootpart in pairs(humanoidRootParts) do
		total += humrootpart.Position
	end
	return total / #humanoidRootParts
end

local function calculateAverageMagnitude()
	local total = 0

	for _, humanoidRootPart in pairs(humanoidRootParts) do
		total += (humanoidRootPart.Position - camPart.Position).Magnitude
	end

	return total / #humanoidRootParts
end

local function camManager()
	local averageMagnitude = calculateAverageMagnitude() + zoffset
	local averagePos = calculateAveragePosition()
	print(averagePos)
	camPart.Position = averagePos
	local tweenPropertyTable = {CFrame = camPart.CFrame * CFrame.new(xoffset, yoffset, averageMagnitude + zoffset)}
	local tween = tweenService:Create(camPart, cameraTweenInfo, tweenPropertyTable)
	tween:Play()
end

local function addToCamList(player:Player)
	humanoidRootParts[#humanoidRootParts+1] = player.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
	for index, value in pairs(humanoidRootParts) do
		print(index)
		print(value)
	end
end

game:GetService("RunService").Heartbeat:Connect(camManager)
playerService.PlayerAdded:Connect(addToCamList)