module NexusSync
  class RawItem < Item
    def initialize(component, asset, download_location)
      super
      @directory = component["group"]
    end

    def download(connection)
      connection.download(@id, full_path)
    end

    def upload(connection)
      connection.upload_raw_component(@repo, @directory, full_path)
    end
  end
end
