<?php
declare(strict_types=1);
namespace App\Controllers\Web;

use App\Core\{Controller, Request, Auth, Response, Lang};

class MessagesController extends Controller
{
    // ── لیست پیام‌ها ─────────────────────────────────────────────────────
    public function index(Request $req): void
    {
        $tid = Auth::tenantId();
        $this->ensureTable();

        $messages = $this->db->rows(
            "SELECT m.*,
                    CASE
                        WHEN m.end_at IS NULL AND NOW() >= m.start_at THEN 'live'
                        WHEN m.end_at IS NOT NULL AND NOW() BETWEEN m.start_at AND m.end_at THEN 'live'
                        WHEN NOW() < m.start_at THEN 'scheduled'
                        ELSE 'ended'
                    END AS state
             FROM screen_messages m
             WHERE m.tenant_id = ?
             ORDER BY m.start_at DESC",
            [$tid]
        ) ?: [];

        $screens = $this->db->rows(
            "SELECT id, name, code FROM screens WHERE tenant_id=? AND status='active' ORDER BY name",
            [$tid]
        ) ?: [];

        $groups = [];
        try {
            $groups = $this->db->rows(
                "SELECT id, name, type FROM screen_groups WHERE tenant_id=? ORDER BY name",
                [$tid]
            ) ?: [];
        } catch (\Throwable $e) {}

        $this->view('admin.messages.index', [
            'title'    => __('messages.title'),
            'messages' => $messages,
            'screens'  => $screens,
            'groups'   => $groups,
        ]);
    }

    // ── ایجاد پیام جدید ────────────────────────────────────────────────
    public function store(Request $req): void
    {
        $tid = Auth::tenantId();
        $this->ensureTable();

        $types  = ['welcome','congratulation','announcement','warning','info'];
        $styles = ['overlay','fullscreen','popup','banner'];
        $repeats = ['once','daily','weekly','monthly'];
        $targets = ['all','screen','group'];

        $targetIds = null;
        if ($req->post('target') !== 'all') {
            $ids = array_filter(array_map('intval', (array)$req->post('target_ids', [])));
            if ($ids) $targetIds = json_encode(array_values($ids));
        }

        // تبدیل end_at خالی به null
        $endAt = trim($req->post('end_at', ''));

        $data = [
            'tenant_id'    => $tid,
            'title'        => trim($req->post('title', '')),
            'title_en'     => trim($req->post('title_en', '')) ?: null,
            'title_ar'     => trim($req->post('title_ar', '')) ?: null,
            'body'         => trim($req->post('body', '')),
            'body_en'      => trim($req->post('body_en', '')) ?: null,
            'body_ar'      => trim($req->post('body_ar', '')) ?: null,
            'type'         => in_array($req->post('type'), $types) ? $req->post('type') : 'announcement',
            'style'        => in_array($req->post('style'), $styles) ? $req->post('style') : 'overlay',
            'icon'         => trim($req->post('icon', '')) ?: null,
            'bg_color'     => preg_match('/^#[0-9a-fA-F]{6}$/', $req->post('bg_color','')) ? $req->post('bg_color') : '#1a1a2e',
            'text_color'   => preg_match('/^#[0-9a-fA-F]{6}$/', $req->post('text_color','')) ? $req->post('text_color') : '#ffffff',
            'accent_color' => preg_match('/^#[0-9a-fA-F]{6}$/', $req->post('accent_color','')) ? $req->post('accent_color') : '#f97316',
            'target'       => in_array($req->post('target'), $targets) ? $req->post('target') : 'all',
            'target_ids'   => $targetIds,
            'start_at'     => $req->post('start_at', date('Y-m-d H:i:s')),
            'end_at'       => $endAt ?: null,
            'duration'     => max(5, min(300, (int)$req->post('duration', 15))),
            'repeat_type'  => in_array($req->post('repeat_type'), $repeats) ? $req->post('repeat_type') : 'once',
            'repeat_days'  => $req->post('repeat_days', '') ?: null,
            'repeat_time'  => $req->post('repeat_time', '') ?: null,
            'is_active'    => 1,
            'created_by'   => Auth::id(),
        ];

        if (!$data['title'] || !$data['body']) {
            $this->flash('error', 'عنوان و متن پیام الزامی است');
            $this->redirect('/admin/messages');
            return;
        }

        $this->db->insert('screen_messages', $data);
        $this->flash('success', __('messages.created'));
        $this->redirect('/admin/messages');
    }

    // ── حذف پیام ────────────────────────────────────────────────────────
    public function delete(Request $req, array $params): void
    {
        $tid = Auth::tenantId();
        $this->ensureTable();

        $this->db->query(
            "DELETE FROM screen_messages WHERE id=? AND tenant_id=?",
            [(int)$params['id'], $tid]
        );
        $this->flash('success', __('messages.deleted'));
        $this->redirect('/admin/messages');
    }

