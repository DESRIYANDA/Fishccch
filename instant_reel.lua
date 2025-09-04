-- Instant Reel Module
-- Automatically catches fish without reel mini-game when lure reaches 100%

local InstantReel = {}

-- Configuration
InstantReel.config = {
    enabled = false,
    perfectCatch = true,
    bypassReelGame = true,
    instantCatch = true,
    debugMode = false
}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Cache for reel detection
InstantReel.reelConnections = {}
InstantReel.activeReels = {}

-- Function to find reel GUI
function InstantReel.findReelGui()
    local screenGui = playerGui:FindFirstChild("reel")
    if screenGui then
        local frame = screenGui:FindFirstChild("bar")
        if frame then
            return frame
        end
    end
    return nil
end

-- Function to get reel progress
function InstantReel.getReelProgress(reelFrame)
    if not reelFrame then return 0 end
    
    local playerbar = reelFrame:FindFirstChild("playerbar")
    if playerbar then
        local size = playerbar.Size.X.Scale
        return math.floor(size * 100)
    end
    return 0
end

-- Function to simulate perfect reel completion
function InstantReel.completePerfectReel()
    if not InstantReel.config.enabled then return end
    
    -- Find reel remote
    local reelFinish = ReplicatedStorage:FindFirstChild("events") and 
                      ReplicatedStorage.events:FindFirstChild("reelfinished")
    
    if reelFinish then
        -- Send perfect reel completion
        reelFinish:FireServer(100, true) -- 100% perfect catch
        
        if InstantReel.config.debugMode then
            print("🎣 Instant Reel: Perfect catch executed!")
        end
        
        return true
    end
    
    return false
end

-- Function to bypass reel mini-game completely
function InstantReel.bypassReelGame()
    if not InstantReel.config.bypassReelGame then return end
    
    local reelGui = InstantReel.findReelGui()
    if reelGui then
        -- Hide reel GUI immediately
        reelGui.Parent.Enabled = false
        
        -- Complete reel instantly
        spawn(function()
            wait(0.1) -- Small delay to ensure server sync
            InstantReel.completePerfectReel()
        end)
        
        if InstantReel.config.debugMode then
            print("🚀 Instant Reel: Bypassed reel mini-game!")
        end
    end
end

-- Function to monitor reel progress and auto-complete
function InstantReel.monitorReelProgress()
    local reelFrame = InstantReel.findReelGui()
    if not reelFrame then return end
    
    local progress = InstantReel.getReelProgress(reelFrame)
    
    if progress >= 100 and InstantReel.config.instantCatch then
        -- Lure reached 100%, instantly catch
        InstantReel.completePerfectReel()
        
        if InstantReel.config.debugMode then
            print("⚡ Instant Reel: Auto-caught at 100% lure!")
        end
    elseif progress >= 95 and InstantReel.config.perfectCatch then
        -- Near perfect, complete immediately
        InstantReel.completePerfectReel()
        
        if InstantReel.config.debugMode then
            print("🎯 Instant Reel: Perfect catch at 95%+!")
        end
    end
end

-- Function to detect when reel starts
function InstantReel.onReelStart()
    local reelGui = playerGui:FindFirstChild("reel")
    if reelGui and reelGui.Enabled then
        if InstantReel.config.bypassReelGame then
            -- Completely bypass the reel game
            InstantReel.bypassReelGame()
        else
            -- Monitor for instant catch
            if not InstantReel.activeReels[reelGui] then
                InstantReel.activeReels[reelGui] = true
                
                local connection = RunService.Heartbeat:Connect(function()
                    if reelGui.Enabled then
                        InstantReel.monitorReelProgress()
                    else
                        -- Reel ended, cleanup
                        InstantReel.activeReels[reelGui] = nil
                        if InstantReel.reelConnections[reelGui] then
                            InstantReel.reelConnections[reelGui]:Disconnect()
                            InstantReel.reelConnections[reelGui] = nil
                        end
                    end
                end)
                
                InstantReel.reelConnections[reelGui] = connection
            end
        end
    end
end

-- Main monitoring function
function InstantReel.startMonitoring()
    if InstantReel.monitorConnection then
        InstantReel.monitorConnection:Disconnect()
    end
    
    InstantReel.monitorConnection = RunService.Heartbeat:Connect(function()
        if InstantReel.config.enabled then
            InstantReel.onReelStart()
        end
    end)
    
    print("🎣 Instant Reel monitoring started!")
end

-- Stop monitoring
function InstantReel.stopMonitoring()
    if InstantReel.monitorConnection then
        InstantReel.monitorConnection:Disconnect()
        InstantReel.monitorConnection = nil
    end
    
    -- Cleanup active connections
    for reelGui, connection in pairs(InstantReel.reelConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    InstantReel.reelConnections = {}
    InstantReel.activeReels = {}
    
    print("🛑 Instant Reel monitoring stopped!")
end

-- Enable/disable instant reel
function InstantReel.toggle(enabled)
    InstantReel.config.enabled = enabled
    
    if enabled then
        InstantReel.startMonitoring()
    else
        InstantReel.stopMonitoring()
    end
end

-- Set bypass mode
function InstantReel.setBypassMode(bypass)
    InstantReel.config.bypassReelGame = bypass
    print("🔧 Bypass reel game: " .. tostring(bypass))
end

-- Set perfect catch mode
function InstantReel.setPerfectCatch(perfect)
    InstantReel.config.perfectCatch = perfect
    print("🎯 Perfect catch mode: " .. tostring(perfect))
end

-- Set instant catch mode
function InstantReel.setInstantCatch(instant)
    InstantReel.config.instantCatch = instant
    print("⚡ Instant catch mode: " .. tostring(instant))
end

-- Set debug mode
function InstantReel.setDebugMode(debug)
    InstantReel.config.debugMode = debug
    print("🐛 Debug mode: " .. tostring(debug))
end

-- Get current status
function InstantReel.getStatus()
    return {
        enabled = InstantReel.config.enabled,
        bypassReelGame = InstantReel.config.bypassReelGame,
        perfectCatch = InstantReel.config.perfectCatch,
        instantCatch = InstantReel.config.instantCatch,
        debugMode = InstantReel.config.debugMode,
        activeReels = #InstantReel.activeReels,
        monitoring = InstantReel.monitorConnection ~= nil
    }
end

-- Alternative reel completion methods
function InstantReel.forceCompleteReel()
    -- Method 1: Direct reel completion
    local reelFinish = ReplicatedStorage:FindFirstChild("events") and 
                      ReplicatedStorage.events:FindFirstChild("reelfinished")
    
    if reelFinish then
        reelFinish:FireServer(100, true)
        return true
    end
    
    -- Method 2: Alternative reel events
    local catchEvent = ReplicatedStorage:FindFirstChild("events") and 
                      ReplicatedStorage.events:FindFirstChild("catch")
    
    if catchEvent then
        catchEvent:FireServer(100)
        return true
    end
    
    return false
end

-- Manual instant catch
function InstantReel.manualInstantCatch()
    local reelGui = InstantReel.findReelGui()
    if reelGui and reelGui.Parent.Enabled then
        local success = InstantReel.forceCompleteReel()
        if success then
            reelGui.Parent.Enabled = false
            print("✅ Manual instant catch executed!")
            return true
        else
            print("❌ Failed to execute instant catch!")
            return false
        end
    else
        print("⚠️ No active reel found!")
        return false
    end
end

return InstantReel
