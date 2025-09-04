-- Enhanced FPS Booster Module for Integration
-- Modified version for main.lua integration

local FPSBooster = {}
local Players, Lighting, StarterGui, MaterialService = game:GetService("Players"), game:GetService("Lighting"), game:GetService("StarterGui"), game:GetService("MaterialService")
local ME = Players.LocalPlayer

-- Initialize global settings if not exists
if not _G.Settings then
    _G.Settings = {
        Players = {
            ["Ignore Me"] = true,
            ["Ignore Others"] = true
        },
        Meshes = {
            Destroy = false,
            LowDetail = true
        },
        Images = {
            Invisible = true,
            LowDetail = true,
            Destroy = false,
        },
        Other = {
            ["No Particles"] = false,
            ["No Camera Effects"] = false,
            ["No Explosions"] = true,
            ["No Clothes"] = false,
            ["Low Water Graphics"] = false,
            ["No Shadows"] = false,
            ["Low Rendering"] = false,
            ["Low Quality Parts"] = false,
            ["FPS Cap"] = 240,
            ["Reset Materials"] = false
        }
    }
end

if not _G.Ignore then
    _G.Ignore = {}
end
if not _G.WaitPerAmount then
    _G.WaitPerAmount = 500
end
if _G.SendNotifications == nil then
    _G.SendNotifications = false -- Disable notifications by default for integration
end
if _G.ConsoleLogs == nil then
    _G.ConsoleLogs = false
end

