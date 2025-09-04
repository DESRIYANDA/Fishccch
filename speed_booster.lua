-- Speed Booster Module
-- Advanced speed enhancement system using dump.txt data analysis

local SpeedBooster = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- Speed configuration
SpeedBooster.config = {
    walkSpeed = 16,          -- Default walk speed
    jumpPower = 50,          -- Default jump power
    swimSpeed = 16,          -- Swimming speed
    vehicleSpeed = 1,        -- Vehicle speed multiplier
    teleportSpeed = true,    -- Instant teleportation
    performanceMode = false  -- Performance optimization
}

-- Performance Controller RemoteEvents (from dump analysis)
SpeedBooster.remotes = {
    enablePerformanceMode = "ReplicatedStorage.packages.Net.RE/PerformanceController/EnablePerformanceMode",
    disableFlags = "ReplicatedStorage.packages.Net.RE/PerformanceController/DisableFlags",
    boostModifier = "ReplicatedStorage.packages.Net.RE/BoostModifier",
    boostBaitModifier = "ReplicatedStorage.packages.Net.RE/BoostBaitModifier",
    fastTravel = "ReplicatedStorage.packages.Net.RE/FastTravel/Teleport",
    requestTeleport = "ReplicatedStorage.packages.Net.RF/RequestTeleportCFrame",
    setZone = "ReplicatedStorage.packages.Net.RF/SetZone"
}

-- Vehicle RemoteEvents (from dump analysis)
SpeedBooster.vessels = {
    "Red Racer", "Fischmas Speedboat", "Really Fast Jetski", "Silent Speeder",
    "Volcanic Speedboat", "Atlantean Jetski", "Molten Jetski", "Airboat",
    "Serpent Cruiser", "Guardian of Atlantis", "Dead Fish Express",
    "Flipper Express", "Cthulhu Boat", "Nessie Nomad"
}

-- Safe remote access function
function SpeedBooster.getRemote(remotePath)
    local pathParts = remotePath:split(".")
    local current = game
    
    for _, part in ipairs(pathParts) do
        if part:find("/") then
            -- Handle Net package paths
            local netParts = part:split("/")
            for _, netPart in ipairs(netParts) do
                current = current:FindFirstChild(netPart)
                if not current then return nil end
            end
        else
            current = current:FindFirstChild(part)
            if not current then return nil end
        end
    end
    
    return current
end

-- Enable performance mode for better speed
function SpeedBooster.enablePerformanceMode()
    local remote = SpeedBooster.getRemote(SpeedBooster.remotes.enablePerformanceMode)
    if remote then
        pcall(function()
            remote:FireServer()
        end)
        print("✅ Performance mode enabled!")
        SpeedBooster.config.performanceMode = true
    else
        print("⚠️ Performance mode remote not found")
    end
end

-- Disable performance flags that might limit speed
function SpeedBooster.disablePerformanceFlags()
    local remote = SpeedBooster.getRemote(SpeedBooster.remotes.disableFlags)
    if remote then
        pcall(function()
            remote:FireServer()
        end)
        print("✅ Performance flags disabled!")
    end
end

-- Apply boost modifiers
function SpeedBooster.applyBoostModifiers(multiplier)
    multiplier = multiplier or 2
    
    -- Boost modifier
    local boostRemote = SpeedBooster.getRemote(SpeedBooster.remotes.boostModifier)
    if boostRemote then
        pcall(function()
            boostRemote:FireServer(multiplier)
        end)
    end
    
    -- Boost bait modifier
    local boostBaitRemote = SpeedBooster.getRemote(SpeedBooster.remotes.boostBaitModifier)
    if boostBaitRemote then
        pcall(function()
            boostBaitRemote:FireServer(multiplier)
        end)
    end
    
    print("✅ Boost modifiers applied: x" .. multiplier)
end

-- Enhance player movement speed
function SpeedBooster.enhanceMovement(walkSpeed, jumpPower)
    walkSpeed = walkSpeed or 50
    jumpPower = jumpPower or 100
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    -- Apply speed enhancements
    humanoid.WalkSpeed = walkSpeed
    humanoid.JumpPower = jumpPower
    
    -- Swimming speed enhancement
    humanoid.Swimming:Connect(function()
        humanoid.WalkSpeed = walkSpeed * 1.2 -- Faster swimming
    end)
    
    SpeedBooster.config.walkSpeed = walkSpeed
    SpeedBooster.config.jumpPower = jumpPower
    
    print("✅ Movement enhanced - Walk: " .. walkSpeed .. ", Jump: " .. jumpPower)
    return true
end

-- Enhanced teleportation using fast travel system
function SpeedBooster.fastTeleport(targetPosition)
    if not targetPosition then return false end
    
    local character = LocalPlayer.Character
    if not character then return false end
    
    if SpeedBooster.config.teleportSpeed then
        -- Instant teleport
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = CFrame.new(targetPosition)
            return true
        end
    else
        -- Use game's fast travel system
        local fastTravelRemote = SpeedBooster.getRemote(SpeedBooster.remotes.fastTravel)
        if fastTravelRemote then
            pcall(function()
                fastTravelRemote:FireServer(targetPosition)
            end)
            return true
        end
    end
    
    return false
