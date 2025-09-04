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

-- Event Types and Detection - Focus on Localized Events only
local LocalizedEvents = {
    -- Hunt Events
    ["Shark Hunt"] = {
        color = Color3.fromRGB(128, 128, 128),
        description = "Shark Hunt Event",
        detection = {"Shark", "shark"},
        priority = 4
    },
    ["Megalodon Hunt"] = {
        color = Color3.fromRGB(200, 0, 0),
        description = "Megalodon Hunt Event",
        detection = {"Megalodon", "megalodon"},
        priority = 5
    },
    ["Kraken Event"] = {
        color = Color3.fromRGB(100, 0, 150),
        description = "Kraken Event",
        detection = {"Kraken", "kraken"},
        priority = 5
    },
    ["Scylla Hunt"] = {
        color = Color3.fromRGB(150, 100, 0),
        description = "Scylla Hunt Event",
        detection = {"Scylla", "scylla"},
        priority = 4
    },
    
    -- Migration Events
    ["Orca Migration"] = {
        color = Color3.fromRGB(0, 0, 0),
        description = "Orca Migration Event",
        detection = {"Orca", "orca"},
        priority = 3
    },
    ["Whale Migration"] = {
        color = Color3.fromRGB(100, 150, 200),
        description = "Whale Migration Event",
        detection = {"Whale", "whale"},
        priority = 3
    },
    
    -- Special Hunt Events
    ["Sea Leviathan Hunt"] = {
        color = Color3.fromRGB(0, 100, 150),
        description = "Sea Leviathan Hunt",
        detection = {"Leviathan", "leviathan"},
        priority = 5
    },
    ["Apex Fish Hunt"] = {
        color = Color3.fromRGB(255, 200, 0),
        description = "Apex Fish Hunt Event",
        detection = {"Apex", "apex"},
        priority = 4
    },
    
    -- Pool/Area Events
    ["Fish Abundance"] = {
        color = Color3.fromRGB(0, 255, 100),
        description = "Fish Abundance Event",
        detection = {"Abundance", "abundance"},
        priority = 3
    },
    ["Lucky Pool"] = {
        color = Color3.fromRGB(255, 215, 0),
        description = "Lucky Pool Event",
        detection = {"Lucky", "lucky"},
        priority = 4
    },
    
    -- Environmental Events
    ["Absolute Darkness"] = {
        color = Color3.fromRGB(50, 0, 50),
        description = "Absolute Darkness Event",
        detection = {"Darkness", "darkness"},
        priority = 4
    },
    ["Strange Whirlpool"] = {
        color = Color3.fromRGB(100, 200, 255),
        description = "Strange Whirlpool Event",
        detection = {"StrangeWhirlpool", "strange"},
        priority = 4
    },
    ["Whirlpool"] = {
        color = Color3.fromRGB(0, 150, 255),
        description = "Whirlpool Event",
        detection = {"Whirlpool", "whirlpool"},
        priority = 3
    },
    
    -- Disaster Events
    ["Nuke"] = {
        color = Color3.fromRGB(255, 0, 0),
        description = "Nuke Event",
        detection = {"Nuke", "nuke"},
        priority = 5
    },
    ["Comet Storm"] = {
        color = Color3.fromRGB(255, 150, 0),
        description = "Comet Storm Event",
        detection = {"Comet", "comet"},
        priority = 4
    },
    ["Blizzard"] = {
        color = Color3.fromRGB(200, 200, 255),
        description = "Blizzard Event",
        detection = {"Blizzard", "blizzard"},
        priority = 3
    },
    ["Avalanche"] = {
        color = Color3.fromRGB(255, 255, 255),
        description = "Avalanche Event",
        detection = {"Avalanche", "avalanche"},
        priority = 4
    },
    
    -- Mythological Events
    ["Poseidon Wrath"] = {
        color = Color3.fromRGB(0, 100, 200),
        description = "Poseidon Wrath Event",
        detection = {"Poseidon", "poseidon"},
        priority = 5
    },
    ["Zeus Storm"] = {
        color = Color3.fromRGB(255, 255, 0),
        description = "Zeus Storm Event",
        detection = {"Zeus", "zeus"},
        priority = 5
    },
    
    -- Celestial Events
    ["Blue Moon"] = {
        color = Color3.fromRGB(100, 150, 255),
        description = "Blue Moon Event",
        detection = {"BlueMoon", "blue moon"},
        priority = 4
    },
    ["Meteor"] = {
        color = Color3.fromRGB(255, 100, 0),
        description = "Meteor Event",
        detection = {"Meteor", "meteor"},
        priority = 4
    },
    
    -- Special Events
    ["Traveling Merchant"] = {
        color = Color3.fromRGB(150, 100, 50),
        description = "Traveling Merchant",
        detection = {"Merchant", "merchant"},
        priority = 3
    },
    ["Sunken Chests"] = {
        color = Color3.fromRGB(150, 100, 0),
        description = "Sunken Chests Event",
        detection = {"Chest", "chest", "Sunken"},
        priority = 3
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
    
    -- Scan workspace zones for localized events
    if Workspace:FindFirstChild("zones") then
        local zones = Workspace.zones
        
        -- Check for event zones in fishing areas
        if zones:FindFirstChild("fishing") then
            for _, zone in pairs(zones.fishing:GetChildren()) do
                if zone:IsA("BasePart") then
                    local zoneName = zone.Name
                    
                    -- Check if it's a known localized event
                    for eventType, eventInfo in pairs(LocalizedEvents) do
                        for _, detection in pairs(eventInfo.detection) do
                            if string.find(zoneName:lower(), detection:lower()) then
                                -- Check if event is active
                                local isActive = self:CheckEventActive(zone, eventType)
                                
                                if isActive then
                                    foundEvents[eventType] = {
                                        zone = zone,
                                        position = zone.Position,
                                        eventInfo = eventInfo
                                    }
                                    print("🌟 Localized Event detected: " .. eventType .. " at " .. zoneName)
                                end
                            end
                        end
                    end
                end
            end
        end
        
        -- Check for special event folders and models
        for _, folder in pairs(zones:GetChildren()) do
            if folder:IsA("Folder") or folder:IsA("Model") then
                local folderName = folder.Name:lower()
                
                -- Check for event-specific folders
                for eventType, eventInfo in pairs(LocalizedEvents) do
                    for _, detection in pairs(eventInfo.detection) do
                        if string.find(folderName, detection:lower()) then
                            -- Find the main part or center of the event
                            local eventPart = self:FindEventCenter(folder)
                            if eventPart then
                                foundEvents[eventType] = {
                                    zone = eventPart,
                                    position = eventPart.Position,
                                    eventInfo = eventInfo
                                }
                                print("🌟 Event folder detected: " .. eventType)
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Check ReplicatedStorage for event information
    local replicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Check for TimeEvent system (from dump.txt analysis)
    if replicatedStorage:FindFirstChild("packages") then
        local packages = replicatedStorage.packages
        if packages:FindFirstChild("Net") then
            -- Try to get current event information
            pcall(function()
                local timeEventRF = packages.Net:FindFirstChild("RF/TimeEvent/GetEventTime")
                if timeEventRF then
                    -- Event system exists, scan for active events
                    self:ScanTimeEvents(foundEvents)
                end
            end)
        end
    end
    
    -- Check for event bestiary information
    pcall(function()
        local eventBestiary = replicatedStorage:FindFirstChild("shared")
        if eventBestiary then
            local timeEvents = eventBestiary:FindFirstChild("modules")
            if timeEvents then
                local timeEventsModule = timeEvents:FindFirstChild("library")
                if timeEventsModule and timeEventsModule:FindFirstChild("timeevents") then
                    -- Time events module exists, can potentially get event data
                    self:ScanBestiaryEvents(foundEvents)
                end
            end
        end
    end)
    
    return foundEvents
end

function EventESP:FindEventCenter(folder)
    -- Try to find the center part of an event
    local centerPart = folder:FindFirstChild("Center") or 
                      folder:FindFirstChild("Main") or 
                      folder:FindFirstChild("Core")
    
    if centerPart then return centerPart end
    
    -- Find the largest part
    local largestPart = nil
    local largestSize = 0
    
    for _, child in pairs(folder:GetDescendants()) do
        if child:IsA("BasePart") then
            local size = child.Size.Magnitude
            if size > largestSize then
                largestSize = size
                largestPart = child
            end
        end
    end
    
    return largestPart
end

function EventESP:ScanTimeEvents(foundEvents)
    -- Scan for active time events using the TimeEvent system
    -- This connects to the system found in dump.txt
    
    local lighting = game:GetService("Lighting")
    
    -- Check lighting conditions for different events
    if lighting.ClockTime < 6 or lighting.ClockTime > 20 then
        -- Night time events more likely
        self:CheckNightEvents(foundEvents)
    end
    
    -- Check for storm conditions (Zeus Storm, Blizzard)
    if lighting.ColorShift_Bottom.B > 0.5 then
        self:CheckStormEvents(foundEvents)
    end
    
    -- Check for special lighting (Blue Moon, etc.)
    if lighting.ColorShift_Top.B > 0.7 then
        foundEvents["Blue Moon"] = {
            zone = nil,
            position = Vector3.new(0, 200, 0),
            eventInfo = LocalizedEvents["Blue Moon"],
            isGlobalEvent = true
        }
    end
end

function EventESP:ScanBestiaryEvents(foundEvents)
    -- Scan using bestiary system for event information
    -- This uses the TimeEventController found in dump.txt
    
    -- NEW: Check CoreGui ScreenManager for Localized Events
    pcall(function()
        local coreGui = game:GetService("CoreGui")
        if coreGui:FindFirstChild("RobloxGui") then
            local robloxGui = coreGui.RobloxGui
            if robloxGui:FindFirstChild("Modules") then
                local modules = robloxGui.Modules
                if modules:FindFirstChild("Shell") then
                    local shell = modules.Shell
                    -- Found in dump.txt: ScreenManagerLocalized Events
                    local screenManager = shell:FindFirstChild("ScreenManagerLocalized Events")
                    if screenManager then
                        print("🌟 Found ScreenManagerLocalized Events module!")
                        self:MonitorScreenManager(screenManager, foundEvents)
                    end
                end
            end
        end
    end)
    
    -- Check for active creature events by scanning workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            local objName = obj.Name:lower()
            
            -- Check for creature spawns that indicate events
            if string.find(objName, "kraken") then
                foundEvents["Kraken Event"] = {
                    zone = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart"),
                    position = obj:GetModelCFrame().Position,
                    eventInfo = LocalizedEvents["Kraken Event"]
                }
            elseif string.find(objName, "megalodon") then
                foundEvents["Megalodon Hunt"] = {
                    zone = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart"),
                    position = obj:GetModelCFrame().Position,
                    eventInfo = LocalizedEvents["Megalodon Hunt"]
                }
            end
        end
    end
end

function EventESP:MonitorScreenManager(screenManager, foundEvents)
    -- Monitor the ScreenManagerLocalized Events for active events
    
    -- Check if it's a ModuleScript and try to require it
    if screenManager:IsA("ModuleScript") then
        pcall(function()
            local screenManagerModule = require(screenManager)
            
            -- Try to get current screen state
            if type(screenManagerModule) == "table" then
                -- Look for event-related properties
                for key, value in pairs(screenManagerModule) do
                    local keyName = tostring(key):lower()
                    
                    -- Check for event indicators
                    if string.find(keyName, "event") or string.find(keyName, "active") then
                        print("🔍 ScreenManager property found: " .. tostring(key) .. " = " .. tostring(value))
                        
                        -- Try to extract event information
                        self:ProcessScreenManagerData(key, value, foundEvents)
                    end
                end
            end
        end)
    end
    
    -- Monitor children for event screens
    for _, child in pairs(screenManager:GetChildren()) do
        local childName = child.Name:lower()
        
        -- Check for event-related screens
        for eventType, eventInfo in pairs(LocalizedEvents) do
            for _, detection in pairs(eventInfo.detection) do
                if string.find(childName, detection:lower()) then
                    print("🌟 Event screen detected: " .. child.Name .. " for " .. eventType)
                    
                    foundEvents[eventType] = {
                        zone = nil,
                        position = Vector3.new(0, 100, 0),
                        eventInfo = eventInfo,
                        isScreenManagerEvent = true,
                        screen = child
                    }
                end
            end
        end
    end
end

function EventESP:ProcessScreenManagerData(key, value, foundEvents)
    -- Process data from ScreenManagerLocalized Events
    
    local keyStr = tostring(key):lower()
    local valueStr = tostring(value):lower()
    
    -- Check for specific event types in the data
    for eventType, eventInfo in pairs(LocalizedEvents) do
        local eventTypeLower = eventType:lower()
        
        -- Check if this data indicates an active event
        if string.find(keyStr, eventTypeLower) or string.find(valueStr, eventTypeLower) then
            print("📊 ScreenManager indicates active event: " .. eventType)
            
            foundEvents[eventType] = {
                zone = nil,
                position = Vector3.new(0, 100, 0),
                eventInfo = eventInfo,
                isScreenManagerEvent = true,
                screenData = {key = key, value = value}
            }
        end
        
        -- Check detection strings
        for _, detection in pairs(eventInfo.detection) do
            if string.find(keyStr, detection:lower()) or string.find(valueStr, detection:lower()) then
                print("📊 ScreenManager detection match for: " .. eventType)
                
                foundEvents[eventType] = {
                    zone = nil,
                    position = Vector3.new(0, 100, 0),
                    eventInfo = eventInfo,
                    isScreenManagerEvent = true,
                    screenData = {key = key, value = value}
                }
            end
        end
    end
end

function EventESP:CheckNightEvents(foundEvents)
    -- Events that are more likely at night
    local nightEvents = {"Kraken Event", "Absolute Darkness", "Blue Moon"}
    
    for _, eventType in pairs(nightEvents) do
        -- Check workspace for signs of these events
        if self:CheckEventIndicators(eventType) then
            foundEvents[eventType] = {
                zone = nil,
                position = Vector3.new(0, 150, 0),
                eventInfo = LocalizedEvents[eventType],
                isNightEvent = true
            }
        end
    end
end

function EventESP:CheckStormEvents(foundEvents)
    -- Storm-related events
    local stormEvents = {"Zeus Storm", "Blizzard", "Comet Storm"}
    
    for _, eventType in pairs(stormEvents) do
        if self:CheckEventIndicators(eventType) then
            foundEvents[eventType] = {
                zone = nil,
                position = Vector3.new(0, 200, 0),
                eventInfo = LocalizedEvents[eventType],
                isStormEvent = true
            }
        end
    end
end

function EventESP:CheckEventIndicators(eventType)
    -- Check for various indicators that an event might be active
    local lighting = game:GetService("Lighting")
    
    if eventType == "Zeus Storm" then
        return lighting.Brightness > 2 and lighting.ColorShift_Top.R > 0.8
    elseif eventType == "Blizzard" then
        return lighting.ColorShift_Bottom.B > 0.8 and lighting.Brightness < 1
    elseif eventType == "Comet Storm" then
        return lighting.ColorShift_Top.G < 0.3 and lighting.Brightness > 1.5
    elseif eventType == "Absolute Darkness" then
        return lighting.Brightness < 0.5
    elseif eventType == "Blue Moon" then
        return lighting.ColorShift_Top.B > 0.7
    elseif eventType == "Kraken Event" then
        -- Check for kraken-related objects in workspace
        return Workspace:FindFirstChild("Kraken") ~= nil
    end
    
    return false
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
        print("❌ Localized Event not found: " .. eventType)
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
    
    print("✅ Teleported to " .. eventType .. " localized event!")
    return true
end

function EventESP:Initialize(tab)
    print("🌟 Initializing Localized Event ESP...")
    
    -- Set default values
    flags['eventesp'] = false
    flags['autoscan'] = false
    flags['selectedevent'] = nil
    flags['espactive'] = false
    flags['showhunts'] = true
    flags['showmigrations'] = true
    flags['showenvironmental'] = true
    
    -- Create UI
    self:CreateUI(tab)
    
    print("🌟 Localized Event ESP initialized successfully!")
    return self
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
        warn("❌ Tab not available for Localized Event ESP")
        return 
    end
    
    print("🌟 Creating Localized Event ESP UI...")
    
    -- Localized Event ESP Section
    local EventSection = tab:NewSection("🌟 Localized Event ESP")
    
    -- Main ESP toggle
    EventSection:NewToggle("Localized Event ESP", "Show ESP for active localized events", function(state)
        flags['eventesp'] = state
        if state then
            EventESP:StartESP()
        else
            EventESP:StopESP()
        end
    end)
    
    -- Auto scan toggle
    EventSection:NewToggle("Auto Event Scan", "Automatically scan for new localized events", function(state)
        flags['autoscan'] = state
        print(state and "🔄 Auto localized event scan enabled" or "⏹️ Auto localized event scan disabled")
    end)
    
    -- Manual scan button
    EventSection:NewButton("Manual Scan Events", "Manually scan for localized events", function()
        local events = EventESP:GetActiveEvents()
        local count = 0
        for _ in pairs(events) do count = count + 1 end
        print("🔍 Localized Event scan complete: " .. count .. " events found")
        
        if flags['eventesp'] then
            EventESP:UpdateESP()
        end
    end)
    
    -- Event Categories Section
    local CategorySection = tab:NewSection("📂 Event Categories")
    
    -- Hunt Events toggle
    CategorySection:NewToggle("Show Hunt Events", "Display hunt-type events (Shark, Megalodon, Kraken, etc.)", function(state)
        flags['showhunts'] = state
    end)
    
    -- Migration Events toggle
    CategorySection:NewToggle("Show Migration Events", "Display migration events (Orca, Whale)", function(state)
        flags['showmigrations'] = state
    end)
    
    -- Environmental Events toggle
    CategorySection:NewToggle("Show Environmental Events", "Display environmental events (Storms, Disasters)", function(state)
        flags['showenvironmental'] = state
    end)
    
    -- Teleport Section
    local TeleportSection = tab:NewSection("🚀 Event Teleportation")
    
    -- Event dropdown
    local eventNames = {}
    for eventType, _ in pairs(LocalizedEvents) do
        table.insert(eventNames, eventType)
    end
    table.sort(eventNames)
    
    TeleportSection:NewDropdown("Select Event", "Choose localized event to teleport to", eventNames, function(event)
        flags['selectedevent'] = event
        print("📍 Selected event: " .. event)
    end)
    
    -- Teleport button
    TeleportSection:NewButton("Teleport to Event", "Teleport to selected localized event", function()
        if flags['selectedevent'] then
            EventESP:TeleportToEvent(flags['selectedevent'])
        else
            print("⚠️ Please select an event first!")
        end
    end)
    
    -- Quick Hunt Teleports
    local HuntSection = tab:NewSection("🦈 Quick Hunt Teleports")
    
    HuntSection:NewButton("🦈 Find Shark Hunt", "Quick scan and teleport to Shark Hunt", function()
        EventESP:TeleportToEvent("Shark Hunt")
    end)
    
    HuntSection:NewButton("🦈 Find Megalodon Hunt", "Quick scan and teleport to Megalodon Hunt", function()
        EventESP:TeleportToEvent("Megalodon Hunt")
    end)
    
    HuntSection:NewButton("🐙 Find Kraken Event", "Quick scan and teleport to Kraken Event", function()
        EventESP:TeleportToEvent("Kraken Event")
    end)
    
    HuntSection:NewButton("🦅 Find Scylla Hunt", "Quick scan and teleport to Scylla Hunt", function()
        EventESP:TeleportToEvent("Scylla Hunt")
    end)
    
    -- Environmental Events
    local EnviroSection = tab:NewSection("🌪️ Environmental Events")
    
    EnviroSection:NewButton("💥 Find Nuke Event", "Quick scan and teleport to Nuke", function()
        EventESP:TeleportToEvent("Nuke")
    end)
    
    EnviroSection:NewButton("⚡ Find Zeus Storm", "Quick scan and teleport to Zeus Storm", function()
        EventESP:TeleportToEvent("Zeus Storm")
    end)
    
    EnviroSection:NewButton("🌊 Find Poseidon Wrath", "Quick scan and teleport to Poseidon Wrath", function()
        EventESP:TeleportToEvent("Poseidon Wrath")
    end)
    
    EnviroSection:NewButton("☄️ Find Comet Storm", "Quick scan and teleport to Comet Storm", function()
        EventESP:TeleportToEvent("Comet Storm")
    end)
    
    -- Special Events
    local SpecialSection = tab:NewSection("✨ Special Events")
    
    SpecialSection:NewButton("� Find Blue Moon", "Quick scan and teleport to Blue Moon", function()
        EventESP:TeleportToEvent("Blue Moon")
    end)
    
    SpecialSection:NewButton("🐠 Find Fish Abundance", "Quick scan and teleport to Fish Abundance", function()
        EventESP:TeleportToEvent("Fish Abundance")
    end)
    
    SpecialSection:NewButton("🍀 Find Lucky Pool", "Quick scan and teleport to Lucky Pool", function()
        EventESP:TeleportToEvent("Lucky Pool")
    end)
    
    SpecialSection:NewButton("💰 Find Traveling Merchant", "Quick scan and teleport to Traveling Merchant", function()
        EventESP:TeleportToEvent("Traveling Merchant")
    end)
    
    -- Info Section
    local InfoSection = tab:NewSection("ℹ️ Localized Event Information")
    
    InfoSection:NewLabel("🦈 Hunt Events: Shark, Megalodon, Kraken, Scylla")
    InfoSection:NewLabel("🐋 Migration: Orca, Whale, Sea Leviathan")
    InfoSection:NewLabel("🌪️ Environmental: Storms, Disasters, Darkness")
    InfoSection:NewLabel("✨ Special: Lucky Pool, Fish Abundance, Merchant")
    InfoSection:NewLabel("🔄 Auto-updates every 5 seconds")
    InfoSection:NewLabel("📍 Shows distance and event details")
    InfoSection:NewLabel("📚 Based on Fischipedia Localized Events")
    
    print("✅ Localized Event ESP UI created successfully!")
end

function EventESP:Initialize(tab)
    print("🌟 Initializing Localized Event ESP...")
    
    -- Set default values
    flags['eventesp'] = false
    flags['autoscan'] = false
    flags['selectedevent'] = nil
    flags['espactive'] = false
    flags['showhunts'] = true
    flags['showmigrations'] = true
    flags['showenvironmental'] = true
    
    -- Create UI
    self:CreateUI(tab)
    
    print("🌟 Localized Event ESP initialized successfully!")
    return self
end

return EventESP
