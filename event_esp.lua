-- Event ESP Module
-- ESP and teleportation for Fisch game events

local EventESP = {}

-- Services
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local Workspace = game:GetService('Workspace')
local TweenService = game:GetService('TweenService')

-- Variables
local lp = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local flags = {}
local espObjects = {}

-- Event Types and Detection
local EventTypes = {
    -- Weather Events
    ["Aurora"] = {
        color = Color3.fromRGB(0, 255, 150),
        description = "Aurora Event - Rare fish spawn",
        detection = "Aurora",
        priority = 5
    },
    ["Meteor"] = {
        color = Color3.fromRGB(255, 100, 0),
        description = "Meteor Event - Meteorite drops",
        detection = "Meteor",
        priority = 4
    },
    ["Windset"] = {
        color = Color3.fromRGB(100, 200, 255),
        description = "Windset Event - Wind patterns",
        detection = "Windset",
        priority = 3
    },
    -- Localized Events
    ["Tsunami"] = {
        color = Color3.fromRGB(0, 100, 255),
        description = "Tsunami Event - Ocean waves",
        detection = "Tsunami",
        priority = 5
    },
    ["Brine Pool"] = {
        color = Color3.fromRGB(100, 0, 200),
        description = "Brine Pool - Deep ocean event",
        detection = "BrinePool",
        priority = 4
    },
    ["The Depths"] = {
        color = Color3.fromRGB(50, 0, 100),
        description = "The Depths Event - Deep sea access",
        detection = "TheDepths",
        priority = 5
    },
    -- Fishing Events
    ["Great White Shark"] = {
        color = Color3.fromRGB(150, 150, 150),
        description = "Great White Shark Event",
        detection = "GreatWhite",
        priority = 4
    },
    ["Megalodon"] = {
        color = Color3.fromRGB(200, 0, 0),
        description = "Megalodon Event - Ancient shark",
        detection = "Megalodon",
        priority = 5
    },
    -- Special Events
    ["FischFright24"] = {
        color = Color3.fromRGB(255, 165, 0),
        description = "Halloween Event Zone",
        detection = "FischFright24",
        priority = 5
    },
    ["Isonade"] = {
        color = Color3.fromRGB(0, 255, 255),
        description = "Isonade Event - Legendary fish",
        detection = "Isonade",
        priority = 5
    }
}

-- ESP Functions
function EventESP:CreateESPBox(part, eventType, eventInfo)
    if not part or not part.Parent then return end
    
    local espData = {
        part = part,
        eventType = eventType,
        eventInfo = eventInfo
    }
    
    -- Create BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "EventESP_" .. eventType
    billboardGui.Adornee = part
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 5, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.Parent = part
    
    -- Background Frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = eventInfo.color
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.new(1, 1, 1)
    frame.Parent = billboardGui
    
    -- Event Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.6, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = eventType
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    -- Description Label
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, 0, 0.4, 0)
    descLabel.Position = UDim2.new(0, 0, 0.6, 0)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = eventInfo.description
    descLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    descLabel.TextScaled = true
    descLabel.Font = Enum.Font.Gotham
    descLabel.Parent = frame
    
    -- Distance tracking
    spawn(function()
        while billboardGui.Parent and flags['eventesp'] do
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (lp.Character.HumanoidRootPart.Position - part.Position).Magnitude
                descLabel.Text = eventInfo.description .. " [" .. math.floor(distance) .. "m]"
            end
            task.wait(0.5)
        end
    end)
    
    -- Glowing effect
    local selectionBox = Instance.new("SelectionBox")
    selectionBox.Adornee = part
    selectionBox.Color3 = eventInfo.color
    selectionBox.LineThickness = 0.2
    selectionBox.Transparency = 0.3
    selectionBox.Parent = part
    
    espData.billboardGui = billboardGui
    espData.selectionBox = selectionBox
    
    return espData
end

