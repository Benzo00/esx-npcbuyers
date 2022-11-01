local SpawnedPeds = {}

local function SpawnPed(Ped)
    ESX.Streaming.RequestModel(joaat(Ped.SpawnName))
    local ped = CreatePed(4, joaat(Ped.SpawnName), Ped.location.xyz, Ped.location.w, false, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityAsMissionEntity(ped, true, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    SetModelAsNoLongerNeeded(joaat(Ped.SpawnName))
    SpawnedPeds[Ped.Name] = ped
    if Config.ox_target then 
      exports.ox_target:AddTargetEntity(ped, {
        options = {
          {
            icon = "far fa-comment-dots",
            label = "Talk to "..Ped.Name,
            action = function(entity)
              Menu(Ped)
            end
          },
        },
        distance = 2.5
      })
    end
end

local function SpawnPeds()
    for i = 1, #Config.peds do
        SpawnPed(Config.peds[i])
    end
end

local function DeletePeds()
    for k, v in pairs(SpawnedPeds) do
        DeletePed(v)
        SpawnedPeds[k] = nil
    end
end

local function deletePed(ped)
    print(ped)
    DeletePed(SpawnedPeds[ped])
    SpawnedPeds[ped] = nil
end

local function Animation(Ped)
    local ped = SpawnedPeds[Ped.Name]
    ESX.Streaming.RequestAnimDict("mp_common")
    FreezeEntityPosition(PlayerPedId(), true)
    TaskLookAtEntity(ESX.PlayerData.ped, ped, 1000)
    TaskPlayAnim(ESX.PlayerData.ped, "mp_common", "givetake1_a", 8.0, -8.0, -1, 0, 0, false, false, false)
    TaskPlayAnim(ped, "mp_common", "givetake2_a", 8.0, -8.0, -1, 0, 0, false, false, false)
    Wait(1500)
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedTasks(ESX.PlayerData.ped)
end

function Menu(Ped)
    local Elements = {{
        unselectable = true,
        icon = "far fa-comment-dots",
        title = ("%s"):format(Ped.Name),
        description = ("%s"):format(Ped.description),
    },
    {
        icon = "fa-solid fa-scale-balanced",
        title = "Select Quantity",
        description = "Qauntity of Drugs to Sell",
        input = true,
        inputType = "number", 
        inputPlaceholder = "Number...", 
        inputValue = 1, 
        inputMin = Ped.item.MinSell,
        inputMax = Ped.item.MaxSell, 
        index = "quantity",
    }, 
    {
        icon = "fa-solid fa-dollar-sign",
        title = "Sell Goods",
        description = "Attempt to sell your goods to "..Ped.Name,
        value = "sell"
    },
    {
        icon = "fa-solid fa-xmark",
        title = "Close",
        description = "Leave "..Ped.Name,
        value = "leave"
    }}

    ESX.OpenContext("right", Elements, function(menu, element)
        if element.value == "sell" then
                 ESX.TriggerServerCallback('buythingy', function(cb)
                  if cb then
                    Animation(Ped)
                    ESX.CloseContext()
                  end
              end, menu.eles[2].inputValue)
        elseif 
            element.value == "leave" then
            ESX.CloseContext()
          end
        end, function(menu)
    end)
end

if not Config.ox_target then
  CreateThread(function()
      while true do
          local sleep = 1500
          local playerCoords = GetEntityCoords(ESX.PlayerData.ped)
          for i = 1, #Config.peds do
              local ped = Config.peds[i]
              if SpawnedPeds[ped.Name] then
                  local distance = #(playerCoords - ped.location.xyz)
                  if distance < 5.0 then
                      sleep = 0
                      ESX.ShowFloatingHelpNotification("~INPUT_PICKUP~ -> Interact", ped.location.xyz + vec3(0, 0, 1.8))
                      if distance < 2.0 then
                          if IsControlJustPressed(0, 38) then
                              Menu(ped)
                          end
                      end
                  end
              end
          end
          Wait(sleep)
      end
  end)
end

CreateThread(function()
    while true do
        local sleep = 0
        local time = GetClockHours()
        for i = 1, #Config.peds do
            local ped = Config.peds[i]
            if time > ped.OpenTime and time < ped.CloseTime then
                if not SpawnedPeds[ped.Name] then
                    SpawnPed(ped)
                end
            else
                if SpawnedPeds[ped.Name] then
                  TaskWanderInArea(SpawnedPeds[ped.Name], ped.location.xyz, 10, 5, 1)
                  Wait(5000)
                  SetPedAsNoLongerNeeded(SpawnedPeds[ped.Name])
                  SpawnedPeds[ped.Name] = nil
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        DeletePeds()
        ESX.CloseContext()
    end
end)
