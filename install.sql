-- Only needed if Config.Storage = 'oxmysql' in config.lua.
-- Run this once against your database, then restart the resource.

CREATE TABLE IF NOT EXISTS `syx_admins` (
  `license`    VARCHAR(64) NOT NULL,
  `name`       VARCHAR(64) NOT NULL,
  `added_by`   VARCHAR(64) NOT NULL,
  `added_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
