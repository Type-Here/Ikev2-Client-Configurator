# Windows IKEv2 Vpn Client Configurator
# By Type-Here (aka ManuEl)

# GitHub Page:https://github.com/Type-Here/Ikev2-Client-Configurator
# License: https://github.com/Type-Here/Ikev2-Client-Configurator/blob/main/LICENSE
# (MIT License)

# --------------------------------------------------------------------- #
# Feel free to copy, modify, improve the code. Please, provide credits. 

# BEFORE USE:
# The Script in this Version works in a PowerShell. It needs to be previously allowed by using
# "Set-ExecutionPolicy remotesigned" in a Powershell with Admin rights.
# If you do not know how Powershell works, use the .exe version instead.

# Only use for Ikev2 VPN with EAP authentication. Compatible with StrongSwan.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND

$Host.ui.RawUI.WindowTitle = 'Windows IKEv2 Vpn Client Configurator -- By Type-Here'
$Host.UI.RawUI.BackgroundColor = "DarkBlue"

# START #
# Check if Admin
# Get the ID and security principal of the current user account
# https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell

$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

# Get the security principal for the administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

# Check to see if we are currently running as an administrator
if ($myWindowsPrincipal.IsInRole($adminRole))
{
    # We are running as an administrator, so change the title and background colour to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkBlue"
    Clear-Host
}
else {
    # We are not running as an administrator, so relaunch as administrator

    # Create a new process object that starts PowerShell
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

    # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path
    $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    # Exit from the current, unelevated, process
    Exit;
}

# ### Crea Nuova IKEv2 VPN ###

Write-Host "Welcome, we're about to set a new Ikev2 VPN Client in Windows"
Write-Host ' ----- '
$b= 0
DO
{
	# Exit if y or n are not pressed for 5 time
	if ( $b -eq 4 ) 
	{ throw  "Too many incorrect inputs. Only 'y' o 'n' are accepted. 'n Turn your cat away from the keyboard"
	  # $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
	}
	
	Write-Host "Phase 1 - Import a CA Certificate (ca-cert) in Root"
	$ask_user_for_certificate= Read-Host -Prompt "Do you want to insert a certificate (y/n): "


	if ( 'y' -eq $ask_user_for_certificate )
	{
		# Write-Host "Now press any key to continue, then select a certificate";
		# $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
		
		# Carica l'assembly necessario a far funzionare il form (LoadWithPartialName sembra deprecato) NB. sostituito da Add-Type -AssemblyName PresentationFramework
		#[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
		
		# Se ModulePath sbagliato, non fa caricare il certificato, errore possibile in alcune versioni di PowerShell
		# https://stackoverflow.com/questions/51954533/cannot-find-cert-drive-or-certificate-provider-via-powershell
		# $env:PSModulePath = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')
		# Import-Module pki

		# $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
		
		# Dialog from https://powerintheshell.com/2015/12/07/ps-openfiledialog/ (modified)		
								
		# Loads the Assembly Module for OpenFileDailog to work			
		Add-Type -AssemblyName PresentationFramework
		 
		$dialog = New-Object -TypeName Microsoft.Win32.OpenFileDialog
		# Set dialog properties
		$dialog.Title = 'Select a Certificate - IKEv2 Client Creator'
		$dialog.InitialDirectory = "$Home\Documents"
		$dialog.Filter = 'Certificates|*.pem|Everything|*.*'
		if ($dialog.ShowDialog())
		{
			$cert_path= $dialog.FileName
			Write-Host -NoNewLine $cert_path
			Write-Host " selected"
			Write-Host "Certificate will be imported. Press any key to confirm"
			$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			Write-Host ' ----- '
			try{
				# ----- Alternative Way 1 ------
				# Import-Certificate -CertStoreLocation cert:\LocalMachine\Root\ -FilePath $cert_path
				# Altri possibili metodi '(da sistemare)'
				# $arguments = "-addstore -f 'Root' '{$dialog.FileName}'"
				
				# ----- Alternative Way 2 ------
				# $ret = Start-Process 'certutil.exe' -Verb RunAs -ArgumentList $arguments -Wait -PassThru -NoNewWindow -Confirm
				
				# Attenzione alle virgolette giuste! Vedi https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules?view=powershell-7.3
				$Command = "certutil.exe -addstore -f 'Root' '${cert_path}'"
				Invoke-Expression $Command

				# ----- Alternative Way 3 ------
				
				#Location of Ca-Cert to be stored
				# $location = 'LocalMachine'
				# $store = 'Root\'
				
				# $cert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2Collection	
				# $cert.Import($cert_path)
				# $certStore = New-Object `
					# -TypeName System.Security.Cryptography.X509Certificates.X509Store `
					# -ArgumentList ($store, $location)

				# $certStore.Open('MaxAllowed')
				# $certStore.AddRange($cert)
				# $certStore.Close()
				
			} catch {
				Write-Host ' ----- '
				Write-Warning "Some error occured while importing the certificate."
				Write-Warning 'Certificate importing skipped'
				Write-Warning 'May be necessary to Exit and Check the certificate validity.'
			}
		}
		else
		{
			Write-Host ' ----- '
			Write-Warning 'Nothing selected.' 
			Write-Warning 'Certificate importing skipped'
			Write-Warning 'A certificate is required for a VPN to work, make sure it already exists.'
		}
		# Variabile di controllo del Loop
		$a='ok'
	} elseif ( 'n' -eq $ask_user_for_certificate )
	{
		Write-Host ' ----- '
		Write-Warning 'A certificate is required for a VPN to work, make sure it already exists.'
		$a= 'ok'
	} else {
		Write-Host ' ----- '
		Write-Warning "Only 'y' o 'n' are accepted."
		$b++
	}
} Until ($a -eq 'ok')

