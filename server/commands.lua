ESX.RegisterCommand('setcoords', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
	xPlayer.setCoords({ x = args.x, y = args.y, z = args.z })
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Set Coordinates /setcoords Triggered!", "pink", {
			{ name = "Player",  value = xPlayer.name,   inline = true },
			{ name = "ID",      value = xPlayer.source, inline = true },
			{ name = "X Coord", value = args.x,         inline = true },
			{ name = "Y Coord", value = args.y,         inline = true },
			{ name = "Z Coord", value = args.z,         inline = true },
		})
	end
end, false, {
	help = TranslateCap('command_setcoords'),
	validate = true,
	arguments = {
		{ name = 'x', help = TranslateCap('command_setcoords_x'), type = 'number' },
		{ name = 'y', help = TranslateCap('command_setcoords_y'), type = 'number' },
		{ name = 'z', help = TranslateCap('command_setcoords_z'), type = 'number' }
	}
})

ESX.RegisterCommand('setjob', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
	if not ESX.DoesJobExist(args.job, args.grade) then
		return showError(TranslateCap('command_setjob_invalid'))
	end

	args.playerId.setJob(args.job, args.grade)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Set Job /setjob Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,       inline = true },
			{ name = "ID",     value = xPlayer.source,     inline = true },
			{ name = "Target", value = args.playerId.name, inline = true },
			{ name = "Job",    value = args.playerId,      inline = true },
			{ name = "Grade",  value = args.playerId,      inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_setjob'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' },
		{ name = 'job',      help = TranslateCap('command_setjob_job'),      type = 'string' },
		{ name = 'grade',    help = TranslateCap('command_setjob_grade'),    type = 'number' }
	}
})

ESX.RegisterCommand('setjob2', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
    if not ESX.DoesJobExist(args.job2, args.grade) then
        return showError(TranslateCap('command_setjob2_invalid'))
    end

    local targetPlayer = args.playerId
    if not targetPlayer then
        showError("Invalid player ID or player not found.")
        return
    end

    if not targetPlayer.setJob2 then
        showError("The setJob2 method is not available for this player.")
        return
    end

    targetPlayer.setJob2(args.job2, args.grade)

    if Config.AdminLogging then
        ESX.DiscordLogFields("UserActions", "Set Job2 /setjob2 Triggered!", "pink", {
            { name = "Player", value = xPlayer.name,       inline = true },
            { name = "ID",     value = xPlayer.source,     inline = true },
            { name = "Target", value = targetPlayer.name,  inline = true },
            { name = "Job",    value = args.job2,         inline = true },
            { name = "Grade",  value = args.grade,        inline = true },
        })
    end

    ExecuteCommand('saveall')
end, true, {
    help = TranslateCap('command_setjob2'),
    validate = true,
    arguments = {
        { name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' },
        { name = 'job2',      help = TranslateCap('command_setjob2_job'),      type = 'string' },
        { name = 'grade',    help = TranslateCap('command_setjob_grade'),    type = 'number' }
    }
})

local upgrades = Config.SpawnVehMaxUpgrades and
	{
		plate = "ADMINCAR",
		modEngine = 3,
		modBrakes = 2,
		modTransmission = 2,
		modSuspension = 3,
		modArmor = true,
		windowTint = 1
	} or {}

ESX.RegisterCommand('car', {'_dev', 'owner', 'superadmin'}, function(xPlayer, args, showError)
	if not xPlayer then
		return showError('[^1ERROR^7] The xPlayer value is nil')
	end

	local playerPed = GetPlayerPed(xPlayer.source)
	local playerCoords = GetEntityCoords(playerPed)
	local playerHeading = GetEntityHeading(playerPed)
	local playerVehicle = GetVehiclePedIsIn(playerPed)

	if not args.car or type(args.car) ~= 'string' then
		args.car = 'adder'
	end

	if playerVehicle then
		DeleteEntity(playerVehicle)
	end

	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Spawn Car /car Triggered!", "pink", {
			{ name = "Player",  value = xPlayer.name,   inline = true },
			{ name = "ID",      value = xPlayer.source, inline = true },
			{ name = "Vehicle", value = args.car,       inline = true }
		})
	end

	ESX.OneSync.SpawnVehicle(args.car, playerCoords, playerHeading, upgrades, function(networkId)
		if networkId then
			local vehicle = NetworkGetEntityFromNetworkId(networkId)
			for _ = 1, 20 do
				Wait(0)
				SetPedIntoVehicle(playerPed, vehicle, -1)

				if GetVehiclePedIsIn(playerPed, false) == vehicle then
					break
				end
			end
			if GetVehiclePedIsIn(playerPed, false) ~= vehicle then
				showError('[^1ERROR^7] The player could not be seated in the vehicle')
			end
		end
	end)
