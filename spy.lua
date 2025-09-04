-- Event spy untuk auto coin fishing area  
local allEvents = {}
local startTime = tick()

print("Starting coin fishing event spy...")
print("Go to the new auto coin fishing area and start fishing!")

-- Function to log events with details
local function logEvent(eventName, eventPath, args, category)
    local eventData = {
        name = eventName,
        fullPath = eventPath,
        args = args or {},
        time = tick() - startTime,
        category = category,
        timestamp = os.date("%H:%M:%S")
    }
    
    table.insert(allEvents, eventData)
    
    -- Pretty print with category icons
    local categoryIcon = {
        ["COIN"] = "[COIN]",
        ["FISHING"] = "[FISH]", 
        ["SYSTEM"] = "[SYS]",
        ["OTHER"] = "[OTHER]"
    }
    
    local icon = categoryIcon[category] or "[OTHER]"
    local argStr = ""
    if #eventData.args > 0 then
        argStr = " -> Args: " .. table.concat(eventData.args, ", ")
    end
    
    print(string.format("%s [%s] %.1fs: %s%s", 
        icon, eventData.timestamp, eventData.time, eventName, argStr))
end

-- Monitor RemoteEvents dengan error safety
local function hookRemoteEvent(obj)
    local success = pcall(function()
        if obj and obj:IsA("RemoteEvent") and obj.FireServer then
            local originalFire = obj.FireServer
            obj.FireServer = function(self, ...)
                local hookSuccess = pcall(function()
                    local args = {...}
                    local eventName = obj.Name or "Unknown"
                    local eventPath = obj:GetFullName() or "Unknown"
                    
                    -- Skip events dari player lain
                    if string.find(eventPath, "Players") and not string.find(eventPath, game.Players.LocalPlayer.Name) then
                        return originalFire(self, ...)
                    end
                    
                    -- Categorize events
                    local category = "OTHER"
                    local lowerName = string.lower(eventName)
                    local lowerPath = string.lower(eventPath)
                    
                    if string.find(lowerName, "coin") or string.find(lowerPath, "coin") or
                       string.find(lowerName, "money") or string.find(lowerPath, "money") or
                       string.find(lowerName, "currency") or string.find(lowerPath, "currency") then
                        category = "COIN"
                    elseif string.find(lowerName, "fish") or string.find(lowerName, "cast") or 
                           string.find(lowerName, "reel") or string.find(lowerName, "catch") or
                           string.find(lowerName, "bite") or string.find(lowerName, "bobber") then
                        category = "FISHING"
                    elseif string.find(lowerPath, "system") or string.find(lowerName, "update") or
                           string.find(lowerName, "status") or string.find(lowerName, "sync") then
                        category = "SYSTEM"
                    end
                    
                    logEvent(eventName, eventPath, args, category)
                    
                    return originalFire(self, ...)
                end)
                
                if not hookSuccess then
                    -- Jika error, panggil original function
                    return originalFire(self, ...)
                end
            end
        end
    end)
    
    if not success then
        -- Ignore failed hooks silently
    end
end

-- Scan semua objects dengan error handling
local function scanObjects()
    local success = pcall(function()
        for _, obj in pairs(game:GetDescendants()) do
            hookRemoteEvent(obj)
        end
    end)
    
    if success then
        print("Successfully hooked existing RemoteEvents")
    else
        print("Warning: Some events could not be hooked")
    end
end

-- Jalankan scan
scanObjects()

-- Monitor new events yang ditambahkan
game.DescendantAdded:Connect(function(obj)
    hookRemoteEvent(obj)
end)

-- Commands untuk analysis
_G.showCoinEvents = function()
    print("\n[COIN-RELATED EVENTS]:")
    for _, event in pairs(allEvents) do
        if event.category == "COIN" then
            print(string.format("  [%.1fs] %s - %s", event.time, event.name, event.fullPath))
            if #event.args > 0 then
                print("    Args:", table.concat(event.args, ", "))
            end
        end
    end
end

_G.showFishingEvents = function()
    print("\n[FISHING EVENTS]:")
    for _, event in pairs(allEvents) do
        if event.category == "FISHING" then
            print(string.format("  [%.1fs] %s", event.time, event.name))
        end
    end
end

_G.showAllEvents = function()
    print("\n[ALL EVENTS SUMMARY]:")
    local categories = {}
    for _, event in pairs(allEvents) do
        categories[event.category] = (categories[event.category] or 0) + 1
    end
    for cat, count in pairs(categories) do
        print(string.format("  %s: %d events", cat, count))
    end
end

print("Event spy active! Categories: COIN, FISHING, SYSTEM, OTHER")
print("Commands: _G.showCoinEvents(), _G.showFishingEvents(), _G.showAllEvents()")