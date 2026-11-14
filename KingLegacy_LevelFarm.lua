
--============================================================
-- KING LEGACY LEVEL FARM - RECONSTRUCTED 23RD BUILD
-- Based on static source analysis and extracted 124-row level table.
-- Re-audited special-quest prompt handling: retries until a visible completion signal.
-- Adds an in-game diagnostic scan; does not invent an NPC-to-level mapping.
--============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then return end

local QUESTS = {
    [4520749081] = {
        {min=1,max=9,mob='Soldiers',quest='Soldiers',x=-1860,y=50,z=-4489},
        {min=10,max=19,mob='Clown Pirates',quest='Clown Pirates',x=-1860,y=50,z=-4489},
        {min=20,max=29,mob='Smoky',quest='Smoky',x=-2065,y=99,z=-4686},
        {min=30,max=49,mob='Tashi',quest='Tashi',x=-2270,y=109,z=-4548},
        {min=50,max=74,mob='Clown Swordman',quest='Clown Swordman',x=-764,y=97,z=-3546},
        {min=75,max=99,mob='The Clown',quest='The Clown',x=-397,y=114,z=-3436},
        {min=100,max=119,mob='Commander',quest='Commander',x=-2122,y=92,z=-2549},
        {min=120,max=144,mob='Captain',quest='Captain',x=-2122,y=92,z=-2549},
        {min=145,max=179,mob='The Barbaric',quest='The Barbaric',x=-2375,y=139,z=-2419},
        {min=180,max=199,mob='Fighter Fishmans',quest='Fighter Fishmans',x=-856,y=52,z=-1422},
        {min=200,max=229,mob='Karate Fishman',quest='Karate Fishman',x=-856,y=52,z=-1422},
        {min=230,max=249,mob='Shark Man',quest='Shark Man',x=-666,y=56,z=-1493},
        {min=250,max=299,mob='Trainer Chef',quest='Trainer Chef',x=-4217,y=162,z=-2899},
        {min=300,max=349,mob='Dark Leg',quest='Dark Leg',x=-4217,y=162,z=-2899},
        {min=350,max=399,mob='Dory',quest='Dory',x=-4217,y=162,z=-2899},
        {min=400,max=449,mob='Snow Soldier',quest='Snow Soldier',x=-5310,y=65,z=-1275},
        {min=450,max=499,mob='King Snow',quest='King Snow',x=-5519,y=40,z=-1557},
        {min=500,max=524,mob='Little Dear',quest='Little Dear',x=-5467,y=55,z=-1104},
        {min=525,max=574,mob='Candle Man',quest='Candle Man',x=-2956,y=92,z=-602},
        {min=575,max=624,mob='Sand Bandit',quest='Sand Bandit',x=-2750,y=73,z=-777},
        {min=625,max=674,mob='Bomb Man',quest='Bomb Man',x=-2956,y=92,z=-602},
        {min=675,max=724,mob='Desert Marauder',quest='Desert Marauder',x=-2750,y=73,z=-777},
        {min=725,max=799,mob='King of Sand',quest='King of Sand',x=-3021,y=92,z=-545},
        {min=800,max=849,mob='Sky Soldier',quest='Sky Soldier',x=-4189,y=407,z=1345},
        {min=850,max=899,mob='Ball Man',quest='Ball Man',x=-4922,y=511,z=1234},
        {min=900,max=949,mob='Cloud Warrior',quest='Cloud Warrior',x=-4433,y=413,z=1248},
        {min=950,max=999,mob='Rumble Man',quest='Rumble Man',x=-4922,y=511,z=1234},
        {min=1000,max=1049,mob='Elite Soldiers',quest='Elite Soldiers',x=1730,y=67,z=894},
        {min=1050,max=1099,mob='High-class Soldier',quest='High-class Soldier',x=1456,y=98,z=917},
        {min=1100,max=1149,mob='Leader',quest='Leader',x=1660,y=47,z=607},
        {min=1150,max=1199,mob='Pasta',quest='Pasta',x=1928,y=128,z=878},
        {min=1200,max=1249,mob='Naval personnel',quest='Naval personnel',x=-1308,y=69,z=2148},
        {min=1250,max=1299,mob='Wolf',quest='Wolf',x=-1308,y=69,z=2148},
        {min=1300,max=1349,mob='Giraffe',quest='Giraffe',x=-1204,y=69,z=2100},
        {min=1350,max=1399,mob='Nautical soldier',quest='Nautical soldier',x=-1204,y=69,z=2100},
        {min=1400,max=1449,mob='Naval soldier',quest='Naval soldier',x=-1256,y=167,z=2585},
        {min=1450,max=1499,mob='Leo',quest='Leo',x=-1256,y=167,z=2585},
        {min=1500,max=1549,mob='Zombies',quest='Zombies',x=-2789,y=16,z=4188},
        {min=1550,max=1599,mob='Elite Zombies',quest='Elite Zombies',x=-2789,y=16,z=4188},
        {min=1600,max=1649,mob='Revenant',quest='Revenant',x=-2849,y=20,z=4319},
        {min=1650,max=1699,mob='Shadow Master',quest='Shadow Master',x=-2849,y=20,z=4319},
        {min=1700,max=1749,mob='New World Pirates',quest='New World Pirates',x=2153,y=109,z=-1587},
        {min=1750,max=1799,mob='Cutlass Pirates',quest='Cutlass Pirates',x=2391,y=80,z=-1982},
        {min=1800,max=1849,mob='Rear Admirals',quest='Rear Admirals',x=2410,y=109,z=-2228},
        {min=1850,max=1924,mob='True Karate Fishman',quest='True Karate Fishman',x=2471,y=103,z=-1938},
        {min=1925,max=1999,mob='Quake Woman',quest='Quake Woman',x=2285,y=49,z=-1908},
        {min=2000,max=2049,mob='Fishmans',quest='Fishmans',x=-1743,y=40,z=6198},
        {min=2050,max=2099,mob='Combat Fishman',quest='Combat Fishman',x=-1956,y=55,z=6236},
        {min=2100,max=2149,mob='Sword Fishman',quest='Sword Fishman',x=-1635,y=96,z=6688},
        {min=2150,max=2199,mob='Soldier Fishman',quest='Soldier Fishman',x=-1801,y=40,z=6451},
        {min=2200,max=999999999,mob='Seasoned Fishman',quest='Seasoned Fishman',x=-1801,y=40,z=6451},
    },
    [6381829480] = {
        {min=2250,max=2299,mob='Beast Pirates',quest='Beast Pirates',x=-4114,y=57,z=113},
        {min=2300,max=2349,mob='Beast Swordman',quest='Beast Swordman',x=-4092,y=98,z=-268},
        {min=2350,max=2399,mob='Gazelle Man',quest='Gazelle Man',x=-4363,y=57,z=252},
        {min=2400,max=2449,mob='Bandit Beast Pirates',quest='Bandit Beast Pirates',x=-4344,y=176,z=-1015},
        {min=2450,max=2499,mob='Powerful Beast Pirates',quest='Powerful Beast Pirates',x=-4656,y=136,z=-851},
        {min=2500,max=2549,mob='Violet Samurai',quest='Violet Samurai',x=-4969,y=105,z=-1007},
        {min=2550,max=2599,mob='Duke',quest='Duke',x=-5434,y=100,z=-228},
        {min=2600,max=2649,mob='Magician',quest='Magician',x=-5048,y=105,z=-154},
        {min=2650,max=2699,mob='Kitsune Samurai',quest='Kitsune Samurai',x=-5452,y=100,z=16},
        {min=2700,max=2749,mob='Elite Beast Pirates',quest='Elite Beast Pirates',x=-4564,y=73,z=1380},
        {min=2750,max=2799,mob='Bear Man',quest='Bear Man',x=-4438,y=53,z=775},
        {min=2800,max=2849,mob='Bean',quest='Bean',x=-4018,y=68,z=904},
        {min=2850,max=2899,mob='Meji',quest='Meji',x=-5302,y=83,z=1163},
        {min=2900,max=2949,mob='Petra',quest='Petra',x=-5857,y=80,z=1308},
        {min=2950,max=2999,mob='Kappa',quest='Kappa',x=-4853,y=109,z=1926},
        {min=3000,max=3049,mob='Joey',quest='Joey',x=-5287,y=57,z=2066},
        {min=3050,max=3099,mob='Skull Pirates',quest='Skull Pirates',x=-6400,y=78,z=6907},
        {min=3100,max=3124,mob='Elite Skeleton',quest='Elite Skeleton',x=-5926,y=98,z=7183},
        {min=3125,max=3149,mob='Desert Thief',quest='Desert Thief',x=1575,y=53,z=1513},
        {min=3150,max=3174,mob='Anubis',quest='Anubis',x=1964,y=48,z=899},
        {min=3175,max=3199,mob='Pharaoh',quest='Pharaoh',x=2048,y=49,z=1632},
        {min=3200,max=3224,mob='Chess Soldiers',quest='Chess Soldiers',x=-7,y=77,z=8164},
        {min=3225,max=3249,mob='Sunken Vessel',quest='Sunken Vessel',x=-986,y=83,z=8169},
        {min=3250,max=3274,mob='Biscuit Man',quest='Biscuit Man',x=-1375,y=202,z=8860},
        {min=3275,max=3299,mob='Dough Master',quest='Dough Master',x=30370,y=106,z=93598},
        {min=3300,max=3324,mob='Azlan',quest='Azlan',x=-832,y=69,z=-2860},
        {min=3325,max=3399,mob='The Volcano',quest='The Volcano',x=-152,y=173,z=-3579},
        {min=3400,max=3424,mob='Dark Beard Servant',quest='Dark Beard Servant',x=-9156,y=94,z=-4629},
        {min=3425,max=3449,mob='Supreme Swordman',quest='Supreme Swordman',x=-9647,y=114,z=-4483},
        {min=3450,max=3499,mob='Sally',quest='Sally',x=-9584,y=135,z=-5374},
        {min=3500,max=3524,mob='Vice Admiral',quest='Vice Admiral',x=-9993,y=87,z=421},
        {min=3525,max=3549,mob='Pondere',quest='Pondere',x=-10142,y=100,z=1298},
        {min=3550,max=3599,mob='Hefty',quest='Hefty',x=-10489,y=84,z=969},
        {min=3600,max=3624,mob='Fiore Gladiator',quest='Fiore Gladiator',x=5450,y=133,z=-2782},
        {min=3625,max=3649,mob='Fiore Fighter',quest='Fiore Fighter',x=5466,y=87,z=-2559},
        {min=3650,max=3674,mob='Fiore Pirate',quest='Fiore Pirate',x=6095,y=134,z=-2905},
        {min=3675,max=3699,mob='Lomeo',quest='Lomeo',x=6487,y=72,z=-2135},
        {min=3700,max=3724,mob='Prince Aria',quest='Prince Aria',x=6785,y=150,z=-3794},
        {min=3725,max=3774,mob='Devastate',quest='Devastate',x=7632,y=122,z=-2644},
        {min=3775,max=3799,mob='Floffy',quest='Floffy',x=7865,y=462,z=-2529},
        {min=3800,max=3849,mob='Dead Troupe',quest='Dead Troupe',x=9716,y=93,z=-4292},
        {min=3850,max=3974,mob='Dead Troupe Captain',quest='Dead Troupe Captain',x=10021,y=102,z=-3947},
        {min=3975,max=9999999,mob='Ryu',quest='Ryu',x=9927,y=86,z=-4856},
    },
    [15759515082] = {
        {min=4000,max=4049,mob='Deep Diver',quest='Deep Diver',x=1674,y=47,z=1015},
        {min=4050,max=4099,mob='Fugitive',quest='Fugitive',x=2888,y=35,z=993},
        {min=4100,max=4149,mob='Deep one Villager',quest='Deep one Villager',x=3299,y=316,z=671},
        {min=4150,max=4199,mob='Fishman Guardian',quest='Fishman Guardian',x=1786,y=66,z=86},
        {min=4200,max=4249,mob='The deep one',quest='The deep one',x=2833,y=35,z=136},
        {min=4250,max=4299,mob='Fishman King\'s Guard',quest='Fishman King\'s Guard',x=1934,y=125,z=-457},
        {min=4300,max=4324,mob='Jungle Gorilla',quest='Jungle Gorilla',x=4215,y=181,z=9081},
        {min=4325,max=4349,mob='Wilderness Gorilla',quest='Wilderness Gorilla',x=4865,y=45,z=9876},
        {min=4350,max=4374,mob='Jungle Ape',quest='Jungle Ape',x=5307,y=45,z=9640},
        {min=4375,max=4399,mob='Cyborg Gorilla',quest='Cyborg Gorilla',x=5784,y=45,z=9463},
        {min=4400,max=4449,mob='Ripcurrent Raider',quest='Ripcurrent Raider',x=-506,y=26,z=-8673},
        {min=4450,max=4499,mob='Tidal Warrior',quest='Tidal Warrior',x=-73,y=96,z=-8404},
        {min=4500,max=4549,mob='Ocean Gladiator',quest='Ocean Gladiator',x=-22,y=44,z=-9066},
        {min=4550,max=4599,mob='Deepfire Combatant',quest='Deepfire Combatant',x=-5174,y=26,z=171},
        {min=4600,max=4649,mob='Electro Abyss Warrior',quest='Electro Abyss Warrior',x=-5230,y=22,z=964},
        {min=4650,max=4699,mob='Inferno Diver',quest='Inferno Diver',x=-6044,y=54,z=467},
        {min=4700,max=4749,mob='Tempest Tidebreaker',quest='Tempest Tidebreaker',x=-7296,y=42,z=469},
        {min=4750,max=4799,mob='Abyssal Swordsman',quest='Abyssal Swordsman',x=-8255,y=186,z=455},
        {min=4800,max=4849,mob='Rogue Prisoner',quest='Rogue Prisoner',x=10931,y=78,z=478},
        {min=4850,max=4874,mob='Prisoner Buccaneer',quest='Prisoner Buccaneer',x=11731,y=125,z=253},
        {min=4875,max=4999,mob='Prisoner of Gravity',quest='Prisoner of Gravity',x=12436,y=79,z=1052},
        {min=5000,max=5049,mob='Obsidian Seeker',quest='Obsidian Seeker',x=-7751,y=165,z=11631},
        {min=5050,max=5099,mob='Forgotten Delver',quest='Forgotten Delver',x=-8570,y=214,z=10434},
        {min=5100,max=5149,mob='Blackreach Scout',quest='Blackreach Scout',x=-8440,y=116,z=12270},
        {min=5150,max=5199,mob='Nightbound Explorer',quest='Nightbound Explorer',x=-8634,y=235,z=11395},
        {min=5200,max=5249,mob='Ruinstep Nomad',quest='Ruinstep Nomad',x=-9066,y=79,z=13239},
        {min=5250,max=5299,mob='Ancient Wayfarer',quest='Ancient Wayfarer',x=-9061,y=79,z=11636},
        {min=5300,max=5349,mob='Depths Voyager',quest='Depths Voyager',x=-10193,y=107,z=12325},
        {min=5350,max=5399,mob='Allosaurus',quest='Allosaurus',x=-10548,y=248,z=11940},
        {min=5400,max=9999,mob='Spinosaurus',quest='Spinosaurus',x=-10655,y=177,z=10159},
    },
}

