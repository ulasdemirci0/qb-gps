QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Server:UpdateObject', function()
    if source ~= '' then return false end
    QBCore = exports['qb-core']:GetCoreObject()
end)

local Units = {}


QBCore.Functions.CreateCallback('fizzfau-gps:getData', function(source, cb)
    for k, v in pairs(Units) do
        if v.ped then
            Units[k].coords = GetEntityCoords(v.ped)
            Units[k].inVehicle = GetVehiclePedIsIn(v.ped, false) ~= 0
            if GetVehiclePedIsIn(v.ped, false) ~= 0 then
                Units[k].isSirenActive = IsVehicleSirenOn(GetVehiclePedIsIn(v.ped, false))
            end
        end
    end
    cb(Units)
end)


RegisterServerEvent("fizzfau-gps:dropGPS")
AddEventHandler("fizzfau-gps:dropGPS", function(_source)
    local src = _source or source
    if Units[src] ~= nil then
        Units[src] = nil
        TriggerClientEvent('ox_lib:notify', src, {
            description = Config.Locales["gps_closed"],
            type = 'error',
            position = 'center-right'
        })

        TriggerClientEvent("fizzfau-gps:client:dropGPS", -1, src)
    end
end)

RegisterNetEvent("fizzfau-gps:connectGps")
AddEventHandler("fizzfau-gps:connectGps", function(callsign)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local count = exports.ox_inventory:GetItemCount(src, "gps", {}, false)
    if count ~= nil and count > 0 then
        Units[player.PlayerData.source] = {
            ped = GetPlayerPed(src),
            job = player.PlayerData.job.name,
            code = callsign,
            name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        }
        TriggerClientEvent('ox_lib:notify', src, {
            description = Config.Locales["gps_opened"],
            type = 'success',
            position = 'center-right'
        })

        TriggerClientEvent("fizzfau-gps:client:connectGps", src)
    end
end)

AddEventHandler("playerDropped", function(reason)
    TriggerEvent("fizzfau-gps:dropGPS", source)
end)






AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if GetResourceState('ox_inventory') ~= 'started' then
        print('^1[magne_gps] ^0ox_inventory is not started.')
        return
    end
    exports.ox_inventory:registerHook(
        'swapItems',
        function(payload)
            if payload.fromInventory ~= payload.toInventory and payload.fromInventory == payload.source then
                local src = payload.source
                if Units[src] ~= nil then
                    Units[src] = nil
                    TriggerClientEvent('ox_lib:notify', src, {
                        description = Config.Locales["gps_closed"],
                        type = 'error',
                        position = 'center-right'
                    })

                    TriggerClientEvent("fizzfau-gps:client:dropGPS", -1, src)
                end
            end
        end,
        {
            itemFilter = {
                ["gps"] = true
            }
        }
    )
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end
    exports.ox_inventory:removeHooks()
end)
