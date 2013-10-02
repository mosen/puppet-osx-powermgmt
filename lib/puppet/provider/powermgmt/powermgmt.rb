Puppet::Type.type(:powermgmt).provide :powermgmt, :parent => Puppet::Provider do

  desc "Manage Mac OS X power management settings."
  
  commands :pmset => "/usr/bin/pmset"
  confine :operatingsystem => :darwin
  defaultfor :operatingsystem => :darwin

  attr_accessor :source
  
  class << self

    source_to_switch = {
        :all => '-a',
        :battery => '-b',
        :charger => '-c'
    }

    def instances
      profiles = {}
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

      profiles = {}
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

      # Select only the required prefetched resources
      resources.each do |name, resource|
        if self.profiles.has_key?(name)
          resource.provider = new(self.profiles[name])
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
    pmset @@source_to_switch[@source], 'displaysleep', minutes
  end

  # disksleep - disk spindown timer; replaces 'spindown' argument in 10.4 (value in minutes, or 0 to disable)
  def disk_sleep
    @property_hash['disksleep']
  end

  def disk_sleep=(minutes)
    pmset @@source_to_switch[@source], 'disksleep', minutes
  end

  # sleep - system sleep timer (value in minutes, or 0 to disable)
  # Strip "(sleep prevented by 58985)"
  def sleep
    @property_hash['sleep'] || 0
  end

  def sleep=(minutes)
    pmset @@source_to_switch[@source], 'sleep', minutes
  end

  # womp - wake on ethernet magic packet (value = 0/1)
  def wake_on_lan
    @property_hash['womp'] == '1' ? :true : :false
  end

  def wake_on_lan=(enabled)
    pmset @@source_to_switch[@source], 'womp', (enabled === :true ? '1' : '0')
  end

  # autorestart - automatic restart on power loss (value = 0/1)
  def autorestart
    @property_hash['autorestart'] == '1' ? :true : :false
  end

  def autorestart=(enabled)
    pmset @@source_to_switch[@source], 'autorestart', (enabled === :true ? '1' : '0')
  end

  # powerbutton - sleep the machine when power button is pressed (value = 0/1)
  def power_button_sleeps
    @property_hash['powerbutton'] == '1' ? :true : :false
  end

  def power_button_sleeps=(enabled)
    pmset @@source_to_switch[@source], 'powerbutton', (enabled === :true ? '1' : '0')
  end

  # lidwake - wake the machine when the laptop lid (or clamshell) is opened (value = 0/1)
  def lidwake
    @property_hash['lidwake'] || nil
  end

  def lidwake=(enabled)
    pmset @@source_to_switch[@source], 'lidwake', (enabled === :true ? '1' : '0')
  end

  # acwake - wake the machine when power source (AC/battery) is changed (value = 0/1)
  def acwake
    @property_hash['acwake'] || nil
  end

  def acwake=(enabled)
    pmset @@source_to_switch[@source], 'acwake', (enabled === :true ? '1' : '0')
  end
  
  # lessbright - slightly turn down display brightness when switching to this power source (value = 0/1)
  def lessbright
    @property_hash['lessbright'] || nil
  end

  def lessbright=(enabled)
    pmset @@source_to_switch[@source], 'lessbright', (enabled === :true ? '1' : '0')
  end

  # halfdim - display sleep will use an intermediate half-brightness state between full brightness and fully off  (value = 0/1)
  def halfdim
    @property_hash['halfdim'] || nil
  end

  def halfdim=(enabled)
    pmset @@source_to_switch[@source], 'halfdim', (enabled === :true ? '1' : '0')
  end

  # sms - use Sudden Motion Sensor to park disk heads on sudden changes in G force (value = 0/1)
  def sms
    @property_hash['sms'] || nil
  end

  def sms=(enabled)
    pmset @@source_to_switch[@source], 'sms', (enabled === :true ? '1' : '0')
  end

  # ttyskeepawake - prevent idle system sleep when any tty (e.g. remote login session) is 'active'.
  # A tty is 'inactive' only when its idle time exceeds the system sleep timer. (value = 0/1)
  def ttyskeepawake
    @property_hash['ttyskeepawake'] || nil
  end

  def ttyskeepawake=(enabled)
    pmset @@source_to_switch[@source], 'ttyskeepawake', (enabled === :true ? '1' : '0')
  end

  # destroyfvkeyonstandby - Destroy File Vault Key when going to standby mode.
  def destroyfvkeyonstandby
    @property_hash['destroyfvkeyonstandby'] || nil
  end

  def destroyfvkeyonstandby=(enabled)
    pmset @@source_to_switch[@source], 'destroyfvkeyonstandby', (enabled === :true ? '1' : '0')
  end

end
