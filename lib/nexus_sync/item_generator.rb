module NexusSync
  class ItemGenerator
    def self.create(component, asset, download_location)
      if component['format'].nil?
        raise "ERROR: Couldn't generate an Item with no component format: #{component}"
      else
        format = component['format']
        case format
        when 'docker'
          NexusSync::DockerItem.new(component, asset, download_location)
        when 'maven2'
          NexusSync::MavenItem.new(component, asset, download_location)
        when 'npm'
          NexusSync::NpmItem.new(component, asset, download_location)
        when 'pypi'
          NexusSync::PypiItem.new(component, asset, download_location)
        when 'raw'
          NexusSync::RawItem.new(component, asset, download_location)
        when 'rubygems'
          NexusSync::RubygemsItem.new(component, asset, download_location)
        when 'yum'
          NexusSync::YumItem.new(component, asset, download_location)
        else
          raise "ERROR: Couldn't generate an Item for #{format} type."
        end
      end
    end
  end
end