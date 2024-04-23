if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
# Elevate permissions due to windows needing Administrative perms to edit time.
Try {
    $getTime = Invoke-WebRequest -method GET -uri "http://worldtimeapi.org/api/ip"
} Catch {
    "Failed to get valid time data from API."
}

If ($getTime) {
    $timeJSON = $getTime.Content | ConvertFrom-Json
    # Unix time to convert
    # Pretty much, what we are doing is getting the standard unix time and adding it to our offset, by multiplying it by 3600 to get the seconds.
    $unixTime = [int]$timeJSON.unixtime + ([int]($timeJSON.utc_offset -replace [Regex]::Escape("+"), "" -replace ":", ".") * 3600)

    # Convert Unix time to DateTime object
    $date = (Get-Date).AddSeconds($unixTime - [double]::Parse((Get-Date -UFormat %s)))

    # Set the system time
    Set-Date -Date $date
}
