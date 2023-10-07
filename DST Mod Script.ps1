# Created on 5-3-19
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DSTmodslua = "C:\Users\Administrator\Desktop\DST\mods\dedicated_server_mods_setup.lua"
$masterFolderLua = "C:\Users\Administrator\Documents\Klei\DoNotStarveTogether\MyDediServer\Master\modoverrides.lua"
$cavesFolderLua = "C:\Users\Administrator\Documents\Klei\DoNotStarveTogether\MyDediServer\Caves\modoverrides.lua"
#$masterFolder = "C:\Users\Administrator\Documents\Klei\DoNotStarveTogether\MyDediServer\Master\"
#$cavesFolder = "C:\Users\Administrator\Documents\Klei\DoNotStarveTogether\MyDediServer\Caves\"

# Function to load the mod.lua file and arrange all mod numbers into array with the comments that is output

function load-LuaFile

{
Clear-Variable luaarraywithcomments -ErrorAction SilentlyContinue
[array]$LuaArrayWithComments = cat $DSTmodslua
return($LuaArrayWithComments)
}

# function to allow user to add more mods
# INPUT: the fullarraywithcomments array object from the load luafile function.
# Output: the same array as the input but with the newly added mod to it.

function add-Mods

{
param($fullarraywithcomments)
Clear-Variable currentread,currentModNumber,matches -ErrorAction SilentlyContinue


    [double]$currentModNumber = Read-Host -Prompt "Enter in the ID of the mod"
    $currentRead = (iwr -uri https://steamcommunity.com/sharedfiles/filedetails/?id=$currentModNumber).content
    if ($currentRead -match "meta name=`"Description`" content=`"Steam Workshop: Don't Starve Together")
        {
            $currentModName = $currentRead -match "<title>Steam Workshop :: (.*)<\/title>" | % {$matches[1]}
            $fullarraywithcomments += "--#$currentModName"
            $fullarraywithcomments += "ServerModSetup(`"$currentModNumber`")"
            write-host "Success, added $currentModName"
        }
    else
        {
            write-host "Mod $currentModNumber doesn't seem to exist, try again"
            $answer = Read-Host -prompt "Do you still want to add the mod anyways?"
            if ($answer.toupper() -eq "Y" -or $answer.toupper() -eq "YES")
                {
                    $moddescription = Read-Host -prompt "Enter in description for mod"
                    $fullarraywithcomments += "--#$moddescription"
                    $fullarraywithcomments += "ServerModSetup(`"$currentModNumber`")"
                    write-host "Success, added $currentModName"
                }
        }



return($fullarraywithcomments)
}

# Function to commit all edits and additions to files
# Input the fullarraywithcomments array
# Output: nothing

function save-All

{
param($fullarraywithcomments)
$arrayofModNumbers = $fullarraywithcomments | out-string | Select-String -AllMatches "`"(\d*)`"" | % {$_.matches} | % {$_.groups[1].value}
$topofmodoveridesfile = "return {"
$pre = "[`"workshop-"
$post = "`"] = { enabled = true},"
$lastpost = "`"] = { enabled = true}"
$bottomofmodoveridesfile = "}"
[array]$outputArray = @($topofmodoveridesfile)

for ($i=0; $i -lt ($arrayofModNumbers.count-1); $i++)

{
$num = $arrayofModNumbers[$i]
$outputArray += "$pre$num$post"
}
$lastnum = $arrayofModNumbers[-1]
$outputArray += "$pre$lastnum$lastpost"
$outputArray += $bottomofmodoveridesfile




$fullarraywithcomments | Out-File $DSTmodslua -encoding ASCII
$outputArray | Out-File $masterFolderLua -encoding ASCII
$outputArray | Out-File $cavesFolderLua -encoding ASCII

}

function show-menu
{
cls
Write-Host "==============Mod Manager for DST=============="

Write-Host "1: Reload Mod List (`"dedicated_server_mods_setup.lua`")"
Write-Host "2: Add Mod"
Write-Host "3: Delete Mods"
Write-Host "4: Save Mods to file"
Write-Host "5: Re-Run/Start dedicated server"
Write-Host "Q: Quit"
Write-Host ""
Write-Host ""
Write-Host "======================================="
Write-Host "How many mods are on" ($existingMods.count/2)
Write-Host "======================================="
}

do
{
show-menu
$input = Read-Host "Please make a selection"
switch ($input)
{

#########################
# "1: Reload Mod List (`"dedicated_server_mods_setup.lua`")"
'1'
    {
    $existingMods = load-LuaFile
    }

#########################
#########################
# "2: Add Mods"
'2'
    {
    $existingMods = add-Mods $existingMods
    }

#########################
#########################
# "3: Delete Mods"

'3'
    {
    write-host "This don't work yet"
    pause
    }

#########################
#########################
# "4: Save Mods to file"

'4'
    {
    save-All $existingMods
    }
#########################
#########################
# "5: Re-Run/Start dedicated server"

'5'
    {
    write-host "This don't work yet"
    pause
    }
#########################
#########################

## Exit loop
'q'
    {

    }
}
pause
}
until ($input -eq 'q')