function EventESP:ScanForEvents()
    local foundEvents = {}
    
    -- Scan workspace zones for events
    if Workspace:FindFirstChild("zones") then
        local zones = Workspace.zones
        
        -- Check for event zones
        if zones:FindFirstChild("fishing") then
            for _, zone in pairs(zones.fishing:GetChildren()) do
                if zone:IsA("BasePart") then
                    local zoneName = zone.Name
                    
                    -- Check if it's a known event
                    for eventType, eventInfo in pairs(EventTypes) do
                        if string.find(zoneName:lower(), eventType:lower()) or 
                           string.find(zoneName, eventInfo.detection) then
                            
                            -- Check if event is active (has special attributes or children)
                            local isActive = self:CheckEventActive(zone, eventType)
                            
                            if isActive then
                                foundEvents[eventType] = {
                                    zone = zone,
                                    position = zone.Position,
                                    eventInfo = eventInfo
                                }
                                print("🌟 Event detected: " .. eventType .. " at " .. zoneName)
                            end
                        end
                    end
                end
            end
        end
        
        -- Check for special event folders
        if zones:FindFirstChild("events") then
            for _, eventZone in pairs(zones.events:GetChildren()) do
                if eventZone:IsA("Model") or eventZone:IsA("BasePart") then
                    local eventName = eventZone.Name
                    
                    for eventType, eventInfo in pairs(EventTypes) do
                        if string.find(eventName:lower(), eventType:lower()) then
                            foundEvents[eventType] = {
                                zone = eventZone,
                                position = eventZone:FindFirstChild("HumanoidRootPart") and 
                                         eventZone.HumanoidRootPart.Position or eventZone.Position,
                                eventInfo = eventInfo
                            }
                        end
                    end
                end
            end
        end
    end
    
    -- Check Lighting for weather events
    local lighting = game:GetService("Lighting")
    for eventType, eventInfo in pairs(EventTypes) do
        if eventType == "Aurora" and lighting:FindFirstChild("Aurora") then
            -- Aurora is typically a lighting effect
            foundEvents[eventType] = {
                zone = nil,
                position = Vector3.new(0, 200, 0), -- Sky position
                eventInfo = eventInfo,
                isWeatherEvent = true
            }
        elseif eventType == "Meteor" and self:CheckMeteorEvent() then
            foundEvents[eventType] = {
                zone = nil,
                position = self:GetMeteorPosition(),
                eventInfo = eventInfo,
                isWeatherEvent = true
            }
        end
    end
    
    return foundEvents
end

function EventESP:CheckEventActive(zone, eventType)
    -- Check various indicators that an event is active
    
    -- Check for abundance attribute
    local abundance = zone:FindFirstChild("Abundance")
    if abundance and abundance.Value then
        return true
    end
    
    -- Check for event-specific children
    if eventType == "Tsunami" and zone:FindFirstChild("TsunamiWave") then
        return true
    end
    
    if eventType == "Brine Pool" and zone:FindFirstChild("BrineEffect") then
        return true
    end
    
    -- Check zone size (events often have different sizes)
    if zone.Size.Magnitude > 100 then -- Large zones might be events
        return true
    end
    
    -- Check for special lighting or effects
    local lighting = zone:FindFirstChild("PointLight") or zone:FindFirstChild("SpotLight")
    if lighting then
        return true
    end
    
    -- Default: assume active if zone exists
    return true
end

function EventESP:CheckMeteorEvent()
    -- Check for meteor indicators
    local lighting = game:GetService("Lighting")
    return lighting.Brightness > 3 or lighting:FindFirstChild("MeteorGlow")
end

function EventESP:GetMeteorPosition()
    -- Try to find meteor object or return sky position
    if Workspace:FindFirstChild("Meteor") then
        return Workspace.Meteor.Position
    end
    return Vector3.new(math.random(-1000, 1000), 500, math.random(-1000, 1000))
end

function EventESP:UpdateESP()
    if not flags['eventesp'] then return end
    
    -- Clear old ESP
    self:ClearESP()
    
    -- Scan for new events
    local events = self:ScanForEvents()
    
    -- Create ESP for found events
    for eventType, eventData in pairs(events) do
        if eventData.zone and eventData.zone.Parent then
            local espData = self:CreateESPBox(eventData.zone, eventType, eventData.eventInfo)
            if espData then
                espObjects[eventType] = espData
            end
        end
    end
end

function EventESP:ClearESP()
    for eventType, espData in pairs(espObjects) do
        if espData.billboardGui then
            espData.billboardGui:Destroy()
        end
        if espData.selectionBox then
            espData.selectionBox:Destroy()
        end
    end
    espObjects = {}
end

function EventESP:TeleportToEvent(eventType)
    local events = self:ScanForEvents()
    local eventData = events[eventType]
    
    if not eventData then
        print("❌ Event not found: " .. eventType)
        return false
    end
    
    if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then
        print("❌ Character not found")
        return false
    end
    
    local targetPosition
    if eventData.zone then
        if eventData.zone:IsA("Model") then
            targetPosition = eventData.zone:GetModelCFrame().Position
        else
            targetPosition = eventData.zone.Position + Vector3.new(0, 10, 0)
        end
    else
        targetPosition = eventData.position
    end
    
    -- Teleport with safety offset
    lp.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
    
    print("✅ Teleported to " .. eventType .. " event!")
    return true
