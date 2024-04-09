local shopOpen = false
WarMenu.CreateMenu('ammunation', 'Ammunation', "Select weapon")
WarMenu.CreateSubMenu('options', 'ammunation', "Select")
WarMenu.CreateSubMenu('count', 'options', "Select")

WarMenu.SetMenuTitleBackgroundColor("ammunation",0,128,0)
WarMenu.SetMenuTitleBackgroundColor("options",0,128,0)
WarMenu.SetMenuTitleBackgroundColor("count",0,128,0)

WarMenu.SetMenuSubTitleColor("ammunation",255,255,255)
WarMenu.SetMenuSubTitleColor("options",255,255,255)
WarMenu.SetMenuSubTitleColor("count",255,255,255)

WarMenu.SetMenuY("ammunation", 0.20)
WarMenu.SetMenuY("options", 0.20)
WarMenu.SetMenuY("count", 0.20)

local typeWeapons = {
    [-728555052] = false,
    [690389602] = false,
    [416676503] = true,
    [970310034] = true,
    [860033945] = true,
    [-957766203] = true,
    [-957766203] = true,

}

local currentWeapon = {}
local currentCount = 0
local state = {}
local items = {}
for i = 1, 1000 do 
    table.insert(items, i)
end

function OpenShopMenu(zone)
    shopOpen = true
    if WarMenu.IsAnyMenuOpened() then
        return
    end
    state = {
        currentIndex = 1
    }
    CreateThread(function()
        WarMenu.OpenMenu('ammunation')
        while true do 
            local ped = PlayerPedId()
            if WarMenu.Begin("ammunation") then 
                for i = 1, #Config.Zones[zone].Items, 1 do
                    local item = Config.Zones[zone].Items[i]
                    item.label = ESX.GetWeaponLabel(item.name)
                    local weaponHash = GetHashKey(item.name)
                    
                    if HasPedGotWeapon(ped, weaponHash, false) then 
                        if WarMenu.SpriteButton(item.label, 'commonmenu','shop_gunclub_icon_b') then
                            
                                currentWeapon = {
                                    price = item.price,
                                    name = item.name,
                                    label = item.label,
                                    weaponType = GetWeapontypeGroup(item.name),
                                    buyed = true,
                                    ammoPrice = item.ammoPrice
                                }

                                WarMenu.OpenMenu('options')

                        end
                    else
                        if WarMenu.Button(item.label, item.price.." ~g~$~s~") then 
                            currentWeapon = {
                                price = item.price,
                                name = item.name,
                                label = item.label,
                                weaponType = GetWeapontypeGroup(item.name),
                                buyed = false,
                                ammoPrice = item.ammoPrice
                            }
                            WarMenu.OpenMenu('options') 
                        end
                    end
                end
                WarMenu.End()
            elseif WarMenu.Begin("options") then 
                if not currentWeapon.buyed then 
                    if WarMenu.Button("Buy "..currentWeapon.label , currentWeapon.price.." ~g~$~s~") then 
                        ESX.TriggerServerCallback('esx_weaponshop:buyWeapon', function(bought)
                            if bought then
                                DisplayBoughtScaleform(currentWeapon.name, currentWeapon.price)
                                WarMenu.CloseMenu()
                            else
                                PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)
                            end
                        end, currentWeapon.name, zone)
                    end
                end
                if typeWeapons[currentWeapon.weaponType] then
                    if WarMenu.Button("Buy ammo", currentWeapon.ammoPrice.." ~g~$~s~") then 
                        WarMenu.OpenMenu('count')
                    end
                end
                WarMenu.End()
            elseif WarMenu.Begin("count") then 
                local button, currentIndex = WarMenu.ComboBox('Count', items, state.currentIndex)
                state.currentIndex = currentIndex
                if button then 
                    local dialog = dialogBox()
                    numberDialog = tonumber(dialog)
                    if numberDialog then 
                        state.currentIndex = numberDialog
                    else
                        ESX.ShowNotification("You must enter a number")
                    end
                end
                if WarMenu.Button("Buy", state.currentIndex * currentWeapon.ammoPrice.." ~g~$~s~") then 
                    
                    ESX.TriggerServerCallback('esx_weaponshop:buyAmmo', function(bought)
                        
                        WarMenu.OpenMenu('ammunation')
                        
                    end, currentWeapon.name, zone, state.currentIndex, state.currentIndex * currentWeapon.ammoPrice)
                    state.currentIndex = 0
                end
                WarMenu.End()
            else
                shopOpen = false
                break
            end
            Wait(0)
        end
    end)
end

function dialogBox()
    DisplayOnscreenKeyboard(1, "FMMC_MPM_NA", "", "", "", "", "", 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0);
        Wait(0);
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return result
    end
end


function DisplayBoughtScaleform(weaponName, price)
    local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
    local sec = 4

    BeginScaleformMovieMethod(scaleform, 'SHOW_WEAPON_PURCHASED')

    ScaleformMovieMethodAddParamTextureNameString("Purchased weapon")
    ScaleformMovieMethodAddParamTextureNameString(ESX.GetWeaponLabel(weaponName))
    ScaleformMovieMethodAddParamInt(joaat(weaponName))
    ScaleformMovieMethodAddParamTextureNameString('')
    ScaleformMovieMethodAddParamInt(100)
    EndScaleformMovieMethod()

    PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)

    CreateThread(function()
        while sec > 0 do
            Wait(0)
            sec = sec - 0.01

            DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
        end
    end)
end

CreateThread(function()
    AddTextEntry("ESX_WEAPONSHOP:OpenShop", '~INPUT_CONTEXT~ Otevrit ammunation')
    while true do
        local sleep = 1500
        local coords = GetEntityCoords(ESX.PlayerData.ped)
        local distanceToShop = 10000.0
        for k, v in pairs(Config.Zones) do
            for i = 1, #v.Locations, 1 do
                local distance = #(coords - v.Locations[i])
                if distance < distanceToShop then
                    distanceToShop = distance
                end
                if distance < Config.DrawDistance and not shopOpen then
                    DrawMarker(Config.Type, v.Locations[i],
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    Config.Size.x, Config.Size.y,Config.Size.z,
                    Config.Color.r, Config.Color.g, Config.Color.b,100,
                    false, true, nil, false)
                    sleep = 0
                    if distance < 2.0 then
                        DisplayHelpTextThisFrame("ESX_WEAPONSHOP:OpenShop")
                        if IsControlJustReleased(0, 38) then
                            if v.Legal then  
                                OpenShopMenu(k)
                            else
                                OpenShopMenu(k)
                            end
                        end
                    end
                end
                
            end
        end

      
        Wait(sleep)
    end
end)