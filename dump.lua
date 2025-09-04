-- ⚡ Advanced Data Extractor & Module Explorer UI (Ultra Lengkap)
local HttpService = game:GetService("HttpService")

-- Data storage untuk hasil extraction
local ExtractedGameData = {
    fish = {},
    locations = {},
    rods = {},
    bait = {},
    items = {},
    npcs = {},
    quests = {},
    shops = {},
    recipes = {},
    enchants = {}
}

-- Function untuk extract data dari ModuleScript (Ultra Safe)
local function extractModuleData(moduleScript)
    local data = {}
    
    -- Ultra safe checks
    if not moduleScript then return data end
    if not moduleScript.Parent then return data end
    if not moduleScript:IsA("ModuleScript") then return data end
    
    local success, result = pcall(function()
        local modulePath = moduleScript:GetFullName()
        
        -- Skip problematic modules
        local skipPatterns = {
            "PlayerEmulatorService", "CoreGui", "CorePackages", "GameAnalytics",
            "DiscoveredSDK", "Analytics", "Net", "Enclave", "Shared", "External",
            "client", "Client", "server", "Server", "legacy", "Legacy"
        }
        
        for _, pattern in ipairs(skipPatterns) do
            if modulePath:find(pattern) then
                return nil
            end
        end
        
        -- Try to require with timeout protection
        local moduleContent
        local requireSuccess = pcall(function()
            moduleContent = require(moduleScript)
        end)
        
        if requireSuccess and type(moduleContent) == "table" then
            return moduleContent
        end
        return nil
    end)
    
    if success and result and type(result) == "table" then
        data = result
    end
    return data
end

-- Function untuk extract data berdasarkan nama module
local function extractSpecificData(moduleName, moduleData)
    local result = {}
    
    -- Extract Fish Data
    if moduleName:lower():find("fish") then
        for name, fishData in pairs(moduleData) do
            if type(fishData) == "table" then
                result[name] = {
                    name = name,
                    rarity = fishData.rarity or fishData.Rarity or "Unknown",
                    weight = fishData.weight or fishData.Weight or 0,
                    price = fishData.price or fishData.Price or 0,
                    zones = fishData.zones or fishData.Zones or {},
                    time = fishData.time or fishData.Time or "Any",
                    weather = fishData.weather or fishData.Weather or "Any",
                    rod = fishData.rod or fishData.Rod or "Any",
                    bait = fishData.bait or fishData.Bait or "Any"
                }
            end
        end
        
    -- Extract Location Data
    elseif moduleName:lower():find("location") then
        for name, locationData in pairs(moduleData) do
            if type(locationData) == "table" then
                result[name] = {
                    name = name,
                    position = locationData.position or locationData.Position,
                    cframe = locationData.cframe or locationData.CFrame,
                    zone = locationData.zone or locationData.Zone or "Unknown",
                    fish = locationData.fish or locationData.Fish or {},
                    weather = locationData.weather or locationData.Weather or "Any"
                }
            elseif typeof(locationData) == "CFrame" or typeof(locationData) == "Vector3" then
                result[name] = {
                    name = name,
                    position = locationData,
                    cframe = locationData
                }
            end
        end
        
    -- Extract Rod Data
    elseif moduleName:lower():find("rod") then
        for name, rodData in pairs(moduleData) do
            if type(rodData) == "table" then
                result[name] = {
                    name = name,
                    luck = rodData.luck or rodData.Luck or 0,
                    lure = rodData.lure or rodData.Lure or 0,
                    control = rodData.control or rodData.Control or 0,
                    resilience = rodData.resilience or rodData.Resilience or 0,
                    price = rodData.price or rodData.Price or 0,
                    enchants = rodData.enchants or rodData.Enchants or {}
                }
            end
        end
        
    -- Extract Bait Data
    elseif moduleName:lower():find("bait") then
        for name, baitData in pairs(moduleData) do
            if type(baitData) == "table" then
                result[name] = {
                    name = name,
                    lure = baitData.lure or baitData.Lure or 0,
                    price = baitData.price or baitData.Price or 0,
                    effectiveness = baitData.effectiveness or baitData.Effectiveness or {},
                    zones = baitData.zones or baitData.Zones or {}
                }
            end
        end
        
    -- Extract Items Data
    elseif moduleName:lower():find("item") then
        for name, itemData in pairs(moduleData) do
            if type(itemData) == "table" then
                result[name] = {
                    name = name,
                    type = itemData.type or itemData.Type or "Unknown",
                    price = itemData.price or itemData.Price or 0,
                    rarity = itemData.rarity or itemData.Rarity or "Common",
                    description = itemData.description or itemData.Description or ""
                }
            end
        end
        
    -- Extract Quest Data  
    elseif moduleName:lower():find("quest") then
        for name, questData in pairs(moduleData) do
            if type(questData) == "table" then
                result[name] = {
                    name = name,
                    npc = questData.npc or questData.NPC or "Unknown",
                    requirements = questData.requirements or questData.Requirements or {},
                    rewards = questData.rewards or questData.Rewards or {},
                    description = questData.description or questData.Description or ""
                }
            end
        end
    end
    
    return result
