local Config = {
    Box = false,
    BoxOutline = false,
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    HealthBar = false,
    HealthBarSide = "Left", -- Options are "Left", "Bottom", "Right"
    Names = false,
    NamesOutline = false,
    NamesColor = Color3.fromRGB(255, 255, 255),
    NamesOutlineColor = Color3.fromRGB(0, 0, 0),
    NamesFont = 2, -- Enum.Font options as numbers
    NamesSize = 13
}

-- Function to create ESP for a player
function CreateEsp(player)
    if not player.Character or player.Team == game:GetService("Players").LocalPlayer.Team then
        return  -- Do not create ESP if on the same team or character does not exist
    end

    local Box, BoxOutline, Name, HealthBar, HealthBarOutline = Drawing.new("Square"), Drawing.new("Square"), Drawing.new("Text"), Drawing.new("Square"), Drawing.new("Square")
    local updater = game:GetService("RunService").RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild("Head") then
            local target2DPosition, isVisible = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            local scaleFactor = 1 / (target2DPosition.Z * math.tan(math.rad(workspace.CurrentCamera.FieldOfView * 0.5)) * 2) * 100
            local width, height = math.floor(40 * scaleFactor), math.floor(60 * scaleFactor)
            
            -- Update ESP elements based on visibility and player settings
            updateEspElements(isVisible, player, Box, BoxOutline, Name, HealthBar, HealthBarOutline, target2DPosition, width, height, Config)
        else
            Box.Visible = false
            BoxOutline.Visible = false
            Name.Visible = false
            HealthBar.Visible = false
            HealthBarOutline.Visible = false
            -- Clean up if the player leaves or the character is deleted
            if not player then
                cleanupEsp(Box, BoxOutline, Name, HealthBar, HealthBarOutline, updater)
            end
        end
    end)
end

-- Function to update ESP elements
function updateEspElements(isVisible, player, Box, BoxOutline, Name, HealthBar, HealthBarOutline, target2DPosition, width, height, config)
    -- Update box
    if config.Box then
        Box.Visible = isVisible
        Box.Color = config.BoxColor
        Box.Size = Vector2.new(width, height)
        Box.Position = Vector2.new(target2DPosition.X - Box.Size.X / 2, target2DPosition.Y - Box.Size.Y / 2)
        Box.Thickness = 1
        Box.ZIndex = 3
        if config.BoxOutline then
            BoxOutline.Visible = isVisible
            BoxOutline.Color = config.BoxOutlineColor
            BoxOutline.Size = Vector2.new(width, height)
            BoxOutline.Position = Vector2.new(target2DPosition.X - Box.Size.X / 2, target2DPosition.Y - Box.Size.Y / 2)
            BoxOutline.Thickness = 3
            BoxOutline.ZIndex = 2
        else
            BoxOutline.Visible = false
        end
    else
        Box.Visible = false
        BoxOutline.Visible = false
    end

    -- Update names
    if config.Names then
        Name.Visible = isVisible
        Name.Color = config.NamesColor
        Name.Text = player.Name.." "..math.floor((workspace.CurrentCamera.CFrame.p - player.Character.HumanoidRootPart.Position).magnitude).."m"
        Name.Center = true
        Name.Outline = config.NamesOutline
        Name.OutlineColor = config.NamesOutlineColor
        Name.Position = Vector2.new(target2DPosition.X, target2DPosition.Y - height * 0.5 - 15)
        Name.Font = config.NamesFont
        Name.Size = config.NamesSize
        Name.ZIndex = 4
    else
        Name.Visible = false
    end

    -- Update health bars
    if config.HealthBar then
        HealthBarOutline.Visible = isVisible
        HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
        HealthBarOutline.Filled = true
        HealthBarOutline.ZIndex = 2

        HealthBar.Visible = isVisible
        HealthBar.Color = Color3.fromRGB(255, 0, 0):lerp(Color3.fromRGB(0, 255, 0), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
        HealthBar.Thickness = 1
        HealthBar.Filled = true
        HealthBar.ZIndex = 3
        updateHealthBarPosition(HealthBar, HealthBarOutline, target2DPosition, width, height, config)
    else
        HealthBar.Visible = false
        HealthBarOutline.Visible = false
    end
end

-- Function to update the position of health bars based on the configuration
function updateHealthBarPosition(HealthBar, HealthBarOutline, target2DPosition, width, height, config)
    if config.HealthBarSide == "Left" then
        HealthBarOutline.Size = Vector2.new(2, height)
        HealthBarOutline.Position = Vector2.new(target2DPosition.X - width / 2 - 3, target2DPosition.Y - height / 2)

        HealthBar.Size = Vector2.new(1, -(height - 2) * (player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth))
        HealthBar.Position = Vector2.new(HealthBarOutline.Position.X + 1, HealthBarOutline.Position.Y + height - 1)
    elseif config.HealthBarSide == "Bottom" then
        HealthBarOutline.Size = Vector2.new(width, 2)
        HealthBarOutline.Position = Vector2.new(target2DPosition.X - width / 2, target2DPosition.Y + height / 2 + 1)

        HealthBar.Size = Vector2.new((width - 2) * (player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth), 1)
        HealthBar.Position = Vector2.new(HealthBarOutline.Position.X + 1, HealthBarOutline.Position.Y + 1)
    elseif config.HealthBarSide == "Right" then
        HealthBarOutline.Size = Vector2.new(2, height)
        HealthBarOutline.Position = Vector2.new(target2DPosition.X + width / 2 + 1, target2DPosition.Y - height / 2)

        HealthBar.Size = Vector2.new(1, -(height - 2) * (player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth))
        HealthBar.Position = Vector2.new(HealthBarOutline.Position.X + 1, HealthBarOutline.Position.Y + height - 1)
    end
end

-- Function to clean up ESP elements when they are no longer needed
function cleanupEsp(Box, BoxOutline, Name, HealthBar, HealthBarOutline, updater)
    Box:Remove()
    BoxOutline:Remove()
    Name:Remove()
    HealthBar:Remove()
    HealthBarOutline:Remove()
    updater:Disconnect()
end

-- Connect events for all players and new players joining
game:GetService("Players").PlayerAdded:Connect(function(player)
    if player ~= game:GetService("Players").LocalPlayer and player.Team ~= game:GetService("Players").LocalPlayer.Team then
        player.CharacterAdded:Connect(function()
            CreateEsp(player)
        end)
    end
end)

for _, player in pairs(game:GetService("Players"):GetPlayers()) do
    if player ~= game:GetService("Players").LocalPlayer and player.Team ~= game:GetService("Players").LocalPlayer.Team then
        player.CharacterAdded:Connect(function()
            CreateEsp(player)
        end)
    end
end