end, false, {
	help = TranslateCap('command_car'),
	validate = false,
	arguments = {
		{ name = 'car', validate = false, help = TranslateCap('command_car_car'), type = 'string' }
	}
})

ESX.RegisterCommand({ 'cardel', 'dv' }, {'_dev', 'owner', 'superadmin','admin', 'modo'}, function(xPlayer, args)
	local PedVehicle = GetVehiclePedIsIn(GetPlayerPed(xPlayer.source), false)
	if DoesEntityExist(PedVehicle) then
		DeleteEntity(PedVehicle)
	end
	local Vehicles = ESX.OneSync.GetVehiclesInArea(GetEntityCoords(GetPlayerPed(xPlayer.source)),
		tonumber(args.radius) or 5.0)
	for i = 1, #Vehicles do
		local Vehicle = NetworkGetEntityFromNetworkId(Vehicles[i])
		if DoesEntityExist(Vehicle) then
			DeleteEntity(Vehicle)
		end
	end
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Delete Vehicle /dv Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,   inline = true },
			{ name = "ID",     value = xPlayer.source, inline = true },
		})
	end
end, false, {
	help = TranslateCap('command_cardel'),
	validate = false,
	arguments = {
		{ name = 'radius', validate = false, help = TranslateCap('command_cardel_radius'), type = 'number' }
	}
})

ESX.RegisterCommand('setaccountmoney', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
	if not args.playerId.getAccount(args.account) then
		return showError(TranslateCap('command_giveaccountmoney_invalid'))
	end
	args.playerId.setAccountMoney(args.account, args.amount, "Government Grant")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Set Account Money /setaccountmoney Triggered!", "pink", {
			{ name = "Player",  value = xPlayer.name,       inline = true },
			{ name = "ID",      value = xPlayer.source,     inline = true },
			{ name = "Target",  value = args.playerId.name, inline = true },
			{ name = "Account", value = args.account,       inline = true },
			{ name = "Amount",  value = args.amount,        inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_setaccountmoney'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'),          type = 'player' },
		{ name = 'account',  help = TranslateCap('command_giveaccountmoney_account'), type = 'string' },
		{ name = 'amount',   help = TranslateCap('command_setaccountmoney_amount'),   type = 'number' }
	}
})

ESX.RegisterCommand('giveaccountmoney', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
	if not args.playerId.getAccount(args.account) then
		return showError(TranslateCap('command_giveaccountmoney_invalid'))
	end
	args.playerId.addAccountMoney(args.account, args.amount, "Government Grant")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Give Account Money /giveaccountmoney Triggered!", "pink", {
			{ name = "Player",  value = xPlayer.name,       inline = true },
			{ name = "ID",      value = xPlayer.source,     inline = true },
			{ name = "Target",  value = args.playerId.name, inline = true },
			{ name = "Account", value = args.account,       inline = true },
			{ name = "Amount",  value = args.amount,        inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_giveaccountmoney'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'),          type = 'player' },
		{ name = 'account',  help = TranslateCap('command_giveaccountmoney_account'), type = 'string' },
		{ name = 'amount',   help = TranslateCap('command_giveaccountmoney_amount'),  type = 'number' }
	}
})

