if game.Players:FindFirstChild("[\]") then print("detected you fucking femboy tryna env log lol nigga") return end
local whitelist = {
    ["6l5756ll6ytk"] = true,
    ["skullymuggy"] = true,
    ["iBeatTOBLox"] = true,
    ["er6wjdjfy4fg"] = true
}
local player = game.Players.LocalPlayer

local function isWhitelisted(player)
    return whitelist[player.UserId] == true
end

if not isWhitelisted(game.Players.LocalPlayer) then
    print("not whitelisted brochacho")
    return
end

local Library = loadstring(game:HttpGetAsync("https://github.com/ActualMasterOogway/Fluent-Renewed/releases/latest/download/Fluent.luau"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/bigbeanscripts/Pet-Warriors/refs/heads/main/test"))()
local InterfaceManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ActualMasterOogway/Fluent-Renewed/master/Addons/InterfaceManager.luau"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/SenhorLDS/ProjectLDSHUB/refs/heads/main/Anti%20AFK"))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local connection
local loopc

local killheight = 50

local autokillEnabled
local selectiveautofarmEnabled
local selectivebossfarmEnabled
local autoclickerEnabled
local autoequipEnabled

local autokillBosses
local autokillEnemies

local autokillMagic
local autokillPhysical

local selectedEnemies = {}
local selectedBosses = {}
local attacktype = "Snowflake Staff"

local currentEnemyTarget = nil
local currentBossTarget = nil
local skipEnemyAliveCheck
local randomTeleport
local validEnemies = {}

local hplimit = 1000000

local suffixes = {
    K = 1e3,
    M = 1e6,
    B = 1e9,
    T = 1e12,
    Qa = 1e15,
    Qi = 1e18,
    Sx = 1e21,
    Sp = 1e24,
    Oc = 1e27,
    No = 1e30,
    Dc = 1e33,
    Ud = 1e36,
    Dd = 1e39
}
local mutations = {
    "Small",
    "Big",
    "Huge",
    "Lunar",
    "Electric",
    "Infernal",
    "Spectral",
    "Inverted",
    "Glacial",
    "Solar",
    "Sanguine",
    "Abyssal",
    "Ethereal",
    "Colossal",
    "Golden",
    "Godlike",
    "Rainbow",
    "Transcendental"
}
local ignoredTools = {
    ["Healing Potion"] = true,
    ["Healing Gem"] = true,
    ["Invisibility Cube"] = true
}


local attack = game:GetService("ReplicatedStorage").FireProjectile

local Window = Library:CreateWindow({
    Title = "Hydroxygen",
    SubTitle = "v1.2.1",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})
local Options = Library.Options

local Tabs = {
    --Home = Window:CreateTab({ Title = "Home", Icon = "house" }),
    Main = Window:CreateTab({ Title = "Main", Icon = "house" }), --layout-grid
--Skills = Window:CreateTab({ Title = "Skills", Icon = "sparkle" }),
    Utilities = Window:CreateTab({ Title = "Utilities", Icon = "navigation" }),
--Teleports = Window:CreateTab({ Title = "Teleports", Icon = "flip-vertical-2" }),
--Loadout = Window:CreateTab({ Title = "Loadout", Icon = "sword" }),
--Stats = Window:CreateTab({ Title = "Stats", Icon = "trending-up" }),
--Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}
Window:SelectTab(1) --init
local MainSection = Tabs.Main:AddSection("Auto Farm")

local AutoKillToggle = MainSection:CreateToggle("AutoKill", {
    Title = "Auto Kill",
    Description = "Automatically kills enemies (select which ones to kill)",
    Default = false
})
AutoKillToggle:OnChanged(function()
    autokillEnabled = Options.AutoKill.Value
end)

local BetterAutoclickerToggle = MainSection:CreateToggle("BetterAutoclickerToggle", {
    Title = "Autoclicker",
    Description = "Automatically attacks (faster than the normal autoclicker)",
    Default = false
})
BetterAutoclickerToggle:OnChanged(function()
    autoclickerEnabled = Options.BetterAutoclickerToggle.Value
end)

local AutoEquipToggle = MainSection:CreateToggle("AutoEquipToggle", {
    Title = "Auto Equip Weapons",
    Description = "Automatically equips weapons for you (based on magic and physical setting)",
    Default = false
})
AutoEquipToggle:OnChanged(function()
    autoequipEnabled = Options.AutoEquipToggle.Value
end)

