require 'nexus_sync/items'
require 'nexus_sync/repo'

module NexusSync
  class Query

    def initialize(download_location, connection, repo_filters, tags)
      @download_location = download_location
      @connection = connection
      @repo_filters = repo_filters
      @tags = tags
    end

    def fetch_repos
      all_repos = create_repos
      return all_repos if @repo_filters.empty?

      all_repos.select do |repo|
        apply_repo_filters(repo)
      end
    end

    def fetch_item_metadata(repos)
      new_repos = repos.map do |repo|
        create_items(@connection.get_components(repo.name), repo)
      end
    end

    def get_list_to_sync(repos)
      repos.map { |repo| repo.items }.flatten
    end

    def download(item)
      @connection.move(:download, item)
    end

    def upload(item)
      @connection.move(:upload, item)
    end

    def get_hash(item)
      attempts = 3
      results = []
      while attempts.positive?
        attempts -= 1
        results = @connection.get_asset(item)
        break if results.any?
      end
      if results.empty?
        return 'no_search_results'
      elsif results.length > 1
        results = refine(results, item)
        return 'multiple_matches_found' unless results.one?
      end
      results.first["checksum"]["sha1"]
    end


    private

    def create_repos
      @connection.get_repos.map do |repo_data|
        NexusSync::Repo.new(repo_data)
      end
    end

    def apply_repo_filters(repo)
      match = true
      @repo_filters.each do |property, values|
        matching_values = values.select do |value|
          begin
            repo.send(property.to_sym).eql?(value)
          rescue NoMethodError
            raise "Filter '#{property}' is not supported by NexusSync::Repo"
          end
        end
        match = false if matching_values.empty?
      end
      match
    end

    def match_tags?(component_tags)
      return true if @tags.nil? || @tags.empty?
      component_tags.each do |tag|
        return true if @tags.include?(tag)
      end
      false
    end
      
    def create_items(components, repo)
      new_repo = repo.copy
      components.each do |component|
        if match_tags?(component["tags"])
          component['assets'].each do |asset|
            if NexusSync::ItemValidator.valid?(asset)
              item = NexusSync::ItemGenerator.create(component, asset, @download_location)
              item.file_size = @connection.get_file_size(asset['downloadUrl'])
              new_repo.add(item)
            end
          end
        end
      end
      new_repo
    end

    def refine(results, item)
      results.select do |result|
        result["path"].eql?(item.path)
      end
    end
  end
end
