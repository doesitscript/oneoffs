
PS C:\Windows\system32> Get-ScheduledTask -TaskName "DomainJoinStartup" | Select-Object -ExpandProperty Triggers


Enabled            : True
EndBoundary        :
ExecutionTimeLimit :
Id                 :
Repetition         : MSFT_TaskRepetitionPattern
StartBoundary      :
Delay              :
PSComputerName     :



PS C:\Windows\system32>
PS C:\Windows\system32> (Get-ScheduledTask -TaskName "DomainJoinStartup").Actions


Id               :
Arguments        : -ExecutionPolicy Bypass -File C:\GoldenImageInstall\ADJoin-Stage\domainjoin.ps1
Execute          : PowerShell.exe
WorkingDirectory :
PSComputerName   :



PS C:\Windows\system32> Get-ScheduledTask -TaskName "DomainJoinStartup" | Get-ScheduledTaskInfo


LastRunTime        : 11/2/2025 7:44:44 AM
LastTaskResult     : 1
NextRunTime        :
NumberOfMissedRuns : 0
TaskName           : DomainJoinStartup
TaskPath           : \
PSComputerName     :

## CRITICAL FINDING
Command ran and result 1 <-- Failed script run>

#TODO ENABLE:
via powershell need equivilent to: open Event Viewer → Microsoft-Windows-TaskScheduler/Operational and filter for that task name to see exit codes and context.

#########################
# enable history for the Operational channel
wevtutil sl Microsoft-Windows-TaskScheduler/Operational /e:true
 Get-WinEvent -LogName Microsoft-Windows-TaskScheduler/Operational -MaxEvents 200 | Where-Object { $_.Message -like '*DomainJoinStartup*'} | Sort-Object TimeCreated | Select-Object -Last 30 | Format-Table TimeCreated, Id, @{Label="Message"; Expression={$_.Message}; Width=150} -Wrap
# show the last 30 events for this task, with result codes when available
Get-WinEvent -LogName Microsoft-Windows-TaskScheduler/Operational -MaxEvents 200 |
  Where-Object { $_.Message -like '*DomainJoinStartup*' } |
  Select-Object TimeCreated, Id, Message | Sort-Object TimeCreated | Select-Object -Last 30
# nothing since history was not enabled prior to our troubleshoot
$task = Get-ScheduledTask -TaskName 'DomainJoinStartup'
$act  = $task.Actions[0]
$act | Select Execute, Arguments, WorkingDirectory
(Get-ScheduledTask -TaskName 'DomainJoinStartup' | Get-ScheduledTaskInfo) |
  Select LastRunTime, @{n='LastTaskResultHex';e={('{0:x}' -f $_.LastTaskResult)}}, LastTaskResult

LastRunTime          LastTaskResultHex LastTaskResult
-----------          ----------------- --------------
11/2/2025 7:44:44 AM 1                              1

### manual trigger


## recheck logs
# channel is already enabled; fetch newest entries and filter client-side

Get-WinEvent -LogName Microsoft-Windows-TaskScheduler/Operational -MaxEvents 200 | Where-Object { $_.Message -like '*DomainJoinStartup*' } | Select-Object TimeCreated, Id, Message | Sort-Object TimeCreated | Select-Object -Last 30 | Format-List


TimeCreated : 11/5/2025 2:35:44 AM
Id          : 325
Message     : Task Scheduler queued instance "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}"  of task "\DomainJoinStartup".

TimeCreated : 11/5/2025 2:35:44 AM
Id          : 110
Message     : Task Scheduler launched "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}"  instance of task "\DomainJoinStartup"  for user "System" .

TimeCreated : 11/5/2025 2:35:44 AM
Id          : 129
Message     : Task Scheduler launch task "\DomainJoinStartup" , instance "PowerShell.exe"  with process ID 3076.

TimeCreated : 11/5/2025 2:35:44 AM
Id          : 100
Message     : Task Scheduler started "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" instance of the "\DomainJoinStartup" task for user "NT AUTHORITY\SYSTEM".

TimeCreated : 11/5/2025 2:35:44 AM
Id          : 200
Message     : Task Scheduler launched action "PowerShell.exe" in instance "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" of task "\DomainJoinStartup".