local CanBeEnabled = {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

local function PartOfCharacter(Instance)
    for i, v in pairs(Players:GetPlayers()) do
        if v ~= ME and v.Character and Instance:IsDescendantOf(v.Character) then
            return true
        end
    end
    return false
end

local function DescendantOfIgnore(Instance)
    for i, v in pairs(_G.Ignore) do
        if Instance:IsDescendantOf(v) then
            return true
        end
    end
    return false
end

local function CheckIfBad(Instance)
    if not Instance:IsDescendantOf(Players) and (_G.Settings.Players["Ignore Others"] and not PartOfCharacter(Instance) or not _G.Settings.Players["Ignore Others"]) and (_G.Settings.Players["Ignore Me"] and ME.Character and not Instance:IsDescendantOf(ME.Character) or not _G.Settings.Players["Ignore Me"]) and (_G.Settings.Players["Ignore Tools"] and not Instance:IsA("BackpackItem") and not Instance:FindFirstAncestorWhichIsA("BackpackItem") or not _G.Settings.Players["Ignore Tools"]) and (_G.Ignore and not table.find(_G.Ignore, Instance) and not DescendantOfIgnore(Instance) or (not _G.Ignore or type(_G.Ignore) ~= "table" or #_G.Ignore <= 0)) then
        if Instance:IsA("DataModelMesh") then
            if _G.Settings.Meshes.NoMesh and Instance:IsA("SpecialMesh") then
                Instance.MeshId = ""
            end
            if _G.Settings.Meshes.NoTexture and Instance:IsA("SpecialMesh") then
                Instance.TextureId = ""
            end
            if _G.Settings.Meshes.Destroy or _G.Settings["No Meshes"] then
                Instance:Destroy()
            end
        elseif Instance:IsA("FaceInstance") then
            if _G.Settings.Images.Invisible then
                Instance.Transparency = 1
                Instance.Shiny = 1
            end
            if _G.Settings.Images.LowDetail then
                Instance.Shiny = 1
            end
            if _G.Settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif Instance:IsA("ShirtGraphic") then
            if _G.Settings.Images.Invisible then
                Instance.Graphic = ""
            end
            if _G.Settings.Images.Destroy then
                Instance:Destroy()
            end
        elseif table.find(CanBeEnabled, Instance.ClassName) then
            if _G.Settings["Invisible Particles"] or _G.Settings["No Particles"] or (_G.Settings.Other and _G.Settings.Other["Invisible Particles"]) or (_G.Settings.Particles and _G.Settings.Particles.Invisible) then
                Instance.Enabled = false
            end
            if (_G.Settings.Other and _G.Settings.Other["No Particles"]) or (_G.Settings.Particles and _G.Settings.Particles.Destroy) then
                Instance:Destroy()
            end
        elseif Instance:IsA("PostEffect") and (_G.Settings["No Camera Effects"] or (_G.Settings.Other and _G.Settings.Other["No Camera Effects"])) then
            Instance.Enabled = false
        elseif Instance:IsA("Explosion") then
            if _G.Settings["Smaller Explosions"] or (_G.Settings.Other and _G.Settings.Other["Smaller Explosions"]) or (_G.Settings.Explosions and _G.Settings.Explosions.Smaller) then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
            end
            if _G.Settings["Invisible Explosions"] or (_G.Settings.Other and _G.Settings.Other["Invisible Explosions"]) or (_G.Settings.Explosions and _G.Settings.Explosions.Invisible) then
                Instance.BlastPressure = 1
                Instance.BlastRadius = 1
                Instance.Visible = false
            end
            if _G.Settings["No Explosions"] or (_G.Settings.Other and _G.Settings.Other["No Explosions"]) or (_G.Settings.Explosions and _G.Settings.Explosions.Destroy) then
                Instance:Destroy()
            end
        elseif Instance:IsA("Clothing") or Instance:IsA("SurfaceAppearance") or Instance:IsA("BaseWrap") then
            if _G.Settings["No Clothes"] or (_G.Settings.Other and _G.Settings.Other["No Clothes"]) then
                Instance:Destroy()
            end
        elseif Instance:IsA("BasePart") and not Instance:IsA("MeshPart") then
            if _G.Settings["Low Quality Parts"] or (_G.Settings.Other and _G.Settings.Other["Low Quality Parts"]) then
                Instance.Material = Enum.Material.Plastic
                Instance.Reflectance = 0
            end
        elseif Instance:IsA("TextLabel") and Instance:IsDescendantOf(workspace) then
            if _G.Settings["Lower Quality TextLabels"] or (_G.Settings.Other and _G.Settings.Other["Lower Quality TextLabels"]) or (_G.Settings.TextLabels and _G.Settings.TextLabels.LowerQuality) then
                Instance.Font = Enum.Font.SourceSans
                Instance.TextScaled = false
                Instance.RichText = false
                Instance.TextSize = 14
            end
            if _G.Settings["Invisible TextLabels"] or (_G.Settings.Other and _G.Settings.Other["Invisible TextLabels"]) or (_G.Settings.TextLabels and _G.Settings.TextLabels.Invisible) then
                Instance.Visible = false
            end
            if _G.Settings["No TextLabels"] or (_G.Settings.Other and _G.Settings.Other["No TextLabels"]) or (_G.Settings.TextLabels and _G.Settings.TextLabels.Destroy) then
                Instance:Destroy()
            end
        elseif Instance:IsA("Model") then
            if _G.Settings["Low Quality Models"] or (_G.Settings.Other and _G.Settings.Other["Low Quality Models"]) then
                Instance.LevelOfDetail = 1
            end
        elseif Instance:IsA("MeshPart") then
            if _G.Settings["Low Quality MeshParts"] or (_G.Settings.Other and _G.Settings.Other["Low Quality MeshParts"]) or (_G.Settings.MeshParts and _G.Settings.MeshParts.LowerQuality) then
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if _G.Settings["Invisible MeshParts"] or (_G.Settings.Other and _G.Settings.Other["Invisible MeshParts"]) or (_G.Settings.MeshParts and _G.Settings.MeshParts.Invisible) then
                Instance.Transparency = 1
                Instance.RenderFidelity = 2
                Instance.Reflectance = 0
                Instance.Material = Enum.Material.Plastic
            end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.NoTexture then
                Instance.TextureID = ""
            end
            if _G.Settings.MeshParts and _G.Settings.MeshParts.NoMesh then
                Instance.MeshId = ""
            end
            if _G.Settings["No MeshParts"] or (_G.Settings.Other and _G.Settings.Other["No MeshParts"]) or (_G.Settings.MeshParts and _G.Settings.MeshParts.Destroy) then
                Instance:Destroy()
            end
        end
    end
end

-- FPS Booster functions
function FPSBooster.applyLowWaterGraphics()
    coroutine.wrap(pcall)(function()
        if (_G.Settings["Low Water Graphics"] or (_G.Settings.Other and _G.Settings.Other["Low Water Graphics"])) then
            if not workspace:FindFirstChildOfClass("Terrain") then
                repeat task.wait() until workspace:FindFirstChildOfClass("Terrain")
            end
            workspace:FindFirstChildOfClass("Terrain").WaterWaveSize = 0
            workspace:FindFirstChildOfClass("Terrain").WaterWaveSpeed = 0
            workspace:FindFirstChildOfClass("Terrain").WaterReflectance = 0
            workspace:FindFirstChildOfClass("Terrain").WaterTransparency = 0
            if sethiddenproperty then
                sethiddenproperty(workspace:FindFirstChildOfClass("Terrain"), "Decoration", false)
            end
        end
    end)
end

function FPSBooster.applyNoShadows()
    coroutine.wrap(pcall)(function()
        if _G.Settings["No Shadows"] or (_G.Settings.Other and _G.Settings.Other["No Shadows"]) then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
            if sethiddenproperty then
                sethiddenproperty(Lighting, "Technology", 2)
            end
        end
    end)
end

function FPSBooster.applyLowRendering()
    coroutine.wrap(pcall)(function()
        if _G.Settings["Low Rendering"] or (_G.Settings.Other and _G.Settings.Other["Low Rendering"]) then
            settings().Rendering.QualityLevel = 1
            settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end
    end)
end

function FPSBooster.resetMaterials()
    coroutine.wrap(pcall)(function()
        if _G.Settings["Reset Materials"] or (_G.Settings.Other and _G.Settings.Other["Reset Materials"]) then
            for i, v in pairs(MaterialService:GetChildren()) do
                v:Destroy()
            end
            MaterialService.Use2022Materials = false
        end
    end)
end

function FPSBooster.setFPSCap(cap)
    coroutine.wrap(pcall)(function()
        if setfpscap then
            setfpscap(cap or 240)
        end
    end)
end

function FPSBooster.initializeOptimizations()
    print("🚀 Initializing FPS optimizations...")
    
    -- Apply all enabled optimizations
    FPSBooster.applyLowWaterGraphics()
    FPSBooster.applyNoShadows()
    FPSBooster.applyLowRendering()
    FPSBooster.resetMaterials()
    
    -- Set up monitoring for new instances
    game.DescendantAdded:Connect(function(value)
        task.wait(_G.LoadedWait or 0.1)
        CheckIfBad(value)
    end)
    
    -- Process existing descendants
    task.spawn(function()
        local Descendants = game:GetDescendants()
        local StartNumber = _G.WaitPerAmount or 500
        local WaitNumber = _G.WaitPerAmount or 500
        
        for i, v in pairs(Descendants) do
            CheckIfBad(v)
            if i == WaitNumber then
                task.wait()
                WaitNumber = WaitNumber + StartNumber
            end
        end
        
        print("✅ FPS Booster initialization complete!")
    end)
end

function FPSBooster.getStatus()
    return {
        lowWaterGraphics = _G.Settings.Other and _G.Settings.Other["Low Water Graphics"] or false,
        noShadows = _G.Settings.Other and _G.Settings.Other["No Shadows"] or false,
        lowRendering = _G.Settings.Other and _G.Settings.Other["Low Rendering"] or false,
        noParticles = _G.Settings.Other and _G.Settings.Other["No Particles"] or false,
        noCameraEffects = _G.Settings.Other and _G.Settings.Other["No Camera Effects"] or false,
        noClothes = _G.Settings.Other and _G.Settings.Other["No Clothes"] or false,
        lowQualityParts = _G.Settings.Other and _G.Settings.Other["Low Quality Parts"] or false,
        resetMaterials = _G.Settings.Other and _G.Settings.Other["Reset Materials"] or false,
        fpsCap = _G.Settings.Other and _G.Settings.Other["FPS Cap"] or 240
    }
end

-- Auto-initialize if loaded
if game:IsLoaded() then
    FPSBooster.initializeOptimizations()
else
    game.Loaded:Connect(function()
        FPSBooster.initializeOptimizations()
    end)
end

return FPSBooster