Write-Host ' ----- '
Write-Host "Phase 2 - Creating a VPN "
Write-Host "Press any key to continue... "
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "Creating Registry Key to enable DH2048_AES256..."

$path1 = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Parameters'
$regvalueName = 'NegotiateDH2048_AES256'

try{
	$get_regkey = Get-ItemProperty -Path $path1 -Name $regvalueName
     if($get_regkey){
		Write-Host 'Security Registry Key already exists... skipping';
	 }
}
 catch {
     New-Item -Path $path1 -Name $regvalueName -Force
     New-ItemProperty -Path $path1 -Name $regvalueName -Value 2 -PropertyType DWord -Force
	 if($get_regkey)
	 {	 
		Write-Host 'Security Registry Key created.'
	 } else {
		 Write-Warning 'Some error occured: Registry Key not created.'
	 }
	 

 }
Write-Host " ----- "
Write-Host "Please enter VPN info: "

$vpn_name= Read-Host -Prompt "Enter a VPN name: "
$ip_domain= Read-Host -Prompt "Enter VPN IP o Domain: "
# $user= Read-Host -Prompt "Enter Username: "
# $pass= Read-Host -Prompt "Enter Pass: " -AsSecureString

try{
	Add-VpnConnection -Name $vpn_name -ServerAddress $ip_domain -TunnelType "IKEv2" -AuthenticationMethod "EAP" -EncryptionLevel "Maximum" -RememberCredential -ErrorAction Stop
	Set-VpnConnectionIPsecConfiguration -Name "VPN Connection" -AuthenticationTransformConstants GCMAES256 -CipherTransformConstants GCMAES256 -DHGroup ECP384 -IntegrityCheckMethod SHA384 -PfsGroup ECP384 -EncryptionMethod GCMAES256
	try{
		Get-VpnConnection -Name $vpn_name
		Write-Host ' ----- '
		Write-Host "VPN Created Successfully"
	} catch {
		Write-Host ' ----- '
		Write-Error "Some error occured, VPN not created."
    }

 }
 catch {
	Get-VpnConnection -Name $vpn_name
	Write-Host ' ----- '
	Write-Error "Error occurred, probably a VPN with this name already exists."
    }
	 

# Codice di chiusura
Write-Host ' ----- '
Write-Host ' ----- '
Write-Host -NoNewLine "Process completed. Press any key to exit...";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");