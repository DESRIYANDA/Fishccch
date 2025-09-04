-- Premium Bobber Features v1.0
-- Advanced bobber manipulation features extracted from old.lau
-- Safe implementation with error handling

local PremiumBobber = {}

-- Premium Bobber Configuration
local BobberConfig = {
    ropeLength = 200000,
    platformSize = Vector3.new(10, 1, 10),
    platformOffset = Vector3.new(0, -4, 0),
    defaultHeight = 126
}

-- Zone-specific optimal positions from old.lau
local ZonePositions = {
    ["Deep Ocean"] = CFrame.new(1521, 126, -3543),
    ["Desolate Deep"] = CFrame.new(-1068, 126, -3108),
    ["Harvesters Spike"] = CFrame.new(-1234, 126, 1748),
    ["Moosewood Docks"] = CFrame.new(345, 126, 214),
    ["Moosewood Ocean"] = CFrame.new(890, 126, 465),
    ["Moosewood Ocean Mythical"] = CFrame.new(270, 126, 52),
    ["Moosewood Pond"] = CFrame.new(526, 126, 305),
    ["Mushgrove Water"] = CFrame.new(2541, 126, -792),
    ["Ocean"] = CFrame.new(-5712, 126, 4059),
    ["Roslit Bay"] = CFrame.new(-1650, 126, 504),
    ["Roslit Bay Ocean"] = CFrame.new(-1825, 126, 946),
    ["Roslit Pond"] = CFrame.new(-1807, 141, 599),
    ["Roslit Pond Seaweed"] = CFrame.new(-1804, 141, 625),
    ["Scallop Ocean"] = CFrame.new(16, 126, 730),
    ["Snowcap Ocean"] = CFrame.new(2308, 126, 2200),
    ["Snowcap Pond"] = CFrame.new(2777, 275, 2605),
    ["Sunstone"] = CFrame.new(-645, 126, -955),
    ["Terrapin Ocean"] = CFrame.new(-57, 126, 2011),
    ["The Arch"] = CFrame.new(1076, 126, -1202),
    ["Vertigo"] = CFrame.new(-75, -740, 1200),
    ["FischFright24"] = CFrame.new(0, 126, 0), -- Dynamic position
    ["Isonade"] = CFrame.new(0, 126, 0) -- Dynamic position
}

-- Special abundance zones
local AbundanceZones = {
    ["Bluefin Tuna Abundance"] = {zone = "Deep Ocean", abundance = "Bluefin Tuna"},
    ["Swordfish Abundance"] = {zone = "Deep Ocean", abundance = "Swordfish"}
}

-- Premium Bobber Functions
function PremiumBobber.GetCurrentTool()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
        return character:FindFirstChildOfClass("Tool")
    end
    return nil
end

function PremiumBobber.GetBobber(tool)
    if tool then
        return tool:FindFirstChild("bobber")
    end
    return nil
end

function PremiumBobber.ExtendRopeLength(bobber)
    if bobber then
        local ropeConstraint = bobber:FindFirstChild("RopeConstraint")
        if ropeConstraint then
            ropeConstraint.Length = BobberConfig.ropeLength
            print("[Premium Bobber] Rope extended to: " .. BobberConfig.ropeLength)
            return true
        end
    end
    return false
end

function PremiumBobber.CreatePlatform(bobber)
    if bobber then
        -- Remove existing platform
        local existingPlatform = bobber:FindFirstChild("PremiumPlatform")
        if existingPlatform then
            existingPlatform:Destroy()
        end
        
        -- Create new platform
        local platform = Instance.new("Part")
        platform.Name = "PremiumPlatform"
        platform.Size = BobberConfig.platformSize
        platform.Position = bobber.Position + BobberConfig.platformOffset
        platform.Anchored = true
        platform.BrickColor = BrickColor.new("Bright blue")
        platform.Transparency = 1.0
        platform.CanCollide = true
        platform.Parent = bobber
        
        print("[Premium Bobber] Platform created at: " .. tostring(platform.Position))
        return platform
    end
    return nil
end