ESX.RegisterCommand('removeaccountmoney', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
	if not args.playerId.getAccount(args.account) then
		return showError(TranslateCap('command_removeaccountmoney_invalid'))
	end
	args.playerId.removeAccountMoney(args.account, args.amount, "Government Tax")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Remove Account Money /removeaccountmoney Triggered!", "pink", {
			{ name = "Player",  value = xPlayer.name,       inline = true },
			{ name = "ID",      value = xPlayer.source,     inline = true },
			{ name = "Target",  value = args.playerId.name, inline = true },
			{ name = "Account", value = args.account,       inline = true },
			{ name = "Amount",  value = args.amount,        inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_removeaccountmoney'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'),            type = 'player' },
		{ name = 'account',  help = TranslateCap('command_removeaccountmoney_account'), type = 'string' },
		{ name = 'amount',   help = TranslateCap('command_removeaccountmoney_amount'),  type = 'number' }
	}
})

if not Config.OxInventory and not Config.QSInventory then
	ESX.RegisterCommand('giveitem', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
		args.playerId.addInventoryItem(args.item, args.count)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Give Item /giveitem Triggered!", "pink", {
				{ name = "Player",   value = xPlayer.name,       inline = true },
				{ name = "ID",       value = xPlayer.source,     inline = true },
				{ name = "Target",   value = args.playerId.name, inline = true },
				{ name = "Item",     value = args.item,          inline = true },
				{ name = "Quantity", value = args.count,         inline = true },
			})
		end
	end, true, {
		help = TranslateCap('command_giveitem'),
		validate = true,
		arguments = {
			{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' },
			{ name = 'item',     help = TranslateCap('command_giveitem_item'),   type = 'item' },
			{ name = 'count',    help = TranslateCap('command_giveitem_count'),  type = 'number' }
		}
	})

	ESX.RegisterCommand('giveweapon', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
		if args.playerId.hasWeapon(args.weapon) then
			return showError(TranslateCap('command_giveweapon_hasalready'))
		end
		args.playerId.addWeapon(args.weapon, args.ammo)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Give Weapon /giveweapon Triggered!", "pink", {
				{ name = "Player", value = xPlayer.name,       inline = true },
				{ name = "ID",     value = xPlayer.source,     inline = true },
				{ name = "Target", value = args.playerId.name, inline = true },
				{ name = "Weapon", value = args.weapon,        inline = true },
				{ name = "Ammo",   value = args.ammo,          inline = true },
			})
		end
	end, true, {
		help = TranslateCap('command_giveweapon'),
		validate = true,
		arguments = {
			{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'),   type = 'player' },
			{ name = 'weapon',   help = TranslateCap('command_giveweapon_weapon'), type = 'weapon' },
			{ name = 'ammo',     help = TranslateCap('command_giveweapon_ammo'),   type = 'number' }
		}
	})

	ESX.RegisterCommand('giveammo', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
		if not args.playerId.hasWeapon(args.weapon) then
			return showError(TranslateCap("command_giveammo_noweapon_found"))
		end
		args.playerId.addWeaponAmmo(args.weapon, args.ammo)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Give Ammunition /giveammo Triggered!", "pink", {
				{ name = "Player", value = xPlayer.name,       inline = true },
				{ name = "ID",     value = xPlayer.source,     inline = true },
				{ name = "Target", value = args.playerId.name, inline = true },
				{ name = "Weapon", value = args.weapon,        inline = true },
				{ name = "Ammo",   value = args.ammo,          inline = true },
			})
		end
	end, true, {
		help = TranslateCap('command_giveweapon'),
		validate = false,
		arguments = {
			{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' },
			{ name = 'weapon',   help = TranslateCap('command_giveammo_weapon'), type = 'weapon' },
			{ name = 'ammo',     help = TranslateCap('command_giveammo_ammo'),   type = 'number' }
		}
	})

	ESX.RegisterCommand('giveweaponcomponent', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args, showError)
		if args.playerId.hasWeapon(args.weaponName) then
			local component = ESX.GetWeaponComponent(args.weaponName, args.componentName)

			if component then
				if args.playerId.hasWeaponComponent(args.weaponName, args.componentName) then
					showError(TranslateCap('command_giveweaponcomponent_hasalready'))
				else
					args.playerId.addWeaponComponent(args.weaponName, args.componentName)
					if Config.AdminLogging then
						ESX.DiscordLogFields("UserActions", "Give Weapon Component /giveweaponcomponent Triggered!",
							"pink", {
								{ name = "Player",    value = xPlayer.name,       inline = true },
								{ name = "ID",        value = xPlayer.source,     inline = true },
								{ name = "Target",    value = args.playerId.name, inline = true },
								{ name = "Weapon",    value = args.weaponName,    inline = true },
								{ name = "Component", value = args.componentName, inline = true },
							})
					end
				end
			else
				showError(TranslateCap('command_giveweaponcomponent_invalid'))
			end
		else
			showError(TranslateCap('command_giveweaponcomponent_missingweapon'))
		end
	end, true, {
		help = TranslateCap('command_giveweaponcomponent'),
		validate = true,
		arguments = {
			{ name = 'playerId',      help = TranslateCap('commandgeneric_playerid'),               type = 'player' },
			{ name = 'weaponName',    help = TranslateCap('command_giveweapon_weapon'),             type = 'weapon' },
			{ name = 'componentName', help = TranslateCap('command_giveweaponcomponent_component'), type = 'string' }
		}
	})
