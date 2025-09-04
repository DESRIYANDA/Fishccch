-- Simple Event Spy - No Unicode Characters
local events = {}
local startTime = tick()

print("Event Spy Started")
print("Go to auto coin fishing area now!")

-- Log function
local function logEvent(name, path, args, category)
    local data = {
        name = name,
        path = path,
        args = args,
        time = tick() - startTime,
        category = category
    }
    
    table.insert(events, data)
    
    local argStr = ""
    if args and #args > 0 then
        argStr = " Args: " .. table.concat(args, ", ")
    end
    
    print(string.format("[%s] %.1fs: %s%s", category, data.time, name, argStr))
end

-- Safe hook function
local function hookEvent(obj)
    if not obj then return end
    
    pcall(function()
        if obj:IsA("RemoteEvent") and obj.FireServer then
            local original = obj.FireServer
            obj.FireServer = function(self, ...)
                pcall(function()
                    local args = {...}
                    local name = obj.Name or "Unknown"
                    local path = obj:GetFullName() or "Unknown"
                    
                    -- Skip other players
                    if string.find(path, "Players") then
                        local playerName = game.Players.LocalPlayer.Name
                        if not string.find(path, playerName) then
                            return original(self, ...)
                        end
                    end
                    
                    -- Categorize
                    local category = "OTHER"
                    local lowerName = string.lower(name)
                    local lowerPath = string.lower(path)
                    
                    if string.find(lowerName, "coin") or string.find(lowerPath, "coin") then
                        category = "COIN"
                    elseif string.find(lowerName, "fish") or string.find(lowerName, "cast") or string.find(lowerName, "reel") then
                        category = "FISHING"
                    end
                    
                    logEvent(name, path, args, category)
                    
                    return original(self, ...)
                end)
                
                return original(self, ...)
            end
        end
    end)
end

-- Hook existing events
pcall(function()
    for _, obj in pairs(game:GetDescendants()) do
        hookEvent(obj)
    end
end)

-- Hook new events
game.DescendantAdded:Connect(function(obj)
    hookEvent(obj)
end)

-- Analysis functions
_G.coins = function()
    print("\nCOIN EVENTS:")
    for _, event in pairs(events) do
        if event.category == "COIN" then
            print(string.format("  %.1fs: %s", event.time, event.name))
            if event.args and #event.args > 0 then
                print("    " .. table.concat(event.args, ", "))
            end
        end
    end
end

_G.fishing = function()
    print("\nFISHING EVENTS:")
    for _, event in pairs(events) do
        if event.category == "FISHING" then
            print(string.format("  %.1fs: %s", event.time, event.name))
        end
    end
end

_G.all = function()
    print("\nALL EVENTS:")
    for _, event in pairs(events) do
        print(string.format("  [%s] %.1fs: %s", event.category, event.time, event.name))
    end
end

_G.clear = function()
    events = {}
    startTime = tick()
    print("Events cleared!")
end

print("Ready! Commands: _G.coins(), _G.fishing(), _G.all(), _G.clear()")