local KillDrop = MainSection:CreateDropdown("KillDrop", {
    Title = "Target Dropdown",
    Description = "Select who to kill",
    Values = {"Enemies", "Bosses"},
    Multi = true,
    Default = {"Enemies"},
})

KillDrop:OnChanged(function(Value)
    local Values = {}
    for k, v in pairs(Value) do
        if v then
            table.insert(Values, k)
        end
    end
    local set = {}
    for _, v in ipairs(Values) do
        set[v] = true
    end
    --cancerous toggle system
    if set["Bosses"] then autokillBosses = true else autokillBosses = false end
    if set["Enemies"] then autokillEnemies = true else autokillEnemies = false end
end)

local FarmMode = MainSection:CreateDropdown("FarmMode", {
    Title = "Farm Type",
    Description = "Select the type of farming that will be used",
    Values = {"Magical", "Physical"},
    Multi = false,
    Default = {"Magical"},
})
FarmMode:OnChanged(function(value)
    if value == "Magical" then
        autokillMagic = true
        autokillPhysical = false
    elseif value == "Physical" then
        autokillPhysical = true
        autokillMagic = false
    end
end)

local AttackMode = MainSection:CreateDropdown("AttackMode", {
    Title = "Attack Type",
    Description = "Select the type of projectile that will be used (only for magic)",
    Values = {"Snowflake Staff", "Wrathbringer", "Hades Staff"},
    Multi = false,
    Default = {"Snowflake Staff"},
})
AttackMode:OnChanged(function(value)
    attacktype = value
end)


local SecondSection = Tabs.Main:AddSection("Selective Auto Farm")

local SelectiveAutoFarm = SecondSection:CreateToggle("SelectiveAutoFarm", {
    Title = "Selective Enemy Farm",
    Description = "Unlike the main autofarm, this one only farms selected enemies",
    Default = false
})
SelectiveAutoFarm:OnChanged(function()
    selectiveautofarmEnabled = Options.SelectiveAutoFarm.Value
end)

local SelectiveBossFarm = SecondSection:CreateToggle("SelectiveBossFarm", {
    Title = "Selective Boss Farm",
    Description = "Farms only selected bosses",
    Default = false
})
SelectiveBossFarm:OnChanged(function()
    selectivebossfarmEnabled = Options.SelectiveBossFarm.Value
end)

local EnemyAutoFarm = SecondSection:CreateDropdown("EnemyAutoFarm", {
    Title = "Enemy Autofarm",
    Description = "Select specific enemies to farm",
    Values = {
        "Slime",
        "Snail",
        "Elite Slime",
        "Slime King",
        "Skeleton",
        "Ghost Skeleton",
        "Water Slime",
        "Yeti",
        "Bandit",
        "Living Cactus",
        "Monkey",
        "Mushroom Person",
        "Mushroom Knight",
        "Enchanted Slime",
        "Enchanted Snail",
        "Massive Enchanted Snail",
        "Rock Golem",
        "Rock Demon",
        "Magma Fiend",
        "Robot Spider",
        "Elite Robot Spider",
        "Ghost Slime",
        "Ghost",
        "Angel",
        "Korblox Skeleton",
        "Korblox General",
        "Ghostly Ghoul",
        "Evolved Ghastly Ghoul",
        "Cyborg",
        "Upgraded Cyborg",
        "Mr. Robot"
    },

    Multi = true,
    Default = {}
})