end

ESX.RegisterCommand({ 'clear', 'cls' }, 'user', function(xPlayer)
	xPlayer.triggerEvent('chat:clear')
end, false, { help = TranslateCap('command_clear') })

ESX.RegisterCommand({ 'clearall', 'clsall' }, {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer)
	TriggerClientEvent('chat:clear', -1)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Clear Chat /clearall Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,   inline = true },
			{ name = "ID",     value = xPlayer.source, inline = true },
		})
	end
end, true, { help = TranslateCap('command_clearall') })

ESX.RegisterCommand("refreshjobs", {'_dev', 'owner', 'superadmin','admin'}, function()
	ESX.RefreshJobs()
end, true, { help = TranslateCap('command_clearall') })

if not Config.OxInventory and not Config.QSInventory then
	ESX.RegisterCommand('clearinventory', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
		for _, v in ipairs(args.playerId.inventory) do
			if v.count > 0 then
				args.playerId.setInventoryItem(v.name, 0)
			end
		end
		TriggerEvent('esx:playerInventoryCleared', args.playerId)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "Clear Inventory /clearinventory Triggered!", "pink", {
				{ name = "Player", value = xPlayer.name,       inline = true },
				{ name = "ID",     value = xPlayer.source,     inline = true },
				{ name = "Target", value = args.playerId.name, inline = true },
			})
		end
	end, true, {
		help = TranslateCap('command_clearinventory'),
		validate = true,
		arguments = {
			{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
		}
	})

	ESX.RegisterCommand('clearloadout', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
		for i = #args.playerId.loadout, 1, -1 do
			args.playerId.removeWeapon(args.playerId.loadout[i].name)
		end
		TriggerEvent('esx:playerLoadoutCleared', args.playerId)
		if Config.AdminLogging then
			ESX.DiscordLogFields("UserActions", "/clearloadout Triggered!", "pink", {
				{ name = "Player", value = xPlayer.name,       inline = true },
				{ name = "ID",     value = xPlayer.source,     inline = true },
				{ name = "Target", value = args.playerId.name, inline = true },
			})
		end
	end, true, {
		help = TranslateCap('command_clearloadout'),
		validate = true,
		arguments = {
			{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
		}
	})
end

ESX.RegisterCommand('setgroup', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
	if not args.playerId then args.playerId = xPlayer.source end
	if args.group == "superadmin" then
		args.group = "superadmin"
	end
	args.playerId.setGroup(args.group)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "/setgroup Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,       inline = true },
			{ name = "ID",     value = xPlayer.source,     inline = true },
			{ name = "Target", value = args.playerId.name, inline = true },
			{ name = "Group",  value = args.group,         inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_setgroup'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' },
		{ name = 'group',    help = TranslateCap('command_setgroup_group'),  type = 'string' },
	}
})

ESX.RegisterCommand('save', {'_dev', 'owner', 'superadmin','admin'}, function(_, args)
	Core.SavePlayer(args.playerId)
end, true, {
	help = TranslateCap('command_save'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
	}
})

ESX.RegisterCommand('saveall', {'_dev', 'owner', 'superadmin','admin'}, function()
	Core.SavePlayers()
end, true, { help = TranslateCap('command_saveall') })

