# Main Telemetry Registry Keys

A short reference of the registry keys in `script/telemetry-win.ps1` that control how Windows **collects and sends** telemetry.
The script sets ~450 values. Most of them are UI, ads, search or personalization tweaks. The keys below are the ones that control the data pipeline itself.

Values are the ones the script writes. All are `DWORD` unless noted. Every path is written in full, so you can paste it into the Registry Editor address bar.

## "Key not found" is normal

Many of these keys **do not exist on a clean Windows install**. Windows only creates them once the setting is changed, and `telemetry-win.ps1` creates every missing key before writing the value (`Set-RegistryValue`, `New-Item -Force`).

- **`...\Policies\...` keys:** Group Policy keys. They are absent until a policy is set by the script, `gpedit.msc` or an MDM. A missing policy key means "not configured", and Windows uses its default.
- **Keys Windows doesn't create at all:** `Diagnostics\DiagTrack\TestHooks`, `Diagnostics\DiagTrack\EventTranscriptKey` and the `Image File Execution Options\CompatTelRunner.exe` key only exist after the script creates them.
- **Edition and build dependent:** `PolicyManager\current\device\System`, `WindowsAI` (Recall, Windows 11 24H2+), `Speech_OneCore\...\OnlineSpeechPrivacy` (created after the privacy choices in OOBE) and `Services\dmwappushservice` (removed on some LTSC or debloated builds) may be missing.
- **Per-user `HKCU` keys:** they belong to the account that is signed in. When you check them from another account (or as SYSTEM or TrustedInstaller), you see that account's hive.

### Check your system

`script/check-telemetry-keys.ps1` is read-only. It reports each key below as `OK`, `DIFF` (a different value), `NOVALUE` (the key exists but the value doesn't) or `NOKEY` (the key doesn't exist):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\script\check-telemetry-keys.ps1
```

Run it as Administrator. Before `telemetry-win.ps1` has run, many entries will show `NOKEY` or `NOVALUE`. After it has run, they should all be `OK`. Any entry that is still missing or `DIFF` was reset by Windows or blocked.

---

## 1. Diagnostic data level (the master switch)

`AllowTelemetry = 0` sets the diagnostic data level to *Security / Off*. Every other telemetry component (DiagTrack, Appraiser, Census, WER uploads) reads this level.

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowTelemetry = 0` | Group Policy diagnostic level. **Most important key.** |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `MaxTelemetryAllowed = 0` | Upper limit for the level the user can choose in Settings |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection` | `AllowTelemetry = 0` | Non-GPO copy of the level |
| `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection` | `AllowTelemetry = 0` | Copy for 32-bit processes (64-bit Windows only) |
| `HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowTelemetry` | `value = 0` | MDM / CSP copy (used on Home editions) |
| `HKCU\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowTelemetry = 0` | Per-user copy |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowDeviceNameInTelemetry = 0` | Keeps the device name out of diagnostic data |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowCommercialDataPipeline = 0` | Turns off the commercial (enterprise) data pipeline |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowDesktopAnalyticsProcessing = 0` | Turns off Desktop Analytics processing |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowUpdateComplianceProcessing = 0` | Turns off Update Compliance processing |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowWUfBCloudProcessing = 0` | Turns off Windows Update for Business cloud processing |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `DisableOneSettingsDownloads = 1` | Stops downloading remote telemetry configuration (OneSettings) |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `LimitDiagnosticLogCollection = 1` | Limits extra diagnostic log collection |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `MicrosoftEdgeDataOptIn = 0` | Stops Edge browsing data from being added to Windows diagnostic data |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `DoNotShowFeedbackNotifications = 1` | Turns off feedback prompts |

---

## 2. DiagTrack: Connected User Experiences and Telemetry

DiagTrack is the service that actually uploads diagnostic data.

| Key | Value | Effect |
|---|---|---|
| `HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack` | `Start = 4` | Disables the telemetry service |
| `HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice` | `Start = 4` | Disables the WAP push service that DiagTrack uses |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack` | `DiagTrackAuthorization = 0` | Revokes DiagTrack's permission to collect |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack` | `UploadPermissionReceived = 0` | Removes upload consent |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack` | `TelemetryServiceDisabled = 1` | Marks the telemetry service as disabled |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack` | `DisableAutomaticTelemetryKeywordReporting = 1` | Stops automatic keyword (event-category) reporting |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\TestHooks` | `DisableAsimovUpload = 1` | Blocks uploads to Asimov, the telemetry back end |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey` | `EnableEventTranscript = 0` | Turns off the local event transcript (Diagnostic Data Viewer store) |

---

## 3. ETW AutoLoggers (event collection at boot)

These trace sessions record events from early boot and feed them to DiagTrack. `Start = 0` keeps them from starting.

