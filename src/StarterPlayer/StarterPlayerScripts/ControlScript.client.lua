local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local playerGui = localPlayer:WaitForChild("PlayerGui")
local debugFrame = playerGui:WaitForChild("DebugGui").DebugFrame
local debugValues = debugFrame:GetDescendants()

local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

--input related variables, easily modularized:tm:
local leftInput:number, rightInput:number = 0, 0
local isJumping:boolean = false
local jumpSquatTimeJumped:number = 0
local doubleJumpPossible:boolean = true
local velocity:Vector3 = Vector3.zero
local xVelocity:number = 0
local yVelocity:number = 0
local currentFallingSpeed:number = 0

--statics, currently based off of converted values from fox in melee, should be modularized, but problem for later me :)
local walkingSpeed = 960/28 --Studs/Frame
local runningSpeed = 1320/28 --Studs/Frame
local fullJumpForce = (3.68/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local shortHopForce = (2.1/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local gravity = (0.23/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local fallingSpeed = (2.8/2.8)*60 --(Studs/Frame)*60 || Studs/Frame = (SU (Smash Unit)/Frame)/2.8
local jumpSquatDurationSecs = 0.05
--debug
local lastJump = "none"

local function isGrounded()
	local raycastResult = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -3.9, 0), RaycastParams.new())

	if raycastResult ~= nil then
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
		jumpSquatTimeJumped = os.clock() --Set the player's time jumped to now
	elseif inputState == Enum.UserInputState.End and isJumping then
		-- how long have they held the jump button?
		local now = os.clock()
		
		if now - jumpSquatTimeJumped < jumpSquatDurationSecs then -- below our short jump threshold
			lastJump = "Short"
		else -- above our short jump threshold
			lastJump = "Full"
		end
		
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
	end

	return 0
end

local function handleMovementY()
	print("asking for grounded status")
	local currentGroundedStatus = isGrounded()

	if not currentGroundedStatus then
		if currentFallingSpeed ~= fallingSpeed and yVelocity > 0 then
			print("setting fall speed non 0")
			currentFallingSpeed = math.min(currentFallingSpeed + gravity, fallingSpeed)
		end
	end
	if currentGroundedStatus and lastJump == nil then
		currentFallingSpeed = 0
		return 0
	end
	if lastJump == "Full" then
		lastJump = nil
		return fullJumpForce
	elseif lastJump == "Short" then
		lastJump = nil
		return shortHopForce
	end

	return yVelocity - currentFallingSpeed
end

local function updateVelocity(delta:number)
	xVelocity = handleMovementX()
	yVelocity = handleMovementY()

	velocity = Vector3.new(xVelocity * delta, yVelocity * delta)
end

local function updatePosition()
	humanoidRootPart:PivotTo(humanoidRootPart.CFrame * CFrame.new(velocity)) --multiplying cframes is like adding regular numebers, confusing, but "it is what it is"
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
				value.Text = tostring(jumpSquatTimeJumped)
			elseif index == 10 then
				value.Text = tostring(velocity)
			elseif index == 12 then
				value.Text = tostring(lastJump)
			elseif index == 14 then
				value.Text = currentFallingSpeed
			elseif index == 16 then
				value.Text = tostring(isGrounded())
			end
		end
	end
end

local function onRenderStep(delta)
	updateVelocity(delta)
	updatePosition()
	debugDisplay()
end

ContextActionService:BindAction("Left", left, false, Enum.KeyCode.A)
ContextActionService:BindAction("Right", right, false, Enum.KeyCode.D)
ContextActionService:BindAction("Jump", onJump, false,Enum.KeyCode.W)

RunService:BindToRenderStep("CharacterController", Enum.RenderPriority.Camera.Value - 1, onRenderStep)