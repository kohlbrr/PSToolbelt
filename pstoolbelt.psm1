function Get-OSVersion {
<#
    .NOTES
    Name: Get-OSVersion
    Author: Richard Kohlbrecher
    Created: 1/29/2014
    Version: 1.0
    History: 1.0 1/29/2014 Initial release

    .SYNOPSIS
    Gets the current Windows OS version of a specified machine (or machines)

    .DESCRIPTION
    This cmdlet queries specified computers via WMI to determine what version of Windows the machine is currently using

    .PARAMETER Computers
    Specifies the computer names of machines to query

    .EXAMPLE
    Get-OSVersion computer1

    Queries "computer1" for its Windows OS version

    .EXAMPLE
    $a = @("computer1","computer2")
    Get-OSVersion $a

    Queries all computers in the array "$a"

    .INPUTS
    System.String

    .OUTPUTS
    System.Array containing System.Management.Automation.PSObject
#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string[]]$computers
    )
    
    PROCESS {
        $OSVersionList = @()
        foreach($computer in $computers) {
        Write-Verbose "Attempting connection to $computer"
            if(Test-Connection -ComputerName $computer -BufferSize 16 -Count 2 -ErrorAction 0 -Quiet) {
                Write-Verbose "Gathering information from $computer"
                $osv = $null
                $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer
                Switch($os.Version) {
                    "5.1.2600" {$osv = "Windows XP"}
                    "5.2.3790" {
                        Switch($os.ProductType) {
                            "1" {$osv = "Windows XP Professional x64"}
                            "3" {$osv = "Windows Server 2003"}
                            DEFAULT {$osv = "5.2.3790 - Unknown Type"}
                        } #end switch
                    } #end 5.2.3790
                    "6.0.6000" {$osv = "Windows Vista"}
                    "6.0.6001" {
                        Switch($os.ProductType) {
                            "1" {$osv = "Windows Vista SP1"}
                            "3" {$osv = "Windows Server 2008"}
                            DEFAULT {$osv = "6.0.6001 - Unknown Type"}
                        } #end switch
                    } #end 6.0.6001
                    "6.0.6002" {
                        Switch($os.ProductType) {
                            "1" {$osv = "Windows Vista SP2"}
                            "3" {$osv = "Windows Server 2008 SP2"}
                            DEFAULT {$osv = "6.0.6002 - Unknown Type"}
                        } #end switch
                    } #end 6.0.6002
                    "6.1.7600" {
                        Switch($os.ProductType) {
                            "1" {$osv = "Windows 7"}
                            "3" {$osv = "Windows Server 2008 R2"}
                            DEFAULT {$osv = "6.1.7600 - Unknown Type"}
                        } #end switch
                    } #end 6.1.7600
                    "6.1.7601" {
                        Switch($os.ProductType) {
                            "1" {$osv = "Windows 7 SP1"}
                            "3" {$osv = "Windows Server 2008 R2 SP1"}
                            DEFAULT {$osv = "6.1.7601 - Unknown Type"}
                        } #end switch
                    } #end 6.1.7601
                    "6.2.9200" {
                        Switch($os.ProductType) {
                            "1" {$osv = "Windows 8"}
                            "3" {$osv = "Windows Server 2012"}
                            DEFAULT {$osv = "6.2.9200 - Unknown Type"}
                        } #end switch
                    } #end 6.2.9200
                    "6.3.9200" {
                        Switch($os.ProductType) {
                            "1" {$osv = "Windows 8.1"}
                            "3" {$osv = "Windows Server 2012 R2"}
                            DEFAULT {$osv = "6.3.9200 - Unknown Type"}
                        } #end switch
                    } #end 6.3.9200
                    DEFAULT {$osv = "Unable to determine version"}
                } #end switch
            } #end if
            else {
                Write-Verbose "Unable to connect to $computer"
                $osv = "Cannot connect to $computer"
                $os = $null
            } #end else
            
            $OSVersion = New-Object PSObject -Property @{
                ComputerName = $computer
                Version = $osv
                Build = $os.Version
            } #end OSVersion
            
            $OSVersionList += $OSVersion
        } #end foreach
    return $OSVersionList
    } #end PROCESS
} #end Get-OSVersion