end

-- Ultra Safe scan function
local function scanGame()
    local remotes, modules = {}, {}
    
    -- Only scan the most essential and safe services
    local safeServices = {
        game.ReplicatedStorage,
        game.Workspace
    }
    
    warn("[Explorer] 🔍 Starting safe scan...")
    
    for _, service in ipairs(safeServices) do
        if service then
            local serviceName = service.Name or "Unknown"
            warn("[Explorer] Scanning: " .. serviceName)
            
            local success, descendants = pcall(function()
                local items = {}
                -- Get direct children first (safer)
                for _, child in ipairs(service:GetChildren()) do
                    table.insert(items, child)
                    -- Get their children too, but limited depth
                    pcall(function()
                        for _, grandchild in ipairs(child:GetChildren()) do
                            table.insert(items, grandchild)
                        end
                    end)
                end
                return items
            end)
            
            if success and descendants then
                warn("[Explorer] Found " .. #descendants .. " objects in " .. serviceName)
                
                for _, obj in ipairs(descendants) do
                    local objSuccess, objErr = pcall(function()
                        if obj and obj.Parent then
                            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                                local remotePath = ""
                                pcall(function()
                                    remotePath = obj:GetFullName()
                                end)
                                table.insert(remotes, {
                                    Name = obj.Name or "Unknown",
                                    Path = remotePath,
                                    Type = obj.ClassName
                                })
                                
                            elseif obj:IsA("ModuleScript") then
                                local objPath = ""
                                pcall(function()
                                    objPath = obj:GetFullName()
                                end)
                                
                                -- Additional safety checks
                                if objPath and not objPath:find("Analytics") and not objPath:find("SDK") then
                                    local moduleInfo = {
                                        Name = obj.Name or "Unknown",
                                        Path = objPath,
                                        Type = obj.ClassName
                                    }
                                    
                                    -- Try to extract data (with extra safety)
                                    local extractSuccess, moduleData = pcall(function()
                                        return extractModuleData(obj)
                                    end)
                                    
                                    if extractSuccess and moduleData and next(moduleData) then
                                        local extractedData = extractSpecificData(obj.Name, moduleData)
                                        if extractedData and next(extractedData) then
                                            moduleInfo.ExtractedData = extractedData
                                            moduleInfo.DataCount = 0
                                            for _ in pairs(extractedData) do
                                                moduleInfo.DataCount = moduleInfo.DataCount + 1
                                            end
                                        end
                                    end
                                    
                                    table.insert(modules, moduleInfo)
                                end
                            end
                        end
                    end)
                    
                    if not objSuccess then
                        -- Silently skip problematic objects
                    end
                end
            end
        end
    end
    
    warn("[Explorer] ✅ Scan complete: " .. #remotes .. " remotes, " .. #modules .. " modules")
    return remotes, modules
end

-- GUI
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "ExplorerUI"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 500, 0, 350)
frame.Position = UDim2.new(0.5, -250, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.Text = "⚡ Remote & Module Explorer"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- List Frame
local listFrame = Instance.new("ScrollingFrame", frame)
listFrame.Size = UDim2.new(0.5,-15,1,-70)
listFrame.Position = UDim2.new(0,10,0,40)
listFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
listFrame.ScrollBarThickness = 6
listFrame.CanvasSize = UDim2.new(0,0,0,0)

-- Info Panel
local infoPanel = Instance.new("TextLabel", frame)
infoPanel.Size = UDim2.new(0.5,-15,1,-70)
infoPanel.Position = UDim2.new(0.5,5,0,40)
infoPanel.BackgroundColor3 = Color3.fromRGB(20,20,20)
infoPanel.TextColor3 = Color3.new(1,1,1)
infoPanel.TextWrapped = true
infoPanel.TextXAlignment = Enum.TextXAlignment.Left
infoPanel.TextYAlignment = Enum.TextYAlignment.Top
infoPanel.Font = Enum.Font.Code
infoPanel.TextSize = 14
infoPanel.Text = "Klik item untuk lihat detail..."

-- Tombol Save
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Text = "💾 Save to Dump.txt"
saveBtn.Size = UDim2.new(0,180,0,30)
saveBtn.Position = UDim2.new(0,10,1,-35)
saveBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
saveBtn.TextColor3 = Color3.new(1,1,1)

-- Tombol Close
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0,40,0,30)
closeBtn.Position = UDim2.new(1,-50,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(170,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)

-- Enhanced info display function
local function displayModuleInfo(moduleInfo)
    local infoText = "Name: "..moduleInfo.Name
        .."\nType: "..moduleInfo.Type
        .."\nPath: "..moduleInfo.Path
    
    if moduleInfo.ExtractedData then
        infoText = infoText .. "\n\n📊 EXTRACTED DATA ("..moduleInfo.DataCount.." items):"
        infoText = infoText .. "\n" .. string.rep("-", 30)
        
        local count = 0
        for name, data in pairs(moduleInfo.ExtractedData) do
            if count >= 10 then -- Limit display untuk performance
                infoText = infoText .. "\n... dan " .. (moduleInfo.DataCount - 10) .. " items lainnya"
                break
            end
            
            infoText = infoText .. "\n\n🔹 " .. name .. ":"
            
            -- Display data berdasarkan type
            if data.rarity then -- Fish data
                infoText = infoText .. "\n  Rarity: " .. data.rarity
                if data.price and data.price > 0 then
                    infoText = infoText .. "\n  Price: $" .. data.price
                end
                if data.zones and #data.zones > 0 then
                    infoText = infoText .. "\n  Zones: " .. table.concat(data.zones, ", ")
                end
                
            elseif data.position then -- Location data
                if typeof(data.position) == "Vector3" then
                    infoText = infoText .. string.format("\n  Position: %.1f, %.1f, %.1f", 
                        data.position.X, data.position.Y, data.position.Z)
                end
                if data.zone then
                    infoText = infoText .. "\n  Zone: " .. data.zone
                end
                
            elseif data.luck then -- Rod data
                infoText = infoText .. "\n  Luck: " .. data.luck
                if data.lure then infoText = infoText .. " | Lure: " .. data.lure end
                if data.control then infoText = infoText .. " | Control: " .. data.control end
                if data.price and data.price > 0 then
                    infoText = infoText .. "\n  Price: $" .. data.price
                end
                
            elseif data.lure and data.effectiveness then -- Bait data
                infoText = infoText .. "\n  Lure: " .. data.lure
                if data.price and data.price > 0 then
                    infoText = infoText .. " | Price: $" .. data.price
                end
                
            elseif data.npc then -- Quest data
                infoText = infoText .. "\n  NPC: " .. data.npc
                if data.description then
                    infoText = infoText .. "\n  " .. data.description:sub(1, 50) .. "..."
                end
                
            elseif data.type then -- Item data
                infoText = infoText .. "\n  Type: " .. data.type
                if data.rarity then infoText = infoText .. " | Rarity: " .. data.rarity end
                if data.price and data.price > 0 then
                    infoText = infoText .. "\n  Price: $" .. data.price
                end
            end
            
            count = count + 1
        end
    else
        infoText = infoText .. "\n\n⚠️ No extractable data found"
    end
    
    return infoText
end

-- Safe List Population
local function refreshList()
    warn("[Explorer] 🔄 Refreshing list...")
    
    -- Clear existing items safely
    pcall(function()
        listFrame:ClearAllChildren()
    end)
    
    local remotes, modules = {}, {}
    local scanSuccess, scanErr = pcall(function()
        remotes, modules = scanGame()
    end)
    
    if not scanSuccess then
        warn("[Explorer] ❌ Scan failed: " .. tostring(scanErr))
        infoPanel.Text = "❌ Scan Error:\n" .. tostring(scanErr) .. "\n\nTry clicking refresh button."
        return remotes, modules
    end
    
    local items = {}
    
    -- Add remotes safely
    for _, r in ipairs(remotes) do
        if r and r.Name then
            table.insert(items, {Text = "[🔗 Remote] "..r.Name, Info = r, Type = "remote"})
        end
    end
    
    -- Add modules safely
    for _, m in ipairs(modules) do
        if m and m.Name then
            local displayText = "[📦 Module] "..m.Name
            if m.ExtractedData and m.DataCount and m.DataCount > 0 then
                displayText = displayText .. " (" .. m.DataCount .. " items)"
            end
            table.insert(items, {Text = displayText, Info = m, Type = "module"})
        end
    end
    
    warn("[Explorer] 📋 Creating " .. #items .. " UI items...")
    
    -- Create UI items safely
    for i, item in ipairs(items) do
        local btnSuccess, btnErr = pcall(function()
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1,-10,0,25)
            btn.Position = UDim2.new(0,5,0,(i-1)*27)
            btn.Text = item.Text or "Unknown"
            
            -- Color coding
            if item.Type == "module" and item.Info.ExtractedData then
                btn.BackgroundColor3 = Color3.fromRGB(0,120,0) -- Green for modules with data
            elseif item.Type == "module" then
                btn.BackgroundColor3 = Color3.fromRGB(120,120,0) -- Yellow for modules without data
            else
                btn.BackgroundColor3 = Color3.fromRGB(70,70,70) -- Gray for remotes
            end
            
            btn.TextColor3 = Color3.new(1,1,1)
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Font = Enum.Font.SourceSans
            btn.TextSize = 14

            btn.MouseButton1Click:Connect(function()
                pcall(function()
                    if item.Type == "module" then
                        infoPanel.Text = displayModuleInfo(item.Info)
                    else
                        infoPanel.Text = "Name: "..(item.Info.Name or "Unknown")
                            .."\nType: "..(item.Info.Type or "Unknown")
                            .."\nPath: "..(item.Info.Path or "Unknown")
                    end
                end)
            end)
        end)
        
        if not btnSuccess then
            warn("[Explorer] Failed to create button " .. i .. ": " .. tostring(btnErr))
        end
    end
    
    -- Update canvas size
    pcall(function()
        listFrame.CanvasSize = UDim2.new(0,0,0,#items*27)
    end)
    
    -- Update info panel
    if #items > 0 then
        infoPanel.Text = "✅ Found " .. #remotes .. " remotes and " .. #modules .. " modules.\nKlik item untuk lihat detail..."
    else
        infoPanel.Text = "⚠️ No items found.\nThis might be normal for some games.\nTry the refresh button."
    end
    
    warn("[Explorer] ✅ List refresh complete!")
    return remotes, modules
end

-- Enhanced save function with detailed data (Fixed)
saveBtn.MouseButton1Click:Connect(function()
    warn("[Explorer] 💾 Starting save process...")
    
    local saveSuccess, saveErr = pcall(function()
        local remotes, modules = scanGame()
        local dump = {
            "🔎 ADVANCED GAME DATA DUMP", 
            "Generated: " .. os.date(), 
            string.rep("=", 50), 
            ""
        }
        
        -- Save remotes
        table.insert(dump, "📡 REMOTE EVENTS & FUNCTIONS:")
        table.insert(dump, string.rep("-", 30))
        for _, r in ipairs(remotes) do
            if r and r.Type and r.Path then
                table.insert(dump, r.Type..": "..r.Path)
            end
        end
        
        -- Save modules with extracted data
        table.insert(dump, "")
        table.insert(dump, "📦 MODULE SCRIPTS WITH EXTRACTED DATA:")
        table.insert(dump, string.rep("-", 40))
        
        local totalDataItems = 0
        for _, m in ipairs(modules) do
            if m and m.Name and m.Path then
                table.insert(dump, "")
                table.insert(dump, "Module: "..m.Name)
                table.insert(dump, "Path: "..m.Path)
                
                if m.ExtractedData and next(m.ExtractedData) then
                    table.insert(dump, "Extracted Data ("..(m.DataCount or 0).." items):")
                    table.insert(dump, string.rep("-", 20))
                    
                    for name, data in pairs(m.ExtractedData) do
                        if name and data then
                            table.insert(dump, "  🔹 "..tostring(name)..":")
                            
                            -- Format data based on type
                            if data.rarity then -- Fish data
                                table.insert(dump, "    Type: Fish")
                                table.insert(dump, "    Rarity: "..tostring(data.rarity))
                                if data.price and tonumber(data.price) and tonumber(data.price) > 0 then
                                    table.insert(dump, "    Price: $"..tostring(data.price))
                                end
                                if data.zones and type(data.zones) == "table" and #data.zones > 0 then
                                    table.insert(dump, "    Zones: "..table.concat(data.zones, ", "))
                                end
                                if data.time and tostring(data.time) ~= "Any" then
                                    table.insert(dump, "    Time: "..tostring(data.time))
                                end
                                if data.weather and tostring(data.weather) ~= "Any" then
                                    table.insert(dump, "    Weather: "..tostring(data.weather))
                                end
                                
                            elseif data.position then -- Location data
                                table.insert(dump, "    Type: Location")
                                if typeof(data.position) == "Vector3" then
                                    table.insert(dump, string.format("    Position: %.2f, %.2f, %.2f", 
                                        data.position.X, data.position.Y, data.position.Z))
                                elseif typeof(data.position) == "CFrame" then
                                    local pos = data.position.Position
                                    table.insert(dump, string.format("    Position: %.2f, %.2f, %.2f", 
                                        pos.X, pos.Y, pos.Z))
                                end
                                if data.zone then
                                    table.insert(dump, "    Zone: "..tostring(data.zone))
                                end
                                
                            elseif data.luck then -- Rod data
                                table.insert(dump, "    Type: Fishing Rod")
                                table.insert(dump, "    Luck: "..tostring(data.luck))
                                if data.lure then table.insert(dump, "    Lure: "..tostring(data.lure)) end
                                if data.control then table.insert(dump, "    Control: "..tostring(data.control)) end
                                if data.resilience then table.insert(dump, "    Resilience: "..tostring(data.resilience)) end
                                if data.price and tonumber(data.price) and tonumber(data.price) > 0 then
                                    table.insert(dump, "    Price: $"..tostring(data.price))
                                end
                                
                            elseif data.lure and data.effectiveness then -- Bait data
                                table.insert(dump, "    Type: Bait")
                                table.insert(dump, "    Lure: "..tostring(data.lure))
                                if data.price and tonumber(data.price) and tonumber(data.price) > 0 then
                                    table.insert(dump, "    Price: $"..tostring(data.price))
                                end
                                
                            elseif data.npc then -- Quest data
                                table.insert(dump, "    Type: Quest")
                                table.insert(dump, "    NPC: "..tostring(data.npc))
                                if data.description and tostring(data.description) ~= "" then
                                    table.insert(dump, "    Description: "..tostring(data.description))
                                end
                                
                            elseif data.type then -- Item data
                                table.insert(dump, "    Type: "..tostring(data.type))
                                if data.rarity then table.insert(dump, "    Rarity: "..tostring(data.rarity)) end
                                if data.price and tonumber(data.price) and tonumber(data.price) > 0 then
                                    table.insert(dump, "    Price: $"..tostring(data.price))
                                end
                                if data.description and tostring(data.description) ~= "" then
                                    table.insert(dump, "    Description: "..tostring(data.description))
                                end
                            end
                            
                            table.insert(dump, "")
                            totalDataItems = totalDataItems + 1
                        end
                    end
                else
                    table.insert(dump, "No extractable data found")
                end
            end
        end
        
        -- Add summary
        table.insert(dump, "")
        table.insert(dump, string.rep("=", 50))
        table.insert(dump, "SUMMARY:")
        table.insert(dump, "Total Remotes: "..tostring(#remotes))
        table.insert(dump, "Total Modules: "..tostring(#modules))
        table.insert(dump, "Total Extracted Data Items: "..tostring(totalDataItems))
        table.insert(dump, string.rep("=", 50))

        local text = table.concat(dump, "\n")
        writefile("AdvancedGameDump.txt", text)
        warn("[Advanced Extractor] ✅ Semua data lengkap tersimpan di AdvancedGameDump.txt!")
        warn("[Data Summary] 📊 "..totalDataItems.." item data berhasil di-extract!")
    end)
    
    if not saveSuccess then
        warn("[Save Error] ❌ " .. tostring(saveErr))
        infoPanel.Text = "❌ Save Error:\n" .. tostring(saveErr) .. "\n\nTry again or check console for details."
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

-- Ultra Safe Init with better error handling
local function safeInit()
    warn("[Explorer] 🚀 Initializing Ultra Safe Explorer...")
    
    local success, err = pcall(function()
        refreshList()
    end)
    
    if not success then
        warn("[Explorer Error] " .. tostring(err))
        warn("[Explorer] 🔄 Falling back to basic mode...")
        
        -- Basic fallback - just show the UI without scanning
        infoPanel.Text = "⚠️ Initialization Error:\n" .. tostring(err) .. "\n\nClick 'Refresh' to try again or 'Manual Scan' for basic mode."
        
        -- Add refresh button if scanning fails
        local refreshBtn = Instance.new("TextButton", frame)
        refreshBtn.Text = "🔄 Refresh"
        refreshBtn.Size = UDim2.new(0,80,0,30)
        refreshBtn.Position = UDim2.new(0,200,1,-35)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(0,120,180)
        refreshBtn.TextColor3 = Color3.new(1,1,1)
        refreshBtn.Font = Enum.Font.SourceSansBold
        refreshBtn.TextSize = 12
        
        refreshBtn.MouseButton1Click:Connect(function()
            warn("[Explorer] 🔄 Manual refresh attempt...")
            pcall(function()
                refreshBtn:Destroy()
                refreshList()
            end)
        end)
        
        -- Add manual scan button for very basic functionality
        local manualBtn = Instance.new("TextButton", frame)
        manualBtn.Text = "🔍 Manual"
        manualBtn.Size = UDim2.new(0,80,0,30)
        manualBtn.Position = UDim2.new(0,290,1,-35)
        manualBtn.BackgroundColor3 = Color3.fromRGB(180,120,0)
        manualBtn.TextColor3 = Color3.new(1,1,1)
        manualBtn.Font = Enum.Font.SourceSansBold
        manualBtn.TextSize = 12
        
        manualBtn.MouseButton1Click:Connect(function()
            warn("[Explorer] 🔧 Starting manual basic scan...")
            pcall(function()
                if refreshBtn then refreshBtn:Destroy() end
                manualBtn:Destroy()
                
                -- Very basic manual scan
                local basicRemotes = {}
                local basicModules = {}
                
                -- Just scan ReplicatedStorage directly
                pcall(function()
                    for _, obj in ipairs(game.ReplicatedStorage:GetChildren()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            table.insert(basicRemotes, {Name=obj.Name, Path=obj:GetFullName(), Type=obj.ClassName})
                        elseif obj:IsA("ModuleScript") then
                            table.insert(basicModules, {Name=obj.Name, Path=obj:GetFullName(), Type=obj.ClassName})
                        end
                    end
                end)
                
                -- Display results
                listFrame:ClearAllChildren()
                local allItems = {}
                
                for _, r in ipairs(basicRemotes) do
                    table.insert(allItems, {Text = "[🔗] "..r.Name, Info = r, Type = "remote"})
                end
                for _, m in ipairs(basicModules) do
                    table.insert(allItems, {Text = "[📦] "..m.Name, Info = m, Type = "module"})
                end
                
                for i, item in ipairs(allItems) do
                    local btn = Instance.new("TextButton", listFrame)
                    btn.Size = UDim2.new(1,-10,0,25)
                    btn.Position = UDim2.new(0,5,0,(i-1)*27)
                    btn.Text = item.Text
                    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
                    btn.TextColor3 = Color3.new(1,1,1)
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    
                    btn.MouseButton1Click:Connect(function()
                        infoPanel.Text = "Name: "..item.Info.Name.."\nType: "..item.Info.Type.."\nPath: "..item.Info.Path
                    end)
                end
                
                listFrame.CanvasSize = UDim2.new(0,0,0,#allItems*27)
                infoPanel.Text = "✅ Manual scan complete!\nFound " .. #basicRemotes .. " remotes and " .. #basicModules .. " modules."
            end)
        end)
    else
        warn("[Explorer] ✅ Initialization successful!")
    end
end

safeInit()
print("[✅ Explorer] Ultra Safe UI aktif → Klik refresh jika ada masalah.")
