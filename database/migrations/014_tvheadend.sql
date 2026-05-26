-- TVHeadend Live TV Sources
CREATE TABLE IF NOT EXISTS `tvheadend_sources` (
    `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `tenant_id`     INT UNSIGNED NOT NULL DEFAULT 1,
    `name`          VARCHAR(255) NOT NULL DEFAULT 'TVHeadend Server',
    `server_url`    VARCHAR(500) NOT NULL,
    `username`      VARCHAR(255) DEFAULT NULL,
    `password`      VARCHAR(255) DEFAULT NULL,
    `stream_profile` VARCHAR(100) DEFAULT 'pass',
    `is_active`     TINYINT(1) NOT NULL DEFAULT 1,
    `last_sync`     TIMESTAMP NULL DEFAULT NULL,
    `sync_count`    INT UNSIGNED DEFAULT 0,
    `created_at`    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at`    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_tenant` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- اضافه کردن source_id به کانال‌های IPTV برای ردیابی منبع
ALTER TABLE `iptv_channels`
    ADD COLUMN IF NOT EXISTS `source_type`  VARCHAR(20) DEFAULT 'manual'   AFTER `is_active`,
    ADD COLUMN IF NOT EXISTS `source_id`    INT UNSIGNED DEFAULT NULL       AFTER `source_type`,
    ADD COLUMN IF NOT EXISTS `tvh_uuid`     VARCHAR(100) DEFAULT NULL       AFTER `source_id`;
