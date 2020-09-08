module NexusSync
  class PypiItem < Item
    def initialize(component, asset, download_location)
      super
    end

    def download(connection)
      connection.download(@id, full_path)
    end

    def upload(connection)
      connection.upload_pypi_component(@repo, full_path)
    end
  end
end