TimeCreated : 11/5/2025 2:35:51 AM
Id          : 201
Message     : Task Scheduler successfully completed task "\DomainJoinStartup" , instance "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" , action
              "PowerShell.exe" with return code 2147942401.

TimeCreated : 11/5/2025 2:35:51 AM
Id          : 102
Message     : Task Scheduler successfully finished "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" instance of the "\DomainJoinStartup" task for user "NT
              AUTHORITY\SYSTEM".


  ####### CRITICAL HOTSPOT #########
Get-WinEvent -LogName Microsoft-Windows-TaskScheduler/Operational -MaxEvents 200 | Where-Object { $_.Message -like '*DomainJoinStartup*' } | Sort-Object TimeCreated | Select-Object -Last 30 | Format-Table TimeCreated, Id, @{Label="Message"; Expression={$_.Message}; Width=150} -Wrap

TimeCreated           Id Message
-----------           -- -------
11/5/2025 2:35:44 AM 325 Task Scheduler queued instance "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}"  of task "\DomainJoinStartup".
11/5/2025 2:35:44 AM 110 Task Scheduler launched "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}"  instance of task "\DomainJoinStartup"  for user "System" .
11/5/2025 2:35:44 AM 129 Task Scheduler launch task "\DomainJoinStartup" , instance "PowerShell.exe"  with process ID 3076.
11/5/2025 2:35:44 AM 100 Task Scheduler started "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" instance of the "\DomainJoinStartup" task for user "NT
                         AUTHORITY\SYSTEM".
11/5/2025 2:35:44 AM 200 Task Scheduler launched action "PowerShell.exe" in instance "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" of task
                         "\DomainJoinStartup".
11/5/2025 2:35:51 AM 201 Task Scheduler successfully completed task "\DomainJoinStartup" , instance "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" , action
                         "PowerShell.exe" with return code 2147942401.
11/5/2025 2:35:51 AM 102 Task Scheduler successfully finished "{cf6be324-0c0e-4819-aaf5-add517a6e3ea}" instance of the "\DomainJoinStartup" task for
                         user "NT AUTHORITY\SYSTEM".
  ################ 
  hex: 2147942401
  1. wrong Cmd Flags -Command or -File        <-- Highest likelyhood from passing userdata into through many handoffs:
  2. AMI Userdata -> xml -> to Scheduled task -> format for PowerShell Cmdline --> $variable_in_script 
  3. Missing paths <-- possible candidate too, since new layers added to ami build
  bad domjoin arguments recieved on whichever  dom join cmd used,likely add-computer <-- see 1. >
  broken relative paths
  #####
  Invoke-RestMethod -Uri "http://169.254.169.254/latest/api/token" -Method PUT -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"}
  ################ Start
# brd26w080n1,dev <-- good>
    $userdataParts = $userdata -split ','
# $userdataParts
# brd26w080n1
# dev
# two situations: $userdataParts=
$userdataParts = $userdata -split ','
# $userdataParts contains:
# brd26w080n1
# dev
# # situation 2
# $userdataParts contains: 
# brd26w080n1
# prod
$secretName = "BreadDomainSecret-CORPDEV"
"BreadDomainSecret-CORP" # DEV condition
# *** THERE IS NO PROD condition , just PRODUCTION #TODO VERIFY PROBLEM?
"BreadDomainSecret-CORP" # default condition 
$token = Invoke-RestMethod -Uri "http://169.254.169.254/latest/api/token" -Method PUT -Headers @{"X-aws-ec2-metadata-token-ttl-seconds" = "21600"} 
$currentRegion = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/placement/region" -Headers @{"X-aws-ec2-metadata-token" = $token}
$secretArn = "arn:aws:secretsmanager:${currentRegion}:422228628991:secret:${secretName}"
PS C:\Windows\system32> $secretArn
arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORPDEV

