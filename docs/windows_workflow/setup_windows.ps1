## Check if the script is running with administrative privileges
#if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
#{
#    Write-Host "Please run this script as an administrator."
#    exit
#}

function Install-WSL
{
    # Enable WSL feature
    wsl.exe --install -d 'ubuntu' --no-launch
    Write-Host "WSL installation started. If ubuntu doesn't start, please run a new terminal and type 'ubuntu' in powershell." -ForegroundColor Yellow
    $wslStatus = wsl.exe --list --quiet
    Write-Host "All available WSL instances: $wslStatus" -ForegroundColor Yellow
    if (wsl -l |Where { $_.Replace("`0", "") -match '^Ubuntu' })
    {
        Write-Host "WSL is installed." -ForegroundColor Green

        # updating windows terminal settings
        $settingsFilePath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $settingsContent = Get-Content -Path $settingsFilePath -Raw | ConvertFrom-Json
        $ubuntuProfile = $settingsContent.profiles.list | Where-Object { $_.name -eq "Ubuntu" }

        if ($ubuntuProfile)
        {
            Write-Host "Found Ubuntu profile in settings. Updating default behavior..."

            $ubuntuProfile | Add-Member -NotePropertyName "startingDirectory" -NotePropertyValue "~" -Force
            $ubuntuProfile | Add-Member -NotePropertyName "commandline" -NotePropertyValue "ubuntu run" -Force

            # Save the updated settings back to the file
            $settingsContent | ConvertTo-Json -Depth 100 | Set-Content -Path $settingsFilePath

            Write-Host "Ubuntu profile updated with default behavior set to %homeuser%."
        }
        else
        {
            Write-Host "Ubuntu profile not found in settings."
        }

        Write-Host "Settings update completed."

        # run wsl
        wsl -d 'Ubuntu'
    }
    else
    {
        Write-Host "WSL installation failed." -ForegroundColor Red
    }
}

function Export-WSL
{
    # Specify the name of your WSL 2 instance
    $wslInstance = 'ubuntu'

    # Specify the path where you want to export the WSL instance
    $exportPath = "E:\$wslInstance.tar"

    # Terminate or shutdown the WSL instance
    wsl.exe --terminate $wslInstance

    # Export the WSL 2 instance to a tar file
    wsl.exe --export $wslInstance $exportPath

    Write-Host "WSL instance '$wslInstance' exported successfully to: $exportPath" -ForegroundColor Yellow

    # Open the location where the file is stored
    Invoke-Item (Get-Item $exportPath).DirectoryName
}

$apps = @{
    11 = "Brave.Brave"
    12 = "Mozilla.Firefox"
    13 = "Microsoft.Edge"

    21 = "Facebook.Messenger"
    22 = "Discord.Discord"
    23 = "WhatsApp.WhatsApp"
    24 = "Viber.Viber"
    25 = "Telegram.TelegramDesktop"
    26 = "Snapchat.Snapchat"
    27 = "Instagram.Instagram"
    28 = "Zoom.Zoom"
    29 = "Microsoft.Teams"

    31 = "VideoLAN.VLC"
    34 = "Netflix"
    35 = "Prime Video"
    36 = "Disney+"

    41 = "Spotify.Spotify"
    42 = "Apple.AppleMusic"

    51 = "Valve.Steam"
    52 = "EpicGames.EpicGamesLauncher"
    53 = "Nvidia.GeForceExperience"
    54 = "Ubisoft.Connect"
    55 = "SideQuestVR.SideQuest"

    61 = "Google.GoogleDrive"
    62 = "Microsoft.OneDrive"
    63 = "icloud"
    64 = "Microsoft 365"
    65 = "Adobe Acrobat Reader DC"
    66 = "Notion.Notion"
    67 = "SublimeHQ.SublimeText.4"
    68 = "Obsidian.Obsidian"

    71 = "OBSProject.OBSStudio"
    72 = "Creative Cloud"
    74 = "ByteDance.CapCut"
    75 = "microsoft clipchamp"
    76 = "canva.canva"

    81 = "NordVPN.NordVPN"
    82 = "qBittorrent.qBittorrent"
    83 = "Ookla.Speedtest.Desktop"
    84 = "Microsoft.BingWallpaper"
    85 = "File-New-Project.EarTrumpet"
    86 = "ShareX.ShareX"
    87 = "glzr-io.glazewm"
    88 = "Microsoft.PowerToys"
    89 = "RevoUninstaller.RevoUninstaller"
    890 = "REALiX.HWiNFO"

    92 = "Microsoft.WindowsTerminal"
    93 = "Microsoft.VisualStudioCode"
    94 = "JetBrains.PyCharm.Community"
    95 = "JetBrains.PyCharm.Professional"
    96 = "Docker.DockerDesktop"


}


