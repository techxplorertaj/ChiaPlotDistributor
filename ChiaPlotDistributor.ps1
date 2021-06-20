#PURPOSE: THis script checks for completed Chia plots in your final directory and finds a drive with enough space to store it.
#This is useful if you are using a tool like the MADMAX plotter and would like to be more hansfree.



#Path that you are plottign to
$plotLocation = "e:\" 


#This is the detination where the final plot(s) will be stored on the drive found with space
#Do not include drive letter
$plotDestination = "\Chia\Final\"

#The list of drives that you do not want to store plots on 
$drivesToExclude = "C:","D:","E:" 

#The timespan in seconds before checking for new plots to transfer
$secondsToSleep = 240 

#I was getting bored seeing the same message whenever there was nothing to transfer
$taunts = "I'm bored.","Nothing to do.","Ive been waiting for too long.","Are we there yet?","This is really slow.","Feels like forever.","Give me plots.","I need plots now, you slow #$@!$.","I'm going back to bed.","Nothing to see. Nothing to do.","Maybe get a better rig next time?","I can't belive that I woke up for this."


$lastTaunt = 0

while($true)
{
    $filesAtLocation = ($plotLocation + "*.plot")

    $driveFound = $false

    $plots = Get-ChildItem -Path $filesAtLocation -Recurse -erroraction SilentlyContinue | Measure-Object -property length -sum

    $plotsize = $plots.Sum

    #Write-Output ("plot size: " + $plotsize)

    if($plotsize -gt 1)
    {
        $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"
        Write-Output ($currentTime + " - GOT ME SOME PLOTS. LETS GO!")

        $Disk = Get-WmiObject -Class Win32_logicaldisk
        $count = $Disk.Count

        for($i=0; $i -lt $count; $i++)
        {
            $device = Write-Output $Disk[$i].DeviceID
            $free = $Disk[$i].FreeSpace 
            Write-Output ($currentTime + " - Device " + $device + " Is being considered. It has " + [math]::Round($free/1GB) + "GB of free space.")

            if($drivesToExclude.Contains($device))
            {
                $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"
                Write-Output ($currentTime + " - Device " + $device + " Excluded.")
                continue
            }
            else
            {
                if($free -gt $plotsize)
                {
                    $driveFound = $true
                    [console]::beep(500,300)
                    $destination = $device + $plotDestination

                    $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"
                    Write-Output ($currentTime + " - Device " + $device + " selected. Space required: " + [math]::Round($plotsize/1GB) + "GB" + ". Free space: " + [math]::Round($free/1GB) + "GB")

                    $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"
                    Write-Output ($currentTime + " - Transferring plot(s) to " + $destination)

                    $cmdArgs = @("$plotLocation","$destination","*.plot","/mov")
                    
                    robocopy @cmdArgs

                    
                    #robocopy $plotLocation $destinaton *.plot /mov
                 
                    $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"
                    Write-Output ($currentTime + " - Plot(s) transferred to " + $destination)
                    
                    [console]::beep(500,200)
                    [console]::beep(500,200)
                    [console]::beep(500,200)

                    break

                }
                else
                {
                    $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"
                    Write-Output ($currentTime + " - Device " + $device + " Ineligible. Insufficient space.")
                }


            }

            
        
        }

        if($driveFound -eq $false)
        {
            [console]::beep(500,200)
            [console]::beep(500,200)
            [console]::beep(500,200)
            [console]::beep(500,200)
            [console]::beep(500,200)
            [console]::beep(500,200)

            $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"
            Write-Output ($currentTime + " - No drives were found with sufficient space to store your plots.")
        }

    }
    else
    {
        $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm"


        $randTaunt = Get-Random -Maximum $taunts.Count
        while($randTaunt -eq $lastTaunt)
        {
            $randTaunt = Get-Random -Maximum $taunts.Count
        }

        $lastTaunt = $randTaunt
        #Write-Output ($currentTime + " - Nothing to transfer. Taking a nap for " + $secondsToSleep + " seconds.")
        Write-Output ($currentTime + " - " + $taunts[$randTaunt])
    }

    sleep $secondsToSleep
}