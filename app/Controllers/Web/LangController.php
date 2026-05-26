<?php
declare(strict_types=1);
namespace App\Controllers\Web;

use App\Core\{Controller, Request, Lang};

class LangController extends Controller
{
    public function switch(Request $req, array $params): void
    {
        $lang = $params['lang'] ?? 'fa';
        Lang::set($lang);

        // بازگشت به صفحه قبلی یا داشبورد
        $referer = $_SERVER['HTTP_REFERER'] ?? '/admin/dashboard';
        // اطمینان از اینکه referer داخلی است
        $host = $_SERVER['HTTP_HOST'] ?? '';
        if ($host && str_contains($referer, $host)) {
            $this->redirect($referer);
        } else {
            $this->redirect('/admin/dashboard');
        }
    }
}
