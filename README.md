Powermgmt - A Puppet resource for OSX Power Management.
-------------------------------------------------------

This provider is a simple interface to `pmset` which will allow you to set power management features in Mac OS X.

Features
--------

+ Set display/system sleep times
+ Set Wake on LAN magic packet
+ Set power button behaviour (sleep/power off)
+ Set auto-restart on power loss

Limitations
-----------

+ Cannot set whether the screen is dimmed or turned off during sleep.
+ Currently pmset only reports the *ACTIVE* profile, and so this isn't very useful for
  dealing with laptop power management unless you would like the same profile regardless of whether the
  system is running on battery or not.

Example
-------

All of the parameters supplied below are optional.

The namevar is just a placeholder for the set of values you are using.

```ruby

powermgmt { "never sleep":
	sleep               => 0, # System sleep time (in minutes) zero means never sleep
	disk_sleep          => 0, # Disk spin down time (in minutes)
	display_sleep       => 0, # Display sleep time (in minutes)
	wake_on_lan         => true, # Turn on wake on lan
	power_button_sleeps => true, # Pressing the power button sleeps instead of shutting down.
	autorestart         => true, # Automatically restart on power outage.
}

```