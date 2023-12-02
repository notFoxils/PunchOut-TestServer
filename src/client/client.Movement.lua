local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local button = Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui").ImageButton
local controller = false
local vectorZero = Vector2.zero
local movementDirection:Vector2 = vectorZero
local thumbstickDeadzone = 0.1
local leftValue, rightValue = 0, 0
local walkingSpeed = 960/28
local runningSpeed = 1320/28

button.Activated:Connect(function()
	if not controller then
		button.BackgroundColor = BrickColor.White()
	else
		button.BackgroundColor = BrickColor.Gray()
	end

	controller = not controller
end)

local function handleMovementX()
	if (controller == false) then
		movementDirection = Vector2.new(rightValue + leftValue, 0)
	end
	if (movementDirection ~= vectorZero) then
		local targetSpeed = (math.abs(movementDirection.X) >= 0.8 and UIS:IsKeyDown(Enum.KeyCode.Space) == false) and runningSpeed * movementDirection.X or (math.abs(movementDirection.X) >= 0.2875 and UIS:IsKeyDown(Enum.KeyCode.Space) == true) and walkingSpeed * movementDirection.X or 0
		return targetSpeed
	end
	return 0
end

local function controllerX(_actionName, inputState, inputObject:InputObject)
	if inputState == Enum.UserInputState.Cancel then
		movementDirection = vectorZero
	end

	if inputObject.Position.Magnitude > thumbstickDeadzone then
		movementDirection = Vector2.new(inputObject.Position.X, inputObject.Position.Y)
	else
		movementDirection = vectorZero
	end
end

local function left(_actionName, inputState, inputObject:InputObject)
    leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
end

local function right(_actionName, inputState, inputObject:InputObject)
    rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
end

local function onJump(_actionName, inputState, inputObject:InputObject)
end

local function onRenderStep(delta)
	local moveBy = handleMovementX() * delta
	Players.LocalPlayer.Character.HumanoidRootPart:PivotTo(Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(Vector3.new(moveBy)))
end

ContextActionService:BindAction("Left", left, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", right, false, Enum.KeyCode.D)
ContextActionService:BindAction("Thumbstick1", controllerX, false, Enum.KeyCode.Thumbstick2)
ContextActionService:BindAction("Jump", onJump, false, Enum.KeyCode.Space, Enum.KeyCode.W, Enum.KeyCode.ButtonX)
RunService.PreRender:Connect(onRenderStep)