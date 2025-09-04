--// Shop Module for Auto Buy Bait
--// Created separately to keep main.lua safe

local Shop = {}

--// Services
local Players = cloneref(game:GetService('Players'))
local ReplicatedStorage = cloneref(game:GetService('ReplicatedStorage'))
local TweenService = cloneref(game:GetService('TweenService'))
local RunService = cloneref(game:GetService('RunService'))

--// Variables
local lp = Players.LocalPlayer
local shopFlags = {}

-- Default values
shopFlags['selectedbaitcrate'] = 'Bait Crate (Moosewood)'
shopFlags['baitamount'] = 10
shopFlags['autobuy'] = false

--// Bait Crate Data
local BaitCrateTypes = {
    ['Basic Crates'] = {
        ['Bait Crate (Moosewood)'] = {location = CFrame.new(315, 135, 335), npc = 'Daily Shopkeeper'},
        ['Bait Crate (Roslit)'] = {location = CFrame.new(-1465, 130, 680), npc = 'Daily Shopkeeper'},
        ['Bait Crate (Forsaken)'] = {location = CFrame.new(-2490, 130, 1535), npc = 'Daily Shopkeeper'},
        ['Bait Crate (Ancient)'] = {location = CFrame.new(6075, 195, 260), npc = 'Daily Shopkeeper'},
        ['Bait Crate (Sunstone)'] = {location = CFrame.new(-1045, 200, -1100), npc = 'Daily Shopkeeper'}
    },
    ['Quality Crates'] = {
        ['Quality Bait Crate (Atlantis)'] = {location = CFrame.new(-177, 144, 1933), npc = 'Angus McBait'},
        ['Quality Bait Crate (Terrapin)'] = {location = CFrame.new(-175, 145, 1935), npc = 'Angus McBait'}
    }
}

--// NPC Locations
local NPCLocations = {
    ['Daily Shopkeeper'] = CFrame.new(229, 139, 42),
    ['Angus McBait'] = CFrame.new(236, 222, 461),
    ['Shell Merchant'] = CFrame.new(972, 132, 9921)
}

--// Bait Crate Locations
local BaitCrates = {
    ['Moosewood'] = CFrame.new(315, 135, 335),
    ['Roslit'] = CFrame.new(-1465, 130, 680),
    ['Atlantis'] = CFrame.new(-177, 144, 1933),
    ['Forsaken'] = CFrame.new(-2490, 130, 1535),
    ['Ancient'] = CFrame.new(6075, 195, 260),
    ['Sunstone'] = CFrame.new(-1045, 200, -1100),
    ['Terrapin'] = CFrame.new(-175, 145, 1935)
}

--// Helper Functions
function Shop:teleportToNPC(npcName)
    if NPCLocations[npcName] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = NPCLocations[npcName]
        return true
    end
    return false
end

function Shop:teleportToCrate(crateName)
    if BaitCrates[crateName] and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = BaitCrates[crateName]
        return true
    end
    return false
end

function Shop:buyBaitFromCrate(crateName, amount)
    local success = false
    
    -- Find crate info
    local crateInfo = nil
    local category = nil
    
    for cat, crates in pairs(BaitCrateTypes) do
        if crates[crateName] then
            crateInfo = crates[crateName]
            category = cat
            break
        end
    end
    
    if not crateInfo then
        warn("Bait crate not found: " .. crateName)
        return false
    end
    
    -- Teleport to crate location
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = crateInfo.location
        wait(1) -- Wait for teleport
        
        -- Try to interact with crate
        pcall(function()
            -- Try BuyBait/Show remote first
            local buyBaitRemote = ReplicatedStorage:FindFirstChild("packages")
            if buyBaitRemote then
                buyBaitRemote = buyBaitRemote:FindFirstChild("Net")
                if buyBaitRemote then
                    buyBaitRemote = buyBaitRemote:FindFirstChild("RE/BuyBait/Show")
                    if buyBaitRemote then
                        buyBaitRemote:FireServer()
                        wait(0.5)
                    end
                end
            end
            
            -- Try Daily Shop Purchase for basic crates
            if category == "Basic Crates" then
                local dailyShopRemote = ReplicatedStorage:FindFirstChild("packages")
                if dailyShopRemote then
                    dailyShopRemote = dailyShopRemote:FindFirstChild("Net")
                    if dailyShopRemote then
                        dailyShopRemote = dailyShopRemote:FindFirstChild("RE/DailyShop/Purchase")
                        if dailyShopRemote then
                            dailyShopRemote:FireServer(crateName, amount)
                            success = true
                        end
                    end
                end
            end
            
            -- Try Shell Merchant for quality crates
            if category == "Quality Crates" then
                local shellRemote = ReplicatedStorage:FindFirstChild("packages")
                if shellRemote then
                    shellRemote = shellRemote:FindFirstChild("Net")
                    if shellRemote then
                        shellRemote = shellRemote:FindFirstChild("RE/ShellMerchant/Purchase")
                        if shellRemote then
                            shellRemote:FireServer(crateName, amount)
                            success = true
                        end
                    end
                end
            end
        end)
    else
        warn("Character not found for teleportation")
    end
    
    return success
end

