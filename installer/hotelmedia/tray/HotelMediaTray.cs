// ============================================================================
//  HotelMedia — System Tray companion (Persian)
//  سماع رایانه کیش | kishwifi.com
//
//  A tiny WinForms tray app. No installer / no dependencies beyond the .NET
//  Framework that ships with Windows 10/11. Compiled at build time with the
//  in-box csc.exe — see the build script.
//
//  Usage:
//    HotelMediaTray.exe         -> run the tray (started at logon)
//    HotelMediaTray.exe open    -> open the panel; used by the Desktop icon.
//                                  If the tray is already running, this second
//                                  instance just opens the browser and exits.
//
//  Tray menu (RTL Persian):
//      باز کردن پنل      -> open panel (/admin)
//      نمایش رمز ورود     -> open the welcome page with credentials (/welcome.php)
//      راه‌اندازی مجدد    -> restart the 3 Windows services (elevated, hidden)
//      خروج              -> quit the tray (services keep running)
// ============================================================================
using System;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Threading;
using System.Windows.Forms;

namespace HotelMedia
{
    static class Program
    {
        static string InstallDir;
        static NotifyIcon Tray;

        [STAThread]
        static void Main(string[] args)
        {
            // The tray exe lives in <InstallDir>\runtime\tray\HotelMediaTray.exe
            string exeDir = AppDomain.CurrentDomain.BaseDirectory;
            InstallDir = Directory.GetParent(Directory.GetParent(exeDir.TrimEnd('\\')).FullName).FullName;

            bool wantOpen = args.Length > 0 && args[0].Equals("open", StringComparison.OrdinalIgnoreCase);

            bool isFirst;
            using (var mutex = new Mutex(true, "HotelMediaTraySingleton", out isFirst))
            {
                if (!isFirst)
                {
                    // Tray already running: just open the panel (if asked) and exit.
                    if (wantOpen) OpenPanel();
                    return;
                }

                Application.EnableVisualStyles();
                Application.SetCompatibleTextRenderingDefault(false);

                var menu = new ContextMenuStrip { RightToLeft = RightToLeft.Yes };
                menu.Items.Add("باز کردن پنل", null, (s, e) => OpenPanel());
                menu.Items.Add("نمایش رمز ورود", null, (s, e) => OpenWelcome());
                menu.Items.Add(new ToolStripSeparator());
                menu.Items.Add("راه‌اندازی مجدد", null, (s, e) => RestartServices());
                menu.Items.Add(new ToolStripSeparator());
                menu.Items.Add("خروج", null, (s, e) => { Tray.Visible = false; Application.Exit(); });

                Tray = new NotifyIcon
                {
                    Icon = LoadIcon(exeDir),
                    Text = "هتل مدیا",
                    Visible = true,
                    ContextMenuStrip = menu
                };
                Tray.DoubleClick += (s, e) => OpenPanel();
                Tray.BalloonTipTitle = "هتل مدیا";
                Tray.BalloonTipText = "برنامه در حال اجراست. برای باز کردن پنل دابل‌کلیک کنید.";
                Tray.ShowBalloonTip(4000);

                if (wantOpen) OpenPanel();

                Application.Run();
            }
        }

        static Icon LoadIcon(string exeDir)
        {
            try
            {
                string ico = Path.Combine(exeDir, "hotelmedia.ico");
                if (File.Exists(ico)) return new Icon(ico);
            }
            catch { }
            return SystemIcons.Application;
        }

        static string BaseUrl()
        {
            try
            {
                string env = Path.Combine(InstallDir, ".env");
                if (File.Exists(env))
                    foreach (var line in File.ReadAllLines(env))
                    {
                        var t = line.Trim();
                        if (t.StartsWith("APP_URL="))
                            return t.Substring("APP_URL=".Length).Trim().Trim('"');
                    }
            }
            catch { }
            return "http://localhost";
        }

        static void OpenPanel()
        {
            try { Process.Start(BaseUrl() + "/admin"); }
            catch { Notify("امکان باز کردن پنل نبود."); }
        }

        static void OpenWelcome()
        {
            try { Process.Start(BaseUrl() + "/welcome.php"); }
            catch { Notify("امکان باز کردن صفحه نبود."); }
        }

        static void RestartServices()
        {
            try
            {
                string script = Path.Combine(InstallDir, "runtime", "scripts", "Manage-HotelMedia.ps1");
                var psi = new ProcessStartInfo
                {
                    FileName = "powershell.exe",
                    Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" + script + "\" restart",
                    UseShellExecute = true,
                    Verb = "runas",            // elevate (restarting services needs admin)
                    WindowStyle = ProcessWindowStyle.Hidden
                };
                Process.Start(psi);
                Notify("در حال راه‌اندازی مجدد برنامه...");
            }
            catch { Notify("راه‌اندازی مجدد لغو شد."); }
        }

        static void Notify(string msg)
        {
            if (Tray == null) return;
            Tray.BalloonTipTitle = "هتل مدیا";
            Tray.BalloonTipText = msg;
            Tray.ShowBalloonTip(3000);
        }
    }
}
