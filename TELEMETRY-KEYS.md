# Main Telemetry Registry Keys

A short reference of the registry keys in `script/telemetry-win.ps1` that control how Windows **collects and sends** telemetry.
The script sets ~450 values. Most of them are UI, ads, search or personalization tweaks. The keys below are the ones that control the data pipeline itself.

Values are the ones the script writes. All are `DWORD` unless noted.

---

## 1. Diagnostic data level (the master switch)

`AllowTelemetry = 0` sets the diagnostic data level to *Security / Off*. Every other telemetry component (DiagTrack, Appraiser, Census, WER uploads) reads this level.

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowTelemetry = 0` | Group Policy diagnostic level. **Most important key.** |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `MaxTelemetryAllowed = 0` | Upper limit for the level the user can choose in Settings |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection` | `AllowTelemetry = 0` | Non-GPO copy of the level |
| `HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection` | `AllowTelemetry = 0` | Copy for 32-bit processes |
| `HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowTelemetry` | `value = 0` | MDM / CSP copy (used on Home editions) |
| `HKCU\SOFTWARE\Policies\Microsoft\Windows\DataCollection` | `AllowTelemetry = 0` | Per-user copy |

### Related DataCollection values (same `...\Policies\Microsoft\Windows\DataCollection` key)

| Value | Set to | Effect |
|---|---|---|
| `AllowDeviceNameInTelemetry` | `0` | Keeps the device name out of diagnostic data |
| `AllowCommercialDataPipeline` | `0` | Turns off the commercial (enterprise) data pipeline |
| `AllowDesktopAnalyticsProcessing` | `0` | Turns off Desktop Analytics processing |
| `AllowUpdateComplianceProcessing` | `0` | Turns off Update Compliance processing |
| `AllowWUfBCloudProcessing` | `0` | Turns off Windows Update for Business cloud processing |
| `DisableOneSettingsDownloads` | `1` | Stops downloading remote telemetry configuration (OneSettings) |
| `LimitDiagnosticLogCollection` | `1` | Limits extra diagnostic log collection |
| `MicrosoftEdgeDataOptIn` | `0` | Stops Edge browsing data from being added to Windows diagnostic data |
| `DoNotShowFeedbackNotifications` | `1` | Turns off feedback prompts |

---

## 2. DiagTrack: Connected User Experiences and Telemetry

DiagTrack is the service that actually uploads diagnostic data.

| Key | Value | Effect |
|---|---|---|
| `HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack` | `Start = 4` | Disables the telemetry service |
| `HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice` | `Start = 4` | Disables the WAP push service that DiagTrack uses |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack` | `DiagTrackAuthorization = 0` | Revokes DiagTrack's permission to collect |
| `...\Diagnostics\DiagTrack` | `UploadPermissionReceived = 0` | Removes upload consent |
| `...\Diagnostics\DiagTrack` | `TelemetryServiceDisabled = 1` | Marks the telemetry service as disabled |
| `...\Diagnostics\DiagTrack` | `DisableAutomaticTelemetryKeywordReporting = 1` | Stops automatic keyword (event-category) reporting |
| `...\Diagnostics\DiagTrack\TestHooks` | `DisableAsimovUpload = 1` | Blocks uploads to Asimov, the telemetry back end |
| `...\Diagnostics\DiagTrack\EventTranscriptKey` | `EnableEventTranscript = 0` | Turns off the local event transcript (Diagnostic Data Viewer store) |

---

## 3. ETW AutoLoggers (event collection at boot)

These trace sessions record events from early boot and feed them to DiagTrack. `Start = 0` keeps them from starting.

| Key (`HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\…`) | Value |
|---|---|
| `AutoLogger-Diagtrack-Listener` | `Start = 0` |
| `Diagtrack-Listener` | `Start = 0` |
| `SQMLogger` | `Start = 0` |
| `SetupPlatformTel` | `Start = 0` |
| `CloudExperienceHostOobe` | `Start = 0` |

---

## 4. Application compatibility telemetry (Appraiser / Inventory / Census)

These components run as `CompatTelRunner.exe` and collect an inventory of installed apps, drivers and hardware.

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat` | `AITEnable = 0` | Turns off Application Impact Telemetry |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat` | `DisableInventory = 1` | Turns off Inventory Collector (app/driver inventory) |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat` | `DisableUAR = 1` | Turns off Steps Recorder (User Activity Recording) |
| `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry` | `TaskEnableRun = 0` | Stops the compatibility telemetry task from running |
| `...\AppCompatFlags\ClientTelemetry` | `IsCensusDisabled = 1` | Turns off Census (device and configuration inventory) |
| `...\AppCompatFlags\TelemetryController` | `RunsBlocked = 1` | Blocks TelemetryController scheduled runs |
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
| `HKLM\SYSTEM\CurrentControlSet\Control\StorPort` | `TelemetryPerformanceEnabled`, `TelemetryErrorDataEnabled`, `TelemetryDeviceHealthEnabled = 0` | Turns off storage driver telemetry |

---

## 7. Activity history, experiments and tailored data

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\System` | `EnableActivityFeed = 0`, `PublishUserActivities = 0`, `UploadUserActivities = 0` | Activity history (Timeline) is neither collected nor uploaded |
| `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System` | `AllowExperimentation = 0` | No feature experiments (flighting) on the device |
| `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy` | `TailoredExperiencesWithDiagnosticDataEnabled = 0` | Diagnostic data is not used for tips and ads |
| `HKCU\Software\Policies\Microsoft\Windows\CloudContent` | `DisableTailoredExperiencesWithDiagnosticData = 1` | Same as above, as a policy |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo` | `DisabledByGroupPolicy = 1` | Turns off the Advertising ID |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI` | `DisableAIDataAnalysis = 1` | Turns off Recall snapshot collection |

---

## 8. Input and speech data collection

| Key | Value | Effect |
|---|---|---|
| `HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization` | `RestrictImplicitInkCollection = 1`, `RestrictImplicitTextCollection = 1`, `AllowInputPersonalization = 0` | Typing and inking data is not collected |
| `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput` | `AllowLinguisticDataCollection = 0` | Linguistic data is not sent |
| `HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC` | `PreventHandwritingDataSharing = 1` | Handwriting samples are not shared |
| `HKCU\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy` | `HasAccepted = 0` | Online speech recognition is off |

---

## Keys re-applied at every startup

The `TelemetryOFF` scheduled task (`%ProgramData%\Scripts\Fix-Telemetry.ps1`) only re-applies these three keys, because Windows updates tend to reset them:

1. `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection` → `AllowTelemetry = 0`
2. `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry` → `TaskEnableRun = 0`
3. `HKLM\SYSTEM\DriverDatabase\Policies\Settings` → `DisableSendGenericDriverNotFoundToWER = 1`

Good candidates to add to that list are `Services\DiagTrack\Start = 4`, `Diagnostics\DiagTrack\DiagTrackAuthorization = 0` and `Autologger\AutoLogger-Diagtrack-Listener\Start = 0`. Updates often reset these too.

---

> **Note:** On Home and Pro editions, Windows clamps `AllowTelemetry = 0` to `1` (Required). The DiagTrack service, AutoLogger and AppCompat keys above are what actually stop the collection on those editions.