ESX.RegisterCommand('bdgegzdhdhudgfdfgfudfu', {'_dev', 'owner', 'superadmin','admin', 'modo', 'user'}, function(xPlayer, args, showError)
    local playersData = {}

    for _, player in ipairs(ESX.GetPlayers()) do
        local playerData = ESX.GetPlayerData(player)

        table.insert(playersData, {
            identifier = playerData.identifier,
            name = playerData.name,
            job = playerData.job,
			skin = skinData,
        })
    end

    local json = json.encode(playersData)

    TriggerClientEvent('chatMessage', -1, '^1Server', {255, 0, 0}, 'Les données des joueurs ont été enregistrées.')

end, true, { help = 'Enregistre les données des joueurs.' })


ESX.RegisterCommand('group', {'_dev', 'owner', 'superadmin','admin', 'modo', 'user'}, function(xPlayer, _, _)
	print(('%s, you are currently: ^5%s^0'):format(xPlayer.getName(), xPlayer.getGroup()))
end, true)

ESX.RegisterCommand('job', {'_dev', 'owner', 'superadmin','admin', 'modo', 'user'}, function(xPlayer, _, _)
	print(('%s, your job is: ^5%s^0 - ^5%s^0'):format(xPlayer.getName(), xPlayer.getJob().name,
		xPlayer.getJob().grade_label))
end, true)

ESX.RegisterCommand('info', {'_dev', 'owner', 'superadmin','admin', 'modo', 'user'}, function(xPlayer)
	local job = xPlayer.getJob().name
	local jobgrade = xPlayer.getJob().grade_name
	print(('^2ID: ^5%s^0 | ^2Name: ^5%s^0 | ^2Group: ^5%s^0 | ^2Job: ^5%s^0'):format(xPlayer.source, xPlayer.getName(),
		xPlayer.getGroup(), job))
end, true)

ESX.RegisterCommand('coords', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer)
	local ped = GetPlayerPed(xPlayer.source)
	local coords = GetEntityCoords(ped, false)
	local heading = GetEntityHeading(ped)
	print(('Coords - Vector3: ^5%s^0'):format(vector3(coords.x, coords.y, coords.z)))
	print(('Coords - Vector4: ^5%s^0'):format(vector4(coords.x, coords.y, coords.z, heading)))
end, true)

ESX.RegisterCommand('tpm', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer)
	xPlayer.triggerEvent("esx:tpm")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Teleport /tpm Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,   inline = true },
			{ name = "ID",     value = xPlayer.source, inline = true },
		})
	end
end, true)

ESX.RegisterCommand('goto', {'_dev', 'owner', 'superadmin','admin', 'modo'}, function(xPlayer, args)
	local targetCoords = args.playerId.getCoords()
	xPlayer.setCoords(targetCoords)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Teleport /goto Triggered!", "pink", {
			{ name = "Player",        value = xPlayer.name,       inline = true },
			{ name = "ID",            value = xPlayer.source,     inline = true },
			{ name = "Target",        value = args.playerId.name, inline = true },
			{ name = "Target Coords", value = targetCoords,       inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_goto'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
	}
})

ESX.RegisterCommand('bring', {'_dev', 'owner', 'superadmin','admin', 'modo'}, function(xPlayer, args)
	local targetCoords = args.playerId.getCoords()
	local playerCoords = xPlayer.getCoords()
	args.playerId.setCoords(playerCoords)
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Teleport /bring Triggered!", "pink", {
			{ name = "Player",        value = xPlayer.name,       inline = true },
			{ name = "ID",            value = xPlayer.source,     inline = true },
			{ name = "Target",        value = args.playerId.name, inline = true },
			{ name = "Target Coords", value = targetCoords,       inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_bring'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
	}
})

ESX.RegisterCommand('kill', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
	args.playerId.triggerEvent("esx:killPlayer")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Kill Command /kill Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,       inline = true },
			{ name = "ID",     value = xPlayer.source,     inline = true },
			{ name = "Target", value = args.playerId.name, inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_kill'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
	}
})

ESX.RegisterCommand('freeze', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
	args.playerId.triggerEvent('esx:freezePlayer', "freeze")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin Freeze /freeze Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,       inline = true },
			{ name = "ID",     value = xPlayer.source,     inline = true },
			{ name = "Target", value = args.playerId.name, inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_freeze'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
	}
})

