Powermgmt - A Puppet resource for OSX Power Management.
-------------------------------------------------------

This provider is a simple interface to `pmset` which will allow you to set power management features in Mac OS X.
I haven't updated the provider in some time, you may want to check out [dayglojesus/managedmac](https://github.com/dayglojesus/managedmac) since he's written an energi saver class for osx.

Features
--------

+ Everything available in `pmset` except options that come with a warning. See limitations.

Limitations
-----------

+ I've omitted hibernatemode and hibernatefile given the warnings about potentially causing huge issues.
+ networkoversleep is also omitted because it cannot be changed.
+ wake on modem ring is omitted because it wasn't a high priority for me.

API Change v0.2
---------------

If you checked out an earlier version of the module, the behaviour of the name variable has changed.
The resource name is now the power policy you want to set. It can be either `charger` or `battery`.
You cannot use `all` because it would create a conflicting policy with the more specific power source policies.
The power source type `ups` is also not currently supported.

Example
-------

All of the parameters supplied below are optional.

```ruby

powermgmt { "charger":
	sleep                 => 0, # System sleep time (in minutes) zero means never sleep
	disk_sleep            => 0, # Disk spin down time (in minutes)
	display_sleep         => 0, # Display sleep time (in minutes)
	wake_on_lan           => true, # Turn on wake on lan
	power_button_sleeps   => true, # Pressing the power button sleeps instead of shutting down.
	autorestart           => true, # Automatically restart on power outage.
	lidwake               => true, # Wake the system when the laptop lid is opened.
	acwake                => true, # Wake the system when the power source changes.
	lessbright            => false, # Turn brightness down slightly when switching to this power source.
  halfdim               => false, # Display sleep only dims the screen instead of turning it off.
  sms                   => true, # Use sudden motion sensor to park disk heads (notebook only).
  ttyskeepawake         => true, # Prevent system from sleeping if ttys are active (including remote shell logins).
  destroyfvkeyonstandby => false, # Destroy filevault key when going into standby, User is prompted to re-enter password.
}
```

And you can of course set a different policy for battery power like so:

```ruby

powermgmt { "battery":
  sleep      => 5,
  lessbright => true,
}

```
