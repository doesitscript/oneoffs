Communications High vis finding 



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


Potential Issue with 

"C:\GoldenImageInstall\ADJoin-Stage\domainjoin.ps1"

If it ran but failed, open Event Viewer → Microsoft-Windows-TaskScheduler/Operational and filter for that task name to see exit codes and context.

Located Domain join script
(Get-ScheduledTask -TaskName "DomainJoinStartup").Actions
Locates  our domainjoin script
`Arguments        : -ExecutionPolicy Bypass -File C:\GoldenImageInstall\ADJoin-Stage\domainjoin.ps1`



Learning: Custom paths slow down finding key steps. 

Document: Little extra time caused by tracking down these compared to where amazon ami builds outout the troubleshooting commands for tasks being executed by our image vs native built ami

Listing ami commands locations below and the analogous command our image runs, outs outs so that we can share this going forward (to avoid new people having to refind these)