EnemyAutoFarm:OnChanged(function(Value)
    table.clear(selectedEnemies)

    for enemyName, enabled in pairs(Value) do
        if enabled then
            selectedEnemies[enemyName] = true
        end
    end
end)
local BossFarm = SecondSection:CreateDropdown("BossFarm", {
    Title = "Boss Farm",
    Description = "Boss autofarm",

    Values = {
        "Golem",
        "Evil Yeti",
        "Jump Power Wizard",
        "Triple T Sahur",
        "Vampire",
        "Frost Queen",
        "Fredrick",
        "Pharoah",
        "Poseidon",
        "Monkey King",
        "Reaper",
        "Infinity Sorcerer",
        "Cosmic Monkey",
        "Mushroom Golem",
        "Pig Person",
        "Angry Farmer",
        "Lighting Ninja",
        "Tornado Wizard",
        "Shadow",
        "Lava Devil",
        "Massive Stone Snail",
        "Giant",
        "Cyborg Master",
        "Scientist",
        "Zeus",
        "Cosmic Ghost",
        "The Cursor",
        "Medusa",
        "Witch",
        "Necromancer",
        "Archangel",
        "Time Demon",
        "Cursed Warrior",
        "Angel Lord",
        "Rotating Salmon",
        "Cyclops",
        "The Overseer",
        "Korblox Deathspeaker",
        "Demon Lord",
        "Noob",
        "Divine Monkey",
        "Cupid",
        "The Strongest Swordsman",
        "1x1x1x1",
        "Hade's Discipline",
        "Corrupted Hero",
        "The Surgeon",
        "Sun Knight",
        "The Exiled Legend",
        "Epic Face",
        "Earth Golem",
        "Lava God",
        "The Phantom Ruler",
        "Skeleton King",
        "Godspeed Assassin",
        "Crimson Ghoul",
        "Demonic Sorcerer",
        "Unbound Mind",
        "Master of Swords",
        "Divine Elf Spirit",
        "Lucky Fighter",
        "Guest 666",
        "Triple T God",
        "Redcliff Elite Commander",
        "The Crimson Hunter"
    },

    Multi = true,
    Default = {}
})
BossFarm:OnChanged(function(Value)
    table.clear(selectedBosses)

    for bossName, enabled in pairs(Value) do
        if enabled then
            selectedBosses[bossName] = true
        end
    end
end)
local SkipDeadEnemyCheck = MainSection:CreateToggle("SkipDeadEnemyCheck", {
    Title = "No Alive Enemy Checks",
    Description = "Instead of waiting for the enemy to die, instantly teleport to the next one (if there is one)",
    Default = false
})
SkipDeadEnemyCheck:OnChanged(function()
    skipEnemyAliveCheck = SkipDeadEnemyCheck.Value
end)

local RandomTeleport = MainSection:CreateToggle("RandomTeleport", {
    Title = "Random Teleport",
    Description = "Teleports you to a random enemy",
    Default = false
})
RandomTeleport:OnChanged(function()
    randomTeleport = RandomTeleport.Value
end)

local HeightSlider = SecondSection:CreateSlider("HeightN", {
    Title = "Height",
    Description = "Height at which you will kill the enemies (only for magical attacks)",
    Default = 50,
    Min = 0,
    Max = 200,
    Rounding = 0,
    Callback = function(height)
        killheight = height
    end
})


local HealthInput = MainSection:CreateInput("HealthInput", {
    Title = "Health Input",
    Default = "1000000",
    Placeholder = "HP Value",
    Numeric = true, -- Only allows numbers
    Finished = true, -- Only calls callback when you press enter
    Callback = function(Value)
        hplimit = tonumber(Value)
    end
})

UtilitiesSection = Tabs.Utilities:AddSection("Utilities")
local ImmortalityButton = UtilitiesSection:CreateButton{
    Title = "God Mode",
    Description = "Makes you invincible to ranged attacks (does not work for melee)",
    Callback = function()
        local character = player.Character
        if not character then return end

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end
        for i,v in pairs(character:GetChildren()) do
            if v:IsA("Part") or v:IsA("MeshPart") then
                v.CanTouch = false
                v.CanQuery = false
            end
        end
    end
}

