[CmdletBinding()]
Param(
    [Parameter(Mandatory = $True)]
    $group
)

function write_error($message, $group) {

    if (!([String]::IsNullOrWhiteSpace($message))) {
        $message = $message | ConvertTo-Json
    }
    else {
        $message = '"No error message recieved."'
    }

    $error_payload = @"
{
    "_error": {
        "msg": $message,
        "kind": "puppetlabs.tasks/task-error",
        "details": {
            "group": "${group}"
            "exitcode": 1
        }
    },
    "_output": "Something went wrong with task",
}
"@

    Write-Host $error_payload
}

function write_success($oldMemberList, $newMemberList, $removedMembers) {
    try {

        $oldMemberList = ConvertTo-Json -InputObject $oldMemberList.name
        $newMemberList = ConvertTo-Json -InputObject $newMemberList.name

        if (!([String]::IsNullOrWhiteSpace($removedMembers))) {
            $removedMembers = ConvertTo-Json -InputObject $removedMembers
        }
        else {
            $removedMembers = '"None"'
        }

        $success_payload = @"
{
        "removed_members": ${removedMembers},
        "old_member_list": ${oldMemberList},
        "new_member_list": ${newMemberList}
}
"@
        Write-Host $success_payload

    }
    catch {
        $error_message = $_.Exception.Message
        write_error -message $error_message -group $group
        exit 1
    }
}

function GetMembers {
    param (
        [Parameter(Mandatory = $True)]
        $group
    )

    $members = @($group.psbase.Invoke("Members")) | ForEach-Object { 
        $path = ([ADSI]$_).InvokeGet("ADsPath") 
        $name = ([ADSI]$_).InvokeGet("Name")
        $member = [PSCustomObject]@{
            name = $name
            path = $path 
        }
        return $member
    }
    
    return $members
}

try {
    $strComputer = hostname
    $computerObj = [ADSI]("WinNT://" + $strComputer + ",computer")
    $groupObj = $computerObj.psbase.children.find($group)
    $currentMembers = GetMembers -group $groupObj

    $unresolvableSIDs = New-Object System.Collections.Generic.List[System.Object]

    foreach ($member in $currentMembers) {
        try {
            #Try to convert to SIDs unresolvable objects will fail.
            $usrObj = New-Object System.Security.Principal.NTAccount($member.name)
            $usrSid = $usrObj.Translate([System.Security.Principal.SecurityIdentifier]).toString()
        }
        catch {
            $unresolvableSIDs.Add($member.path)
        }
    }

    if ($unresolvableSIDs.Count -gt 0) {
        foreach ($sid in $unresolvableSIDs) {
            $groupObj.remove($sid)
        }
    }

    $newMembers = GetMembers -group $groupObj

    write_success -oldMemberList $currentMembers -newMemberList $newMembers -removedMembers $unresolvableSIDs 
}
catch {
    $error_message = $_.Exception.Message
    write_error -message $error_message -group $group
    exit 1
}
