local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local playerGui = localPlayer:WaitForChild("PlayerGui")
local debugFrame = playerGui:WaitForChild("DebugGui").DebugFrame
local debugValues = debugFrame:GetDescendants()

local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

local leftInput, rightInput = 0, 0
local isJumping = false
local framesSinceJump = 0
local doubleJumpPossible = true
local inAir = false
local velocity:Vector2 = Vector2.new(0, 0)
local currentFallingSpeed = 0

--statics, currently based off of converted values from fox in melee,should be modularized, but problem for later me :)
local walkingSpeed = 960/28 --Studs/Frame
local runningSpeed = 1320/28 --Studs/Frame
local jumpForce = (3.68/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local shortHopForce = (2.1/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local gravity = (0.23/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local fallingSpeed = (2.8/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local jumpSquatFrames = 3

--debug
local lastJump = "none"

--temporoary, to be solved/implemented later ingame though menus and whatnot


local function isGrounded()
	local raycastResult = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -1, 0), RaycastParams.new())

	if not raycastResult == nil then
		return true
	end
	return false
end

local function left(_actionName, inputState, _inputObject:InputObject)
	leftInput = (inputState == Enum.UserInputState.Begin) and -1 or 0
end

local function right(_actionName, inputState, _inputObject:InputObject)
    rightInput = (inputState == Enum.UserInputState.Begin) and 1 or 0
end

local function onJump(_actionName, inputState, _inputObject:InputObject)
	local currentGroundedStatus = isGrounded()

	if inputState == Enum.UserInputState.Begin and (currentGroundedStatus or doubleJumpPossible) then
		doubleJumpPossible = (currentGroundedStatus) and true or false
		isJumping = true
	elseif inputState == Enum.UserInputState.End then
		isJumping = false
	end
end

local function horizontalInput()
	return leftInput + rightInput
end

local function handleMovementX()
	local currentInputX = horizontalInput()

	if math.abs(currentInputX) >= 0.2875 or UserInputService:IsKeyDown(Enum.KeyCode.Space) == true then --The keycode should be user configureable later on
		return walkingSpeed * currentInputX
	elseif math.abs(currentInputX) >= 0.8 and UserInputService:IsKeyDown(Enum.KeyCode.Space) == false then --The keycode should be user configureable later on
		return runningSpeed * currentInputX
	else
		return 0
	end
end

local function handleMovementY()
	
end

local function updateVelocity(delta:number)
	velocity = Vector2.new(handleMovementX() * delta)--, handleMovementY() * delta)
end

local function updatePosition()
	humanoidRootPart:PivotTo(humanoidRootPart.CFrame * CFrame.new(Vector3.new(velocity.X, velocity.Y, 0))) --multiplying cframes is like adding regular numebers, confusing, but "it is what it is"
end

local function debugDisplay()
	for index, value:TextLabel in pairs(debugValues) do
		if value.Parent.ClassName == "TextLabel" then
			if index == 2 then
				value.Text = leftInput
			elseif index == 4 then
				value.Text = rightInput
			elseif index == 6 then
				value.Text = tostring(isJumping)
			elseif index == 8 then
				value.Text = tostring(framesSinceJump)
			elseif index == 10 then
				value.Text = tostring(velocity)
			elseif index == 12 then
				value.Text = lastJump
			elseif index == 14 then
				value.Text = currentFallingSpeed
			elseif index == 16 then
				value.Text = tostring(isGrounded)
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
	updateVelocity(delta)
	updatePosition()
	debugDisplay()
end

ContextActionService:BindAction("Left", left, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", right, false, Enum.KeyCode.D)
ContextActionService:BindAction("Jump", onJump, false, Enum.KeyCode.Space, Enum.KeyCode.W)

RunService.RenderStepped:Connect(onRenderStep)