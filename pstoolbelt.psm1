function Get-OSVersion {
<#
    .NOTES
    Name: Get-OSVersion
    Author: Richard Kohlbrecher
    Created: 1/29/2014
    Version: 1.1
    History: 1.0 1/29/2014 Initial release
    1.1 2/14/2014 Replaced if/else with try/catch

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
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$computers
    )
    
    PROCESS {
        $OSVersionList = @()
        foreach($computer in $computers) {
            Write-Verbose "Attempting connection to $computer"
            Try {
                $osv = $null
                $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -ErrorAction stop
                Write-Verbose "Gathering information from $computer"
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
            } #end try
            catch {
                Write-Verbose "Unable to connect to $computer"
                $osv = "Cannot connect to $computer"
                $os = $null
            } #end catch
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

function Get-CurrentUser {
<#
    .NOTES
    Name: Get-CurrentUser
    Author: Richard Kohlbrecher
    Created: 2/11/2014
    Version: 1.0
    History: 1.0 2/11/2014 Initial release

    .SYNOPSIS
    Gets the current logged in user of a specified machine (or machines)

    .DESCRIPTION
    This cmdlet queries specified computers via WMI to determine what user is currently logged in

    .PARAMETER Computers
    Specifies the computer names of machines to query

    .EXAMPLE
    Get-CurrentUser computer1

    Queries "computer1" for the current logged in user

    .EXAMPLE
    $a = @("computer1","computer2")
    Get-CurrentUser $a

    Queries all computers in the array "$a"

    .INPUTS
    System.String

    .OUTPUTS
    System.Array containing System.Management.Automation.PSObject
#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$computers
    )

    PROCESS {
        $current_list = @()
        foreach($computer in $computers) {
            Write-Verbose "Attempting to determine current user on $computer"
            Try {
                $username = Get-WMIObject -ComputerName $computer -class Win32_ComputerSystem -ErrorAction stop | select username
                Write-Verbose "Gathering information from $computer"
            } #end try
            Catch {
                Write-Verbose "Unable to connect to $computer"
                $username = "Unable to connect"
            } #end catch
            $current_user = New-Object PSObject -Property @{
                Name = $username
                Computer = $computer
            } #end CurrentUser
            $current_list += $current_user
        } #end foreach
        return $current_list
    } #end PROCESS
} #end Get-CurrentUser