| Key | Value |
|---|---|
| `HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener` | `Start = 0` |
| `HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener` | `Start = 0` |
| `HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SQMLogger` | `Start = 0` |
| `HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SetupPlatformTel` | `Start = 0` |
| `HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe` | `Start = 0` |

---

## 4. Application compatibility telemetry (Appraiser / Inventory / Census)

These components run as `CompatTelRunner.exe` and collect an inventory of installed apps, drivers and hardware.

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat` | `AITEnable = 0` | Turns off Application Impact Telemetry |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat` | `DisableInventory = 1` | Turns off Inventory Collector (app/driver inventory) |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat` | `DisableUAR = 1` | Turns off Steps Recorder (User Activity Recording) |
| `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry` | `TaskEnableRun = 0` | Stops the compatibility telemetry task from running |
| `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry` | `IsCensusDisabled = 1` | Turns off Census (device and configuration inventory) |
| `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TelemetryController` | `RunsBlocked = 1` | Blocks TelemetryController scheduled runs |
| `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe` | `Debugger = %windir%\System32\taskkill.exe` (String) | Kills `CompatTelRunner.exe` every time it starts |

---

## 5. Customer Experience Improvement Program (SQM / CEIP)

| Key | Value |
|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows` | `CEIPEnable = 0` |
| `HKLM\SOFTWARE\Microsoft\SQMClient\Windows` | `CEIPEnable = 0` |

---

## 6. Windows Error Reporting (crash data upload)

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting` | `Disabled = 1` | Turns off WER (policy) |
| `HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting` | `Disabled = 1` | Turns off WER (local setting) |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting` | `DontSendAdditionalData = 1` | Never sends dumps or extra files |
| `HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent` | `DefaultConsent = 0` | No default upload consent |
| `HKLM\SYSTEM\DriverDatabase\Policies\Settings` | `DisableSendGenericDriverNotFoundToWER = 1` | Stops "driver not found" reports |
| `HKLM\SYSTEM\CurrentControlSet\Control\StorPort` | `TelemetryPerformanceEnabled = 0` | Turns off storage driver performance telemetry |
| `HKLM\SYSTEM\CurrentControlSet\Control\StorPort` | `TelemetryErrorDataEnabled = 0` | Turns off storage driver error telemetry |
| `HKLM\SYSTEM\CurrentControlSet\Control\StorPort` | `TelemetryDeviceHealthEnabled = 0` | Turns off storage device health telemetry |

---

## 7. Activity history, experiments and tailored data

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\System` | `EnableActivityFeed = 0` | Activity history (Timeline) is off |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\System` | `PublishUserActivities = 0` | Activities are not collected |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\System` | `UploadUserActivities = 0` | Activities are not uploaded |
| `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System` | `AllowExperimentation = 0` | No feature experiments (flighting) on the device |
| `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy` | `TailoredExperiencesWithDiagnosticDataEnabled = 0` | Diagnostic data is not used for tips and ads |
| `HKCU\Software\Policies\Microsoft\Windows\CloudContent` | `DisableTailoredExperiencesWithDiagnosticData = 1` | Same as above, as a policy |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo` | `DisabledByGroupPolicy = 1` | Turns off the Advertising ID |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI` | `DisableAIDataAnalysis = 1` | Turns off Recall snapshot collection |

---

## 8. Input and speech data collection

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization` | `RestrictImplicitInkCollection = 1` | Inking data is not collected |
| `HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization` | `RestrictImplicitTextCollection = 1` | Typing data is not collected |
| `HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization` | `AllowInputPersonalization = 0` | Turns off input personalization |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput` | `AllowLinguisticDataCollection = 0` | Linguistic data is not sent |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC` | `PreventHandwritingDataSharing = 1` | Handwriting samples are not shared |
| `HKCU\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy` | `HasAccepted = 0` | Online speech recognition is off |

---

## Keys re-applied at every startup

The `TelemetryOFF` scheduled task (`%ProgramData%\Scripts\Fix-Telemetry.ps1`) only re-applies these three keys, because Windows updates tend to reset them:

1. `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` → `AllowTelemetry = 0`
2. `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry` → `TaskEnableRun = 0`
3. `HKLM\SYSTEM\DriverDatabase\Policies\Settings` → `DisableSendGenericDriverNotFoundToWER = 1`

Good candidates to add to that list:

- `HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack` → `Start = 4`
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack` → `DiagTrackAuthorization = 0`
- `HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener` → `Start = 0`

Updates often reset these too.

---

> **Note:** On Home and Pro editions, Windows clamps `AllowTelemetry = 0` to `1` (Required). The DiagTrack service, AutoLogger and AppCompat keys above are what actually stop the collection on those editions.
