# pmset provider for mac os x power management settings
# At the moment we can only set power on all sources, because pmset will not report one setting list per power source with -g option
Puppet::Type.newtype(:powermgmt) do
  @doc = "Manage power management settings."

  # Switches to pmset depending on power source
  PuppetToNativeSwitchMap = {
    :all => '-a',
    :battery => '-b',
    :charger => '-c',
    :ups => '-u', }

  def munge_boolean(value)
    case value
    when true, "true", :true
      :true
    when false, "false", :false
      :false
    else
      fail("munge_boolean only takes booleans")
    end
  end
  
  def munge_integer(value)
      Integer(value)
  rescue ArgumentError
      fail("munge_integer only takes integers")
  end
  
  newparam(:name) do
    desc "Name of this power management setting"
    
    isnamevar
  end
  
  newparam(:source) do
    desc "The type(s) of power source to apply this setting to."
    # The -a, -b, -c, -u flags determine whether the settings apply to battery ( -b ), charger (wall power) ( -c ),
    # UPS ( -u ) or all ( -a ).
    newvalues(:all, :battery, :charger, :ups)
    defaultto :all
  end
  
  newproperty(:sleep) do
    desc "System sleep time (in minutes)"
    
    munge do |value|
      @resource.munge_integer(value)
    end
    defaultto 30 # Mac OS X Default
  end
  
  newproperty(:disk_sleep) do
    desc "Disk sleep/spin down time (in minutes)"
    
    munge do |value|
      @resource.munge_integer(value)
    end
    defaultto 10 # Mac OS X Default
  end
  
  newproperty(:display_sleep) do
    desc "Display sleep time (in minutes)"
    
    munge do |value|
      @resource.munge_integer(value)
    end
    defaultto 10 # Mac OS X Default
  end
  
  newproperty(:wake_on_lan, :boolean => true) do
    desc "Whether the system will respond to a magic ethernet wake packet."
    
    newvalue(:true)
    newvalue(:false)
    
    defaultto :true
    
    munge do |value|
      @resource.munge_boolean(value)
    end    
  end
  
  newproperty(:power_button_sleeps, :boolean => true) do
    desc "Whether the power button will cause the system to sleep or not.
    The alternative is to shut down immediately (if false)
    "
    
    newvalue(:true)
    newvalue(:false)
    
    defaultto :true # Mac OS X Default
    
    munge do |value|
      @resource.munge_boolean(value)
    end
  end
  
  newproperty(:autorestart, :boolean => true) do
    desc "Automatically restart on power loss."
    
    newvalue(:true)
    newvalue(:false)
    
    defaultto :true # Mac OS X Default
    
    munge do |value|
      @resource.munge_boolean(value)
    end
  end

  # pmset -g doesn't display current halfdim setting
  # newproperty(:display_is_dimmed, :boolean => true) do
  #   desc "Does the display sleep dim the screen instead of powering off?"
  #   
  #   newvalue(:true)
  #   newvalue(:false)
  #   defaultto :true
  #   
  #   munge do |value|
  #     @resource.munge_boolean(value)
  #   end
  # end  
end