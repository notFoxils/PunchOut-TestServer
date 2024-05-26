local cam = workspace.CurrentCamera
local Players = game:GetService("Players")
local ts = game:GetService("TweenService")
task.wait(5)
local hurmps = {Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")}

local xoffset = 0
local yoffset = 2
local zoffset = 40

local camPart = Instance.new("Part")
camPart.Anchored = true
camPart.Name = "CamPart"
camPart.Parent = workspace
camPart.Transparency = 1
camPart.CanCollide = false

function calculateAveragePosition()
	local total = Vector3.new()
	for _, humrootpart in pairs(hurmps) do    
		total += humrootpart.Position
	end
	return total / #hurmps
end

function calculateAverageMagnitude()
	local total = 0
	for _, humrootpart in pairs(hurmps) do    
		total += (humrootpart.Position - camPart.Position).Magnitude
	end

	return total / #hurmps
end

function camManager()
	local averagePos = calculateAveragePosition()
	camPart.Position = averagePos
	local averageMagnitude = calculateAverageMagnitude() + zoffset
	local tweenInfo = TweenInfo.new(0.02, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
	local propertyTable = {CFrame = camPart.CFrame * CFrame.new(xoffset, yoffset, averageMagnitude)}
	
	ts:Create(cam, tweenInfo, propertyTable):Play()
end

task.wait()
cam.CameraType = Enum.CameraType.Scriptable

game:GetService("RunService").Heartbeat:Connect(camManager)

