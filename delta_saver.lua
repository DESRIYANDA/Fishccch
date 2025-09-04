-- Delta Android File Saver
-- Script khusus untuk save file di Android dengan Delta

-- Check if writefile is supported
if not writefile then
    print("ERROR: writefile not supported in this executor")
    print("Please use an executor that supports file operations")
    return
end

print("🤖 Delta Android File Saver - Starting...")

-- Quick AutoFishing analysis function
local function quickAnalysis()
    local results = {}
    table.insert(results, "=== QUICK AUTOFISHING ANALYSIS ===")
    table.insert(results, "Date: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(results, "Executor: Delta Android")
    table.insert(results, "")
    
    -- Check key paths
    local paths = {
        "ReplicatedStorage.shared.modules.ABTestExperiments.Experiments.AutoFishingExperiment",
        "ReplicatedStorage.client.legacyControllers.AutoFishingController",
        "ReplicatedStorage.client.legacyControllers.AFKFishingController"
    }
    
    for _, path in ipairs(paths) do
        table.insert(results, "Checking: " .. path)
        
        local success, module = pcall(function()
            local parts = string.split(path, ".")
            local current = game
            for _, part in ipairs(parts) do
                current = current[part]
            end
            return current
        end)
        
        if success and module then
            table.insert(results, "  Status: FOUND")
            table.insert(results, "  Type: " .. module.ClassName)
            
            if module:IsA("ModuleScript") then
                local reqSuccess, content = pcall(require, module)
                if reqSuccess then
                    table.insert(results, "  Require: SUCCESS")
                    table.insert(results, "  Content Type: " .. type(content))
                    
                    if type(content) == "table" then
                        table.insert(results, "  Keys:")
                        local count = 0
                        for key, _ in pairs(content) do
                            count = count + 1
                            if count <= 5 then
                                table.insert(results, "    - " .. tostring(key))
                            end
                        end
                        if count > 5 then
                            table.insert(results, "    ... and " .. (count-5) .. " more")
                        end
                    end
                else
                    table.insert(results, "  Require: FAILED")
                end
            end
        else
            table.insert(results, "  Status: NOT FOUND")
        end
        table.insert(results, "")
    end
    
    table.insert(results, "=== END ANALYSIS ===")
    return table.concat(results, "\n")
end

-- Save function
local function saveAnalysis()
    local content = quickAnalysis()
    local timestamp = os.date("%H%M%S")
    local filename = "autofishing_" .. timestamp .. ".txt"
    
    local success = pcall(function()
        writefile(filename, content)
    end)
    
    if success then
        print("✅ SUCCESS: File saved!")
        print("📁 Filename: " .. filename)
        print("📍 Location: Check your device storage")
        print("   - Executor folder")
        print("   - Download folder") 
        print("   - Android/data/com.roblox.client/files/")
        
        -- Also copy to clipboard
        pcall(function()
            setclipboard(content)
            print("📋 Also copied to clipboard!")
        end)
        
        return true
    else
        print("❌ FAILED: Could not save file")
        print("📋 Copying to clipboard instead...")
        
        pcall(function()
            setclipboard(content)
            print("✅ Copied to clipboard!")
        end)
        
        return false
    end
end

-- Test file write capability
print("🔍 Testing file write capability...")
local testSuccess = pcall(function()
    writefile("test.txt", "test")
    delfile("test.txt")
end)

if testSuccess then
    print("✅ File operations supported!")
    print("🚀 Starting analysis...")
    
    wait(1)
    saveAnalysis()
    
    print("\n💡 Commands:")
    print("_G.saveAnalysis() - Run analysis again")
    print("_G.quickSave(text) - Save custom text")
    
    -- Global functions
    _G.saveAnalysis = saveAnalysis
    _G.quickSave = function(text)
        local filename = "custom_" .. os.date("%H%M%S") .. ".txt"
        writefile(filename, text or "Empty file")
        print("Saved: " .. filename)
    end
    
else
    print("❌ File operations not supported")
    print("💡 Try using clipboard method instead")
end