local State = {
    Running = false,
    LoopToken = 0,
    AutoNPC = true,
    LastAttack = 0,
    LastMove = 0,
    LastNPCCheck = 0,
    LastTarget = nil,
    LastBoardVisible = false, LastBoardTitle = nil,
    SpecialDone = {}, SpecialAt = 0, SpecialAttempts = {}, SpecialWaitAt = {},
    CodexAttempts = {}, NPCActionAt = {}, ManualNPC = "",
}

local function safeCall(fn, ...)
    local args = {...}
    local ok, result = pcall(function() return fn(table.unpack(args)) end)
    if ok then return result end
    return nil
end

local function getCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, root, hum
end

-- The original source reads PlayerStats.lvl.Value. Other UI paths are fallbacks.
local function getLevel()
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    local lvl = stats and stats:FindFirstChild("lvl")
    if lvl then
        local n = tonumber(lvl.Value)
        if n then return n end
    end

    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, value in ipairs(leaderstats:GetChildren()) do
            if string.find(string.lower(value.Name), "level", 1, true) then
                local n = tonumber(value.Value)
                if n then return n end
            end
        end
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                local name = string.lower(obj.Name)
                local value = tostring(obj.Text or "")
                if string.find(name, "level", 1, true) or string.match(string.lower(value), "^%s*level%s*[:%-]?") then
                    local n = tonumber(string.match(value, "%d+"))
                    if n then return n end
                end
            end
        end
    end
    return nil