# PS C:\Windows\system32> $token
# AQAEANrYHf6S3om5lpHOXH8MuqUqWDfrs3fArZvi7rJlorz2-mcprA==
$userdata = (Invoke-RestMethod -Uri "http://169.254.169.254/latest/user-data" -Headers @{"X-aws-ec2-metadata-token" = $token} -ErrorAction Stop).Trim()
$userdata = (Invoke-RestMethod -Uri "http://169.254.169.254/latest/user-data" -Headers @{"X-aws-ec2-metadata-token" = $token} -ErrorAction Stop).Trim()
$userdata
$secretArn
arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORPDEV ## at this point I"M SURE PROD
#********** POSSIBLE CRITICAL
aws secretsmanager get-secret-value --secret-id $secretArn --region $currentRegion
An error occurred (AccessDeniedException) when calling the GetSecretValue operation: Access to KMS is not allowed

##########in both situation, the first if contdition is true correct and we don't evaluate the second else correct?
if ($userdataParts.Count -ge 2) {
        $environment = $userdataParts[1].ToUpper()
    } else {
        $environment = "PRODUCTION"  # Default fallback
    }
  $secretName = "BreadDomainSecret-CORPDEV"  <-- break into script here>
      $secretArn = "arn:aws:secretsmanager:${currentRegion}:422228628991:secret:${secretName}"
          $secret = aws secretsmanager get-secret-value --secret-id $secretArn --region $currentRegion
          $secret | ConvertFrom-Json

### This is failing --> verify we have been given needed perm
# Setup ####
currentRegion = Invoke-RestMethod -Uri "http://169.254.169.254/latest/meta-data/placement/region" -Headers @{"X-aws-ec2-meta
data-token" = $token}
$secretArn = "arn:aws:secretsmanager:${currentRegion}:422228628991:secret:${secretName}"
#"arn:aws:secretsmanager:$currentRegion:422228628991:secret:BreadDomainSecret-CORPDEV"
#"arn:aws:secretsmanager:$currentRegion:422228628991:secret:BreadDomainSecret-CORP"
$secret = aws secretsmanager get-secret-value --secret-id $secretArn --region $currentRegion
# Copy the script to the instance, then:
aws ssm send-command --instance-ids i-054443c7dc4253556 --document-name "AWS-RunShellScript" --parameters 'commands=["curl -o /tmp/verify.sh <script-url>","chmod +x /tmp/verify.sh","bash /tmp/verify.sh"]' --profile CASTSoftware_dev_925774240130_admin --region us-east-2

aws ssm start-session --target <instance-id> \
  --profile CASTSoftware_dev_925774240130_admin \
  --region us-east-2

# Then inside the instance:
aws sts get-caller-identity
aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-2:422228628991:secret:BreadDomainSecret-CORP

PS C:\Windows\system32> aws sts get-caller-identity
{
    "UserId": "AROA5PDDR3GBA5SCPH2NO:i-0a04cb53a9e6a2348",
    "Account": "925774240130",
    "Arn": "arn:aws:sts::925774240130:assumed-role/brd-ue2-dev-cast-srv-01-role/i-0a04cb53a9e6a2348"
}

# likely issue 1 (double verify: string syntax, escape issue in script)
"arn:aws:secretsmanager:$currentRegion:422228628991:secret:BreadDomainSecret-CORPDEV"
OR FOR DEB
"arn:aws:secretsmanager:$currentRegion:422228628991:secret:BreadDomainSecret-CORP"
An error occurred (AccessDeniedException) when calling the GetSecretValue operation: Access to KMS is not allowed

### Issue 2 break down; 
# second issue 2 access deny orstring syntax collapse string making aws secret path var mismatch to the secret manager path --> would report access error or not exists 
"arn:aws:secretsmanager:$currentRegion:422228628991:secret:BreadDomainSecret-CORPDEV"
"arn:aws:secretsmanager:$currentRegion:422228628991:secret:BreadDomainSecret-CORP"
arn:aws:secretsmanager:-CORPDEV
###############



# minor related finding
No winevents to go off of:

PS C:\Windows\system32>    Get-WinEvent -LogName Microsoft-Windows-TaskScheduler/Operational | Where-Object {$_.Message -like "*DomainJoinStartup*"} | Select-Object -First 10
Get-WinEvent : No events were found that match the specified selection criteria.