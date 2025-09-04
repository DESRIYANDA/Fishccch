-- AutoFishing Implementation
-- Berdasarkan analisis data yang ditemukan

print("🎣 AutoFishing Implementation - Based on Analysis Data")

-- Data yang ditemukan dari analisis
local autoFishingPaths = {
    experiment = "ReplicatedStorage.shared.modules.ABTestExperiments.Experiments.AutoFishingExperiment",
    controller = "ReplicatedStorage.client.legacyControllers.AutoFishingController", 
    afkController = "ReplicatedStorage.client.legacyControllers.AFKFishingController",
    abTestController = "ReplicatedStorage.client.legacyControllers.ABTestController"
}

-- Function untuk mengakses module
local function getModule(path)
    local success, module = pcall(function()
        local parts = string.split(path, ".")
        local current = game
        for _, part in ipairs(parts) do
            current = current[part]
        end
        return current
    end)
    return success and module or nil
end

-- Get all modules
local modules = {}
for name, path in pairs(autoFishingPaths) do
    modules[name] = getModule(path)
    if modules[name] then
        print("✅ Found: " .. name)
    else
        print("❌ Missing: " .. name)
    end
end

-- Function untuk aktivasi AutoFishing
local function enableAutoFishing()
    print("\n🔄 Attempting to enable AutoFishing...")
    
    -- Method 1: Menggunakan AutoFishingController
    if modules.controller then
        local success = pcall(function()
            local controller = require(modules.controller)
            if controller.Start then
                controller.Start()
                print("✅ AutoFishingController.Start() called")
                return true
            end
        end)
        if success then return true end
    end
    
    -- Method 2: Menggunakan AFKFishingController  
    if modules.afkController then
        local success = pcall(function()
            local afkController = require(modules.afkController)
            if afkController.Start then
                afkController.Start()
                print("✅ AFKFishingController.Start() called")
                return true
            end
        end)
        if success then return true end
    end
    
    -- Method 3: Menggunakan ABTest untuk enable experiment
    if modules.experiment and modules.abTestController then
        local success = pcall(function()
            local experiment = require(modules.experiment)
            local abTest = require(modules.abTestController)
            
            -- Set experiment state ke enabled
            experiment.DefaultState = true
            experiment.Disabled = false
            
            print("✅ AutoFishing experiment enabled")
            return true
        end)
        if success then return true end
    end
    
    print("❌ All activation methods failed")
    return false
end

-- Function untuk check status
local function checkAutoFishingStatus()
    print("\n📊 Checking AutoFishing Status...")
    
    if modules.experiment then
        local success, experiment = pcall(require, modules.experiment)
        if success then
            print("Experiment DefaultState:", experiment.DefaultState)
            print("Experiment Disabled:", experiment.Disabled)
            print("RemoteConfig:", experiment.RemoteConfig)
        end
    end
    
    -- Check if fishing rod is equipped
    local player = game.Players.LocalPlayer
    if player.Character then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            print("Current Tool:", tool.Name)
        else
            print("❌ No tool equipped")
        end
    end
end

-- Function untuk force enable via RemoteConfig
local function forceEnableViaRemote()
    print("\n🔧 Trying RemoteConfig method...")
    
    local success = pcall(function()
        -- Berdasarkan data: RemoteConfig: "ABAutoFishing"
        local remoteEvent = game:GetService("ReplicatedStorage"):FindFirstChild("ABAutoFishing", true)
        if remoteEvent and remoteEvent:IsA("RemoteEvent") then
            remoteEvent:FireServer(true) -- Enable auto fishing
            print("✅ RemoteConfig ABAutoFishing fired")
        else
            print("❌ ABAutoFishing remote not found")
        end
    end)
    
    return success
end

-- Global functions untuk testing
_G.enableAuto = enableAutoFishing
_G.checkStatus = checkAutoFishingStatus  
_G.forceEnable = forceEnableViaRemote

-- Try to enable automatically
print("\n🚀 Auto-enabling AutoFishing...")
checkAutoFishingStatus()

local enabled = enableAutoFishing()
if not enabled then
    enabled = forceEnableViaRemote()
end

if enabled then
    print("\n🎉 AutoFishing activation attempted!")
    print("📝 Go fishing to test if it works")
else
    print("\n⚠️ Could not activate AutoFishing")
    print("💡 Try manual commands:")
end

print("\n💡 Available Commands:")
print("_G.enableAuto() - Try to enable AutoFishing")
print("_G.checkStatus() - Check current status")
print("_G.forceEnable() - Force enable via RemoteConfig")

-- Additional: Monitor for auto fishing activity
local function monitorFishing()
    local player = game.Players.LocalPlayer
    
    -- Monitor tool changes
    if player.Character then
        player.Character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then
                print("🎣 Fishing rod equipped: " .. child.Name)
                wait(1)
                enableAutoFishing() -- Try to enable when rod is equipped
            end
        end)
    end
    
    -- Monitor character respawn
    player.CharacterAdded:Connect(function(character)
        wait(3) -- Wait for character to load
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and string.find(string.lower(child.Name), "rod") then
                print("🎣 Fishing rod equipped after respawn: " .. child.Name)
                wait(1)
                enableAutoFishing()
            end
        end)
    end)
end

-- Start monitoring
monitorFishing()
print("👁️ Monitoring for fishing rod equipped...")