end

local function getQuestBoard()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local main = pg and pg:FindFirstChild("MainGui")
    local frame = main and main:FindFirstChild("QuestFrame")
    local board = frame and frame:FindFirstChild("QuestBoard")
    local textFrame = board and board:FindFirstChild("TextFrame")
    local questName = textFrame and textFrame:FindFirstChild("QuestName")
    return board ~= nil and board.Visible == true, questName and tostring(questName.Text or "") or ""
end

local function getQuestEntry(level)
    -- IMPORTANT: QUESTS uses numeric PlaceId keys, so do not tostring(game.PlaceId).
    local list = QUESTS[game.PlaceId]
    if not list then return nil end
    for _, entry in ipairs(list) do
        if level >= entry.min and level <= entry.max then return entry end
    end
    return nil
end

local function getEntryForBoard(level, boardTitle)
    local current = getQuestEntry(level)
    local function matches(a, b)
        a = string.lower(string.gsub(tostring(a or ""), "[^%w]", ""))
        b = string.lower(string.gsub(tostring(b or ""), "[^%w]", ""))
        if #a > 3 and string.sub(a, -1) == "s" then a = string.sub(a, 1, -2) end
        if #b > 3 and string.sub(b, -1) == "s" then b = string.sub(b, 1, -2) end
        return a ~= "" and b ~= "" and (string.find(a,b,1,true) ~= nil or string.find(b,a,1,true) ~= nil)
    end
    if current and matches(boardTitle, current.mob) then return current end
    local list = QUESTS[game.PlaceId]
    if list then
        for _, entry in ipairs(list) do
            if matches(boardTitle, entry.mob) then return entry end
        end
    end
    return current
end

local function normalizeName(value)
    value = string.lower(tostring(value or ""))
    value = string.gsub(value, "[^%w]", "")
    if #value > 3 and string.sub(value, -1) == "s" then
        value = string.sub(value, 1, -2)
    end
    return value
end

local function questTitleMatches(title, mobName)
    local a = normalizeName(title)
    local b = normalizeName(mobName)
    if a == "" or b == "" then return false end
    return string.find(a, b, 1, true) ~= nil or string.find(b, a, 1, true) ~= nil
end