function PremiumBobber.TeleportBobberToZone(zoneName)
    local tool = PremiumBobber.GetCurrentTool()
    if not tool then
        print("[Premium Bobber] No tool equipped!")
        return false
    end
    
    local bobber = PremiumBobber.GetBobber(tool)
    if not bobber then
        print("[Premium Bobber] No bobber found!")
        return false
    end
    
    local targetPosition = nil
    
    -- Check abundance zones first
    if AbundanceZones[zoneName] then
        local abundanceData = AbundanceZones[zoneName]
        local zone = Workspace.zones.fishing:FindFirstChild(abundanceData.zone)
        if zone then
            local abundanceValue = zone:FindFirstChild("Abundance")
            if abundanceValue and abundanceValue.Value == abundanceData.abundance then
                targetPosition = CFrame.new(zone.Position.X, 126.564, zone.Position.Z)
                print("[Premium Bobber] Found abundance zone: " .. abundanceData.abundance)
            end
        end
    end
    
    -- Check regular zones
    if not targetPosition and ZonePositions[zoneName] then
        -- Handle dynamic zones
        if zoneName == "FischFright24" or zoneName == "Isonade" then
            local zone = Workspace.zones.fishing:FindFirstChild(zoneName)
            if zone then
                targetPosition = CFrame.new(zone.Position.X, BobberConfig.defaultHeight, zone.Position.Z)
            end
        else
            targetPosition = ZonePositions[zoneName]
        end
    end
    
    -- Generic zone fallback
    if not targetPosition then
        local zone = Workspace.zones.fishing:FindFirstChild(zoneName)
        if zone then
            targetPosition = CFrame.new(zone.Position.X, BobberConfig.defaultHeight, zone.Position.Z)
            print("[Premium Bobber] Using generic position for: " .. zoneName)
        end
    end
    
    if targetPosition then
        bobber.CFrame = targetPosition
        PremiumBobber.ExtendRopeLength(bobber)
        PremiumBobber.CreatePlatform(bobber)
        print("[Premium Bobber] Bobber teleported to: " .. zoneName .. " at " .. tostring(targetPosition))
        return true
    else
        print("[Premium Bobber] Zone not found: " .. zoneName)
        return false
    end
end

function PremiumBobber.GetAvailableZones()
    local zones = {}
    for zoneName, _ in pairs(ZonePositions) do
        table.insert(zones, zoneName)
    end
    for zoneName, _ in pairs(AbundanceZones) do
        table.insert(zones, zoneName)
    end
    table.sort(zones)
    return zones
end

function PremiumBobber.AutoZoneCast(zoneName, enabled)
    if not enabled then
        print("[Premium Bobber] Auto Zone Cast disabled")
        return
    end
    
    spawn(function()
        while enabled and flags and flags['premiumbobber'] do
            local success = PremiumBobber.TeleportBobberToZone(zoneName)
            if success then
                print("[Premium Bobber] Auto cast to " .. zoneName .. " successful")
            end
            task.wait(2) -- Wait 2 seconds between attempts
        end
    end)
end

function PremiumBobber.ResetBobber()
    local tool = PremiumBobber.GetCurrentTool()
    if tool then
        local bobber = PremiumBobber.GetBobber(tool)
        if bobber then
            -- Remove platform
            local platform = bobber:FindFirstChild("PremiumPlatform")
            if platform then
                platform:Destroy()
                print("[Premium Bobber] Platform removed")
            end
            
            -- Reset rope length
            local ropeConstraint = bobber:FindFirstChild("RopeConstraint")
            if ropeConstraint then
                ropeConstraint.Length = 50 -- Default rope length
                print("[Premium Bobber] Rope length reset to default")
            end
        end
    end
end

function PremiumBobber.GetStatus()
    local tool = PremiumBobber.GetCurrentTool()
    if not tool then
        return "No tool equipped"
    end
    
    local bobber = PremiumBobber.GetBobber(tool)
    if not bobber then
        return "No bobber found"
    end
    
    local platform = bobber:FindFirstChild("PremiumPlatform")
    local ropeConstraint = bobber:FindFirstChild("RopeConstraint")
    
    local status = "Bobber Status:\n"
    status = status .. "Position: " .. tostring(bobber.Position) .. "\n"
    status = status .. "Platform: " .. (platform and "Active" or "Inactive") .. "\n"
    status = status .. "Rope Length: " .. (ropeConstraint and ropeConstraint.Length or "Unknown")
    
    return status
end

-- Export the module
return PremiumBobber
