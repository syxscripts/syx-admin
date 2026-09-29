-- ==========================================================
--  Storage backend abstraction
--  Exposes: Storage.LoadAll(), Storage.SaveAdmin(license, data), Storage.RemoveAdmin(license)
--  data shape: { name, addedBy, addedAt }
-- ==========================================================

Storage = {}

local FILE_PATH = 'data/admins.json'

-- ---------------------------------------------------------------
--  file backend (default)
-- ---------------------------------------------------------------
local function file_LoadAll()
    local raw = LoadResourceFile(GetCurrentResourceName(), FILE_PATH)
    if not raw or raw == '' then return {} end
    local ok, tbl = pcall(json.decode, raw)
    if ok and type(tbl) == 'table' then return tbl end
    return {}
end

local function file_SaveAll(tbl)
    SaveResourceFile(GetCurrentResourceName(), FILE_PATH, json.encode(tbl), -1)
end

local function file_SaveAdmin(license, data)
    local all = file_LoadAll()
    all[license] = data
    file_SaveAll(all)
end

local function file_RemoveAdmin(license)
    local all = file_LoadAll()
    all[license] = nil
    file_SaveAll(all)
end

-- ---------------------------------------------------------------
--  oxmysql backend
-- ---------------------------------------------------------------
local function ox_LoadAll()
    local rows = exports.oxmysql:executeSync('SELECT license, name, added_by, added_at FROM syx_admins', {})
    local out = {}
    for _, row in ipairs(rows or {}) do
        out[row.license] = { name = row.name, addedBy = row.added_by, addedAt = row.added_at }
    end
    return out
end

local function ox_SaveAdmin(license, data)
    exports.oxmysql:execute(
        'INSERT INTO syx_admins (license, name, added_by, added_at) VALUES (:license, :name, :addedBy, NOW()) ' ..
        'ON DUPLICATE KEY UPDATE name = :name, added_by = :addedBy',
        { license = license, name = data.name, addedBy = data.addedBy }
    )
end

local function ox_RemoveAdmin(license)
    exports.oxmysql:execute('DELETE FROM syx_admins WHERE license = :license', { license = license })
end

-- ---------------------------------------------------------------
--  pick backend
-- ---------------------------------------------------------------
if Config.Storage == 'oxmysql' then
    Storage.LoadAll      = ox_LoadAll
    Storage.SaveAdmin    = ox_SaveAdmin
    Storage.RemoveAdmin  = ox_RemoveAdmin
else
    Storage.LoadAll      = file_LoadAll
    Storage.SaveAdmin    = file_SaveAdmin
    Storage.RemoveAdmin  = file_RemoveAdmin
end