local function findMonster(questTitle, mobName)
    local folder = Workspace:FindFirstChild("Monster")
    if not folder then return nil, nil, nil, "Monster 폴더 없음" end

    local titleKey = normalizeName(questTitle)
    local mobKey = normalizeName(mobName)
    local exactTitle, exactMob, partial = {}, {}, {}

    for _, folderName in ipairs({"Mon", "Boss"}) do
        local container = folder:FindFirstChild(folderName)
        if container then
            for _, model in ipairs(container:GetChildren()) do
                if model:IsA("Model") then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    local root = model:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and root then
                        local key = normalizeName(model.Name)
                        local item = {model, hum, root}
                        if key == titleKey then
                            table.insert(exactTitle, item)
                        elseif key == mobKey then
                            table.insert(exactMob, item)
                        elseif mobKey ~= "" and string.find(key, mobKey, 1, true) then
                            table.insert(partial, item)
                        end
                    end
                end
            end
        end
    end

    local function nearestCandidate(items)
        local _, playerRoot = getCharacter()
        local best, bestDistance = nil, math.huge
        for _, candidate in ipairs(items) do
            local distance = playerRoot and (playerRoot.Position - candidate[3].Position).Magnitude or math.huge
            if not best or distance < bestDistance then
                best, bestDistance = candidate, distance
            end
        end
        return best
    end

    -- Multiple live mobs with the exact same name are normal in a farm area.
    -- Select the nearest one instead of treating their existence as ambiguity.
    if #exactTitle > 0 then
        local best = nearestCandidate(exactTitle)
        return best[1], best[2], best[3]
    end

    if #exactMob > 0 then
        local best = nearestCandidate(exactMob)
        return best[1], best[2], best[3]
    end

    -- Partial matching is safe only when every candidate has the same actual
    -- model name. Similar but distinct model names remain intentionally blocked.
    if #partial > 0 then
        local uniqueNames = {}
        for _, candidate in ipairs(partial) do
            uniqueNames[normalizeName(candidate[1].Name)] = true
        end
        local count = 0
        for _ in pairs(uniqueNames) do count = count + 1 end
        if count == 1 then
            local best = nearestCandidate(partial)
            return best[1], best[2], best[3]
        end
        return nil, nil, nil, "비슷하지만 서로 다른 이름의 몬스터가 있어 공격 보류"
    end
    return nil, nil, nil, "대상 몬스터 없음"
end

local function getEquippedTool(character)
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    return nil
end

local function readStatValue(stats, key)
    local object = stats and stats:FindFirstChild(key)
    if not object then return nil end
    local ok, value = pcall(function() return tostring(object.Value) end)
    if ok and value ~= "" and value ~= "nil" and string.lower(value) ~= "none" then
        return value
    end
    return nil
end

local function attackOnce(character, targetRoot)
    if os.clock() - State.LastAttack < 0.35 then return end
    State.LastAttack = os.clock()

    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    local chest = ReplicatedStorage:FindFirstChild("Chest")
    local remotes = chest and chest:FindFirstChild("Remotes")
    local functions = remotes and remotes:FindFirstChild("Functions")
    local skillAction = functions and functions:FindFirstChild("SkillAction")
    local targetCFrame = targetRoot and targetRoot.CFrame

    if skillAction and skillAction:IsA("RemoteFunction") and targetCFrame then
        local actions = {
            {"FS_", readStatValue(stats, "FightingStyle")},
            {"SW_", readStatValue(stats, "SwordName")},
            {"DF_", readStatValue(stats, "DFName")},
        }
        local sent = false
        for _, item in ipairs(actions) do
            if item[2] then
                local actionName = item[1] .. item[2] .. "_M1"
                local ok = pcall(function()
                    skillAction:InvokeServer(actionName, {MouseHit = targetCFrame})
                end)
                if ok then sent = true end
            end
        end
        if sent then return end
    end

    -- Fallback only when the original SkillAction weapon metadata is unavailable.
    local tool = getEquippedTool(character)
    if not tool then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if backpack and humanoid then
            for _, item in ipairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    pcall(function() humanoid:EquipTool(item) end)
                    break
                end
            end
        end
        return
    end
    pcall(function() tool:Activate() end)
end

local function tryNearbyQuestNPCs()
    if os.clock() - State.LastNPCCheck < 1.5 then return nil end
    State.LastNPCCheck = os.clock()
    local _, root = getCharacter()
    if not root then return nil end
    local allNPC = Workspace:FindFirstChild("AllNPC")
    local remote = ReplicatedStorage:FindFirstChild("Chest")
    remote = remote and remote:FindFirstChild("Remotes")
    remote = remote and remote:FindFirstChild("Functions")
    remote = remote and remote:FindFirstChild("CheckQuest")
    if not allNPC or not remote or not remote:IsA("RemoteFunction") then return nil end
    local candidates = {}
    for _, npc in ipairs(allNPC:GetChildren()) do
        if npc:IsA("BasePart") then
            local d = (root.Position - npc.Position).Magnitude
            if d < 10 then table.insert(candidates, {npc=npc, distance=d}) end
        end
    end
    table.sort(candidates, function(x,y) return x.distance < y.distance end)
    local requested
    for _, item in ipairs(candidates) do
        local ok = pcall(function() remote:InvokeServer(item.npc) end)
        if ok then requested = requested or item.npc.Name end
    end
    return requested
end

