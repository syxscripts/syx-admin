# syx-admin

License-based admin list with an in-game panel, so you don't have to hand
edit `server.cfg` ace/principal lines every time you want to trust someone.
Other Syntax scripts (syx-handling, syx-weapon-modifier) accept this as an
admin source automatically, alongside their existing ace permission.

## Install

1. Put `syx-ui` and `syx-admin` in your resources folder.
2. In `server.cfg`, start `syx-ui` before `syx-admin`:
   ```
   ensure syx-ui
   ensure syx-admin
   ```
3. Open `config.lua` and add **your own** license identifier to
   `Config.SuperAdmins` - this is how you bootstrap the very first admin,
   since nobody can add anyone through the panel until at least one person
   already has access.

   To find your license: join the server once, then check your server
   console or txAdmin's player list for your identifiers, or add a
   temporary `print(GetPlayerIdentifierByType(source, 'license'))` in any
   script's `playerConnecting` handler.

4. Default storage needs nothing else - it saves to `data/admins.json`
   inside this resource automatically.

### Optional: use oxmysql instead of the JSON file
1. Set `Config.Storage = 'oxmysql'` in `config.lua`.
2. Run `install.sql` against your database once.
3. Make sure `oxmysql` starts before `syx-admin`.

## Using it

Run `/syxadmins` (super admins, or anyone already on the list, can open
it). Switch to **Add Admin**, find them in the online player list (search
by name or server id), hit **Add**. They're now an admin - permanently,
tied to their Rockstar license, so it survives name changes, Discord
changes, IP changes, everything. **Current Admins** lets you remove
anyone you added (super admins from `config.lua` can't be removed here on
purpose - edit the config file for that).

There's also a quick command version if you don't want to open the panel:
`/addadmin [server id]` and `/removeadmin [server id]`.

By default only super admins (from `config.lua`) can add/remove other
admins. Set `Config.AdminsCanManageAdmins = true` if you want every admin
to be able to add/remove other admins too.

## For other resources: checking admin status

```lua
-- server-side only
local isAdmin = exports['syx-admin']:IsAdmin(source)
local isSuperAdmin = exports['syx-admin']:IsSuperAdmin(source)
```

syx-handling and syx-weapon-modifier already call this - a player is
allowed in if they pass EITHER the ace permission check OR this export,
so you can use whichever system you prefer (or both).