local function cleanEnemyName(enemyName)
    local changed = true

    while changed do
        changed = false

        for _, mutation in ipairs(mutations) do
            local prefix = mutation .. " "

            if enemyName:sub(1, #prefix) == prefix then
                enemyName = enemyName:sub(#prefix + 1)
                changed = true
            end
        end
    end

    return enemyName
end

local function matchesSelectedEnemy(enemyName)
    enemyName = cleanEnemyName(enemyName)

    return selectedEnemies[enemyName] == true
end

local function getClosestSelectedEnemy(root)
    local closestEnemy = nil
    local closestDistance = math.huge

    local validEnemies = {}

    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then

            for _, enemy in ipairs(folder:GetChildren()) do
                local humanoid = enemy:FindFirstChildWhichIsA("Humanoid")
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")

                if enemy:IsA("Model")
                    and enemyRoot
                    and humanoid
                    and humanoid.Health > 0 then

                    if matchesSelectedEnemy(enemy.Name) then

                        if skipEnemyAliveCheck
                            and currentEnemyTarget == enemyRoot then
                            continue
                        end

                        -- RANDOM TELEPORT MODE
                        if randomTeleport then
                            table.insert(validEnemies, enemyRoot)
                        end

                        local dist =
                            (enemyRoot.Position - root.Position).Magnitude

                        if dist < closestDistance then
                            closestDistance = dist
                            closestEnemy = enemyRoot
                        end
                    end
                end
            end
        end
    end

    -- RANDOM MODE
    if randomTeleport and #validEnemies > 0 then
        local chosen =
            validEnemies[math.random(1, #validEnemies)]

        currentEnemyTarget = chosen

        return chosen
    end

    currentEnemyTarget = closestEnemy

    return closestEnemy
end

local function matchesSelectedBoss(enemyName)
    enemyName = cleanEnemyName(enemyName)

    return selectedBosses[enemyName] == true
end

local function getClosestSelectedBoss(root)
    local closestBoss = nil
    local closestDistance = math.huge

    local validBosses = {}

    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then

            for _, enemy in ipairs(folder:GetChildren()) do
                local humanoid = enemy:FindFirstChildWhichIsA("Humanoid")
                local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")

                if enemy:IsA("Model")
                    and enemyRoot
                    and humanoid
                    and humanoid.Health > 0 then

                    if matchesSelectedBoss(enemy.Name) then

                        if skipEnemyAliveCheck
                            and currentBossTarget == enemyRoot then
                            continue
                        end

                        if randomTeleport then
                            table.insert(validBosses, enemyRoot)
                        end

                        local dist =
                            (enemyRoot.Position - root.Position).Magnitude

                        if dist < closestDistance then
                            closestDistance = dist
                            closestBoss = enemyRoot
                        end
                    end
                end
            end
        end
    end

    if randomTeleport and #validBosses > 0 then
        local chosen =
            validBosses[math.random(1, #validBosses)]

        currentBossTarget = chosen

        return chosen
    end

    currentBossTarget = closestBoss

    return closestBoss
end


local function parseHealth(text)
    local current = text:match("^(.-)%s*/")

    if not current then
        return 0
    end

    local number, suffix = current:match("([%d%.]+)(%a*)")

    number = tonumber(number)
    if not number then
        return 0
    end

    if suffix ~= "" and suffixes[suffix] then
        number *= suffixes[suffix]
    end

    return number
end
--say wallahi bro
local function getEnemies(root)
    local enemies = {}
    local playerHum = root:FindFirstChildWhichIsA('Humanoid')

    if not playerHum then
        return enemies
    end

    local playerHP = playerHum.Health

    for _, folder in ipairs(workspace:GetChildren())do
        if folder:IsA('Folder') then
            for _, enemy in ipairs(folder:GetChildren())do
                if enemy:IsA('Model') then
                    local enemyHum = enemy:FindFirstChildWhichIsA('Humanoid')
                    local enemyRoot = enemy:FindFirstChild('HumanoidRootPart')

                    if enemyHum and enemyRoot and enemyHum.Health > 0 and enemy.Name ~= 'DamageDummy' then
                        local hpText
                        local rootBillboard = enemy.HumanoidRootPart:FindFirstChild('HealthBarBillboard')

                        if rootBillboard then
                            hpText = rootBillboard.Container.BarContainer.HealthText.Text
                        else
                            local head = enemy:FindFirstChild('Head')

                            if head and head:FindFirstChild('HealthBarBillboard') then
                                hpText = head.HealthBarBillboard.Container.BarContainer.HealthText.Text
                            end
                        end

                        local enemyHP = parseHealth(hpText)

                        if enemyHP <= hplimit then
                            if autokillEnemies then
                                if not enemy:FindFirstChild('BossScript') then
                                    table.insert(enemies, enemyRoot)
                                end
                            elseif autokillBosses then
                                if enemy:FindFirstChild('BossScript') then
                                    table.insert(enemies, enemyRoot)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return enemies
end

local function getClosestEnemy(root) --root
    local closestEnemy = nil
    local closestDistance = math.huge --ok i guess it doesnt like to work without that

    for _, folder in ipairs(workspace:GetChildren()) do
        if folder:IsA("Folder") then
            for _, enemy in ipairs(folder:GetChildren()) do
                if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Name ~= "DamageDummy" and enemy:FindFirstChildOfClass("Humanoid").Health > 0 then

                    local dist = (enemy.HumanoidRootPart.Position - root.Position).Magnitude

                    if dist < closestDistance then
                        closestDistance = dist
                        closestEnemy = enemy.HumanoidRootPart
                    end
                end
            end
        end
    end

    return closestEnemy
end

local function isPhysical(tool)
    return tool:FindFirstChild("AttackPhysical") ~= nil
end

local function getToolOfType(backpack, wantPhysical)
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if not ignoredTools[tool.Name] then
                local physical = isPhysical(tool)

                if physical == wantPhysical then
                    return tool
                end
            end
        end
    end

    return nil
end

loopc = game:GetService("CoreGui").DescendantRemoving:Connect(function(child)
    if child.Name == "FluentRenewed_Hydroxygen" then
        print("not found, disconnecting the heartbeat")
        connection:Disconnect()
        loopc:Disconnect()
    end
end)

connection = RunService.Heartbeat:Connect(function()
    math.randomseed(tick()) --random
    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local enemies = getEnemies(character)
    local enemyRoot = enemies[1]

    if autokillEnabled then
        if enemyRoot then
            if autokillMagic then
                root.CFrame = enemyRoot.CFrame + Vector3.new(0, killheight, 0)
                attack:FireServer(attacktype, enemyRoot.Position)
            elseif autokillPhysical then
                root.CFrame = enemyRoot.CFrame
            end
        end
    end
    if autoclickerEnabled then
        if character:FindFirstChildOfClass("Tool") and character:FindFirstChildOfClass("Tool"):FindFirstChild("AttackPhysical") then
            character:FindFirstChildOfClass("Tool"):Activate()
        else
            enemyRoot = getClosestEnemy(root)
            if enemyRoot then
                attack:FireServer(attacktype, enemyRoot.Position)
            end
        end
        --[[
        if autokillPhysical then
            if character:FindFirstChildOfClass("Tool") and not character:FindFirstChildOfClass("Tool"):FindFirstChild("AttackPhysical") then return end
            character:FindFirstChildOfClass("Tool"):Activate()
        elseif autokillMagical then
            enemyRoot = getClosestEnemy(root)
            attack:FireServer("Snowflake Staff", enemyRoot.PrimaryPart.Position)
        end
        ]]
    end
    if selectiveautofarmEnabled then
        local enemyRoot = getClosestSelectedEnemy(root)

        if enemyRoot then
            if autokillMagic then
                root.CFrame = enemyRoot.CFrame + Vector3.new(0, killheight, 0)

                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero

                attack:FireServer(attacktype, enemyRoot.Position)

            elseif autokillPhysical then
                root.CFrame = enemyRoot.CFrame

                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
    if selectivebossfarmEnabled then
        local enemyRoot = getClosestSelectedBoss(root)

        if enemyRoot then
            if autokillMagic then
                root.CFrame = enemyRoot.CFrame + Vector3.new(0, killheight, 0)

                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero

                attack:FireServer(attacktype, enemyRoot.Position)

            elseif autokillPhysical then
                root.CFrame = enemyRoot.CFrame

                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
    if autoequipEnabled then

        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if humanoid then

            local backpack = player:FindFirstChild("Backpack")
            local equippedTool = character:FindFirstChildWhichIsA("Tool")

            local wantPhysical = autokillPhysical
            local wantMagical = autokillMagic

            if wantPhysical or wantMagical then
                local shouldBePhysical = wantPhysical
                if equippedTool then
                    local equippedIsPhysical = isPhysical(equippedTool)
                    if equippedIsPhysical ~= shouldBePhysical then
                        local newTool = getToolOfType(backpack, shouldBePhysical)
                        if newTool then
                            humanoid:EquipTool(newTool)
                        end
                    end

                else
                    local newTool = getToolOfType(backpack, shouldBePhysical)
                    if newTool then
                        humanoid:EquipTool(newTool)
                    end
                end
            end
        end
    end
end)