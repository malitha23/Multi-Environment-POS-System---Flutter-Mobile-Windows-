#define MyAppName "My Pos System"
#define MyAppVersion "1.0"
#define MyAppPublisher "My Company, Inc."
#define MyAppURL "https://www.example.com/"
#define MyAppExeName "shop_pos_system_app.exe"
#define MyAppAssocName MyAppName + " File"
#define MyAppAssocExt ".myp"
#define MyAppAssocKey StringChange(MyAppAssocName, " ", "") + MyAppAssocExt

[Setup]
AppId={{39623141-D341-47F6-A109-C1B8E61E4A59}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=yes
DisableProgramGroupPage=yes
OutputDir=F:\github\shop_pos_system_app\installer_exe
OutputBaseFilename=mysetup
SetupIconFile=C:\Users\Malith\Downloads\2656425.ico
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Main EXE
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; Flutter runtime DLL (essential)
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion

; Copy entire data folder (app.so, flutter_assets, icudtl.dat, etc.) inside {app}\data
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

; Plugin DLLs
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\file_saver_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\file_selector_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\pdfium.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\permission_handler_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\print_bluetooth_thermal_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\printing_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\rive_common_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\screen_retriever_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\github\shop_pos_system_app\build\windows\x64\runner\Release\window_manager_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion

; Additional DLLs your app needs
Source: "C:\Users\Malith\Downloads\dlls\SQLite3.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Malith\Downloads\dlls\msvcp140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Malith\Downloads\dlls\vcruntime140.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\Malith\Downloads\dlls\vcruntime140_1.dll"; DestDir: "{app}"; Flags: ignoreversion

[Registry]
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocExt}\OpenWithProgids"; ValueType: string; ValueName: "{#MyAppAssocKey}"; ValueData: ""; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}"; ValueType: string; ValueName: ""; ValueData: "{#MyAppAssocName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#MyAppExeName},0"
Root: HKA; Subkey: "Software\Classes\{#MyAppAssocKey}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent; WorkingDir: "{app}"
