; Inno Setup script for the Windows installer (built by .github/workflows/windows.yml).
#define AppName "Navo"
#ifndef AppVersion
  #define AppVersion "1.2.0"
#endif

[Setup]
AppId={{6B1C2E7A-4F0D-4C55-9A3E-8E2B7D51C0A4}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher=Feruzbek Namozboyev
AppPublisherURL=https://github.com/Feruzbek0318/navo-music-player
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=..\..\build\release
OutputBaseFilename=Navo-{#AppVersion}-windows-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\Navo.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\Navo.exe"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\Navo.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Navo.exe"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
