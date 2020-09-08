module NexusSync
  class YumItem < Item
    def initialize(component, asset, download_location)
      super
      unless asset['downloadUrl'].nil?
        path_pieces = asset["path"].split('/')
        path_pieces.pop
        @directory = path_pieces.join('/')
      end
    end

    def download(connection)
      connection.download(@id, full_path)
    end

    def upload(connection)
      connection.upload_yum_component(@repo, @directory, full_path)
    end
  end
end