local function getNPCPart(npc)
    if not npc then return nil end
    if npc:IsA("BasePart") then return npc end
    if npc:IsA("Model") then
        local p = npc:FindFirstChild("HumanoidRootPart", true) or npc.PrimaryPart
        if p and p:IsA("BasePart") then return p end
        return npc:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function moveToNamedNPC(npcName)
    local allNPC = Workspace:FindFirstChild("AllNPC")
    local npc = allNPC and allNPC:FindFirstChild(npcName)
    local part = getNPCPart(npc)
    if not part then return true, "AllNPC에서 NPC를 찾지 못함: " .. tostring(npcName) end
    local _, root = getCharacter()
    if not root then return true, "캐릭터 대기 중" end
    if (root.Position - part.Position).Magnitude >= 10 then
        root.CFrame = part.CFrame
        return true, npcName .. " 이동 중"
    end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local loreGui = pg and pg:FindFirstChild("LoreGUI")
    local npcGui = pg and pg:FindFirstChild(npcName)
    local loreMap = {
        ["Lore Sea Sick!"]="I'm not,YOU ARE!", ["Lore Sea Diving"]="Under The Sea~",
        ["Lore Sea Madness"]="Catch me,If you can", ["Lore Bone Hunter"]="Bone Hunter",
        ["Lore Lost Fugitive"]="Redemption", ["Lore Puzzle First"]="Puzzle Mania",
        ["Lore the Depth"]="Rolling in the Depth", ["Lore Kraken Codex Easy"]="Krakenci Codes (Easy)",
        ["Lore The Bubble One"]="Hide'n Seek!", ["Lore Mossy Must Gone"]="Mossy Must Gone",
        ["Lore Into the Bubble-Verse"]="Into the Bubble-Verse", ["Lore The Pillar"]="The Pillar",
        ["Lore Kraken Codex Hard"]="Krakenci Codes (Hard)", ["Lore Until Pond"]="Until Pond",
        ["Lore Kraken Codex Medium"]="Krakenci Codes (Medium)",
    }
    local mapped = loreMap[npcName]
    local loreRemote = loreGui and loreGui:FindFirstChild("LOREGUI_REMOTE")
    if mapped and loreRemote and loreRemote:IsA("RemoteFunction") then
        local actionKey = "Lore|" .. npcName
        local lastAction = State.NPCActionAt[actionKey] or 0
        if os.clock() - lastAction < 4 then
            return true, "Lore 요청 전송 후 상태 확인 중 · " .. npcName
        end
        State.NPCActionAt[actionKey] = os.clock()
        local ok = pcall(function() loreRemote:InvokeServer({Quest=mapped}) end)
        return true, ok and ("Lore 요청 전송 · 서버 승인 미확인: " .. npcName)
            or ("Lore 요청 호출 실패 · 재시도 대기: " .. npcName)
    end
    local dialogue = npcGui and npcGui:FindFirstChild("Dialogue")
    local accept = dialogue and dialogue:FindFirstChild("Accept")
    if accept and (accept:IsA("TextButton") or accept:IsA("ImageButton")) then
        local actionKey = "Dialogue|" .. npcName
        local lastAction = State.NPCActionAt[actionKey] or 0
        if os.clock() - lastAction < 2 then
            return true, "대화 수락 요청 후 UI 반응 대기: " .. npcName
        end
        State.NPCActionAt[actionKey] = os.clock()
        local ok = pcall(function() accept:Activate() end)
        return true, ok and ("대화 수락 요청: " .. npcName) or ("대화 수락 호출 실패: " .. npcName)
    end
    local nearName = tryNearbyQuestNPCs()
    return true, nearName and ("CheckQuest 요청: " .. nearName) or (npcName .. " 근처 · 대화 UI 대기")
end

local function firePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    if type(fireproximityprompt) == "function" then return pcall(function() fireproximityprompt(prompt) end) end
    return pcall(function()
        prompt:InputHoldBegin()
        task.wait(math.max(prompt.HoldDuration, 0.1))
        prompt:InputHoldEnd()
    end)
end

local function getSpawnItems()
    local folder = Workspace:FindFirstChild("SpawnItem")
    return folder and folder:GetChildren() or {}
end

local function findSpawnItem(name)
    for _, item in ipairs(getSpawnItems()) do if item.Name == name then return item end end
    return nil
end

local function itemPart(item)
    if not item then return nil end
    if item:IsA("BasePart") then return item end
    return item:FindFirstChildWhichIsA("BasePart", true)
end

local function moveToItem(item)
    local _, root = getCharacter()
    local part = itemPart(item)
    if not root or not part then return false, "캐릭터/오브젝트 위치 파트 대기" end
    if (root.Position - part.Position).Magnitude > 8 then
        root.CFrame = part.CFrame
        return false, "오브젝트로 이동 중"
    end
    return true, "오브젝트 도착"
end

local function oneShotPrompt(title, item, prompt, waitBefore)
    if not item then return true, "오브젝트 대기: " .. title end

    local key = title .. "|" .. item:GetFullName()
    if State.SpecialDone[key] then
        -- If the target becomes active again, allow a fresh request.
        if not item.Parent or (prompt and not prompt.Enabled) then
            return true, "상호작용 완료 확인: " .. title
        end
        State.SpecialDone[key] = nil
    end

    if not item.Parent then
        State.SpecialDone[key] = true
        return true, "오브젝트 제거 확인: " .. title
    end

    if prompt and prompt:IsA("ProximityPrompt") and not prompt.Enabled then
        State.SpecialDone[key] = true
        return true, "프롬프트 비활성화 확인: " .. title
    end

    local arrived, msg = moveToItem(item)
    if not arrived then return true, msg end

    -- Delay is scoped to this exact target and starts only after arrival.
    -- It must not share the Codex/UI cooldown clock.
    if waitBefore then
        local waitUntil = State.SpecialWaitAt[key]
        if waitUntil == nil then
            waitUntil = os.clock() + waitBefore
            State.SpecialWaitAt[key] = waitUntil
            return true, "상호작용 준비 대기: " .. math.ceil(waitBefore) .. "초"
        elseif waitUntil > 0 and os.clock() < waitUntil then
            return true, "상호작용 준비 대기: " .. math.ceil(waitUntil-os.clock()) .. "초"
        else
            -- 0 means the initial delay has already elapsed; do not restart it
            -- after every unconfirmed prompt request.
            State.SpecialWaitAt[key] = 0
        end
    end

    if not prompt or not prompt:IsA("ProximityPrompt") then
        return true, "ProximityPrompt 대기: " .. title
    end
    if not prompt.Enabled then
        State.SpecialDone[key] = true
        return true, "프롬프트 비활성화 확인: " .. title
    end

    local lastAttempt = State.SpecialAttempts[key] or 0
    if os.clock() - lastAttempt < 2.0 then
        return true, "서버 반응 확인 대기: " .. title
    end

    local called = firePrompt(prompt)
    if called then
        -- pcall success only means the client call did not throw. It does NOT
        -- prove that the server accepted the quest interaction. Retry after a
        -- cooldown until the prompt is disabled or the target disappears.
        State.SpecialAttempts[key] = os.clock()
        State.SpecialAt = os.clock() + 0.8
        return true, "상호작용 요청 전송 · 서버 확인 대기: " .. title
    end
    State.SpecialAttempts[key] = os.clock()
    return true, "프롬프트 요청 실패 · 재시도 대기: " .. title
end

