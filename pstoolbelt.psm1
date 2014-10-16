function Get-CurrentUser
{
<#
    .NOTES
    Name: Get-CurrentUser
    Author: Richard Kohlbrecher
    Created: 2/11/2014
    Version: 1.1
    History: 1.0 2/11/2014 Initial release
    1.1 10/16/2014 Minor refactoring and upates (variable names and adding "-ExpandProperty")

    .SYNOPSIS
    Gets the current logged in user of a specified machine (or machines)

    .DESCRIPTION
    This cmdlet queries specified computers via WMI to determine what user is currently logged in.

    .PARAMETER ComputerName
    Specifies the computer names of machines to query.

    .EXAMPLE
    Get-CurrentUser Test1,Test2

    Returns the current logged in user of the computers "Test1" and "Test2" (if reachable).

    .INPUTS
    System.String[]

    .OUTPUTS
    System.Array containing System.Management.Automation.PSObject
#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$ComputerName
    )

    PROCESS
    {
        $currentList = @()

        foreach($comp in $ComputerName)
        {
            Write-Verbose "Attempting to determine current user on $comp"

            Try
            {
                $username = Get-WMIObject -ComputerName $comp -class Win32_ComputerSystem -ErrorAction stop | Select-Object -ExpandProperty username
                Write-Verbose "Gathering information from $comp"
            }
            Catch
            {
                Write-Verbose "Unable to connect to $comp"
                $username = "Unable to connect"
            }

            $currentUser = New-Object PSObject -Property @{
                Name = $username
                Computer = $comp
            }

            $currentList += $currentUser
        }

        return $currentList
    }
}

function Get-Uptime
{
<#
    .NOTES
    Name: Get-Uptime
    Author: Richard Kohlbrecher
    Created: 10/16/2014
    Version: 1.0
    History: 1.0 10/16/2014 Initial release

    .SYNOPSIS
    Gets the current uptime (time since hardware boot) of a specified machine (or machines)

    .DESCRIPTION
    This cmdlet queries specified computers to determine the time since the last hardware boot.

    The command returns System.Timespan objects with an added "ComputerName" parameter.

    .PARAMETER ComputerName
    Specifies the computer names of machines to query. If nothing is provided, the command will
    use the current computer (as determined by $env:COMPUTERNAME).

    .EXAMPLE
    Get-Uptime

    Returns the uptime of the computer the command is run on.

    .EXAMPLE
    Get-Uptime Test1,Test2

    Returns the uptimes of computers "Test1" and "Test2" (if reachable).

    .Example
    Get-Uptime Test1,Test2 | ft ComputerName,Days,Hours,Minutes,Seconds

    Returns a table containing the uptime and computer name of each machine queried (in this
    case, "Test1" and "Test2"). This is the way I have typically ran the command unless it's
    neccesary to use the output elsewhere / export it.

    .INPUTS
    System.String[]

    .OUTPUTS
    System.Timespan containing extra "ComputerName" parameter
#>
    param (
        [parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true)]
        [string[]]$ComputerName
    )

    BEGIN
    {
    <#
        ToDo:
            - Duplicate removal during validation
    #>
        $validComputers = @()
        
        if (-not ($ComputerName))
        {
            $validComputers = $env:COMPUTERNAME
        }
        else
        {
            foreach($comp in $ComputerName)
            {
                if ($comp -eq $env:COMPUTERNAME)
                {
                    $validComputers += $comp
                }
                elseif (Test-Connection $comp -BufferSize 16 -Count 2 -Quiet)
                {
                    $validComputers += $comp
                }
                else
                {
                    Write-Error "Unable to connect to $comp"
                }
            }
        }
    }

    PROCESS
    {
    <#
        ToDo:
            - Ensure that the added ComputerName property is displayed on default output
            Currently needs to be selected via dot sourcing / Select-Object / a formatting method
    #>
        foreach ($comp in $validComputers)
        {
            $output = ((Get-Date)-(Get-EventLog -ComputerName $comp -LogName System -InstanceId 27 -Newest 1).TimeGenerated)
            $output = $output | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value "$comp" -PassThru

            $output

            $output = $null
        }
    }
}