local Players = game:GetService("Players")

local char = Players.LocalPlayer.CharacterAdded:Wait()

local function deez(yes:Model)
    print(Players:GetPlayerFromCharacter(yes).DisplayName)
end

deez(char)