function Install-Windows-Apps
{
    Write-Host "Welcome to the Windows apps installer script. This script will INSTALL or UPDATE the following apps:" -ForegroundColor Yellow

    $categories = @{
        1 = "Web Browsers"
        2 = "Messaging"
        3 = "Meetings and Conferencing"
        4 = "Media, music and Entertainment"
        5 = "Gaming"
        6 = "Documents, drives & editing"
        7 = "Image & Video Editing"
        8 = "Security, monitoring & others"
        9 = "Development & Programming"
        0 = "Others"
    }

    function Display-Menu
    {
        Write-Host "Menu:" -ForegroundColor Yellow
        foreach ($category in $categories.Keys | Sort-Object)
        {
            Write-Host ""
            Write-Host $categories[$category]":" -ForegroundColor Yellow
            foreach ($key in $apps.Keys | Where-Object { $_ -match "^$category" } | Sort-Object)
            {
                Write-Host "$key. $( $apps[$key] )"
            }
        }
    }

    function Install-Apps
    {
        param(
            [string]$selectedApps,
            [hashtable]$apps
        )

        $selectedAppsArray = $selectedApps -split ',' | ForEach-Object { $_.Trim() }
        $confirmationMessage = "This script will install the selected apps. Do you want to continue?"
        $confirmation = $host.ui.PromptForChoice("Confirmation", $confirmationMessage, @("&Yes", "&No"), 1)

        if ($confirmation -eq 0)
        {
            foreach ($app in $selectedAppsArray)
            {
                if ($app -in $apps.Keys)
                {
                    $app = [int]$app
                    $appName = $apps[$app]
                    Write-Host "Installing $appName..."
                    $installCommand = "winget install -e --id '$appName'"
                    Invoke-Expression $installCommand
                }
                else
                {
                    Write-Host "Invalid app number: $app. Available app numbers: $( $apps.Keys -join ', ' )"
                }
            }
        }
        else
        {
            Write-Host "Operation canceled."
        }
    }



    Display-Menu

    $selectedApps = Read-Host "Enter the numbers of the apps to install or update (separated by comma). For example 11,25 to install both brave & discord:"

    Install-Apps -selectedApps $selectedApps -apps $apps
}