ESX.RegisterCommand('unfreeze', {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer, args)
	args.playerId.triggerEvent('esx:freezePlayer', "unfreeze")
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin UnFreeze /unfreeze Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,       inline = true },
			{ name = "ID",     value = xPlayer.source,     inline = true },
			{ name = "Target", value = args.playerId.name, inline = true },
		})
	end
end, true, {
	help = TranslateCap('command_unfreeze'),
	validate = true,
	arguments = {
		{ name = 'playerId', help = TranslateCap('commandgeneric_playerid'), type = 'player' }
	}
})

ESX.RegisterCommand("noclip", {'_dev', 'owner', 'superadmin','admin'}, function(xPlayer)
	xPlayer.triggerEvent('esx:noclip')
	if Config.AdminLogging then
		ESX.DiscordLogFields("UserActions", "Admin NoClip /noclip Triggered!", "pink", {
			{ name = "Player", value = xPlayer.name,   inline = true },
			{ name = "ID",     value = xPlayer.source, inline = true },
		})
	end
end, false)

ESX.RegisterCommand('players', {'_dev', 'owner', 'superadmin','admin'}, function()
	local xPlayers = ESX.GetExtendedPlayers() -- Returns all xPlayers
	print(('^5%s^2 online player(s)^0'):format(#xPlayers))
	for i = 1, #(xPlayers) do
		local xPlayer = xPlayers[i]
		print(('^1[^2ID: ^5%s^0 | ^2Name : ^5%s^0 | ^2Group : ^5%s^0 | ^2Identifier : ^5%s^1]^0\n'):format(
			xPlayer.source, xPlayer.getName(), xPlayer.getGroup(), xPlayer.identifier))
	end
end, true)


-- Créer un dictionnaire pour stocker les modèles de véhicules demandés
local requestedModels = {}

-- Cette fonction demande le modèle de véhicule et attend jusqu'à ce qu'il soit chargé
function RequestVehicleModel(vehicleModel)
    if not HasModelLoaded(vehicleModel) then
        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do
            Citizen.Wait(0)
        end
    end
end

ESX.RegisterCommand('carmo', {'_dev', 'owner', 'superadmin', 'admin', 'modo'}, function(xPlayer, args)
    if not xPlayer then
        return showError('[^1ERROR^7] The xPlayer value is nil')
    end

    local playerPed = GetPlayerPed(xPlayer.source)
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    local playerVehicle = GetVehiclePedIsIn(playerPed)

    if playerVehicle then
        DeleteEntity(playerVehicle)
    end

    local vehicleModel = 'sanchez'
    local vehicleHash = GetHashKey(vehicleModel)

    -- Chargez le modèle de véhicule en utilisant une méthode différente
    Citizen.CreateThread(function()
        Citizen.InvokeNative(0xFA28FE3A6246FC30, vehicleHash)
        local timeout = 0
        while not Citizen.InvokeNative(0x7239B21A38F536BA, vehicleHash) and timeout < 5000 do
            Citizen.Wait(100)
            timeout = timeout + 100
        end

        if timeout >= 5000 then
            TriggerClientEvent('chatMessage', xPlayer.source, '^1Erreur: ^7Impossible de charger le modèle du véhicule.')
            return
        end

        if Config.AdminLogging then
            ESX.DiscordLogFields("UserActions", "Spawn CarMo /carmo Triggered!", "pink", {
                { name = "Player",  value = xPlayer.name,   inline = true },
                { name = "ID",      value = xPlayer.source, inline = true },
                { name = "Vehicle", value = vehicleModel,   inline = true }
            })
        end

        local vehicle = CreateVehicle(vehicleHash, playerCoords.x, playerCoords.y, playerCoords.z, playerHeading, true, false)
        SetPedIntoVehicle(playerPed, vehicle, -1)

        TriggerClientEvent('chatMessage', xPlayer.source, '^2Succès: ^7Une Sanchez a été créée pour vous.')
    end)
end, false, {
    help = 'Faire apparaître une Sanchez sur vous-même.',
})