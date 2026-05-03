-- MAIN SCRIPT : À METTRE DANS ServerScriptService
-- Il crée automatiquement toute l’architecture (UI + RemoteEvent + Script serveur)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayer").StarterPlayerScripts
local ServerScriptService = game:GetService("ServerScriptService")

---------------------------------------------------------------------
-- 1) CRÉATION DU REMOTEEVENT
---------------------------------------------------------------------
local event = ReplicatedStorage:FindFirstChild("ChangeAvatarEvent")
if not event then
    event = Instance.new("RemoteEvent")
    event.Name = "ChangeAvatarEvent"
    event.Parent = ReplicatedStorage
end

---------------------------------------------------------------------
-- 2) CRÉATION DU SCRIPT SERVEUR QUI CHANGE L’AVATAR
---------------------------------------------------------------------
if not ServerScriptService:FindFirstChild("AvatarChanger") then
    local serverScript = Instance.new("Script")
    serverScript.Name = "AvatarChanger"
    serverScript.Source = [[
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local event = ReplicatedStorage:WaitForChild("ChangeAvatarEvent")

        event.OnServerEvent:Connect(function(player, targetUserId)
            local character = player.Character
            if not character then return end

            local humanoid = character:FindFirstChild("Humanoid")
            if not humanoid then return end

            local success, description = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(targetUserId)
            end)

            if success then
                humanoid:ApplyDescription(description)
            else
                warn("Impossible de charger la description du joueur ID :", targetUserId)
            end
        end)
    ]]
    serverScript.Parent = ServerScriptService
end

---------------------------------------------------------------------
-- 3) CRÉATION DU LOCALSCRIPT QUI GÈRE L’UI
---------------------------------------------------------------------
if not StarterPlayerScripts:FindFirstChild("AvatarUI") then
    local localScript = Instance.new("LocalScript")
    localScript.Name = "AvatarUI"
    localScript.Source = [[
        local Players = game:GetService("Players")
        local ReplicatedStorage = game:GetService("ReplicatedStorage")

        local event = ReplicatedStorage:WaitForChild("ChangeAvatarEvent")
        local LocalPlayer = Players.LocalPlayer

        -- GUI
        local gui = Instance.new("ScreenGui")
        gui.Name = "AvatarChangerUI"
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 220, 0, 140)
        frame.Position = UDim2.new(0.3, 0, 0.3, 0)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        frame.Active = true
        frame.Draggable = true
        frame.Parent = gui

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 25)
        title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        title.Text = "Changer d'Avatar"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Parent = frame

        local textbox = Instance.new("TextBox")
        textbox.Size = UDim2.new(1, -20, 0, 30)
        textbox.Position = UDim2.new(0, 10, 0, 35)
        textbox.PlaceholderText = "Entre un UserId"
        textbox.Text = ""
        textbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        textbox.TextColor3 = Color3.new(1, 1, 1)
        textbox.Parent = frame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 30)
        button.Position = UDim2.new(0, 10, 0, 70)
        button.Text = "Transformer"
        button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Parent = frame

        button.MouseButton1Click:Connect(function()
            local userId = tonumber(textbox.Text)
            if userId then
                event:FireServer(userId)
            else
                textbox.Text = "ID invalide"
            end
        end)
    ]]
    localScript.Parent = StarterPlayerScripts
end

print("Avatar Changer installé automatiquement.")
