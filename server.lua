-- ==========================================================
--  syx-admin : server
--  Other resources check admin status with:
--    exports['syx-admin']:IsAdmin(source)
--    exports['syx-admin']:IsSuperAdmin(source)
-- ==========================================================

local admins = {}       -- license -> { name, addedBy, addedAt }
local superAdminSet = {}

for _, license in ipairs(Config.SuperAdmins) do
    superAdminSet[license] = true
end

CreateThread(function()
    admins = Storage.LoadAll()
    local n = 0
    for _ in pairs(admins) do n = n + 1 end
    print(('[syx-admin] loaded %d saved admin(s), %d super admin(s) configured')
        :format(n, #Config.SuperAdmins))
end)

local function getLicense(src)
    return GetPlayerIdentifierByType(src, 'license')
end

local function isSuperAdmin(src)
    local license = getLicense(src)
    return license ~= nil and superAdminSet[license] == true
end

local function isAdmin(src)
    if isSuperAdmin(src) then return true end
    local license = getLicense(src)
    return license ~= nil and admins[license] ~= nil
end

local function canManageAdmins(src)
    if isSuperAdmin(src) then return true end
    return Config.AdminsCanManageAdmins and isAdmin(src)
end

-- ---------------------------------------------------------------
--  exports for other resources
-- ---------------------------------------------------------------
exports('IsAdmin', function(src) return isAdmin(src) end)
exports('IsSuperAdmin', function(src) return isSuperAdmin(src) end)

-- ---------------------------------------------------------------
--  shared add/remove logic (used by both the NUI panel and /addadmin)
-- ---------------------------------------------------------------
local function doAddAdmin(src, targetId)
    if not canManageAdmins(src) then
        TriggerClientEvent('syx-admin:notify', src, 'You do not have permission to manage admins.', 'error')
        return
    end

    targetId = tonumber(targetId)
    local targetName = targetId and GetPlayerName(targetId)
    if not targetId or not targetName then
        TriggerClientEvent('syx-admin:notify', src, 'That player is not online.', 'error')
        return
    end

    local license = getLicense(targetId)
    if not license then
        TriggerClientEvent('syx-admin:notify', src, "Could not read that player's license identifier.", 'error')
        return
    end

    if superAdminSet[license] then
        TriggerClientEvent('syx-admin:notify', src, targetName .. ' is already a super admin.', 'error')
        return
    end

    local data = {
        name = targetName,
        addedBy = GetPlayerName(src) or 'console',
        addedAt = os.date('%Y-%m-%d'),
    }
    admins[license] = data
    Storage.SaveAdmin(license, data)

    TriggerClientEvent('syx-admin:notify', src, targetName .. ' is now an admin.', 'success')
    TriggerClientEvent('syx-admin:notify', targetId, 'You were granted admin access.', 'success')
end

local function doRemoveAdmin(src, license)
    if not canManageAdmins(src) then
        TriggerClientEvent('syx-admin:notify', src, 'You do not have permission to manage admins.', 'error')
        return
    end
    if type(license) ~= 'string' then return end

    if superAdminSet[license] then
        TriggerClientEvent('syx-admin:notify', src, "Super admins are set in config.lua and can't be removed here.", 'error')
        return
    end

    admins[license] = nil
    Storage.RemoveAdmin(license)
    TriggerClientEvent('syx-admin:notify', src, 'Removed that admin.', 'success')
end

-- ---------------------------------------------------------------
--  panel data
-- ---------------------------------------------------------------
local function onlinePlayersList(excludeSrc)
    local list = {}
    for _, src in ipairs(GetPlayers()) do
        if tonumber(src) ~= excludeSrc then
            list[#list+1] = { id = src, name = GetPlayerName(src) }
        end
    end
    return list
end

local function adminListForPanel()
    local list = {}
    for _, license in ipairs(Config.SuperAdmins) do
        list[#list+1] = { license = license, name = 'Super Admin', addedBy = 'config.lua', super = true }
    end
    for license, data in pairs(admins) do
        list[#list+1] = { license = license, name = data.name or '?', addedBy = data.addedBy or '?', super = false }
    end
    return list
end

RegisterNetEvent('syx-admin:requestPanel', function()
    local src = source
    if not isAdmin(src) then
        TriggerClientEvent('syx-admin:accessDenied', src)
        return
    end
    TriggerClientEvent('syx-admin:openPanel', src, {
        admins = adminListForPanel(),
        onlinePlayers = onlinePlayersList(src),
        canManage = canManageAdmins(src),
    })
end)

RegisterNetEvent('syx-admin:addAdmin', function(targetId)
    doAddAdmin(source, targetId)
end)

RegisterNetEvent('syx-admin:removeAdmin', function(license)
    doRemoveAdmin(source, license)
end)

-- ---------------------------------------------------------------
--  quick chat-command alternative to the panel
-- ---------------------------------------------------------------
RegisterCommand('addadmin', function(src, args)
    if src == 0 then
        print('[syx-admin] /addadmin must be run in-game (use the console to edit Config.SuperAdmins instead).')
        return
    end
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('syx-admin:notify', src, 'Usage: /addadmin [server id]', 'error')
        return
    end
    doAddAdmin(src, targetId)
end, false)

RegisterCommand('removeadmin', function(src, args)
    if src == 0 then return end
    local targetId = tonumber(args[1])
    if not targetId then
        TriggerClientEvent('syx-admin:notify', src, 'Usage: /removeadmin [server id]', 'error')
        return
    end
    local license = getLicense(targetId)
    if not license then
        TriggerClientEvent('syx-admin:notify', src, 'That player is not online.', 'error')
        return
    end
    doRemoveAdmin(src, license)
end, false)