end

-- Enhanced vehicle speed using vessel RemoteEvents
function SpeedBooster.enhanceVehicleSpeed(speedMultiplier)
    speedMultiplier = speedMultiplier or 3
    
    local enhanced = 0
    
    for _, vesselName in ipairs(SpeedBooster.vessels) do
        local vesselPath = "ReplicatedStorage.resources.replicated.instances.vessels." .. vesselName .. ".Base.RemoteEvent"
        local vesselRemote = SpeedBooster.getRemote(vesselPath)
        
        if vesselRemote then
            pcall(function()
                vesselRemote:FireServer("speed", speedMultiplier)
            end)
            enhanced = enhanced + 1
        end
    end
    
    SpeedBooster.config.vehicleSpeed = speedMultiplier
    print("✅ Enhanced " .. enhanced .. " vehicles with speed multiplier: x" .. speedMultiplier)
    
    return enhanced > 0
end

-- Auto-speed maintenance
function SpeedBooster.startAutoSpeed()
    if SpeedBooster.autoSpeedConnection then
        SpeedBooster.autoSpeedConnection:Disconnect()
    end
    
    SpeedBooster.autoSpeedConnection = RunService.Heartbeat:Connect(function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                -- Maintain enhanced speeds
                if humanoid.WalkSpeed < SpeedBooster.config.walkSpeed then
                    humanoid.WalkSpeed = SpeedBooster.config.walkSpeed
                end
                if humanoid.JumpPower < SpeedBooster.config.jumpPower then
                    humanoid.JumpPower = SpeedBooster.config.jumpPower
                end
            end
        end
    end)
    
    print("✅ Auto-speed maintenance started!")
end

-- Stop auto-speed maintenance
function SpeedBooster.stopAutoSpeed()
    if SpeedBooster.autoSpeedConnection then
        SpeedBooster.autoSpeedConnection:Disconnect()
        SpeedBooster.autoSpeedConnection = nil
        print("🔄 Auto-speed maintenance stopped!")
    end
end

-- Zone-based speed optimization
function SpeedBooster.optimizeForZone(zoneName)
    local setZoneRemote = SpeedBooster.getRemote(SpeedBooster.remotes.setZone)
    if setZoneRemote then
        pcall(function()
            setZoneRemote:InvokeServer(zoneName)
        end)
        print("✅ Zone optimized: " .. tostring(zoneName))
        return true
    end
    return false
end

-- Master speed boost function
function SpeedBooster.enableMasterSpeed(config)
    config = config or {}
    
    -- Configure settings
    local walkSpeed = config.walkSpeed or 60
    local jumpPower = config.jumpPower or 120
    local vehicleMultiplier = config.vehicleMultiplier or 3
    local boostMultiplier = config.boostMultiplier or 2.5
    
    print("🚀 Enabling Master Speed Boost...")
    
    -- Apply all speed enhancements
    SpeedBooster.enablePerformanceMode()
    wait(0.1)
    
    SpeedBooster.disablePerformanceFlags()
    wait(0.1)
    
    SpeedBooster.enhanceMovement(walkSpeed, jumpPower)
    wait(0.1)
    
    SpeedBooster.applyBoostModifiers(boostMultiplier)
    wait(0.1)
    
    SpeedBooster.enhanceVehicleSpeed(vehicleMultiplier)
    wait(0.1)
    
    SpeedBooster.startAutoSpeed()
    
    print("🔥 Master Speed Boost ACTIVATED!")
    print("📊 Configuration:")
    print("   Walk Speed: " .. walkSpeed)
    print("   Jump Power: " .. jumpPower)
    print("   Vehicle Multiplier: x" .. vehicleMultiplier)
    print("   Boost Multiplier: x" .. boostMultiplier)
    
    return true
end

-- Disable all speed enhancements
function SpeedBooster.disableAllSpeed()
    print("🔄 Disabling speed enhancements...")
    
    SpeedBooster.stopAutoSpeed()
    
    -- Reset to default speeds
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
    
    -- Reset config
    SpeedBooster.config.walkSpeed = 16
    SpeedBooster.config.jumpPower = 50
    SpeedBooster.config.vehicleSpeed = 1
    SpeedBooster.config.performanceMode = false
    
    print("✅ Speed enhancements disabled!")
end

-- Get current speed status
function SpeedBooster.getStatus()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    local status = {
        walkSpeed = humanoid and humanoid.WalkSpeed or "N/A",
        jumpPower = humanoid and humanoid.JumpPower or "N/A",
        vehicleMultiplier = SpeedBooster.config.vehicleSpeed,
        performanceMode = SpeedBooster.config.performanceMode,
        autoSpeed = SpeedBooster.autoSpeedConnection ~= nil
    }
    
    return status
end

-- Error handling wrapper
function SpeedBooster.safeExecute(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("SpeedBooster Error: " .. tostring(result))
        return false
    end
    return result
end

return SpeedBooster
