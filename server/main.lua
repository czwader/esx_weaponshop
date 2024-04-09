ESX.RegisterServerCallback('esx_weaponshop:buyWeapon', function(source, cb, weaponName, zone)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = GetPrice("weapon", weaponName, zone)

	if price <= 0  then

		print(('[^3WARNING^7] Player ^5%s^7 attempted to buy Invalid weapon - %s!'):format(source, weaponName))
		cb(false)
	else
		if xPlayer.hasWeapon(weaponName) then
			xPlayer.showNotification("weapon owned")
			cb(false)
		else
			if zone == 'BlackWeashop' then
				if xPlayer.getAccount('black_money').money >= price then
					xPlayer.removeAccountMoney('black_money', price, "Black Weapons Deal")
					xPlayer.addWeapon(weaponName, 42)
	
					cb(true)
				else
					xPlayer.showNotification("no money")
					cb(false)
				end
			else
				if xPlayer.getMoney() >= price then
					xPlayer.removeMoney(price, "Weapons Deal")
					xPlayer.addWeapon(weaponName, 42)
	
					cb(true)
				else
					xPlayer.showNotification("no money")
					cb(false)
				end
			end
		end
	end
end)

ESX.RegisterServerCallback('esx_weaponshop:buyAmmo', function(source, cb, weaponName, zone, ammoCount, price)
	local xPlayer = ESX.GetPlayerFromId(source)



	if zone == 'BlackWeashop' then
		if xPlayer.getAccount('black_money').money >= price then
			xPlayer.removeAccountMoney('black_money', price, "Black Weapons Deal")
			xPlayer.addWeaponAmmo(weaponName, ammoCount)

			cb(true)
		else
			xPlayer.showNotification("no money")
			cb(false)
		end
	else
		if xPlayer.getMoney() >= price then
			xPlayer.removeMoney(price, "Weapons Deal")
			xPlayer.addWeaponAmmo(weaponName, ammoCount)

			cb(true)
		else
			xPlayer.showNotification("no money")
			cb(false)
		end
	end
end)


function GetPrice(type, weaponName, zone)
	for i=1, #(Config.Zones[zone].Items) do
		if Config.Zones[zone].Items[i].name == weaponName then
			local weapon = Config.Zones[zone].Items[i]
			if type == "ammo" then 
				return weapon.ammoPrice
			elseif type == "weapon" then 
				return weapon.price
			end
			
		end
	end

	return -1
end
