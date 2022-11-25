local QBCore = exports['qb-core']:GetCoreObject()


CreateThread(function()
    while true do
        Wait(10)
        if QBCore == nil then
            TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
            Wait(200)
        end
    end
end)

local PlayerData = {}

RegisterNetEvent('QBCore:playerLoaded')
AddEventHandler('QBCore:playerLoaded', function(xPlayer)
  PlayerData = xPlayer   
end)

local group = "user"
RegisterNetEvent('es_admin:setGroup')
AddEventHandler('es_admin:setGroup', function(g)
	group = g
end)

---------------------------------------------------------

local ST = ST or {}
ST.Scoreboard = {}
ST._Scoreboard = {}

ST.Scoreboard.Menu = {}

ST._Scoreboard.Players = {}
ST._Scoreboard.Recent = {}
ST._Scoreboard.SelectedPlayer = nil
ST._Scoreboard.MenuOpen = false
ST._Scoreboard.Menus = {}

local function spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function ST.Scoreboard.AddPlayer(self, data)
    ST._Scoreboard.Players[data.src] = data
end

function ST.Scoreboard.RemovePlayer(self, data)
    ST._Scoreboard.Players[data.src] = nil
    ST._Scoreboard.Recent[data.src] = data
end

function ST.Scoreboard.RemoveRecent(self, src)
    ST._Scoreboard.Recent[src] = nil
end

function ST.Scoreboard.AddAllPlayers(self, data)
    ST._Scoreboard.Players[data.src] = data
    -- ST._Scoreboard.Recent[recentData.src] = recentData
end

function ST.Scoreboard.GetPlayerCount(self)
    local count = 0

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then count = count + 1 end
    end

    return count
end

PoliceCount = 0
EMSCount = 0
Dealer = 0
Mechanic = 0