end

function EventESP:GetActiveEvents()
    return self:ScanForEvents()
end

function EventESP:StartESP()
    if flags['espactive'] then return end
    
    flags['espactive'] = true
    spawn(function()
        while flags['eventesp'] and flags['espactive'] do
            self:UpdateESP()
            task.wait(5) -- Update every 5 seconds
        end
        flags['espactive'] = false
    end)
    
    print("🌟 Event ESP started!")
end

function EventESP:StopESP()
    flags['eventesp'] = false
    flags['espactive'] = false
    self:ClearESP()
    print("🌟 Event ESP stopped!")
end

function EventESP:CreateUI(tab)
    if not tab then 
        warn("❌ Tab not available for Event ESP")
        return 
    end
    
    print("🌟 Creating Event ESP UI...")
    
    -- Event ESP Section
    local EventSection = tab:NewSection("🌟 Event ESP & Detection")
    
    -- Main ESP toggle
    EventSection:NewToggle("Event ESP", "Show ESP for active events", function(state)
        flags['eventesp'] = state
        if state then
            EventESP:StartESP()
        else
            EventESP:StopESP()
        end
    end)
    
    -- Auto scan toggle
    EventSection:NewToggle("Auto Event Scan", "Automatically scan for new events", function(state)
        flags['autoscan'] = state
        print(state and "🔄 Auto event scan enabled" or "⏹️ Auto event scan disabled")
    end)
    
    -- Manual scan button
    EventSection:NewButton("Manual Scan", "Manually scan for events", function()
        local events = EventESP:GetActiveEvents()
        local count = 0
        for _ in pairs(events) do count = count + 1 end
        print("🔍 Scan complete: " .. count .. " events found")
        
        if flags['eventesp'] then
            EventESP:UpdateESP()
        end
    end)
    
    -- Teleport Section
    local TeleportSection = tab:NewSection("🚀 Event Teleportation")
    
    -- Event dropdown
    local eventNames = {}
    for eventType, _ in pairs(EventTypes) do
        table.insert(eventNames, eventType)
    end
    table.sort(eventNames)
    
    TeleportSection:NewDropdown("Select Event", "Choose event to teleport to", eventNames, function(event)
        flags['selectedevent'] = event
        print("📍 Selected event: " .. event)
    end)
    
    -- Teleport button
    TeleportSection:NewButton("Teleport to Event", "Teleport to selected event", function()
        if flags['selectedevent'] then
            EventESP:TeleportToEvent(flags['selectedevent'])
        else
            print("⚠️ Please select an event first!")
        end
    end)
    
    -- Quick teleport buttons for common events
    TeleportSection:NewButton("🌊 Find Tsunami", "Quick scan and teleport to Tsunami", function()
        EventESP:TeleportToEvent("Tsunami")
    end)
    
    TeleportSection:NewButton("🌌 Find Aurora", "Quick scan and teleport to Aurora", function()
        EventESP:TeleportToEvent("Aurora")
    end)
    
    TeleportSection:NewButton("☄️ Find Meteor", "Quick scan and teleport to Meteor", function()
        EventESP:TeleportToEvent("Meteor")
    end)
    
    -- Info Section
    local InfoSection = tab:NewSection("ℹ️ Event Information")
    
    InfoSection:NewLabel("🌟 Detects: Aurora, Meteor, Tsunami, Brine Pool")
    InfoSection:NewLabel("🎃 Special: FischFright24, Isonade Events")
    InfoSection:NewLabel("🦈 Marine: Great White, Megalodon")
    InfoSection:NewLabel("🔄 Auto-updates every 5 seconds")
    InfoSection:NewLabel("📍 Shows distance and event info")
    
    print("✅ Event ESP UI created successfully!")
end

-- Initialize function
function EventESP:Initialize(tab)
    print("🌟 Initializing Event ESP...")
    
    -- Set default values
    flags['eventesp'] = false
    flags['autoscan'] = false
    flags['selectedevent'] = nil
    flags['espactive'] = false
    
    -- Create UI
    self:CreateUI(tab)
    
    print("🌟 Event ESP initialized successfully!")
    return self
end

return EventESP
