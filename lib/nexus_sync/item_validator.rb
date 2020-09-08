module NexusSync
  class ItemValidator
    def self.valid?(asset)
      if asset['format'].nil?
        raise "ERROR: Couldn't validate an Item with no asset format: #{asset}"
      elsif asset['downloadUrl'].nil?
        raise "ERROR: Couldn't validate an Item with no asset downloadUrl: #{asset}"
      else
        format = asset['format']
        case format
        when 'docker'
        when 'maven2'
          return false if asset["downloadUrl"].include?('.md5')
          return false if asset["downloadUrl"].include?('.sha1')
          return false if asset["downloadUrl"].include?('.xml')
        when 'npm'
          return false unless asset["downloadUrl"].include?('.tgz')
        when 'pypi'
        when 'raw'
        when 'rubygems'
          return false if asset["downloadUrl"].include?('gemspec.rz')
          return false if asset["downloadUrl"].include?('.ruby')
          return false if asset["downloadUrl"].include?('.gz')
        when 'yum'
          return false if asset["downloadUrl"].include?('.xml')
        else
          raise "ERROR: Couldn't validate an Item for #{format} type."
        end
      end
      true
    end
  end
end