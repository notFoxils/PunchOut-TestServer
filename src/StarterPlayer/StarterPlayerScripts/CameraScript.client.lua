local currentCamera = workspace.CurrentCamera
currentCamera.CameraType = Enum.CameraType.Scriptable
local playerService = game:GetService("Players")
local tweenService = game:GetService("TweenService")

local humanoidRootParts = {playerService.LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")}

local xoffset = 0
local yoffset = 2
local zoffset = 40

local camPart = Instance.new("Part")
camPart.Anchored = true
camPart.Name = "CamPart"
camPart.Parent = workspace
camPart.Transparency = 1
camPart.CanCollide = false

local function calculateAveragePosition()
	local totalOfPositions = Vector3.new()

	for _, humanoidRootPart in pairs(humanoidRootParts) do
		totalOfPositions += humanoidRootPart.Position
	end

	return totalOfPositions / #humanoidRootParts
end

local function calculateAverageMagnitude()
	local total = 0

	for _, humanoidRootPart in pairs(humanoidRootParts) do
		total += (humanoidRootPart.Position - camPart.Position).Magnitude
	end

	return total / #humanoidRootParts
end

local function camManager()
	local averagePos = calculateAveragePosition()
	camPart.Position = averagePos
	local averageMagnitude = calculateAverageMagnitude() + zoffset
	local tweenInfo = TweenInfo.new(0.02, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local propertyTable = {CFrame = camPart.CFrame * CFrame.new(xoffset, yoffset, averageMagnitude)}
	tweenService:Create(currentCamera, tweenInfo, propertyTable):Play()
end

game:GetService("RunService").Heartbeat:Connect(camManager)