function Update-Terminal-Settings()
# used inside the function Update-Terminal-UI
{
    # Check if the Font is installed
    $fontName = "JetBrainsMonoNerdFont-Regular.ttf"  # Adjust the font file name as needed
    $fontPath = Join-Path -Path ([System.IO.Path]::GetFullPath("C:\Windows\Fonts")) -ChildPath $fontName
    $isFontInstalled = Test-Path -Path $fontPath

    if (-not $isFontInstalled)
    {
        Write-Host "Font $( $fontName ) is not installed. Please install the font" -ForegroundColor Red
        exit
    }
    else
    {
        Write-Host "Updating Settings..."

        # Specify the path to your settings file
        $settingsFilePath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

        # Read the content of the settings file
        $settingsContent = Get-Content -Path $settingsFilePath -Raw | ConvertFrom-Json

        # Update the default profile settings if they exist
        if ($settingsContent.profiles -and $settingsContent.profiles.defaults)
        {
            $fontObject = New-Object PSObject -Property @{
                face = "JetBrainsMono Nerd Font"
                size = 12.0
            }
            $schemesObject = $settingsContent.schemes
            # Check if the "Night Owl" scheme exists in the list of schemes
            $schemeExists = $false
            foreach ($scheme in $schemesObject)
            {
                if ($scheme.name -eq "Night Owl")
                {
                    $schemeExists = $true
                    Write-Host "Scheme 'Night Owl' is present." -ForegroundColor Green
                    break
                }
            }

            # If the scheme does not exist, create it
            if (-not $schemeExists)
            {
                Write-Host "Scheme 'Night Owl' not found. Adding it now." -ForegroundColor Yellow
                $newScheme = @{
                    name = "Night Owl"
                    cursorColor = "#80a4c2"
                    selectionBackground = "#1d3b53"
                    background = "#011627"
                    foreground = "#D6DEEB"
                    black = "#011627"
                    blue = "#82AAFF"
                    cyan = "#21C7A8"
                    green = "#22DA6E"
                    purple = "#C792EA"
                    red = "#EF5350"
                    white = "#FFFFFF"
                    yellow = "#c5e478"
                    brightBlack = "#575656"
                    brightBlue = "#82AAFF"
                    brightCyan = "#7FDBCA"
                    brightGreen = "#22DA6E"
                    brightPurple = "#C792EA"
                    brightRed = "#EF5350"
                    brightWhite = "#FFFFFF"
                    brightYellow = "#FFEB95"
                }

                $settingsContent.schemes += $newScheme
            }

            # Update the default profile settings

            $settingsContent.profiles.defaults | Add-Member -NotePropertyName "colorScheme" -NotePropertyValue "Night Owl" -Force
            $settingsContent.profiles.defaults | Add-Member -NotePropertyName "font" -NotePropertyValue $fontObject -Force
            $settingsContent.profiles.defaults | Add-Member -NotePropertyName "opacity" -NotePropertyValue 90 -Force
            $settingsContent.profiles.defaults | Add-Member -NotePropertyName "elevate" -NotePropertyValue $true -Force
            $settingsContent.profiles.defaults | Add-Member -NotePropertyName "selectionBackground" -NotePropertyValue "#FFFF00" -Force
        }

        # Convert back to JSON and save the updated settings
        $settingsContent | ConvertTo-Json -depth 100 | Set-Content -Path $settingsFilePath

        Write-Host "Windows Terminal settings updated successfully." -ForegroundColor Green
    }
}

# function to install fonts
function Update-Terminal-UI()
{
    $windowsTerminalSettingsDirectory = "$env:UserProfile\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    $settingsJsonFileName = "settings.json"

    $confirmationMessage = "Do you want to update the default apperance of Windows Terminal (font, size) ? The following file will be modified:`n`n$windowsTerminalSettingsDirectory\$settingsJsonFileName`n`nDo you want to continue?"
    $confirmation = $host.ui.PromptForChoice("Confirmation", $confirmationMessage, @("&Yes", "&No"), 0)

    if ($confirmation -eq 0)
    {
        # Check if the Font is installed
        $fontName = "JetBrainsMonoNerdFont-Regular.ttf"  # Adjust the font file name as needed
        $fontPath = Join-Path -Path ([System.IO.Path]::GetFullPath("C:\Windows\Fonts")) -ChildPath $fontName
        $isFontInstalled = Test-Path -Path $fontPath

        if ($isFontInstalled)
        {
            Write-Host "Font $( $fontName ) is installed." -ForegroundColor Green
        }
        else
        {

            Write-Host "Font $( $fontName ) is not installed. Installing..." -ForegroundColor Yellow
            $fontZipUrl = "https://github.com/AmineDjeghri/awesome-os-setup/raw/main/docs/JetBrainsMonoNerdFont-Regular.zip"
            $fontsPath = "$env:TEMP\JetBrainsMono"

            # Create the destination directory if it doesn't exist
            if (-not (Test-Path -Path $fontsPath -PathType Container))
            {
                New-Item -ItemType Directory -Path $fontsPath | Out-Null
            }

            # Download the font zip file & extract the file
            $fontZipPath = Join-Path -Path $fontsPath -ChildPath "JetBrainsMonoNerdFont-Regular.zip"
            Invoke-WebRequest -Uri $fontZipUrl -OutFile $fontZipPath

            Write-Host "Extracting font files..."
            Expand-Archive -Path $fontZipPath -DestinationPath $fontsPath -Force

            # Install all TTF files
            $getFonts = Get-ChildItem -Path $fontsPath -Include '*.ttf', '*.ttc', '*.otf' -recurse

            $systemFontsPath = "C:\Windows\Fonts"
            $getFonts = Get-ChildItem $fontsPath -Include '*.ttf', '*.ttc', '*.otf' -recurse

            foreach ($fontFile in $getFonts)
            {
                $targetPath = Join-Path $systemFontsPath $fontFile.Name

                if (Test-Path -Path $targetPath)
                {
                    $FontFile.Name + " already installed"
                }
                else
                {

                    "Installing font " + $fontFile.Name
                    #Extract Font information for Reqistry
                    $ShellFolder = (New-Object -COMObject Shell.Application).Namespace($fontsPath)
                    $ShellFile = $shellFolder.ParseName($fontFile.name)
                    $ShellFileType = $shellFolder.GetDetailsOf($shellFile, 2)
                    #Set the $FontType Variable
                    If ($ShellFileType -Like '*TrueType font file*')
                    {
                        $FontType = '(TrueType)'
                    }
                    #Update Registry and copy font to font directory
                    $RegName = $shellFolder.GetDetailsOf($shellFile, 21) + ' ' + $FontType
                    New-ItemProperty -Name $RegName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.name -Force | out-null
                    Copy-item $fontFile.FullName -Destination $systemFontsPath
                    "Done"
                }
            }
            Write-Host "Font installation complete." -ForegroundColor Yellow

            # Clean up
            Remove-Item -Path $fontZipPath -Force
            Remove-Item -Path $fontsPath -Recurse -Force
        }

        Update-Terminal-Settings
    }
    else
    {
        Write-Host "Operation canceled. Windows Terminal's appearance wasn't updated." -ForegroundColor Yellow
    }


}