function Shop:equipBait(baitName)
    pcall(function()
        local equipRemote = ReplicatedStorage:FindFirstChild("packages")
        if equipRemote then
            equipRemote = equipRemote:FindFirstChild("Net")
            if equipRemote then
                equipRemote = equipRemote:FindFirstChild("RE/Bait/Equip")
                if equipRemote then
                    equipRemote:FireServer(baitName)
                end
            end
        end
    end)
end

function Shop:autoBuyLoop()
    spawn(function()
        while shopFlags['autobuy'] do
            if shopFlags['selectedbaitcrate'] and shopFlags['baitamount'] then
                local success = Shop:buyBaitFromCrate(shopFlags['selectedbaitcrate'], shopFlags['baitamount'])
                if success then
                    print("✅ Bought " .. shopFlags['baitamount'] .. "x from " .. shopFlags['selectedbaitcrate'])
                    wait(2) -- Wait between purchases
                else
                    print("❌ Failed to buy from " .. shopFlags['selectedbaitcrate'])
                    wait(5) -- Wait longer on failure
                end
            end
            wait(1)
        end
    end)
end

function Shop:createShopTab(Window)
    local ShopTab = Window:NewTab("🛒 Shop")
    local ShopSection = ShopTab:NewSection("Auto Buy Bait")
    
    -- Bait Crate Selection
    local crateList = {}
    for category, crates in pairs(BaitCrateTypes) do
        for crateName, _ in pairs(crates) do
            table.insert(crateList, crateName)
        end
    end
    
    ShopSection:NewDropdown("Select Bait Crate", "Choose bait crate to buy from", crateList, function(selectedCrate)
        shopFlags['selectedbaitcrate'] = selectedCrate
        print("Selected bait crate: " .. selectedCrate)
    end)
    
    -- Amount Input
    ShopSection:NewTextBox("Amount", "Enter amount to buy (default: 10)", function(txt)
        local amount = tonumber(txt)
        if amount and amount > 0 and amount <= 1000 then
            shopFlags['baitamount'] = amount
            print("Set amount: " .. amount)
        else
            print("Invalid amount! Use 1-1000")
        end
    end)
    
    -- Buy Button
    ShopSection:NewButton("💰 Buy Bait", "Buy bait from selected crate", function()
        if shopFlags['selectedbaitcrate'] and shopFlags['baitamount'] then
            local success = Shop:buyBaitFromCrate(shopFlags['selectedbaitcrate'], shopFlags['baitamount'])
            if success then
                print("✅ Purchase successful!")
            else
                print("❌ Purchase failed!")
            end
        else
            print("Please select bait crate and amount first!")
        end
    end)
    
    -- Auto Buy Toggle
    ShopSection:NewToggle("🔄 Auto Buy", "Automatically buy bait continuously", function(state)
        shopFlags['autobuy'] = state
        if state then
            print("🔄 Auto buy started")
            Shop:autoBuyLoop()
        else
            print("⏹️ Auto buy stopped")
        end
    end)
    
    -- Quick Actions Section
    local QuickSection = ShopTab:NewSection("Quick Teleport")
    
    -- Teleport to NPCs
    QuickSection:NewButton("📍 Daily Shopkeeper", "Teleport to Daily Shopkeeper", function()
        Shop:teleportToNPC('Daily Shopkeeper')
    end)
    
    QuickSection:NewButton("📍 Angus McBait", "Teleport to Angus McBait", function()
        Shop:teleportToNPC('Angus McBait')
    end)
    
    QuickSection:NewButton("📍 Shell Merchant", "Teleport to Shell Merchant", function()
        Shop:teleportToNPC('Shell Merchant')
    end)
    
    -- Bait Crates Section
    local CrateSection = ShopTab:NewSection("Bait Crate Locations")
    
    -- Basic Crates
    local BasicSection = ShopTab:NewSection("Basic Bait Crates")
    for crateName, info in pairs(BaitCrateTypes['Basic Crates']) do
        BasicSection:NewButton("📦 " .. crateName, "Teleport to " .. crateName, function()
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = info.location
                print("Teleported to " .. crateName)
            end
        end)
    end
    
    -- Quality Crates
    local QualitySection = ShopTab:NewSection("Quality Bait Crates")
    for crateName, info in pairs(BaitCrateTypes['Quality Crates']) do
        QualitySection:NewButton("⭐ " .. crateName, "Teleport to " .. crateName, function()
            if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = info.location
                print("Teleported to " .. crateName)
            end
        end)
    end
    
    -- Info Section
    local InfoSection = ShopTab:NewSection("ℹ️ Information")
    
    InfoSection:NewButton("📋 Show Crate Locations", "Display all bait crate locations", function()
        print("=== BAIT CRATE LOCATIONS ===")
        for category, crates in pairs(BaitCrateTypes) do
            print("📂 " .. category .. ":")
            for crateName, info in pairs(crates) do
                print("  � " .. crateName .. " (" .. info.npc .. ")")
            end
        end
    end)
    
    InfoSection:NewLabel("💡 Tip: Basic crates = common bait, Quality crates = rare bait")
    InfoSection:NewLabel("⚠️ Auto buy will teleport and purchase continuously")
    InfoSection:NewLabel("🎯 Make sure you have enough money before buying!")
    
    return ShopTab
end

return Shop
