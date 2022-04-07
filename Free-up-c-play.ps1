function Delete-Folder_Files
{
    param($computer)
    Get-ChildItem -Path \\$computer\c$\Windows\WinSxS\ManifestCache -ErrorAction SilentlyContinue |ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\Windows\Logs\CBS -ErrorAction SilentlyContinue |ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\Windows\Logs\DISM -ErrorAction SilentlyContinue |ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\Windows\Web -ErrorAction SilentlyContinue|ForEach-Object{Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\Windows\'Downloaded Program Files' -ErrorAction SilentlyContinue|ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\ProgramData\Microsoft\Windows\WER\ReportQueue -ErrorAction SilentlyContinue|ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\Windows\SoftwareDistribution\Download -ErrorAction SilentlyContinue|ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\inetpub\logs\LogFiles -ErrorAction SilentlyContinue|ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\Windows\ccmcache -ErrorAction SilentlyContinue|ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\Recycler -ErrorAction SilentlyContinue |ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}
    Get-ChildItem -Path \\$computer\c$\'$Recycle.Bin' -ErrorAction SilentlyContinue|ForEach-Object{Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue}

}

function Get-C_FreeSpace
{
    param($ComputerName)
    try{
            $Computer_LocalDisks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $ComputerName -ErrorAction Stop| Where-Object {$_.DriveType -eq 3}
    
            $disk_enumerator = -1

            foreach($drive in $Computer_LocalDisks.DeviceID)
            {
                $disk_enumerator++
                if($drive -eq "C:")
                {
                    return [math]::Round(($Computer_LocalDisks[$disk_enumerator].FreeSpace)/1GB,2)
                }
            }
    }

    catch{
            return "UTC"
    }

    
}

$obj = @()

$hostname = hostname

$pre_free = Get-C_FreeSpace $hostname

Delete-Folder_Files $hostname

$post_free = Get-C_FreeSpace $hostname

$date = get-date -Format "dd-MMM-yyyy HHmm"

$obj += New-Object psobject -Property @{
                                         'Date' = $date
                                         'Before(GB)' = $pre_free
                                         'After (GB)' = $post_free

                                       }

$obj |Select-Object Date,'Before(GB)','After (GB)'|Export-Csv c:\temp\clean_c_play_$date.csv -NoTypeInformation  
