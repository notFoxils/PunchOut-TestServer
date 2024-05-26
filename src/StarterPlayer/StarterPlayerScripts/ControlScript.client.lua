local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local humanoidRootPart = Players.LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")

local leftValue, rightValue = 0, 0
local movementDirection:Vector2 = Vector2.new(rightValue + leftValue, 0)
local walkingSpeed = 960/28
local runningSpeed = 1320/28

local function handleMovementX()
	if math.abs(movementDirection.X) >= 0.8 and UIS:IsKeyDown(Enum.KeyCode.Space) == false then
		return runningSpeed * movementDirection.X
	elseif math.abs(movementDirection.X) >= 0.2875 and UIS:IsKeyDown(Enum.KeyCode.Space) == true then
		return walkingSpeed * movementDirection.X
	else
		return 0
	end
end

local function left(_actionName, inputState, _inputObject:InputObject)
	leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
end

local function right(_actionName, inputState, _inputObject:InputObject)
    rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
end

local function onJump(_actionName, _inputState, _inputObject:InputObject)

end

local function onRenderStep(delta)
	movementDirection = Vector2.new(rightValue + leftValue, 0)

	if movementDirection ~= Vector2.zero then
		local moveBy = handleMovementX() * delta
		humanoidRootPart:PivotTo(humanoidRootPart.CFrame * CFrame.new(Vector3.new(moveBy)))
	end
end

ContextActionService:BindAction("Left", left, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", right, false, Enum.KeyCode.D)
ContextActionService:BindAction("Jump", onJump, false, Enum.KeyCode.Space, Enum.KeyCode.W)

RunService.PreRender:Connect(onRenderStep)