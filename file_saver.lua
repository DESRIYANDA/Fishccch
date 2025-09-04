-- File Saver Script
-- Script untuk menyimpan hasil analisis ke file .txt

local function saveModuleAnalysis()
    local analysis = {}
    table.insert(analysis, "=== AUTOFISHING MODULE ANALYSIS REPORT ===")
    table.insert(analysis, "Generated on: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(analysis, "")
    
    -- Daftar path yang akan dianalisis
    local autoFishingPaths = {
        "ReplicatedStorage.shared.modules.ABTestExperiments.Experiments.AutoFishingExperiment",
        "ReplicatedStorage.client.legacyControllers.AutoFishingController", 
        "ReplicatedStorage.client.legacyControllers.AFKFishingController",
        "ReplicatedStorage.client.legacyControllers.ABTestController"
    }
    
    -- Function untuk navigate ke path
    local function navigateToPath(pathString)
        local parts = string.split(pathString, ".")
        local current = game
        
        for i, part in ipairs(parts) do
            local child = current:FindFirstChild(part)
            if child then
                current = child
            else
                return nil, "Failed at: " .. part .. " (step " .. i .. ")"
            end
        end
        
        return current, "Success"
    end
    
    -- Function untuk analyze dan save ke array
    local function analyzeAndSave(module, pathString)
        table.insert(analysis, "")
        table.insert(analysis, "ANALYZING: " .. pathString)
        table.insert(analysis, "Object Type: " .. module.ClassName)
        
        if module:IsA("ModuleScript") then
            table.insert(analysis, "Status: Is ModuleScript")
            
            -- Try to require
            local success, content = pcall(require, module)
            if success then
                table.insert(analysis, "Require Status: Successfully required")
                table.insert(analysis, "Content Type: " .. type(content))
                
                if type(content) == "table" then
                    table.insert(analysis, "")
                    table.insert(analysis, "TABLE CONTENTS:")
                    local count = 0
                    for key, value in pairs(content) do
                        count = count + 1
                        if count <= 20 then -- Show more items in file
                            local valueType = type(value)
                            local valueStr = tostring(value)
                            
                            if valueType == "function" then
                                valueStr = "function()"
                            elseif valueType == "table" then
                                valueStr = "table{...}"
                            elseif string.len(valueStr) > 100 then
                                valueStr = string.sub(valueStr, 1, 100) .. "..."
                            end
                            
                            table.insert(analysis, string.format("  %s: %s (%s)", 
                                tostring(key), valueStr, valueType))
                        end
                    end
                    
                    if count > 20 then
                        table.insert(analysis, string.format("  ... and %d more items", count - 20))
                    end
                    
                    -- Look for AutoFishing related keys
                    local autoFishingKeys = {}
                    for key, _ in pairs(content) do
                        local keyLower = string.lower(tostring(key))
                        if string.find(keyLower, "auto") or 
                           string.find(keyLower, "fish") or 
                           string.find(keyLower, "coin") or
                           string.find(keyLower, "enable") or
                           string.find(keyLower, "active") or
                           string.find(keyLower, "start") or
                           string.find(keyLower, "stop") then
                            table.insert(autoFishingKeys, key)
                        end
                    end
                    
                    if #autoFishingKeys > 0 then
                        table.insert(analysis, "")
                        table.insert(analysis, "AUTOFISHING-RELATED KEYS FOUND:")
                        for _, key in ipairs(autoFishingKeys) do
                            table.insert(analysis, "  - " .. tostring(key))
                        end
                    end
                else
                    table.insert(analysis, "Content: " .. tostring(content))
                end
            else
                table.insert(analysis, "Require Status: Failed - " .. tostring(content))
            end
        else
            table.insert(analysis, "Status: Not a ModuleScript")
            
            -- If it's a folder, list children
            if module:IsA("Folder") then
                table.insert(analysis, "Folder contents:")
                for _, child in ipairs(module:GetChildren()) do
                    table.insert(analysis, "  - " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
        
        table.insert(analysis, string.rep("-", 50))
    end
    
    -- Analyze each path
    local foundCount = 0
    for _, path in ipairs(autoFishingPaths) do
        table.insert(analysis, "")
        table.insert(analysis, "CHECKING PATH: " .. path)
        
        local module, status = navigateToPath(path)
        if module then
            table.insert(analysis, "RESULT: Found - " .. module.Name)
            foundCount = foundCount + 1
            analyzeAndSave(module, path)
        else
            table.insert(analysis, "RESULT: " .. status)
            table.insert(analysis, string.rep("-", 50))
        end
    end
    
    -- Additional search
    table.insert(analysis, "")
    table.insert(analysis, "ADDITIONAL SEARCH IN KEY LOCATIONS:")
    
    local searchLocations = {
        {path = "ReplicatedStorage.shared.modules", obj = game:GetService("ReplicatedStorage").shared.modules},
        {path = "ReplicatedStorage.client.legacyControllers", obj = game:GetService("ReplicatedStorage").client.legacyControllers}
    }
    
    for _, location in ipairs(searchLocations) do
        local success = pcall(function()
            table.insert(analysis, "")
            table.insert(analysis, "Searching in: " .. location.path)
            for _, child in ipairs(location.obj:GetChildren()) do
                local name = string.lower(child.Name)
                if (string.find(name, "auto") and string.find(name, "fish")) or
                   (string.find(name, "afk") and string.find(name, "fish")) then
                    table.insert(analysis, "Additional find: " .. child:GetFullName())
                    foundCount = foundCount + 1
                    analyzeAndSave(child, child:GetFullName())
                end
            end
        end)
    end
    
    -- Summary
    table.insert(analysis, "")
    table.insert(analysis, "=== ANALYSIS SUMMARY ===")
    table.insert(analysis, "Total AutoFishing modules found: " .. foundCount)
    table.insert(analysis, "Analysis completed on: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(analysis, "")
    table.insert(analysis, "=== END OF REPORT ===")
    
    return table.concat(analysis, "\n")
end

-- Function untuk auto save ke file dan clipboard
local function exportAnalysis()
    print("Starting AutoFishing module analysis...")
    local report = saveModuleAnalysis()
    
    -- Generate filename with timestamp
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local filename = "autofishing_analysis_" .. timestamp .. ".txt"
    
    -- Try to save to file (Delta/Android support)
    local fileSuccess = pcall(function()
        writefile(filename, report)
        print("SUCCESS: File saved as '" .. filename .. "'")
        print("Location: Executor folder in your device storage")
    end)
    
    if not fileSuccess then
        print("INFO: writefile not supported, trying alternative methods...")
        
        -- Try different file functions
        local altSuccess = pcall(function()
            -- Some executors use different function names
            if writefileExploit then
                writefileExploit(filename, report)
                print("SUCCESS: File saved using writefileExploit")
            elseif syn and syn.write_file then
                syn.write_file(filename, report)
                print("SUCCESS: File saved using syn.write_file")
            else
                error("No file write function available")
            end
        end)
        
        if not altSuccess then
            print("WARNING: File write not supported")
        end
    end
    
    -- Try to copy to clipboard as backup
    local clipSuccess = pcall(function()
        setclipboard(report)
        print("SUCCESS: Report also copied to clipboard!")
    end)
    
    if not clipSuccess then
        print("INFO: Clipboard not available")
    end
    
    -- Show file location info
    if fileSuccess then
        print("\nFILE SAVED SUCCESSFULLY!")
        print("Filename: " .. filename)
        print("Check your device storage in:")
        print("- Internal Storage/Android/data/com.roblox.client/files/")
        print("- Or in your executor's folder")
        print("- Some devices: Download folder")
    else
        -- Fallback: Print for manual copying
        print("\nFALLBACK - MANUAL COPY METHOD:")
        print(string.rep("=", 60))
        print("COPY EVERYTHING BELOW TO SAVE AS .TXT FILE:")
        print(string.rep("=", 60))
        print(report)
        print(string.rep("=", 60))
        print("COPY EVERYTHING ABOVE TO SAVE AS .TXT FILE:")
        print(string.rep("=", 60))
    end
    
    return report
end

-- Global function to run the export
_G.exportAnalysisToFile = exportAnalysis

-- Additional function for custom filename
_G.saveWithCustomName = function(customName)
    print("Starting analysis with custom filename...")
    local report = saveModuleAnalysis()
    
    local filename = customName or "autofishing_analysis.txt"
    if not string.find(filename, "%.txt$") then
        filename = filename .. ".txt"
    end
    
    local success = pcall(function()
        writefile(filename, report)
        print("SUCCESS: File saved as '" .. filename .. "'")
    end)
    
    if not success then
        print("ERROR: Could not save file")
        setclipboard(report)
        print("Copied to clipboard instead")
    end
    
    return report
end

-- Function to check if writefile is supported
_G.checkFileSupport = function()
    print("Checking file write support...")
    
    local functions = {
        {"writefile", writefile},
        {"writefileExploit", writefileExploit}, 
        {"syn.write_file", syn and syn.write_file},
        {"setclipboard", setclipboard}
    }
    
    for _, func in ipairs(functions) do
        if func[2] then
            print("✅ " .. func[1] .. " - SUPPORTED")
        else
            print("❌ " .. func[1] .. " - NOT SUPPORTED")
        end
    end
    
    -- Test write
    local testSuccess = pcall(function()
        writefile("test_write.txt", "Test file write")
        print("✅ File write test - SUCCESS")
        
        -- Clean up test file
        pcall(function()
            delfile("test_write.txt")
        end)
    end)
    
    if not testSuccess then
        print("❌ File write test - FAILED")
    end
end

-- Auto run
print("Advanced File Saver Script loaded!")
print("Commands available:")
print("- _G.exportAnalysisToFile() - Auto save with timestamp")
print("- _G.saveWithCustomName('filename') - Save with custom name")  
print("- _G.checkFileSupport() - Check what functions are supported")
print("")
print("Auto-running analysis in 3 seconds...")
print("File will be saved to your executor's folder on Android device")

wait(3)
exportAnalysis()
