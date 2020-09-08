require 'nexus_api'

module NexusSync
  class NexusConnection
    def initialize(config:{}, api:nil)
      if api.nil?
        @api = NexusAPI::API.new(
          username: config[:username],
          password: config[:password],
          hostname: config[:nexus_url],
          docker_pull_hostname: config[:docker_pull_url],
          docker_push_hostname: config[:docker_push_url]
        )
      else
        @api = api
      end
    end

    def verify_connection
      unless @api.status_writable
        raise 'ERROR: Nexus connection not writable; likely bad credentials'
      end
    end

    def get_components(repo)
      Array.new.tap do |items|
        loop do
          items.concat(@api.list_components(repository: repo, paginate: true))
          break unless @api.paginate?
        end
      end
    end

    def move(action, item)
      item.send(action, self)
    end

    def get_file_size(download_link)
      @api.get_asset_size(asset_url: download_link).to_i
    end

    # Let's encapsulate any library methods we don't have control
    # over so if they change we only need to update these methods
    def get_repos
      @api.list_repositories
    end

    def get_asset(item)
      results = Array.new.tap do |results|
        loop do
          results.concat(
            @api.search_asset(
              name: item.name,
              format: item.format,
              repository: item.repo,
              sha1: item.sha1,
              paginate: true,
            )
          )
          break unless @api.paginate?
        end
      end
    end

    def download_docker_component(image, tag)
      @api.download_docker_component(image: image, tag: tag)
    end

    def upload_docker_component(image, tag)
      @api.upload_docker_component(image: image, tag: tag)
    end

    def download(id, full_path)
      @api.download(id: id, name: full_path)
    end

    def upload_maven_component(repo, group_id, artifact_id, version, full_path)
      @api.upload_maven_component(
        filename: full_path,
        group_id: group_id,
        artifact_id: artifact_id,
        version: version,
        repository: repo,
      )
    end

    def upload_npm_component(repo, full_path)
      @api.upload_npm_component(filename: full_path, repository: repo)
    end

    def upload_pypi_component(repo, full_path)
      @api.upload_pypi_component(filename: full_path, repository: repo)
    end

    def upload_raw_component(repo, directory, full_path)
      @api.upload_raw_component(filename: full_path, directory: directory, repository: repo)
    end

    def upload_rubygems_component(repo, full_path)
      @api.upload_rubygems_component(filename: full_path, repository: repo)
    end

    def upload_yum_component(repo, directory, full_path)
      @api.upload_yum_component(filename: full_path, directory: directory, repository: repo)
    end
  end
end
