Puppet::Type.type(:powermgmt).provide :powermgmt, :parent => Puppet::Provider do

  desc "Manage Mac OS X power management settings."
  
  commands :pmset => "/usr/bin/pmset"
  confine :operatingsystem => :darwin
  defaultfor :operatingsystem => :darwin

  Source_To_Switch = {
      :all => '-a',
      :battery => '-b',
      :charger => '-c'
  }

  attr_accessor :source

  class << self

    def instances
      profiles = Hash.new
      current_profile = 'default'
      output = pmset '-g', 'custom'

      # Parse all of the available pmset output
      output.each_line do |line|
        case
          when line.match(/^[^:]+:$/)

            current_profile = {
                "AC Power:" => :charger,
                "Battery Power:" => :battery
            }[$~.to_s]

            profiles[current_profile] = Hash.new
          else
            line_hash = line.strip.split(/\s+/)
            profiles[current_profile][line_hash[0]] = line_hash[1]
        end
      end

      pmset_instances = []

      profiles.each_pair do |k, v|
        v[:source] = k
        v[:name] = k
        v[:provider] = :powermgmt

        pmset_instances << new(v)
      end

      pmset_instances
    end
  
    def prefetch(resources)

      @profiles = Hash.new
      current_profile = 'default'
      output = pmset '-g', 'custom'

      # Parse all of the available pmset output
      output.each_line do |line|
        case
          when line.match(/^[^:]+:$/)

            current_profile = {
                "AC Power:" => :charger,
                "Battery Power:" => :battery
            }[$~.to_s]

            @profiles[current_profile] = Hash.new
          else
            line_hash = line.strip.split(/\s+/)
            @profiles[current_profile][line_hash[0]] = line_hash[1]
        end
      end

      # Select only the required prefetched resources
      resources.each do |name, resource|
        if @profiles.has_key?(name)
          resource.provider = new(@profiles[name])
        else
          resource.provider = new()
        end
      end

      #debug(profiles.inspect)
    end 
  end

  # Accessors for `pmset` information

  # displaysleep - display sleep timer; replaces 'dim' argument in 10.4 (value in minutes, or 0 to disable)
  def display_sleep
    @property_hash['displaysleep']
  end

  def display_sleep=(minutes)
    pmset Source_To_Switch[@source], 'displaysleep', minutes
  end

  # disksleep - disk spindown timer; replaces 'spindown' argument in 10.4 (value in minutes, or 0 to disable)
  def disk_sleep
    @property_hash['disksleep']
  end

  def disk_sleep=(minutes)
    pmset Source_To_Switch[@source], 'disksleep', minutes
  end

  # sleep - system sleep timer (value in minutes, or 0 to disable)
  # Strip "(sleep prevented by 58985)"
  def sleep
    @property_hash['sleep'] || 0
  end

  def sleep=(minutes)
    pmset Source_To_Switch[@source], 'sleep', minutes
  end

  # womp - wake on ethernet magic packet (value = 0/1)
  def wake_on_lan
    return nil unless @property_hash.has_key? 'womp'
    return nil unless @property_hash['womp'] == '0' || @property_hash['womp'] == '1'
    
    @property_hash['womp'] == '1' ? :true : :false
  end

  def wake_on_lan=(enabled)
    pmset Source_To_Switch[@source], 'womp', (enabled === :true ? '1' : '0')
  end

  # autorestart - automatic restart on power loss (value = 0/1)
  def autorestart
    return nil unless @property_hash.has_key? 'autorestart'
    return nil unless @property_hash['autorestart'] == '0' || @property_hash['autorestart'] == '1'
    
    @property_hash['autorestart'] == '1' ? :true : :false
  end

  def autorestart=(enabled)
    pmset Source_To_Switch[@source], 'autorestart', (enabled === :true ? '1' : '0')
  end

  # powerbutton - sleep the machine when power button is pressed (value = 0/1)
  def power_button_sleeps
    return nil unless @property_hash.has_key? 'powerbutton'
    return nil unless @property_hash['powerbutton'] == '0' || @property_hash['powerbutton'] == '1'
    
    @property_hash['powerbutton'] == '1' ? :true : :false
  end

  def power_button_sleeps=(enabled)
    pmset Source_To_Switch[@source], 'powerbutton', (enabled === :true ? '1' : '0')
  end

  # lidwake - wake the machine when the laptop lid (or clamshell) is opened (value = 0/1)
  def lidwake
    return nil unless @property_hash.has_key? 'lidwake'
    return nil unless @property_hash['lidwake'] == '0' || @property_hash['lidwake'] == '1'
    
    @property_hash['lidwake'] == '1' ? :true : :false
  end

  def lidwake=(enabled)
    pmset Source_To_Switch[@source], 'lidwake', (enabled === :true ? '1' : '0')
  end

  # acwake - wake the machine when power source (AC/battery) is changed (value = 0/1)
  def acwake
    return nil unless @property_hash.has_key? 'acwake'
    return nil unless @property_hash['acwake'] == '0' || @property_hash['acwake'] == '1'
    
    @property_hash['acwake'] == '1' ? :true : :false
  end

  def acwake=(enabled)
    pmset Source_To_Switch[@source], 'acwake', (enabled === :true ? '1' : '0')
  end
  
  # lessbright - slightly turn down display brightness when switching to this power source (value = 0/1)
  def lessbright
    return nil unless @property_hash.has_key? 'lessbright'
    return nil unless @property_hash['lessbright'] == '0' || @property_hash['lessbright'] == '1'
    
    @property_hash['lessbright'] == '1' ? :true : :false
  end

  def lessbright=(enabled)
    pmset Source_To_Switch[@source], 'lessbright', (enabled === :true ? '1' : '0')
  end

  # halfdim - display sleep will use an intermediate half-brightness state between full brightness and fully off  (value = 0/1)
  def halfdim
    return nil unless @property_hash.has_key? 'halfdim'
    return nil unless @property_hash['halfdim'] == '0' || @property_hash['halfdim'] == '1'

    @property_hash['halfdim'] == '1' ? :true : :false
  end

  def halfdim=(enabled)
    pmset Source_To_Switch[@source], 'halfdim', (enabled === :true ? '1' : '0')
  end

  # sms - use Sudden Motion Sensor to park disk heads on sudden changes in G force (value = 0/1)
  def sms
    return nil unless @property_hash.has_key? 'sms'
    return nil unless @property_hash['sms'] == '0' || @property_hash['sms'] == '1'

    @property_hash['sms'] == '1' ? :true : :false
  end

  def sms=(enabled)
    pmset Source_To_Switch[@source], 'sms', (enabled === :true ? '1' : '0')
  end

  # change hibernation mode. hibernatemode takes a bitfield argument defining SafeSleep behavior. Passing 0 disables
  # SafeSleep altogether, forcing the computer into a regular sleep.
  # See PMSET(1) for SafeSleep bitmask reference.
  def hibernatemode
    return nil unless @property_hash.has_key? 'hibernatemode'

    @property_hash['hibernatemode'].to_i
  end

  def hibernatemode=(sleepmask)
    pmset Source_To_Switch[@source], 'hibernatemode', sleepmask
  end

  # standby delay: specifies the delay, in seconds, before writing the hibernation image to disk and powering off memory for
  # Standby.
  # You cannot set standbydelay on machines that do not support standby.
  def standbydelay
    return nil unless @property_hash.has_key? 'standbydelay'

    @property_hash['standbydelay'].to_i
  end

  def standbydelay=(seconds)
    pmset Source_To_Switch[@source], 'standbydelay', seconds
  end


  # ttyskeepawake - prevent idle system sleep when any tty (e.g. remote login session) is 'active'.
  # A tty is 'inactive' only when its idle time exceeds the system sleep timer. (value = 0/1)
  def ttyskeepawake
    return nil unless @property_hash.has_key? 'ttyskeepawake'
    return nil unless @property_hash['ttyskeepawake'] == '0' || @property_hash['ttyskeepawake'] == '1'
    
    @property_hash['ttyskeepawake'] == '1' ? :true : :false
  end

  def ttyskeepawake=(enabled)
    pmset Source_To_Switch[@source], 'ttyskeepawake', (enabled === :true ? '1' : '0')
  end

  # destroyfvkeyonstandby - Destroy File Vault Key when going to standby mode.
  def destroyfvkeyonstandby
    return nil unless @property_hash.has_key? 'destroyfvkeyonstandby'
    return nil unless @property_hash['destroyfvkeyonstandby'] == '0' || @property_hash['destroyfvkeyonstandby'] == '1'

    @property_hash['destroyfvkeyonstandby'] == '1' ? :true : :false
  end

  def destroyfvkeyonstandby=(enabled)
    pmset Source_To_Switch[@source], 'destroyfvkeyonstandby', (enabled === :true ? '1' : '0')
  end

end
