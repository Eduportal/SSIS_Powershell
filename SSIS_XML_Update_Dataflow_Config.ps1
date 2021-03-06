################### DESCRIPTION ###########
## DEVELOPER: AARON JACKSON
## DATE: 29/09/2014
## DESC: This script will update all the packages in a given directory and update the dataflow configurations
## 
## VERSION: 1.0.0
################## END DESCRIPTION ########

## TEST
# .\SSIS_XML_Update_Dataflow_Config.ps1 -Package_Dir "C:\Users\ajackso6\Documents\qrm-data-integration\GlareSSIS\GlareETL\" -Buffer_Size 104857600 -Engine_Threads 15 -Buffer_MaxRows 10000
##

################ VARIABLES #################
Param (
    [String]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [Parameter(Mandatory = $true)] 
    $Package_Dir,
    
    [String]
    #[Parameter(Mandatory = $true)] 
    $Package_Name,
    
    [Int]
    [Parameter(Mandatory = $false)] 
    [ValidateNotNull()]
    $Buffer_Size,
    
    [Int]
    [Parameter(Mandatory = $false)]
    [ValidateNotNull()] 
    $Engine_Threads,
    
    [Int]
    [Parameter(Mandatory = $false)]
    [ValidateNotNull()] 
    $Buffer_MaxRows
    
    #[String]
    #[Parameter(Mandatory = $true)] 
    #$Version_Comments
)
################ END VARIABLES #################

Clear-Host

#Get List of all relevant SSIS Packages
$files = Get-ChildItem $Package_Dir -Filter *.dtsx

#initialise as false
[string]$Correct_Version = "3"
#[int]$Default_Buffer_Size = 10485760
#[int]$Default_Engine_Threads = 10
 
#process file by file
foreach($file in $files)
{

    Write-Host "Loading $file"
    ## TODO
    ## PARALLEL PROCESSING.. do each file in a seperate worker thread? - version 2 improvement perhaps

    #get the content of SSIS package as XML
    $dts = New-Object System.Xml.XmlDocument
    $dts.PreserveWhitespace = $true   
    $dts.Load($Package_Dir+$file)

    #create XmlNamespaceManager
    $mng = [System.Xml.XmlNamespaceManager]($dts.NameTable)
    #add a DTS namespace to the XmlNamespaceManager
    $mng.AddNamespace("DTS", "www.microsoft.com/SqlServer/Dts")

    ## Test package is correct version, i.e. SQL Server 2008 R2 format

    $SSIS_Version = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='PackageFormatVersion']", $mng)
 
    if ($SSIS_Version.InnerText -eq $Correct_Version)
    {
        $update = $dts.SelectSingleNode("//DTS:Executable/DTS:Executable/DTS:ObjectData/pipeline/@defaultBufferSize", $mng)    
        $update.Value = $Buffer_Size
        
        $update = $dts.SelectSingleNode("//DTS:Executable/DTS:Executable/DTS:ObjectData/pipeline/@engineThreads", $mng)    
        $update.Value = $Engine_Threads
        
        $update = $dts.SelectSingleNode("//DTS:Executable/DTS:Executable/DTS:ObjectData/pipeline/@defaultBufferMaxRows", $mng)    
        $update.Value = $Buffer_MaxRows
        
        try
        {
            $dts.Save($Package_Dir+$file) 

            Write-Host "$file was updated successfully!"
        }
        catch [system.exception]
        {

            write-host "Exception raised!" -ForegroundColor Red
            write-host "Exception Type: $($_.Exception.GetType().FullName)" -ForegroundColor Red
            write-host "Exception Message: $($_.Exception.Message)" -ForegroundColor Red

            Write-Host "$file was not updated!"

        }
   }
   else
   {

        Write-Host "Incompatible version detected"
        Write-Host "$file was not updated!"
   }
    

}