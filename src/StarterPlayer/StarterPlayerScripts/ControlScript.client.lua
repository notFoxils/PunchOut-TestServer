local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local playerGui = localPlayer:WaitForChild("PlayerGui")
local debugFrame = playerGui:WaitForChild("DebugGui").DebugFrame
local debugValues = debugFrame:GetDescendants()

local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

local leftValue, rightValue = 0, 0
local isJumping = false
local jumpSquatFrames = 3
local framesSinceJump = 0
local timesJumped = 0
local inAir = false
local lastJump = "none"
local movementDirection:Vector2 = Vector2.new(rightValue + leftValue, 0)
local walkingSpeed = 960/28
local runningSpeed = 1320/28
local jumpForce = 3.68
local shortHopForce = 2.1

local function handleMovementX()
	if math.abs(movementDirection.X) >= 0.2875 or UIS:IsKeyDown(Enum.KeyCode.Space) == true then
		return walkingSpeed * movementDirection.X
	elseif math.abs(movementDirection.X) >= 0.8 and UIS:IsKeyDown(Enum.KeyCode.Space) == false then
		return runningSpeed * movementDirection.X
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

local function onJump(_actionName, inputState, _inputObject:InputObject)
	if inputState == Enum.UserInputState.Begin then
		isJumping = true
	elseif inputState == Enum.UserInputState.End then
		isJumping = false
		timesJumped += 1
	end
end

local function moveThePlayer(delta:number)
	movementDirection = Vector2.new(rightValue + leftValue, 0)

	if movementDirection ~= Vector2.zero then
		humanoidRootPart:PivotTo(humanoidRootPart.CFrame * CFrame.new(Vector3.new(handleMovementX() * delta)))
	end
end

local function handleJumpForce()
	if movementDirection.Y == 0 or inAir then
		if not isJumping and framesSinceJump > 0 then
			if framesSinceJump <= jumpSquatFrames then
				movementDirection = Vector2.new(movementDirection.X, shortHopForce)
				lastJump = "short"
			elseif framesSinceJump >= jumpSquatFrames then
				movementDirection = Vector2.new(movementDirection.X, jumpForce)
				lastJump = "full"
			end
			framesSinceJump = 0
		elseif isJumping then
			framesSinceJump += 1
			if framesSinceJump > jumpSquatFrames then
				isJumping = false
			end
		end
	end
end

local function debugDisplay()
	for index, value:TextLabel in pairs(debugValues) do
		if value.Parent.ClassName == "TextLabel" then
			if index == 2 then
				value.Text = leftValue
			elseif index == 4 then
				value.Text = rightValue
			elseif index == 6 then
				value.Text = tostring(isJumping)
			elseif index == 8 then
				value.Text = tostring(framesSinceJump)
			elseif index == 10 then
				value.Text = tostring(movementDirection)
			elseif index == 12 then
				value.Text = lastJump
			end
		end
	end
end

local function onRenderStep(delta)
	moveThePlayer(delta)
	handleJumpForce()
	debugDisplay()
end

ContextActionService:BindAction("Left", left, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", right, false, Enum.KeyCode.D)
ContextActionService:BindAction("Jump", onJump, false, Enum.KeyCode.Space, Enum.KeyCode.W)

RunService.RenderStepped:Connect(onRenderStep)