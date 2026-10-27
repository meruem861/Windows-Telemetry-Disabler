# check-telemetry-keys.ps1
# Read-only: reports the state of the main telemetry registry keys (see TELEMETRY-KEYS.md).
# Changes nothing. Run as Administrator to read every key.

$keys = @(
    # --- 1. Diagnostic data level ---
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='AllowTelemetry';                            Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='MaxTelemetryAllowed';                       Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection';                  Name='AllowTelemetry';                            Value=0},
    @{Path='HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection';      Name='AllowTelemetry';                            Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\PolicyManager\default\System\AllowTelemetry';                     Name='value';                                     Value=0},
    @{Path='HKCU:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='AllowTelemetry';                            Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='AllowDeviceNameInTelemetry';                Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='AllowCommercialDataPipeline';               Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='AllowDesktopAnalyticsProcessing';           Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='AllowUpdateComplianceProcessing';           Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='AllowWUfBCloudProcessing';                  Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='DisableOneSettingsDownloads';               Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='LimitDiagnosticLogCollection';              Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='MicrosoftEdgeDataOptIn';                    Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection';                                 Name='DoNotShowFeedbackNotifications';            Value=1},

    # --- 2. DiagTrack ---
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack';                                        Name='Start';                                     Value=4},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice';                                 Name='Start';                                     Value=4},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack';                    Name='DiagTrackAuthorization';                    Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack';                    Name='UploadPermissionReceived';                  Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack';                    Name='TelemetryServiceDisabled';                  Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack';                    Name='DisableAutomaticTelemetryKeywordReporting'; Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\TestHooks';          Name='DisableAsimovUpload';                       Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey'; Name='EnableEventTranscript';                     Value=0},

    # --- 3. ETW AutoLoggers ---
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener';      Name='Start';                                     Value=0},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\Diagtrack-Listener';                 Name='Start';                                     Value=0},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SQMLogger';                          Name='Start';                                     Value=0},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\SetupPlatformTel';                   Name='Start';                                     Value=0},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\CloudExperienceHostOobe';            Name='Start';                                     Value=0},

    # --- 4. Application compatibility telemetry ---
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat';                                      Name='AITEnable';                                 Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat';                                      Name='DisableInventory';                          Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat';                                      Name='DisableUAR';                                Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry';        Name='TaskEnableRun';                             Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\ClientTelemetry';        Name='IsCensusDisabled';                          Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TelemetryController';    Name='RunsBlocked';                               Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe'; Name='Debugger';                       Value='%windir%\System32\taskkill.exe'},

    # --- 5. CEIP ---
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows';                                      Name='CEIPEnable';                                Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\SQMClient\Windows';                                               Name='CEIPEnable';                                Value=0},

    # --- 6. Windows Error Reporting ---
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting';                        Name='Disabled';                                  Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting';                                 Name='Disabled';                                  Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting';                        Name='DontSendAdditionalData';                    Value=1},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent';                         Name='DefaultConsent';                            Value=0},
    @{Path='HKLM:\SYSTEM\DriverDatabase\Policies\Settings';                                            Name='DisableSendGenericDriverNotFoundToWER';     Value=1},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\StorPort';                                          Name='TelemetryPerformanceEnabled';               Value=0},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\StorPort';                                          Name='TelemetryErrorDataEnabled';                 Value=0},
    @{Path='HKLM:\SYSTEM\CurrentControlSet\Control\StorPort';                                          Name='TelemetryDeviceHealthEnabled';              Value=0},

    # --- 7. Activity history, experiments and tailored data ---
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System';                                         Name='EnableActivityFeed';                        Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System';                                         Name='PublishUserActivities';                     Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\System';                                         Name='UploadUserActivities';                      Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\System';                             Name='AllowExperimentation';                      Value=0},
    @{Path='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy';                                  Name='TailoredExperiencesWithDiagnosticDataEnabled'; Value=0},
    @{Path='HKCU:\Software\Policies\Microsoft\Windows\CloudContent';                                   Name='DisableTailoredExperiencesWithDiagnosticData'; Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo';                                Name='DisabledByGroupPolicy';                     Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI';                                      Name='DisableAIDataAnalysis';                     Value=1},

    # --- 8. Input and speech data collection ---
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization';                                   Name='RestrictImplicitInkCollection';             Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization';                                   Name='RestrictImplicitTextCollection';            Value=1},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization';                                   Name='AllowInputPersonalization';                 Value=0},
    @{Path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput';                       Name='AllowLinguisticDataCollection';             Value=0},
    @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\TabletPC';                                       Name='PreventHandwritingDataSharing';             Value=1},
    @{Path='HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy';                     Name='HasAccepted';                               Value=0}
)

$counts = @{ OK = 0; DIFF = 0; NOVALUE = 0; NOKEY = 0 }

foreach ($k in $keys) {
    $item = Get-Item -LiteralPath $k.Path -ErrorAction SilentlyContinue
    if (!$item) {
        $status = 'NOKEY'; $actual = ''
    } elseif ($item.GetValueNames() -notcontains $k.Name) {
        $status = 'NOVALUE'; $actual = ''
    } else {
        $actual = $item.GetValue($k.Name, $null, 'DoNotExpandEnvironmentNames')
        $status = if ("$actual" -eq "$($k.Value)") { 'OK' } else { 'DIFF' }
    }
    $counts[$status]++

    switch ($status) {
        'OK'      { $color = 'Green';  $text = "[ OK      ] $($k.Path)\$($k.Name) = $actual" }
        'DIFF'    { $color = 'Yellow'; $text = "[ DIFF    ] $($k.Path)\$($k.Name) = $actual (expected $($k.Value))" }
        'NOVALUE' { $color = 'Red';    $text = "[ NOVALUE ] $($k.Path)\$($k.Name) (key exists, value missing)" }
        'NOKEY'   { $color = 'Red';    $text = "[ NOKEY   ] $($k.Path) (key missing)" }
    }
    Write-Host $text -ForegroundColor $color
}

Write-Host ""
Write-Host ("Checked {0}: {1} OK, {2} different, {3} value missing, {4} key missing" -f `
    $keys.Count, $counts.OK, $counts.DIFF, $counts.NOVALUE, $counts.NOKEY) -ForegroundColor Cyan
if ($counts.NOKEY + $counts.NOVALUE -gt 0) {
    Write-Host "Missing keys/values are normal before telemetry-win.ps1 has run: it creates them." -ForegroundColor Gray
}
