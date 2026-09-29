Config = {}

Config.OpenCommand = 'syxadmins'

-- These identities ALWAYS have full access and are the only ones who can
-- add/remove other admins (unless Config.AdminsCanManageAdmins is true
-- below). They don't need to be added through the panel.
--
-- Use the FULL license identifier, e.g. 'license:1234567890abcdef...'.
-- Easiest way to get yours: connect to the server, then check the server
-- console/txAdmin player list, or run `/getid` if your server has that.
Config.SuperAdmins = {
    -- 'license:1234567890abcdef1234567890abcdef12345678',
}

-- If true, any admin already in the list (not just super admins) can add
-- or remove other admins from the panel. Leave false if you only want
-- the people in Config.SuperAdmins to be able to do that.
Config.AdminsCanManageAdmins = false

-- Storage backend:
--   'file'    -> zero setup, saves to data/admins.json inside this resource
--   'oxmysql' -> requires the oxmysql resource + the table in install.sql
Config.Storage = 'file'
