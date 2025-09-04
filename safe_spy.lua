-- Safe Event Spy untuk Auto Coin Fishing
-- Versi yang aman tanpa error dari player lain

local events = {}
local startTime = tick()

print("🛡️ Safe Event Spy Started - Monitoring relevant events only")
print("🎯 Focus: ReplicatedStorage, Workspace events, dan Local Player tools")

-- Function untuk log events
local function logEvent(eventName, eventPath, args, category)
    local eventData = {
        name = eventName,
        path = eventPath,
        args = args or {},
        time = tick() - startTime,
        category = category,
        timestamp = os.date("%H:%M:%S")
    }
    
    table.insert(events, eventData)
    
    local icons = {
        ["COIN"] = "💰",
        ["FISHING"] = "🎣", 
        ["TOOL"] = "🔧",
        ["SYSTEM"] = "⚙️"
    }
    
    local icon = icons[category] or "📡"
    local argStr = ""
    if #eventData.args > 0 then
        local argsDisplay = {}
        for i, arg in ipairs(eventData.args) do
            if i <= 3 then -- Limit display to first 3 args
                table.insert(argsDisplay, tostring(arg))
            end
        end
        if #eventData.args > 3 then
            table.insert(argsDisplay, "...")
        end
        argStr = " → " .. table.concat(argsDisplay, ", ")
    end
    
    print(string.format("%s [%s] %.1fs: %s%s", 
        icon, eventData.timestamp, eventData.time, eventName, argStr))
end

-- Function aman untuk hook RemoteEvent
local function safeHookEvent(obj)
    if not obj or not obj:IsA("RemoteEvent") then return end
    
    local success, err = pcall(function()
        local originalFire = obj.FireServer
        if originalFire then
            obj.FireServer = function(self, ...)
                local args = {...}
                local eventName = obj.Name
                local eventPath = obj:GetFullName()
                
                -- Kategorisasi berdasarkan nama dan path
                local category = "SYSTEM"
                local lowerName = eventName:lower()
                local lowerPath = eventPath:lower()
                
                if string.find(lowerName, "coin") or string.find(lowerPath, "coin") or
                   string.find(lowerName, "money") or string.find(lowerName, "cash") or
                   string.find(lowerName, "currency") then
                    category = "COIN"
                elseif string.find(lowerName, "fish") or string.find(lowerName, "cast") or 
                       string.find(lowerName, "reel") or string.find(lowerName, "catch") or
                       string.find(lowerName, "bite") then
                    category = "FISHING"
                elseif string.find(lowerPath, "tool") or string.find(lowerPath, "rod") then
                    category = "TOOL"
                end
                
                logEvent(eventName, eventPath, args, category)
                
                return originalFire(self, ...)
            end
        end
    end)
    
    if not success then
        -- Jika gagal hook, abaikan saja
        warn("Failed to hook event: " .. tostring(obj))
    end
end

-- Monitor hanya area yang aman
local function monitorSafeAreas()
    -- 1. ReplicatedStorage (biasanya events utama game)
    if game:GetService("ReplicatedStorage") then
        for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            safeHookEvent(obj)
        end
    end
    
    -- 2. Local Player tools
    local player = game.Players.LocalPlayer
    if player and player.Character then
        for _, obj in pairs(player.Character:GetDescendants()) do
            safeHookEvent(obj)
        end
    end
    
    -- 3. Backpack tools
    if player and player.Backpack then
        for _, obj in pairs(player.Backpack:GetDescendants()) do
            safeHookEvent(obj)
        end
    end
    
    -- 4. StarterPack
    if game:GetService("StarterPack") then
        for _, obj in pairs(game:GetService("StarterPack"):GetDescendants()) do
            safeHookEvent(obj)
        end
    end
    
    print("✅ Safe areas monitored: ReplicatedStorage, Local Player, Backpack, StarterPack")
end

-- Jalankan monitoring
monitorSafeAreas()

-- Monitor character respawn
game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to load
    for _, obj in pairs(character:GetDescendants()) do
        safeHookEvent(obj)
    end
    print("🔄 Character respawned - re-hooked events")
end)

-- Monitor new events di area aman
game:GetService("ReplicatedStorage").DescendantAdded:Connect(function(obj)
    safeHookEvent(obj)
end)

-- Analysis functions
_G.showCoins = function()
    print("\n💰 COIN EVENTS:")
    for _, event in pairs(events) do
        if event.category == "COIN" then
            print(string.format("  [%.1fs] %s", event.time, event.name))
            if #event.args > 0 then
                print("    Args:", table.concat(event.args, ", "))
            end
        end
    end
end

_G.showFishing = function()
    print("\n🎣 FISHING EVENTS:")
    for _, event in pairs(events) do
        if event.category == "FISHING" then
            print(string.format("  [%.1fs] %s", event.time, event.name))
            if #event.args > 0 then
                print("    Args:", table.concat(event.args, ", "))
            end
        end
    end
end

_G.showAll = function()
    print("\n📊 ALL EVENTS:")
    for _, event in pairs(events) do
        print(string.format("  %s [%.1fs] %s - %s", 
            event.category, event.time, event.name, event.path))
    end
end

_G.clearEvents = function()
    events = {}
    startTime = tick()
    print("🧹 Events cleared!")
end

print("💡 Commands:")
print("  _G.showCoins() - Show coin events")
print("  _G.showFishing() - Show fishing events") 
print("  _G.showAll() - Show all events")
print("  _G.clearEvents() - Clear event history")
print("🎯 Go fishing in the auto coin area now!")