CreateThread(function()
    local function DrawMain()
        QBCore.Functions.TriggerCallback('GetPolice:server:ScoreBoard', function(cops, ambulance, cardealer, mecha)
            Wait(2000)
            PoliceCount = cops
            EMSCount = ambulance
            Dealer = cardealer
            Mechanic = Mechanic
        end)

        if PoliceCount ~= nil then 
            if PoliceCount >= 1 then
                store = "✔"
            else
                store =  "✖"
            end

            if PoliceCount >= 4 then
                flecca = "✔"
            else
                flecca =  "✖"
            end

            if PoliceCount >= 5 then
                pacific = "✔"
            else
                pacific =  "✖"
            end

            if PoliceCount >= 4 then
                jewel = "✔"
            else
                jewel =  "✖"
            end
        end

        if WarMenu.Button("Total:", tostring(ST.Scoreboard:GetPlayerCount()), {r = 135, g = 206, b = 250, a = 150}) then end
        if WarMenu.MenuButton("Job Information", "job", {r = 0, g = 0, b = 0, a = 150}) then end
        if WarMenu.MenuButton("Robbery Information", "robbery", {r = 0, g = 0, b = 0, a = 150}) then end

      --  print(ST._Scoreboard.Players)
        for k,v in pairs(ST._Scoreboard.Players) do
        --    print(k)
        --    print(v)
        end
        for k,v in spairs(ST._Scoreboard.Players, function(t, a, b) return t[a].src < t[b].src end) do
        --    print(k)
         --   print(v)
            local playerId = GetPlayerFromServerId(v.src)

            if NetworkIsPlayerActive(playerId) or GetPlayerPed(playerId) == GetPlayerPed(-1) then
                if WarMenu.MenuButton("[" .. v.src .. "] " .. v.steamid .. " ", "options") then ST._Scoreboard.SelectedPlayer = v end
            else
                if WarMenu.MenuButton("[" .. v.src .. "] - instanced?", "options", {r = 255, g = 0, b = 0, a = 255}) then ST._Scoreboard.SelectedPlayer = v end
            end
        end

        
        if WarMenu.MenuButton("Recent Disconnects", "recent", {r = 0, g = 0, b = 0, a = 150}) then
        end
    end

    local function DrawRecent()
        for k,v in spairs(ST._Scoreboard.Recent, function(t, a, b) return t[a].src < t[b].src end) do
            if WarMenu.MenuButton("[" .. v.src .. "] " .. v.name, "options") then ST._Scoreboard.SelectedPlayer = v end
        end
    end

    local function DrawOptions()
        if WarMenu.Button("Server ID:", ST._Scoreboard.SelectedPlayer.src) then end
        if WarMenu.Button("Community ID:", ST._Scoreboard.SelectedPlayer.comid) then end
        if WarMenu.Button("Steam Name:", ST._Scoreboard.SelectedPlayer.name) then end
        if WarMenu.Button("Ping:", ST._Scoreboard.SelectedPlayer.pong) then end
    end

    local function JobOptions()
        if WarMenu.Button("Police:", tostring(PoliceCount), {r = 135, g = 206, b = 250, a = 175}) then end
        if WarMenu.Button("EMS:", tostring(EMSCount), {r = 255, g = 182, b = 193, a = 150}) then end
        if WarMenu.Button("Car Dealer:", tostring(Dealer), {r = 135, g = 0, b = 0, a = 150}) then end
        if WarMenu.Button("Mechanic:", tostring(Mechanic), {r = 255, g = 255, b = 0, a = 150}) then end
    end

    local function RobOptions()
        if WarMenu.Button("Store Robbery:", store, {r = 135, g = 206, b = 250, a = 175}) then end
        if WarMenu.Button("Pacific Robbery:", pacific, {r = 135, g = 206, b = 250, a = 175}) then end
        if WarMenu.Button("Flecca Robbery:", flecca, {r = 135, g = 206, b = 250, a = 175}) then end
        if WarMenu.Button("Jewellery Robbery:", jewel, {r = 135, g = 206, b = 250, a = 175}) then end
    end

    ST._Scoreboard.Menus = {
        ["scoreboard"] = DrawMain,
        ["recent"] = DrawRecent,
        ["options"] = DrawOptions,
        ["job"] = JobOptions,
        ["robbery"] = RobOptions
    }

    local function Init()
        WarMenu.CreateMenu("scoreboard", "Players Info")
        WarMenu.SetSubTitle("scoreboard", "Players")

        WarMenu.SetMenuWidth("scoreboard", 0.5)
        WarMenu.SetMenuX("scoreboard", 0.71)
        WarMenu.SetMenuY("scoreboard", 0.017)
        WarMenu.SetMenuMaxOptionCountOnScreen("scoreboard", 30)
        WarMenu.SetTitleColor("scoreboard", 135, 206, 250, 255)
        WarMenu.SetTitleBackgroundColor("scoreboard", 0 , 0, 0, 150)
        WarMenu.SetMenuBackgroundColor("scoreboard", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("scoreboard", 255, 255, 255, 255)

        WarMenu.CreateSubMenu("recent", "scoreboard", "Recent D/C's")
        WarMenu.SetMenuWidth("recent", 0.5)
        WarMenu.SetTitleColor("recent", 135, 206, 250, 255)
        WarMenu.SetTitleBackgroundColor("recent", 0 , 0, 0, 150)
        WarMenu.SetMenuBackgroundColor("recent", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("recent", 255, 255, 255, 255)

        WarMenu.CreateSubMenu("options", "scoreboard", "User Info")
        WarMenu.SetMenuWidth("options", 0.5)
        WarMenu.SetTitleColor("options", 135, 206, 250, 255)
        WarMenu.SetTitleBackgroundColor("options", 0 , 0, 0, 150)
        WarMenu.SetMenuBackgroundColor("options", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("options", 255, 255, 255, 255)

        WarMenu.CreateSubMenu("job", "scoreboard", "")
        WarMenu.SetMenuWidth("job", 0.5)
        WarMenu.SetTitleColor("job", 135, 206, 250, 255)
        WarMenu.SetTitleBackgroundColor("job", 0 , 0, 0, 150)
        WarMenu.SetMenuBackgroundColor("job", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("job", 255, 255, 255, 255)

        WarMenu.CreateSubMenu("robbery", "scoreboard", "")
        WarMenu.SetMenuWidth("robbery", 0.5)
        WarMenu.SetTitleColor("robbery", 135, 206, 250, 255)
        WarMenu.SetTitleBackgroundColor("robbery", 0 , 0, 0, 150)
        WarMenu.SetMenuBackgroundColor("robbery", 0, 0, 0, 100)
        WarMenu.SetMenuSubTextColor("robbery", 255, 255, 255, 255)
    end

    Init()
    timed = 0
    while true do
        for k,v in pairs(ST._Scoreboard.Menus) do
            if WarMenu.IsMenuOpened(k) then
                v()
                WarMenu.Display()
            else
                if timed > 0 then
                    timed = timed - 1
                end
            end
        end

        Wait(1)
    end

    

end)

function ST.Scoreboard.Menu.Open(self)
    ST._Scoreboard.SelectedPlayer = nil
    if not IsPedInAnyVehicle(PlayerPedId(),true) and not (QBCore.Functions.GetPlayerData().metadata["isdead"]) and not (QBCore.Functions.GetPlayerData().metadata["inlaststand"]) then
        TriggerEvent('animations:client:EmoteCommandStart', {"clipboard"})   
    end   
    WarMenu.OpenMenu("scoreboard")
    shouldDraw = true
end

function ST.Scoreboard.Menu.Close(self)
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    ClearPedTasks(GetPlayerPed(-1))
    for k,v in pairs(ST._Scoreboard.Menus) do
        WarMenu.CloseMenu(K)        
        shouldDraw =false    
    end
end




CreateThread(function()
    local function IsAnyMenuOpen()
        for k,v in pairs(ST._Scoreboard.Menus) do
            if WarMenu.IsMenuOpened(k) then return true end
        end

        return false
    end

    while true do
        Wait(0)
        if IsControlPressed(0, 303) then
           -- print("something pressed")
            if not IsAnyMenuOpen() then
                ST.Scoreboard.Menu:Open()
            end
        else
            if IsAnyMenuOpen() then ST.Scoreboard.Menu:Close() end
            Wait(100)
        end
    end
end)

RegisterNetEvent("st-scoreboard:RemovePlayer")
AddEventHandler("st-scoreboard:RemovePlayer", function(data)
    ST.Scoreboard:RemovePlayer(data)
end)

RegisterNetEvent("st-scoreboard:AddPlayer")
AddEventHandler("st-scoreboard:AddPlayer", function(data)
   -- print("add player client")
    ST.Scoreboard:AddPlayer(data)
end)

RegisterNetEvent("st-scoreboard:RemoveRecent")
AddEventHandler("st-scoreboard:RemoveRecent", function(src)
    ST.Scoreboard:RemoveRecent(src)
end)

RegisterNetEvent("st-scoreboard:AddAllPlayers")
AddEventHandler("st-scoreboard:AddAllPlayers", function(data, recentData)
    ST.Scoreboard:AddAllPlayers(data, recentData)
end)

-----------------------------
-- Player IDs Above Head
-----------------------------


CreateThread(function()
    while true do
        TriggerServerEvent("st-scoreboard:GiveMePlayers")
        Wait(5*1000)
    end
end)

--Draw Things
CreateThread(function()
    while true do
        Wait(0)

        if shouldDraw or forceDraw then
            local nearbyPlayers = GetNeareastPlayers()
            for k, v in pairs(nearbyPlayers) do
                local x, y, z = table.unpack(v.coords)
                Draw3DText(x, y, z + 1.05, v.playerId)
            end
        end
    end
end)


function Draw3DText(x, y, z, text)
    -- Check if coords are visible and get 2D screen coords
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        -- Calculate text scale to use
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = 1.4 * (1 / dist) * (1 / GetGameplayCamFov()) * 100

        -- Draw text on screen
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


function GetNeareastPlayers()
	local playerPed = PlayerPedId()
	local playerlist = GetActivePlayers()
   --local players, _ = ESX.Game.GetPlayersInArea(GetEntityCoords(playerPed), Config.DrawDistance)

    local players_clean = {}
    local found_players = false

    for i = 1, #playerlist, 1 do
        found_players = true
        table.insert(players_clean, { playerName = GetPlayerName(playerlist[i]), playerId = GetPlayerServerId(playerlist[i]), coords = GetEntityCoords(GetPlayerPed(playerlist[i])) })
    end
    return players_clean
end

