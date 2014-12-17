# This is an example only, you should not normally include 'puppet-osx-powermgmt'

class powermgmt {
    powermgmt { "charger":
    	sleep               => 0, # System sleep time (in minutes) zero means never sleep
    	disk_sleep          => 0, # Disk spin down time (in minutes)
    	display_sleep       => 0, # Display sleep time (in minutes)
    	wake_on_lan         => true, # Turn on wake on lan
    	power_button_sleeps => true, # Pressing the power button sleeps instead of shutting down.
    	autorestart         => true, # Automatically restart on power outage.
      hibernatemode       => 3, # Create hibernation file
      standbydelay        => 10, # Delay creation of hibernation image.
    }
}