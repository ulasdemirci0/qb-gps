QBCore = exports['qb-core']:GetCoreObject()
RegisterNetEvent('QBCore:Client:UpdateObject', function()
	QBCore = exports['qb-core']:GetCoreObject()
end)

local blips = {}
local retval = false
local usingGps = false
Callsign = ''
exports('toggleGPS', function(data, slot)
	local menu = GpsMenu()
	if menu then
		local gpsStatus = menu[1]
		if not usingGps and gpsStatus == "on" then
			TriggerServerEvent("fizzfau-gps:connectGps", menu[2])
			usingGps = true
			Callsign = menu[2]
		else
			usingGps = false
			Callsign = ""
			TriggerServerEvent("fizzfau-gps:dropGPS")
		end
	end
end)

function CreateBlipThread()
	retval = true
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(Config.UpdateTick)
			if not retval then
				return
			end
			QBCore.Functions.TriggerCallback('fizzfau-gps:getData', function(Units)
				CreateBlips(Units)
			end)
		end
	end)
end

RegisterNetEvent("fizzfau-gps:client:connectGps")
AddEventHandler("fizzfau-gps:client:connectGps", function()
	CreateBlipThread()
end)

RegisterNetEvent("fizzfau-gps:client:dropGPS")
AddEventHandler("fizzfau-gps:client:dropGPS", function(id)
	Callsign = ""
	if id == GetPlayerServerId(PlayerId()) then
		retval = false
		RemoveExistingBlips()
	end
	if blips[id] then
		RemoveBlip(blips[id])
		blips[id] = nil
	end
end)

function CreateBlips(Units)
	for k, v in pairs(Units) do
		if v ~= nil then
			local blip
			if k ~= GetPlayerServerId(PlayerId()) or Config.ShowYourself then
				if not DoesBlipExist(blips[k]) then
					blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
					-- SetBlipShowCone(blip, true)
					-- SetPedAiBlipHasCone(blip ,true)
					blips[k] = blip
				else
					SetBlipCoords(blips[k], v.coords.x, v.coords.y, v.coords.z)
				end
				SetBlipSprite(blips[k],
					(v.inVehicle == true and Config.VehicleBlips and v.isSirenActive ~= false) and 42 or
					Config.Jobs[v.job].sprite)
				SetBlipColour(blips[k], Config.Jobs[v.job].color)
				SetBlipScale(blips[k],
					((v.inVehicle == true and Config.VehicleBlips) and 0.6 or Config.Jobs[v.job].scale) or 0.8)
				SetBlipAsShortRange(blips[k], true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(v.code ~= nil and v.code or Config.Locales["unknown"] .. " | " .. v.name)
				EndTextCommandSetBlipName(blips[k])
			end
		end
	end
end

function RemoveExistingBlips()
	for k, v in pairs(blips) do
		if DoesBlipExist(v) then
			RemoveBlip(v)
			blips[k] = nil
		end
	end
end

function GpsMenu()
	local menu = lib.inputDialog('GPS Sistemi', {
		{
			type = 'select',
			label = "GPS Durumu",
			icon = "hashtag",
			required = true,
			options = { { label = "Aç", value = "on" }, { label = "Kapat", value = "off" } }
		},
		{ type = 'input', label = 'GPS Kodu', placeholder = Callsign, required = not usingGps, disabled = usingGps, min = 6 },

	})
	if not menu then return end
	return menu
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
	Citizen.CreateThread(function()
		while true do
			Wait(1000)
			if exports.ars_ambulancejob:isDead() then
				TriggerServerEvent("fizzfau-gps:dropGPS")
			end
		end
	end)
end)
