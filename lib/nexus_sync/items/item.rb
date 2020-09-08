require 'fileutils'

module NexusSync
  class Item
    attr_reader :id
    attr_reader :path
    attr_reader :download_link
    attr_reader :name
    attr_reader :sha1

    attr_reader :format
    attr_reader :repo
    attr_reader :tags

    attr_accessor :file_size

    MAX_REQUEUE = 3

    def initialize(component, asset, download_location)
      @id            = asset['id']
      @path          = asset['path']
      @download_link = asset['downloadUrl']
      @name          = asset['downloadUrl'].split('/').last unless asset['downloadUrl'].nil?
      @sha1          = asset['checksum']['sha1'] unless asset['checksum'].nil?

      @format        = component['format']
      @repo          = component['repository']
      @tags          = component['tags']

      @download_location = download_location

      @times_requeued = 0
    end

    def download(connection)
      raise "ERROR: #download is not defined in #{self.class}.\nThis method needs to be defined in every subclass of NexusSync::Item"
    end

    def upload(connection)
      raise "ERROR: #upload is not defined in #{self.class}.\nThis method needs to be defined in every subclass of NexusSync::Item"
    end

    def full_path
      file = File.join(@download_location, @repo, @path)
      directory = file.gsub(@name, '')
      FileUtils.mkdir_p(directory)
      file
    end

    def requeue?
      if @times_requeued < MAX_REQUEUE
        @times_requeued += 1
        return true
      end
      false
    end

    def docker_format?
      @format.eql?('docker')
    end

    def eql?(item)
      self.path   == item.path   &&
      self.name   == item.name   &&
      self.sha1   == item.sha1   &&
      self.format == item.format &&
      self.repo   == item.repo
    end

    def hash
      path.hash + name.hash + sha1.hash + format.hash + repo.hash
    end
  end
end
