<?php
declare(strict_types=1);
namespace App\Controllers\Web;

use App\Core\{Controller, Request};

class HelpController extends Controller
{
    public function index(Request $req): void
    {
        $this->view('admin.help.index', ['title' => 'راهنما']);
    }
}
