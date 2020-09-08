module NexusSync
  class MavenItem < Item
    def initialize(component, asset, download_location)
      super
      @group_id    = component["group"]
      @artifact_id = component["name"]
      @version     = component["version"]
    end

    def download(connection)
      connection.download(@id, full_path)
    end

    def upload(connection)
      connection.upload_maven_component(@repo, @group_id, @artifact_id, @version, full_path)
    end
  end
end