# function to replace settings.json of GlazeWM
function Get-GlazeWM-Settings()
{
    #todo: update to support glazewm 3.x
    $glazeWMConfigDirectory = "$env:UserProfile\.glzr\glazewm"

    $confirmationMessageGlazeWM = "This script will install GlazeWM by replacing the config file located at:`n`n$glazeWMConfigDirectory\$glazeWMConfigFileName`n`nDo you want to continue?"
    $confirmationGlazeWM = $host.ui.PromptForChoice("Confirmation", $confirmationMessageGlazeWM, @("&Yes", "&No"), 1)

    if ($confirmationGlazeWM -eq 0)
    {
        $glazeWMConfigUrl = "https://raw.githubusercontent.com/AmineDjeghri/awesome-os-setup/main/docs/windows_workflow/win_dotfiles/glazewm/config.yaml"
        $glazeWMConfigFileName = "config.yaml"

        Invoke-WebRequest -Uri $glazeWMConfigUrl -OutFile $glazeWMConfigDirectory\$glazeWMConfigFileName

        Write-Host "GlazeWM config.yaml file downloaded and replaced. Restart GlazeWM to see the changes." -ForegroundColor Yellow
    }
    else
    {
        Write-Host "Operation canceled."
    }

}

function Show-Menu
{
    Clear-Host
    Write-Host "===== Windows/WSL Management Menu =====" -ForegroundColor Yellow
    Write-Host "1. Install Windows Apps"
    Write-Host "2. Update Windows Terminal UI"
    Write-Host "3. Install WSL (Ubuntu)"
    Write-Host "4. Setup WSL with Linux"
    Write-Host "5. Export WSL & Backup"
    Write-Host "6. Optimize WSL size (coming soon...)"
    Write-Host "7. Get GlazeWM settings"
}

function Execute-Choice
{
    param(
        [string]$choice
    )

    switch ($choice)
    {
        '1' {
            Install-Windows-Apps
        }
        '2' {
            Update-Terminal-UI
        }
        '3' {
            Install-WSL
        }
        '4' {
            Write-Host 'Run this command in Linux:'
            Write-Host 'sh -c "$(wget https://raw.githubusercontent.com/AmineDjeghri/awesome-os-setup/main/docs/unix_workflow/setup_linux.sh -O -)"' -ForegroundColor Green
        }
        '5' {
            Export-WSL
        }
        '6' {
            Optimize-WSL
        }
        '7' {
            Get-GlazeWM-Settings
        }
        default {
            Write-Host "Invalid choice. Please enter a valid option."
        }
    }
}

while ($true)
{
    Show-Menu
    $userChoice = Read-Host "Enter your choice"

    Execute-Choice -choice $userChoice
    Pause
}
