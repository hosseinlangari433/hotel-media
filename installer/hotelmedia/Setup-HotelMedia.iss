; ============================================================================
;  HotelMedia — Persian one-click Windows installer (NO Docker, offline bundle)
;  سماع رایانه کیش | kishwifi.com
;
;  Produces Setup-HotelMedia.exe. A non-technical user double-clicks it, types
;  (optionally) the hotel name, clicks Next a few times — and at the end gets a
;  Desktop icon that opens the ready-to-use panel. Everything (PHP + MariaDB +
;  realtime server) is bundled and installed as auto-start Windows services.
;
;  Build (done by build-hotelmedia.ps1 / build.bat):
;     ISCC /DMyAppVersion=1.7.2 /DPayloadDir="...\dist\hm-payload" Setup-HotelMedia.iss
; ============================================================================

#ifndef MyAppVersion
  #define MyAppVersion "1.7.2"
#endif
#ifndef PayloadDir
  #define PayloadDir "..\..\dist\hm-payload"
#endif

#define MyAppName     "هتل مدیا"
#define MyAppNameEn   "HotelMedia"
#define MyAppPublisher "سماع رایانه کیش — kishwifi.com"
#define MyAppURL      "https://kishwifi.com"

[Setup]
AppId={{9C7A3F21-5E4D-4B8A-9D12-6F0E3C7A1B55}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
DefaultDirName=C:\HotelMedia
DisableProgramGroupPage=yes
DisableDirPage=no
DisableReadyPage=no
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
OutputDir=.\Output
OutputBaseFilename=Setup-HotelMedia
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\runtime\tray\hotelmedia.ico
SetupIconFile={#PayloadDir}\runtime\tray\hotelmedia.ico
ShowLanguageDialog=no

[Languages]
Name: "fa"; MessagesFile: "compiler:Default.isl"

[LangOptions]
RightToLeft=yes
DialogFontName=Tahoma
DialogFontSize=9
WelcomeFontName=Tahoma
TitleFontName=Tahoma
CopyrightFontName=Tahoma

; ── Persian overrides for the built-in wizard text ──────────────────────────
[Messages]
SetupWindowTitle=نصب %1
SetupAppTitle=نصب
WelcomeLabel1=به نصب‌کننده‌ی [name] خوش آمدید
WelcomeLabel2=این برنامه روی رایانه‌ی شما نصب خواهد شد.%n%nنیازی به هیچ پیش‌نیازی (Docker، دیتابیس و ...) نیست — همه چیز خودکار نصب می‌شود.%n%nبرای ادامه روی «بعدی» کلیک کنید.
ClickNext=برای ادامه «بعدی» و برای خروج «انصراف» را بزنید.
ButtonNext=بعدی >
ButtonBack=< قبلی
ButtonCancel=انصراف
ButtonInstall=نصب
ButtonFinish=پایان
ButtonBrowse=انتخاب...
SelectDirDesc=[name] در کدام پوشه نصب شود؟
SelectDirLabel3=برنامه در پوشه‌ی زیر نصب می‌شود.
SelectDirBrowseLabel=برای ادامه «بعدی» را بزنید. اگر می‌خواهید پوشه‌ی دیگری انتخاب کنید «انتخاب...» را بزنید.
DiskSpaceMBLabel=حداقل [mb] مگابایت فضای خالی لازم است.
ReadyLabel1=نصب‌کننده آماده‌ی نصب [name] روی رایانه‌ی شماست.
ReadyLabel2a=برای شروع نصب «نصب» را بزنید.
WizardInstalling=در حال نصب
InstallingLabel=لطفاً تا پایان نصب [name] صبر کنید.
FinishedHeadingLabel=نصب [name] کامل شد
FinishedLabelNoIcons=نصب [name] با موفقیت انجام شد.
FinishedLabel=نصب [name] با موفقیت انجام شد. برنامه آماده‌ی استفاده است و آیکون آن روی دسکتاپ قرار گرفت.
ClickFinish=برای بستن «پایان» را بزنید.
ExitSetupTitle=خروج از نصب
ExitSetupMessage=نصب کامل نشده است. اگر اکنون خارج شوید برنامه نصب نخواهد شد.%n%nآیا می‌خواهید خارج شوید؟
StatusExtractFiles=در حال کپی فایل‌ها...
WizardPreparing=در حال آماده‌سازی
PreparingDesc=در حال آماده‌سازی نصب [name] روی رایانه‌ی شما.
UninstallStatusLabel=لطفاً تا حذف کامل [name] صبر کنید...

[CustomMessages]
fa.HotelPageCaption=نام هتل
fa.HotelPageDesc=نام هتل یا مجموعه‌ی خود را وارد کنید (اختیاری)
fa.HotelPagePrompt=این نام در پنل و صفحه‌ی خوش‌آمدگویی نمایش داده می‌شود:
fa.ProvisionStatus=در حال آماده‌سازی برنامه و دیتابیس... این مرحله ممکن است چند دقیقه طول بکشد. لطفاً صبر کنید.
fa.NoInternetTitle=اتصال اینترنت
fa.ProvisionFailed=متأسفانه نصب کامل نشد. برنامه به‌طور خودکار پاک‌سازی شد.%n%nلطفاً دوباره تلاش کنید یا با پشتیبانی تماس بگیرید (kishwifi.com).
fa.AskRemoveData=آیا می‌خواهید اطلاعات هتل (دیتابیس، رسانه‌ها و تنظیمات) هم به‌طور کامل پاک شود؟%n%n«بله» = حذف کامل همه‌چیز.%n«خیر» = برنامه حذف می‌شود ولی اطلاعات شما نگه داشته می‌شود.
fa.OpenPanel=باز کردن پنل هتل مدیا
fa.RunTray=اجرای هتل مدیا

[Files]
Source: "{#PayloadDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Dirs]
Name: "{app}\data";             Permissions: users-modify
Name: "{app}\storage\logs";     Permissions: users-modify
Name: "{app}\storage\cache";    Permissions: users-modify
Name: "{app}\storage\sessions"; Permissions: users-modify
Name: "{app}\storage\temp";     Permissions: users-modify
Name: "{app}\public\uploads";   Permissions: users-modify

[Icons]
; Desktop icon → opens the panel (and starts the tray if not running).
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\runtime\tray\HotelMediaTray.exe"; Parameters: "open"; IconFilename: "{app}\runtime\tray\hotelmedia.ico"; Comment: "{cm:OpenPanel}"
; Tray runs at logon.
Name: "{userstartup}\{#MyAppNameEn} Tray"; Filename: "{app}\runtime\tray\HotelMediaTray.exe"; IconFilename: "{app}\runtime\tray\hotelmedia.ico"
; Start-menu group.
Name: "{group}\{cm:OpenPanel}"; Filename: "{app}\runtime\tray\HotelMediaTray.exe"; Parameters: "open"; IconFilename: "{app}\runtime\tray\hotelmedia.ico"
Name: "{group}\حذف هتل مدیا"; Filename: "{uninstallexe}"

[Run]
; Launch the tray right after install, as the logged-in user (not elevated).
Filename: "{app}\runtime\tray\HotelMediaTray.exe"; Flags: nowait postinstall skipifsilent runasoriginaluser; Description: "{cm:RunTray}"

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File ""{app}\runtime\scripts\uninstall-hm.ps1"" -InstallDir ""{app}"""; Flags: runhidden waituntilterminated; RunOnceId: "HotelMediaDown"

[Code]
var
  HotelPage: TInputQueryWizardPage;

procedure InitializeWizard();
begin
  HotelPage := CreateInputQueryPage(wpSelectDir,
    ExpandConstant('{cm:HotelPageCaption}'),
    ExpandConstant('{cm:HotelPageDesc}'),
    ExpandConstant('{cm:HotelPagePrompt}'));
  HotelPage.Add('', False);
  HotelPage.Values[0] := 'هتل مدیا';
end;

function GetHotelName(): String;
begin
  Result := Trim(HotelPage.Values[0]);
  if Result = '' then Result := 'هتل مدیا';
end;

{ Run the provisioning (hidden) during post-install; roll back on failure. }
procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
  Cmd, Params: String;
begin
  if CurStep = ssPostInstall then
  begin
    { Write the hotel name (Unicode Inno saves SaveStringToFile as UTF-8). }
    ForceDirectories(ExpandConstant('{app}\runtime'));
    SaveStringToFile(ExpandConstant('{app}\runtime\hotelname.txt'), GetHotelName(), False);

    WizardForm.StatusLabel.Caption := ExpandConstant('{cm:ProvisionStatus}');
    WizardForm.ProgressGauge.Style := npbstMarquee;

    Cmd := 'powershell.exe';
    Params := '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' +
      ExpandConstant('{app}\runtime\scripts\provision-hm.ps1') + '" -InstallDir "' +
      ExpandConstant('{app}') + '"';

    if not Exec(Cmd, Params, ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      ResultCode := -1;

    WizardForm.ProgressGauge.Style := npbstNormal;

    if ResultCode <> 0 then
    begin
      { Clean up any partial install, then abort so Inno rolls back the files. }
      Exec('powershell.exe',
        '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "' +
        ExpandConstant('{app}\runtime\scripts\uninstall-hm.ps1') + '" -InstallDir "' +
        ExpandConstant('{app}') + '"',
        '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      MsgBox(ExpandConstant('{cm:ProvisionFailed}'), mbCriticalError, MB_OK);
      RaiseException('Provisioning failed');
    end;
  end;
end;

{ Uninstall: ask (Persian) whether to wipe the hotel data folder. }
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  DataDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    DataDir := ExpandConstant('{app}\data');
    { Ask only if there is actually hotel data to lose. }
    if DirExists(DataDir) then
    begin
      if MsgBox(ExpandConstant('{cm:AskRemoveData}'), mbConfirmation, MB_YESNO) = IDYES then
        { Wipe everything — including the untracked data/logs/.env left behind. }
        DelTree(ExpandConstant('{app}'), True, True, True);
      { On "No" we keep the data: Inno already removed the program files it
        tracked, and data\, .env and uploads are left in place on purpose. }
    end;
  end;
end;