local CODEX = {
    ["Solving Kraken's Codex (Easy)"]={"Fallen","Dark","Heroic"},
    ["Solving Kraken's Codex (Medium)"]={"Moon","Savior","Bright"},
    ["Solving Kraken's Codex (Hard)"]={"Fearful","Moon","Night"},
}

local function handleCodex(title)
    local _, msg = moveToNamedNPC("Lore Kraken Codex Giver")
    local _, root = getCharacter()
    local allNPC = Workspace:FindFirstChild("AllNPC")
    local giver = allNPC and allNPC:FindFirstChild("Lore Kraken Codex Giver")
    local part = getNPCPart(giver)
    if not part or not root or (root.Position-part.Position).Magnitude >= 10 then return true, msg end
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local libs = pg and pg:FindFirstChild("LeePungg_PuzzleLibs")
    local puzzleRemote = libs and libs:FindFirstChild("PuzzleRemote")
    if puzzleRemote and puzzleRemote:IsA("RemoteFunction") then
        local key = "CodexSubmit|" .. title
        local lastAttempt = State.CodexAttempts[key] or 0
        if os.clock() - lastAttempt < 8 then
            return true, "Codex 제출 요청 후 서버/퀘스트 상태 확인 중"
        end
        local answers = CODEX[title]
        local ok, result = pcall(function()
            return puzzleRemote:InvokeServer("Submit", answers)
        end)
        State.CodexAttempts[key] = os.clock()
        if ok then
            -- Client call success is not proof of server-side acceptance.
            return true, "Codex 제출 요청 전송 · 서버 승인 미확인: " .. table.concat(answers, " / ")
        end
        return true, "PuzzleRemote 호출 오류 · 재시도 대기"
    end
    local loreGui = pg and pg:FindFirstChild("LoreGUI")
    local loreRemote = loreGui and loreGui:FindFirstChild("LOREGUI_REMOTE")
    if loreRemote and loreRemote:IsA("RemoteFunction") and os.clock()-State.SpecialAt > 2 then
        pcall(function() loreRemote:InvokeServer({Quest="Krakenci Codes", Gui="PuzzleLibs"}) end)
        State.SpecialAt = os.clock()
        return true, "Codex 퍼즐 UI 요청 중"
    end
    return true, "Codex 퍼즐 UI 대기"
end

local function handleAllSpawnItems(title, objectName, promptName, predicate, waitBefore)
    local found = false
    local targets = {}
    local _, root = getCharacter()

    -- Process one nearest unfinished object per loop. The previous build could
    -- teleport from object to object in a single pass and repeatedly restart
    -- interaction on the first target before the server had updated it.
    for _, item in ipairs(getSpawnItems()) do
        if item.Name == objectName and (not predicate or predicate(item)) then
            found = true
            local prompt = item:FindFirstChild(promptName)
            local key = title .. "|" .. item:GetFullName()
            if prompt and prompt:IsA("ProximityPrompt") and not prompt.Enabled then
                State.SpecialDone[key] = true
                State.SpecialWaitAt[key] = nil
            else
                if State.SpecialDone[key] and prompt and prompt.Enabled then
                    State.SpecialDone[key] = nil
                end
                if not State.SpecialDone[key] then
                    local part = itemPart(item)
                    local distance = (root and part) and (root.Position - part.Position).Magnitude or math.huge
                    table.insert(targets, {item=item, prompt=prompt, distance=distance})
                end
            end
        end
    end

    table.sort(targets, function(a, b) return a.distance < b.distance end)
    if #targets > 0 then
        local target = targets[1]
        return oneShotPrompt(title, target.item, target.prompt, waitBefore)
    end
    if found then return true, "대상 프롬프트 비활성화 확인 · 완료 대기: " .. title end
    return true, "대상 오브젝트 대기: " .. objectName
end

local function handleSpecialQuest(title)
    if CODEX[title] then return handleCodex(title) end
    if title == "Find out Where's 'Old Man'" then
        return moveToNamedNPC("Civilian Old")
    elseif title == "Deliver a Boxes" then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild(LocalPlayer.Name .. "QuestBox") then return moveToNamedNPC("Civilian Port") end
        local box = findSpawnItem("Box")
        return oneShotPrompt(title, box, box and box:FindFirstChild("ProximityPrompt"))
    elseif title == "Ancient Book" then
        local island = Workspace:FindFirstChild("Island")
        local fiore = island and island:FindFirstChild("H - Fiore")
        local book = fiore and fiore:FindFirstChild("Lost Book")
        local main = book and book:FindFirstChild("Main")
        return oneShotPrompt(title, main, main and main:FindFirstChild("ProximityPrompt"))
    elseif title == "Tear down all Cultist's Poster" then
        return handleAllSpawnItems(title, "PosterQuest", "ProximityPrompt", function(item)
            local decal = item:FindFirstChild("Decal")
            return decal ~= nil and decal.Transparency == 0
        end)
    elseif title == "Floating Feather" then
        return handleAllSpawnItems(title, "Floating Feather", "ProximityPrompt")
    elseif title == "Walk to Objective!" then
        local item = findSpawnItem("I'm not,YOU ARE!")
        if not item or not item:FindFirstChild("LeePunggQuestTracker") then return true, "Objective/Tracker 대기" end
        local key = title .. "|" .. item:GetFullName()
        if State.SpecialDone[key] then
            return true, "Objective 위치 도착 · 퀘스트 진행 반응 대기"
        end
        local arrived, msg = moveToItem(item)
        if arrived then
            State.SpecialDone[key] = true
            return true, "Objective 위치 도착 · 퀘스트 진행 반응 대기"
        end
        return true, msg
    elseif title == "Just Dive?" then
        for _, item in ipairs(getSpawnItems()) do
            if item.Name == "Under The Sea~" and item:FindFirstChild("LeePunggQuestTracker") then
                local arrived, msg = moveToItem(item)
                return true, arrived and "Dive Objective 위치 도착" or msg
            end
        end
        return true, "Under The Sea~/Tracker 대기"
    elseif title == "His treasure or my precious?" then
        return handleAllSpawnItems(title, "Catch me,If you can", "PromptQuest")
    elseif title == "Find the lost bone" then
        return handleAllSpawnItems(title, "Bone Hunter", "PromptQuest", function(item)
            return not item:IsA("BasePart") or item.Transparency == 0
        end)
    elseif title == "Hide?" then
        return handleAllSpawnItems(title, "Hide'n Seek!", "PromptQuest", nil, 3)
    elseif title == "Remove Mosses" then
        return handleAllSpawnItems(title, "Mossy Must Gone", "PromptQuest", function(item)
            local prompt = item:FindFirstChild("PromptQuest")
            return prompt and prompt.Enabled == true
        end)
    elseif title == "Investigate Stranded Pillar?" then
        return handleAllSpawnItems(title, "The Pillar", "PromptQuest")
    end
    return false, nil
