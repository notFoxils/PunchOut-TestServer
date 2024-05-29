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
local walkingSpeed = 960/28 --Studs/Frame
local runningSpeed = 1320/28 --Studs/Frame
local jumpForce = (3.68/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local shortHopForce = (2.1/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local gravity = (0.23/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local fallingSpeed = (2.8/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local currentFallingSpeed = 0

local function handleMovementX()
	if math.abs(movementDirection.X) >= 0.2875 or UIS:IsKeyDown(Enum.KeyCode.Space) == true then
		return walkingSpeed * movementDirection.X
	elseif math.abs(movementDirection.X) >= 0.8 and UIS:IsKeyDown(Enum.KeyCode.Space) == false then
		return runningSpeed * movementDirection.X
	else
		return 0
	end
end

local function handleMovementY()
	if currentFallingSpeed > 0 then
		currentFallingSpeed = 0
	elseif currentFallingSpeed < fallingSpeed and inAir then
		currentFallingSpeed += gravity
		if currentFallingSpeed >= fallingSpeed then
			currentFallingSpeed = fallingSpeed
			inAir = false
		end
	end

	if movementDirection.Y > 0 then
		movementDirection = Vector3.new(movementDirection.X, movementDirection.Y - currentFallingSpeed)
		return movementDirection.Y
	end

	return 0
end

local function left(_actionName, inputState, _inputObject:InputObject)
	leftValue = (inputState == Enum.UserInputState.Begin) and -1 or 0
end

local function right(_actionName, inputState, _inputObject:InputObject)
    rightValue = (inputState == Enum.UserInputState.Begin) and 1 or 0
end

local function onJump(_actionName, inputState, _inputObject:InputObject)
	if timesJumped >= 2 and inAir == false then
		timesJumped = 0
	end

	if timesJumped < 2 then
		if inputState == Enum.UserInputState.Begin then
			isJumping = true
		elseif inputState == Enum.UserInputState.End then
			isJumping = false
			timesJumped += 1
		end
	end
end

local function moveThePlayer(delta:number)
	movementDirection = Vector2.new(rightValue + leftValue, movementDirection.Y)

	if movementDirection ~= Vector2.zero then
		humanoidRootPart:PivotTo(humanoidRootPart.CFrame * CFrame.new(Vector3.new(handleMovementX() * delta, handleMovementY() * delta)))
	end
end

local function handleJumpForce()
	if movementDirection.Y == 0 or inAir then
		if not isJumping and framesSinceJump > 0 then
			if framesSinceJump <= jumpSquatFrames then
				movementDirection = Vector2.new(movementDirection.X, shortHopForce)
				inAir = true
				lastJump = "short"
			elseif framesSinceJump >= jumpSquatFrames then
				movementDirection = Vector2.new(movementDirection.X, jumpForce)
				inAir = true
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
			elseif index == 14 then
				value.Text = currentFallingSpeed
			elseif index == 16 then
				value.Text = tostring(inAir)
			end
		end
	end
end

function isGrounded(part)
    local rayStart = part.Position
    local rayEnd = part.Position - Vector3.new(0, 5, 0) -- Extend the ray downwards by 5 studs

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {part}

    local result = workspace:Raycast(rayStart, rayEnd, raycastParams)

    if result then
        -- The part is grounded if the ray hits another part
        return true
    else
        -- The part is not grounded if the ray doesn't hit anything
        return false
    end
end

local function onRenderStep(delta)
	handleJumpForce()
	moveThePlayer(delta)
	debugDisplay()
end

ContextActionService:BindAction("Left", left, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", right, false, Enum.KeyCode.D)
ContextActionService:BindAction("Jump", onJump, false, Enum.KeyCode.Space, Enum.KeyCode.W)

RunService.RenderStepped:Connect(onRenderStep)