    // ── تغییر وضعیت فعال/غیرفعال ────────────────────────────────────────
    public function toggle(Request $req, array $params): void
    {
        $tid = Auth::tenantId();
        $this->ensureTable();

        $msg = $this->db->row(
            "SELECT id, is_active FROM screen_messages WHERE id=? AND tenant_id=?",
            [(int)$params['id'], $tid]
        );
        if ($msg) {
            $this->db->update('screen_messages',
                ['is_active' => $msg['is_active'] ? 0 : 1],
                ['id' => $msg['id']]
            );
        }
        Response::json(['success' => true]);
    }

    // ── API: پیام‌های در حال نمایش برای یک صفحه ────────────────────────
    public static function getPendingForScreen(int $screenId, int $tenantId): array
    {
        try {
            $db = \App\Core\Database::getInstance();

            // صفحه + گروه آن
            $screen = $db->row("SELECT group_id FROM screens WHERE id=?", [$screenId]);
            $gid    = $screen['group_id'] ?? null;

            // پیام‌هایی که:
            // - active هستند
            // - الان بین start_at و end_at هستند (یا end_at = null)
            // - برای این تنانت هستند
            // - target شامل این صفحه می‌شه
            $now     = date('Y-m-d H:i:s');
            $msgs    = $db->rows(
                "SELECT * FROM screen_messages
                 WHERE tenant_id = ?
                   AND is_active = 1
                   AND start_at <= ?
                   AND (end_at IS NULL OR end_at >= ?)
                 ORDER BY start_at DESC
                 LIMIT 5",
                [$tenantId, $now, $now]
            ) ?: [];

            $result = [];
            foreach ($msgs as $m) {
                // بررسی target
                if ($m['target'] === 'all') {
                    $result[] = $m;
                } elseif ($m['target'] === 'screen') {
                    $ids = json_decode($m['target_ids'] ?? '[]', true) ?: [];
                    if (in_array($screenId, $ids)) $result[] = $m;
                } elseif ($m['target'] === 'group' && $gid) {
                    $ids = json_decode($m['target_ids'] ?? '[]', true) ?: [];
                    if (in_array($gid, $ids)) $result[] = $m;
                }
            }

            return $result;
        } catch (\Throwable $e) {
            return [];
        }
    }

    // ── اطمینان از وجود جدول ────────────────────────────────────────────
    private function ensureTable(): void
    {
        try {
            $this->db->query("
                CREATE TABLE IF NOT EXISTS `screen_messages` (
                    `id`           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
                    `tenant_id`    INT UNSIGNED    NOT NULL DEFAULT 1,
                    `title`        VARCHAR(500)    NOT NULL,
                    `title_en`     VARCHAR(500)    DEFAULT NULL,
                    `title_ar`     VARCHAR(500)    DEFAULT NULL,
                    `body`         TEXT            NOT NULL,
                    `body_en`      TEXT            DEFAULT NULL,
                    `body_ar`      TEXT            DEFAULT NULL,
                    `type`         ENUM('welcome','congratulation','announcement','warning','info') NOT NULL DEFAULT 'announcement',
                    `style`        ENUM('overlay','fullscreen','popup','banner') NOT NULL DEFAULT 'overlay',
                    `icon`         VARCHAR(10)     DEFAULT NULL,
                    `bg_color`     VARCHAR(20)     NOT NULL DEFAULT '#1a1a2e',
                    `text_color`   VARCHAR(20)     NOT NULL DEFAULT '#ffffff',
                    `accent_color` VARCHAR(20)     NOT NULL DEFAULT '#f97316',
                    `target`       ENUM('all','screen','group') NOT NULL DEFAULT 'all',
                    `target_ids`   JSON            DEFAULT NULL,
                    `start_at`     DATETIME        NOT NULL,
                    `end_at`       DATETIME        DEFAULT NULL,
                    `duration`     INT UNSIGNED    NOT NULL DEFAULT 15,
                    `repeat_type`  ENUM('once','daily','weekly','monthly') NOT NULL DEFAULT 'once',
                    `repeat_days`  VARCHAR(20)     DEFAULT NULL,
                    `repeat_time`  TIME            DEFAULT NULL,
                    `show_count`   INT UNSIGNED    NOT NULL DEFAULT 0,
                    `is_active`    TINYINT(1)      NOT NULL DEFAULT 1,
                    `created_by`   INT UNSIGNED    DEFAULT NULL,
                    `created_at`   TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP,
                    `updated_at`   TIMESTAMP       NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    PRIMARY KEY (`id`),
                    INDEX `idx_tenant_active` (`tenant_id`, `is_active`),
                    INDEX `idx_schedule`      (`start_at`, `end_at`, `is_active`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ");
        } catch (\Throwable $e) {}
    }
}
