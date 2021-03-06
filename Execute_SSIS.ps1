################### DESCRIPTION ###########
## DEVELOPER: AARON JACKSON
## DATE: 08/07/2014
## DESC: This script is used to call DTEXEC with the correct switches and params
## Needs to be run on a server (or PC) with SSIS Server installed.
## THIS WILL NOT WORK ON YOUR DESKTOP! Sorry folks!
################## END DESCRIPTION ########

################ VARIABLES #################

$Package_Dir = "\\Vfsydcagdev01\QRM\DEV\SSIS\Deployment\"
$Package_Name = "Acquire_IRIS_GLDimAccount.dtsx"
$id_DeliveryQueueID = 8
$id_RunID = 8
$id_RunItemID = 8

################ END VARIABLES #################

################ SCRIPT ########################

Clear-Host

Get-ChildItem Env:QRMControlDatabaseConnectionString

$DTExecArgs  = "/FILE ""$Package_Dir$Package_Name"" /CHECKPOINTING OFF  /REPORTING EW"
$DTExecArgs += " /SET ""\Package.Variables[Acquisition::id_DeliveryQueueID].Properties[Value]"";$id_DeliveryQueueID "
$DTExecArgs += " /SET ""\Package.Variables[Acquisition::id_RunID].Properties[Value]"";$id_RunID "
$DTExecArgs += " /SET ""\Package.Variables[Acquisition::id_RunItemID].Properties[Value]"";$id_RunItemID "

Get-Location

# Run DTExec

$pinfo = New-Object System.Diagnostics.ProcessStartInfo
If ($Architecture -eq "64")
{
    $pinfo.FileName = "C:\Program Files\Microsoft SQL Server\100\DTS\Binn\DTExec.exe"
}
Else
{
    $pinfo.FileName = "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\DTExec.exe"
}
$pinfo.FileName  # Output the DTExec path and filename
$DTExecArgs      # Output the DTExecArgs variable

# The next few lines are required to make sure the process waits for
# the package execution to finish
$pinfo.RedirectStandardOutput = $true
$pinfo.UseShellExecute = $false
$pinfo.Arguments = $DTExecArgs
$p = New-Object System.Diagnostics.Process
$p.StartInfo = $pinfo
$p.Start() | Out-Null
$output = $p.StandardOutput.ReadToEnd()
$p.WaitForExit()
$DTExecExitCode = $p.ExitCode
$output
# DTExec Finished

Write-Output "Return Code = $DTExecExitCode"
Exit $Result
################ END SCRIPT ####################