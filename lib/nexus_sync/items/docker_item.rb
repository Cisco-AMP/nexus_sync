module NexusSync
  class DockerItem < Item
    def initialize(component, asset, download_location)
      super
      @image = component["name"]
      @tag   = component["version"]
    end

    def download(connection)
      connection.download_docker_component(@image, @tag)
    end

    def upload(connection)
      connection.upload_docker_component(@image, @tag)
    end
  end
end
