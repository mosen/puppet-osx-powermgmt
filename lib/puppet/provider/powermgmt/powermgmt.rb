Puppet::Type.type(:powermgmt).provide :powermgmt, :parent => Puppet::Provider do

  desc "Manage Mac OS X power management settings."
  
  commands :pmset => "/usr/bin/pmset"
  confine :operatingsystem => :darwin
  defaultfor :operatingsystem => :darwin
  
  class << self
  
    attr_accessor :pm_profiles
  
    def prefetch(resources)
      # info("Fetching current power management profile")
      
      self.pm_profiles = {
        :profiles => {},
        :current_profile => {}
      }
      pm_section = :profiles

      # Unfortunately this only retrieves the 'active' profile,
      # so we can't really examine the battery profile when we are on charger
      output = pmset '-g'
      output.each do |line|

        case
          when line.match(/Active Profiles:/)
            pm_section = :profiles
          when line.match(/Currently in use:/)
            pm_section = :current_profile
          else
            # TODO: split only on tabs in the Active Profiles
            line_kv = (pm_section === :profiles) ? line.strip.split(/\t+/) : line.strip.split(/\s+/)
            self.pm_profiles[pm_section][line_kv[0]] = line_kv[1]
        end
      end
      
      #debug(pm_profiles.inspect)
    end 
  end
  
  # TODO: does not parse
  # System sleep time
  def sleep
    return Integer(self.class.pm_profiles[:current_profile]["sleep"]) if self.class.pm_profiles[:current_profile]["sleep"].length > 0
    0
  end
  
  def sleep=(minutes)
    pmset '-a', 'sleep', minutes
  end
  
  # Disk spin down time
  def disk_sleep
    return self.class.pm_profiles[:current_profile]["disksleep"].to_i
  end
  
  def disk_sleep=(minutes)
    pmset '-a', 'disksleep', minutes
  end
  
  # Display sleep time
  def display_sleep
    return self.class.pm_profiles[:current_profile]["displaysleep"].to_i
  end
  
  def display_sleep=(minutes)
    pmset '-a', 'displaysleep', minutes
  end
  
  # TODO: does not parse
  def wake_on_lan
    if self.class.pm_profiles[:current_profile]["womp"] === '1'
      :true
    else
      :false
    end
  end
  
  def wake_on_lan=(enabled)
    pmset '-a', 'womp', (enabled === :true ? '1' : '0')
  end
  
  # Power button causes sleep instead of shut down
  def power_button_sleeps
    if self.class.pm_profiles[:current_profile]["powerbutton"] === '1'
      :true
    else
      :false
    end
  end
  
  def power_button_sleeps=(enabled)
    pmset '-a', 'powerbutton', (enabled === :true ? '1' : '0')
  end
  
  # Restart on power failure
  def autorestart
    if self.class.pm_profiles[:current_profile]["autorestart"] === '1'
      :true
    else
      :false
    end
  end
  
  def autorestart=(enabled)
    pmset '-a', 'autorestart', (enabled === :true ? '1' : '0')
  end

  # pmset -g doesnt display current halfdim setting
  # def display_is_dimmed
  #   return self.class.pm_profiles[:current_profile].has_key? "halfdim" && self.class.pm_profiles[:current_profile]["halfdim"] == "1"
  # end
  # 
  # def display_is_dimmed=(is_dimmed)
  #   pmset '-a', 'halfdim', (is_dimmed ? '1' : '0')
  # end
  
end
