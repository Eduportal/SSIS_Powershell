# Developer: Aaron Jackson
# Date: 26/07/2014

## THIS IS NOT WORKING YET

#Get List of all relevat SSIS Packages
$files = Get-ChildItem "Directory or Filename"

## UPDATE RELEASE NUMBER
## Update Comments
## INSERT COMMENT
 
#process file by file
foreach($file in $files)
{
    #get the content of SSIS package as XML
    $dts = [xml](Get-Content $file.FullName)
 
    #create XmlNamespaceManager
    $mng = [System.Xml.XmlNamespaceManager]($dts.NameTable)
    #add a DTS namespace to the XmlNamespaceManager
    $mng.AddNamespace("DTS", "www.microsoft.com/SqlServer/Dts")
 
    #use XPath query to get DTS:PackageParameters node
    $version = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionComments']", $mng)
    
    $version.InnerText = "Iteration 3 Release"    

    #use XPath query to get DTS:PackageParameters node
    $version = $dts.SelectSingleNode("/DTS:Executable/DTS:Property[@DTS:Name='VersionMinor']", $mng)
    
    $version.InnerText = "3"  

    Set-Content -Path $file $dts.InnerText
    
    $dts.Save($file)    

}