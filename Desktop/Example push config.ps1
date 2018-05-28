################################################################
# EXAMPLE USAGE OF A SCRIPT TO PUSH CONFIG TO ALL CISCO DEVICES.
################################################################

################################################################
# Create Array for retunring data values
################################################################
$devices = @()

################################################################
# Import device list containing initial data. The below points to the most recent copy of the Statseeker import.
################################################################
$list = Import-Csv "\\ad.aberdeenshire.gov.uk\acnet\Statseeker_data\Cisco_Complete.csv"

################################################################
# Populate array from using details form imported list $ fields to be populated later
################################################################
### Step through each line of imported file
foreach($line in $list){
### Set device variable to null.                                           
$device = $null                                                    
### Create custom object with fields that are required to collect data and any rouble shooting.
$device = [pscustomobject][ordered] @{                             

                    ### Use Device field from import to populate Device field in array
                    Device = [String]"$($line.Device)"             
                    ### Use Ipaddress field from import to populate Ipaddress field in array
                    Ipaddress = [String]"$($line.Ipaddress)"
                    ### Use SSHConnected field from import to populate SSHConnected field in array to use correct connection type and log if successfull       
                    SSHConnected = "$($line.SSHConnection)" 
                    ### Use TelnetConnected field from import to populate TelnetConnected field in array to use correct connection type and log if successfull       
                    TelnetConnected = "$($line.TelnetConnection)"
                    ### Use Model field from import to populate Model field in array for trouble shooting, is to see if a particular result is commmon to a single device  
                    Model = [String]"$($line.Model)"
                    ### Use Image field from import to populate Image field in array for trouble shooting, is to see if a particular result is commmon to a single image               
                    Image = [String]"$($line.Image)"
                     ### Usedt to populate Result field in array with results of any test that may be performed               
                    Result = [String[]]$null                                         
                    }
### Add single object to overall array
$devices += $device                                                
}

################################################################
# Export array to create testing file - Remove for LIVE run of script
################################################################

$devices | Export-Csv "C:\Users\sarchib2\Desktop\Powershell Hand Over\CiscoList.csv" -NoTypeInformation

############################################################
# Once file exported 'pick' out the required devices for testing
################################################################
# Import list of test devices - Remove for LIVE run of script
################################################################
$devices = Import-Csv "C:\Users\sarchib2\Desktop\Powershell Hand Over\CiscoList.csv"
### Display results for testing purposes. Checking desired amount of objects
$devices.count  
### Display results for testing purposes. List objects                                                  
$devices | ft                                                     

################################################################
# Set up variables for running of script
################################################################
### Stores log on credentials for passing to multiple functions
$creds = Get-Credential                                           

################################################################
# Get file containing commands required to 'push' 
# Proper syntax required so test layout manually first and create file.
################################################################
$vstackcmds = Get-Content "C:\Users\sarchib2\Desktop\Powershell Hand Over\vstack.txt"

################################################################
# Run SSH commands to push commands and check results of test.
################################################################
### Step through each line of imported file if the SSHConnected field is TRUE
foreach($device in $devices | where {$_.SSHConnected -eq $true}){
### Set device variable to null.                                
$pushlog = $null
### Call SSH function, passing ipaddress to connect, list of commands, credentials to use                                                                                 
$pushlog = Get-ACCiscoSSH -IpAddress $device.Ipaddress -Commands $vstackcmds -Credentials $creds 
### Set the connection result
$device.SShConnected = $pushlog.Connected
### Set device variable to null                     
$cehcklog = $null
### Run test command and store result for later review                                                           .
$checklog = Get-ACCiscoSSH -IpAddress $device.Ipaddress -Commands "sho vstack config | inc Role:" -Credentials $creds
[string]$device.Result = $checklog.Results
$checklog
}

################################################################
# Run Telnet commands to push commands and check results of test.
################################################################
### Step through each line of imported file
foreach($device in $devices | where {$_.TelnetConnected -eq $true}){
### Set device variable to null.                                          
$pushlog = $null
### Call Telnet function, passing ipaddress to connect, list of commands, credentials to use                                                            
$pushlog = Get-ACCiscoTelnetShire -IpAddress $device.Ipaddress -Commands $vstackcmds -Credentials $creds
### Set the connection result 
$device.TelnetConnected = $pushlog.Connected
### Set device variable to null. 
$cehcklog = $null
### Run test command and store result for later review                                                           
$checklog = Get-ACCiscoTelnetShire -IpAddress $device.Ipaddress -Commands "sho vstack config | inc Role:" -Credentials $creds
[string]$device.Result = $checklog.Results 
$checklog 
}

################################################################
# Export results list for review
################################################################
$devices | Export-Csv "C:\Users\sarchib2\Desktop\Powershell Hand Over\Vstack.csv" -NoTypeInformation







