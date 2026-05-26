-- ── 016 Screen Messages — Scheduled Greeting/Announcement System ─────────
CREATE TABLE IF NOT EXISTS `screen_messages` (
    `id`           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `tenant_id`    INT UNSIGNED    NOT NULL DEFAULT 1,
    `title`        VARCHAR(500)    NOT NULL,
    `title_en`     VARCHAR(500)    DEFAULT NULL,
    `title_ar`     VARCHAR(500)    DEFAULT NULL,
    `body`         TEXT            NOT NULL,
    `body_en`      TEXT            DEFAULT NULL,
    `body_ar`      TEXT            DEFAULT NULL,
    `type`         ENUM('welcome','congratulation','announcement','warning','info')
                                   NOT NULL DEFAULT 'announcement',
    `style`        ENUM('overlay','fullscreen','popup','banner')
                                   NOT NULL DEFAULT 'overlay',
    `icon`         VARCHAR(10)     DEFAULT NULL COMMENT 'emoji icon',
    `bg_color`     VARCHAR(20)     NOT NULL DEFAULT '#1a1a2e',
    `text_color`   VARCHAR(20)     NOT NULL DEFAULT '#ffffff',
    `accent_color` VARCHAR(20)     NOT NULL DEFAULT '#f97316',
    `target`       ENUM('all','screen','group')
                                   NOT NULL DEFAULT 'all',
    `target_ids`   JSON            DEFAULT NULL COMMENT 'array of screen/group IDs',
    `start_at`     DATETIME        NOT NULL,
    `end_at`       DATETIME        DEFAULT NULL,
    `duration`     INT UNSIGNED    NOT NULL DEFAULT 15 COMMENT 'seconds to show per display',
    `repeat_type`  ENUM('once','daily','weekly','monthly')
                                   NOT NULL DEFAULT 'once',
    `repeat_days`  VARCHAR(20)     DEFAULT NULL COMMENT 'comma-separated 0-6 (Sun-Sat)',
    `repeat_time`  TIME            DEFAULT NULL COMMENT 'time of day for repeating messages',
    `show_count`   INT UNSIGNED    NOT NULL DEFAULT 0,
    `is_active`    TINYINT(1)      NOT NULL DEFAULT 1,
    `created_by`   INT UNSIGNED    DEFAULT NULL,
    `created_at`   TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`   TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_tenant_active`   (`tenant_id`, `is_active`),
    INDEX `idx_schedule`        (`start_at`, `end_at`, `is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
