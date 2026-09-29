-- ==========================================================
--  syx-admin : client
-- ==========================================================

local panelOpen = false

RegisterCommand(Config.OpenCommand, function()
    if panelOpen then return end
    TriggerServerEvent('syx-admin:requestPanel')
end, false)

RegisterNetEvent('syx-admin:accessDenied', function()
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName('You do not have permission to use the admin panel.')
    EndTextCommandThefeedPostTicker(false, false)
end)

RegisterNetEvent('syx-admin:openPanel', function(data)
    panelOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        admins = data.admins,
        onlinePlayers = data.onlinePlayers,
        canManage = data.canManage,
    })
end)

RegisterNetEvent('syx-admin:notify', function(message, kind)
    if panelOpen then
        SendNUIMessage({ action = 'toast', message = message, kind = kind })
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, false)
    end
end)

local function closePanel()
    panelOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('closeMenu', function(_, cb)
    closePanel()
    cb({})
end)

RegisterNUICallback('addAdmin', function(data, cb)
    if data and data.id then
        TriggerServerEvent('syx-admin:addAdmin', data.id)
    end
    cb({})
end)

RegisterNUICallback('removeAdmin', function(data, cb)
    if data and data.license then
        TriggerServerEvent('syx-admin:removeAdmin', data.license)
    end
    cb({})
end)

RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('syx-admin:requestPanel')
    cb({})
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() and panelOpen then
        SetNuiFocus(false, false)
    end
end)