end

-- GUI
local function getGuiRoot()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end
    return CoreGui
end

local guiRoot = getGuiRoot()
local oldGui = guiRoot:FindFirstChild("KL_LevelFarm_Rebuilt_23")
if oldGui then pcall(function() oldGui:Destroy() end) end
local Gui = Instance.new("ScreenGui")
Gui.Name = "KL_LevelFarm_Rebuilt_23"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local okParent = pcall(function() Gui.Parent = guiRoot end)
if not okParent then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(340, 280)
Main.Position = UDim2.new(0, 24, 0.34, 0)
Main.BackgroundColor3 = Color3.fromRGB(24, 29, 38)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 9)
corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -16, 0, 30)
Title.Position = UDim2.fromOffset(8, 4)
Title.BackgroundTransparency = 1
Title.Text = "KING LEGACY  |  LEVEL FARM 23"
Title.TextColor3 = Color3.fromRGB(230, 240, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.Parent = Main

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -18, 0, 94)
Status.Position = UDim2.fromOffset(9, 39)
Status.BackgroundColor3 = Color3.fromRGB(15, 19, 26)
Status.TextColor3 = Color3.fromRGB(190, 220, 205)
Status.Font = Enum.Font.Gotham
Status.TextSize = 10
Status.TextWrapped = true
Status.TextYAlignment = Enum.TextYAlignment.Center
Status.Text = "준비 중..."
Status.Parent = Main
local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = Status

local function makeButton(text, x, y, width, color)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(width, 32)
    button.Position = UDim2.fromOffset(x, y)
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Parent = Main
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = button
    return button
end

local StartButton = makeButton("START", 10, 145, 82, Color3.fromRGB(34, 145, 94))
local StopButton = makeButton("STOP", 102, 145, 82, Color3.fromRGB(170, 65, 65))
local NPCButton = makeButton("AUTO NPC: ON", 194, 145, 88, Color3.fromRGB(55, 105, 160))

local NPCNameBox = Instance.new("TextBox")
NPCNameBox.Size = UDim2.fromOffset(152, 28)
NPCNameBox.Position = UDim2.fromOffset(10, 184)
NPCNameBox.BackgroundColor3 = Color3.fromRGB(35, 43, 55)
NPCNameBox.TextColor3 = Color3.fromRGB(235, 240, 250)
NPCNameBox.PlaceholderColor3 = Color3.fromRGB(145, 155, 170)
NPCNameBox.PlaceholderText = "NPC 실제 이름 입력"
NPCNameBox.Text = ""
NPCNameBox.ClearTextOnFocus = false
NPCNameBox.Font = Enum.Font.Gotham
NPCNameBox.TextSize = 10
NPCNameBox.Parent = Main
local npcBoxCorner = Instance.new("UICorner")
npcBoxCorner.CornerRadius = UDim.new(0, 5)
npcBoxCorner.Parent = NPCNameBox
local NextNPCButton = makeButton("NEXT", 170, 182, 72, Color3.fromRGB(75, 115, 145))
local GoNPCButton = makeButton("GO NPC", 248, 182, 82, Color3.fromRGB(110, 90, 155))
local ScanButton = makeButton("SCAN NPC / QUEST", 10, 220, 320, Color3.fromRGB(65, 105, 125))

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -16, 0, 18)
Footer.Position = UDim2.fromOffset(8, 256)
Footer.BackgroundTransparency = 1
Footer.Text = "SCAN은 NPC 정보만 표시 · 레벨별 자동 매핑은 미확정"
Footer.TextColor3 = Color3.fromRGB(145, 155, 170)
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 9
Footer.Parent = Main

local function setStatus(text)
    pcall(function() Status.Text = text end)
end

local function farmLoop(token)
    while State.Running and State.LoopToken == token do
        local ok, err = pcall(function()
            local level = getLevel()
            if not level then
                setStatus("레벨 인식 실패\nPlayerStats.lvl / leaderstats 확인 필요")
                return
            end
            local entry = getQuestEntry(level)
            if not entry then
                setStatus("퀘스트 데이터 없음\nPlaceId: " .. tostring(game.PlaceId) .. " | Lv." .. tostring(level))
                return
            end

            local character, root, humanoid = getCharacter()
            if not character or not root or not humanoid or humanoid.Health <= 0 then
                setStatus("리스폰 대기 중...\n캐릭터가 다시 생성되면 자동 재개")
                return
            end

            local boardVisible, boardTitle = getQuestBoard()
            if boardVisible then
                -- Re-accepting the same quest after its board closed must create
                -- a fresh interaction cycle, even when the title is unchanged.
                if not State.LastBoardVisible or State.LastBoardTitle ~= boardTitle then
                    State.SpecialDone = {}
                    State.SpecialAttempts = {}
                    State.SpecialWaitAt = {}
                    State.CodexAttempts = {}
                    State.SpecialAt = 0
                end
                State.LastBoardTitle = boardTitle
            elseif State.LastBoardVisible then
                State.SpecialDone = {}
                State.SpecialAttempts = {}
                State.SpecialWaitAt = {}
                State.CodexAttempts = {}
                State.SpecialAt = 0
                State.LastBoardTitle = nil
            end
            State.LastBoardVisible = boardVisible
            if boardVisible then
                local specialHandled, specialMessage = handleSpecialQuest(boardTitle)
                if specialHandled then
                    setStatus("특수 퀘스트 처리 중\n" .. tostring(specialMessage))
                    return
                end
            end

            if not boardVisible then
                if State.AutoNPC then
                    local manualName = string.gsub(State.ManualNPC or "", "^%s*(.-)%s*$", "%1")
                    if manualName ~= "" then
                        local _, message = moveToNamedNPC(manualName)
                        setStatus("NPC 퀘스트 진행\n" .. tostring(message))
                    else
                        local npcName = tryNearbyQuestNPCs()
                        setStatus(npcName and ("근처 NPC에 CheckQuest 호출\n" .. npcName .. " (서버 승인 미확인)")
                            or "퀘스트 NPC 대기 중\nNPC 이름 입력 후 GO NPC를 누르거나 직접 수락해줘")
                    end
                else
                    setStatus("퀘스트 대기 중\nAUTO NPC를 켜거나 직접 수락해줘")
                end
                return
            end

            entry = getEntryForBoard(level, boardTitle) or entry
            if not questTitleMatches(boardTitle, entry.mob) then
                setStatus("퀘스트 불일치 - 공격 중지\n현재: " .. string.sub(boardTitle, 1, 42) .. "\n필요 대상: " .. entry.mob)
                return
            end

            local model, mobHum, mobRoot, findError = findMonster(boardTitle, entry.mob)
            if model and mobHum and mobRoot then
                local distance = (root.Position - mobRoot.Position).Magnitude
                if distance > 24 and os.clock() - State.LastMove > 1.2 then
                    root.CFrame = mobRoot.CFrame * CFrame.new(0, 8, 5)
                    State.LastMove = os.clock()
                end
                attackOnce(character, mobRoot)
                State.LastTarget = model.Name
                setStatus("사냥 중 | Lv." .. level .. "\n" .. entry.mob .. " | 거리 " .. math.floor(distance) .. "\n" .. string.sub(boardTitle, 1, 38))
            else
                if os.clock() - State.LastMove > 4 then
                    root.CFrame = CFrame.new(entry.x, entry.y + 10, entry.z)
                    State.LastMove = os.clock()
                end
                setStatus("몬스터 탐색 중 | Lv." .. level .. "\n" .. entry.mob .. "\n" .. tostring(findError or "스폰 대기") .. " · 좌표 이동")
            end
        end)
        if not ok then setStatus("오류: " .. tostring(err):sub(1, 100)) end
        task.wait(0.25)
    end
