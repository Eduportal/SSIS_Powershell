################### DESCRIPTION ###########
## DEVELOPER: AARON JACKSON
## GitHub: https://github.com/nvrmnd85/SSIS_Powershell/blob/master/SSIS_XML_Update_Version_Number.ps1
## Blog URL: http://www.barkingcat.com.au
## DATE: 15/08/2014
## DESC: This script will update all the packages in a given directory and overwrite the version numbers. The helps track releases and bug tracking.
## Only tested with 2008 R2
################## END DESCRIPTION ########

## TEST
# .\SSIS_XML_Update_Version_Number.ps1 -Version_Major 0 -Version_Minor 4 -Version_Build 0 -Version_Comments "Test"
##

################ VARIABLES #################
Param (
    [String]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [Parameter(Mandatory = $true)] 
    $Package_Dir,
    
#    [String]
    # *.dtsx
#    [Parameter(Mandatory = $true)] 
#    $Package_Name,
    
    [Int]
    [Parameter(Mandatory = $true)] 
    $Version_Major,
    
    [Int]
    [Parameter(Mandatory = $true)] 
    $Version_Minor,
    
    [Int] #x>=0
    [Parameter(Mandatory = $true)] 
    $Version_Build,
    
    [String]
    [Parameter(Mandatory = $true)] 
    $Version_Comments
)
################ END VARIABLES #################

Clear-Host

#Get List of all relevant SSIS Packages
$files = Get-ChildItem $Package_Dir

## TODO 
## Test package is correct version
 
#process file by file
foreach($file in $files)
{

## TODO
## PARALLEL PROCESSING

    #get the content of SSIS package as XML
    $dts = New-Object System.Xml.XmlDocument
    $dts.PreserveWhitespace = $true   
    $dts.Load($file)

    #create XmlNamespaceManager
    $mng = [System.Xml.XmlNamespaceManager]($dts.NameTable)
    #add a DTS namespace to the XmlNamespaceManager
    $mng.AddNamespace("DTS", "www.microsoft.com/SqlServer/Dts")
 
    #use XPath query to get DTS:PackageParameters node
    $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionComments']", $mng)    
    $update.InnerText = $Version_Comments  

    #use XPath query to get DTS:PackageParameters node
    $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionMajor']", $mng)    
    $update.InnerText = $Version_Major 

    #use XPath query to get DTS:PackageParameters node
    $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionMinor']", $mng)    
    $update.InnerText = $Version_Minor 
    
    #use XPath query to get DTS:PackageParameters node
    $update = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionBuild']", $mng)    
    $update.InnerText = $Version_Build 
   
    $dts.Save($file)
    
    ## READ AND VERIFY WRITE
    
    Write-Host "$file was updated successfully!"    

}