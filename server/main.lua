
-- Create a function that finds the closest Ped to the player from Config.peds
function FindClosestPed(player)
    local playerPed = GetPlayerPed(player)
    local playerCoords = GetEntityCoords(playerPed)
    local closestPed = nil
    local closestDistance = -1
    local searchDistance = 3.0

    for _, ped in pairs(Config.peds) do
        local pedCoords = ped.location.xyz
        local distance = #(playerCoords - pedCoords)

        if closestDistance == -1 or closestDistance > distance then
            closestPed = ped
            closestDistance = distance
        end
    end

    if closestDistance <= searchDistance then
        return closestPed, closestDistance
    end
end

ESX.RegisterServerCallback('buythingy', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ClosestPed = FindClosestPed(source)

    if ClosestPed ~= nil then
       if xPlayer.getInventoryItem(ClosestPed.item.name).count > 0 then 
        xPlayer.removeInventoryItem(ClosestPed.item.name, 1)
        xPlayer.addMoney(ClosestPed.item.price)
        local itemLabel = ESX.GetItemLabel(ClosestPed.item.name)
        TriggerClientEvent('esx:showNotification', source, 'You sold a ~b~'.. itemLabel .. '~s~ for $~g~' ..  ClosestPed.item.price, "success")
        cb(true)
    else
      local itemLabel = ESX.GetItemLabel(ClosestPed.item.name)
      TriggerClientEvent('esx:showNotification', source, ('%s Is ~r~Required!'):format(itemLabel), "error")
      cb(false)
      end
    end
end)