end

StartButton.MouseButton1Click:Connect(function()
    if State.Running then return end
    State.Running = true
    State.LoopToken = State.LoopToken + 1
    local token = State.LoopToken
    setStatus("시작됨\n레벨 및 퀘스트 상태 확인 중...")
    task.spawn(farmLoop, token)
end)

local NPCListIndex = 0
local function getSelectableNPCNames()
    local allNPC = Workspace:FindFirstChild("AllNPC")
    local names = {}
    if not allNPC then return names end
    for _, npc in ipairs(allNPC:GetChildren()) do
        local name = npc.Name
        local lower = string.lower(name)
        local excluded =
            string.find(lower, "setspawn", 1, true) ~= nil
            or string.find(lower, "progre", 1, true) ~= nil
            or (string.find(lower, "quest", 1, true) ~= nil and string.find(lower, "daily", 1, true) == nil)
            or string.find(lower, "buyships", 1, true) ~= nil
        if not excluded then table.insert(names, name) end
    end
    table.sort(names)
    return names
end

-- Diagnostic only: report live NPC names/types/distances and current quest state.
-- This deliberately does not guess which NPC belongs to the player's level.
local function scanNPCAndQuestState()
    local level = getLevel()
    local boardVisible, boardTitle = getQuestBoard()
    local _, root = getCharacter()
    local allNPC = Workspace:FindFirstChild("AllNPC")
    local rows = {}
    if allNPC and root then
        for _, npc in ipairs(allNPC:GetChildren()) do
            local part = getNPCPart(npc)
            if part then
                local distance = (root.Position - part.Position).Magnitude
                table.insert(rows, {name=npc.Name, class=npc.ClassName, distance=distance})
            end
        end
        table.sort(rows, function(a,b) return a.distance < b.distance end)
    end
    local lines = {
        "진단 결과 (NPC 자동 선택 아님)",
        "PlaceId: " .. tostring(game.PlaceId) .. " | Level: " .. tostring(level or "인식 실패"),
        "QuestBoard: " .. (boardVisible and (boardTitle ~= "" and boardTitle or "표시/제목 없음") or "없음/숨김"),
        "AllNPC: " .. tostring(allNPC and #allNPC:GetChildren() or 0) .. "개 | 위치 파트 탐색: " .. tostring(#rows) .. "개"
    }
    for i = 1, math.min(5, #rows) do
        local r = rows[i]
        table.insert(lines, string.format("%d) %s [%s] %.1f studs", i, r.name, r.class, r.distance))
    end
    if #rows == 0 then table.insert(lines, "근처 NPC 정보 없음 (캐릭터/AllNPC/파트 확인)") end
    setStatus(table.concat(lines, "\n"))
end

ScanButton.MouseButton1Click:Connect(scanNPCAndQuestState)

NextNPCButton.MouseButton1Click:Connect(function()
    local names = getSelectableNPCNames()
    if #names == 0 then
        setStatus("Workspace.AllNPC에서 선택 가능한 NPC를 찾지 못함")
        return
    end
    NPCListIndex = (NPCListIndex % #names) + 1
    NPCNameBox.Text = names[NPCListIndex]
    State.ManualNPC = NPCNameBox.Text
    setStatus("NPC 선택 " .. NPCListIndex .. "/" .. #names .. "\n" .. NPCNameBox.Text)
end)

NPCNameBox:GetPropertyChangedSignal("Text"):Connect(function()
    State.ManualNPC = NPCNameBox.Text
end)
GoNPCButton.MouseButton1Click:Connect(function()
    State.ManualNPC = NPCNameBox.Text
    local name = string.gsub(State.ManualNPC or "", "^%s*(.-)%s*$", "%1")
    if name == "" then setStatus("NPC 이름을 입력해줘"); return end
    local _, message = moveToNamedNPC(name)
    setStatus(tostring(message))
end)

StopButton.MouseButton1Click:Connect(function()
    State.Running = false
    State.LoopToken = State.LoopToken + 1
    setStatus("정지됨")
end)

NPCButton.MouseButton1Click:Connect(function()
    State.AutoNPC = not State.AutoNPC
    NPCButton.Text = State.AutoNPC and "AUTO NPC: ON" or "AUTO NPC: OFF"
    NPCButton.BackgroundColor3 = State.AutoNPC and Color3.fromRGB(55, 105, 160) or Color3.fromRGB(90, 90, 90)
end)

LocalPlayer.CharacterAdded:Connect(function()
    State.LastMove = 0
    State.LastNPCCheck = 0
    if State.Running then setStatus("리스폰 감지\n캐릭터 재연결 중...") end
end)

setStatus("준비 완료\nLv. 자동 인식 | 퀘스트 먼저 수락 후 START")
