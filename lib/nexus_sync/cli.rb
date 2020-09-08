require 'optparse'
require 'dotenv/load'

module NexusSync
  class CLI
    SOURCE_USERNAME = ENV['SOURCE_USERNAME']
    SOURCE_PASSWORD = ENV['SOURCE_PASSWORD']
    SOURCE_NEXUS_URL = ENV['SOURCE_NEXUS_URL']

    DESTINATION_USERNAME = ENV['DESTINATION_USERNAME']
    DESTINATION_PASSWORD = ENV['DESTINATION_PASSWORD']
    DESTINATION_NEXUS_URL = ENV['DESTINATION_NEXUS_URL']

    DOCKER_PULL_URL = ENV['DOCKER_PULL_URL']
    DOCKER_PUSH_URL = ENV['DOCKER_PUSH_URL']

    def self.parse_arguments
      @options = {}
      OptionParser.new do |parser|
        parser.banner = "\nUsage: nexus_sync [options]"

        parser.on('-f', '--repo-format [FORMAT1,FORMAT2,...]', String,
          'Sync ONLY assets that match the provided repository format(s)') do |format|
          @options[:format] = format.split(',')
        end

        parser.on('-h', '--help', 'Displays this help') do
          puts parser
          puts "\n"
          exit
        end

        parser.on('-l', '--item_location [LOCATION]', String,
          'Relative path to download and upload assets to/from (DEFAULT: ./downloads)') do |item_location|
          @options[:item_location] = item_location
        end

        parser.on('-n', '--repo-name [NAME1,NAME2,...]', String,
          'Sync ONLY assets that match the provided repository name(s)') do |name|
          @options[:name] = name.split(',')
        end

        parser.on('-p', '--parallelization [COUNT]', Integer,
          'Number of sync tasks to run concurrently (DEFAULT: 4)') do |parallelization|
          @options[:parallelization] = parallelization
        end

        parser.on('-t', '--tags [TAG1,TAG2,...]', String,
          'Sync ONLY assets that match the provided tag(s)') do |tags|
          @options[:tags] = tags.split(',')
        end

        @options[:verbose] = false
        parser.on('-v', '--verbose', 'Displays an additional level of output details') do |verbose|
          @options[:verbose] = true
        end
      end.parse!
    end

    def self.validate_arguments
      @options[:item_location] ||= 'downloads'
      @options[:parallelization] ||= 4
      @options[:tags] ||= []
    end

    def self.setup
      source_config = {}
      source_config[:username] = SOURCE_USERNAME
      source_config[:password] = SOURCE_PASSWORD
      source_config[:nexus_url] = SOURCE_NEXUS_URL
      source_config[:docker_pull_url] = DOCKER_PULL_URL
      source_config[:docker_push_url] = DOCKER_PUSH_URL
      source = NexusSync::NexusConnection.new(config: source_config)
      source.verify_connection
      
      destination_config = {}
      destination_config[:username] = DESTINATION_USERNAME
      destination_config[:password] = DESTINATION_PASSWORD
      destination_config[:nexus_url] = DESTINATION_NEXUS_URL
      destination_config[:docker_pull_url] = DOCKER_PULL_URL
      destination_config[:docker_push_url] = DOCKER_PUSH_URL
      destination = NexusSync::NexusConnection.new(config: destination_config)
      destination.verify_connection

      repo_filters = {
        'type'   => ['hosted', 'proxy', 'group']
      }
      repo_filters['name'] = @options[:name] unless @options[:name].nil?
      repo_filters['format'] = @options[:format] unless @options[:format].nil?

      source_query = NexusSync::Query.new(@options[:item_location], source, repo_filters, @options[:tags])
      destination_query = NexusSync::Query.new(@options[:item_location], destination, repo_filters, @options[:tags])
      @brain = Brain.new(source_query, destination_query, @options)
    end

    def self.select_items_to_sync
      @brain.get_common_repos
      @brain.get_items_to_sync
    end

    def self.create_thread_core
      core_values = {
        :verbose => @options[:verbose],
        :download_count => @brain.download_count,
        :upload_count => @brain.upload_count,
      }
      @thread_core = NexusSync::ThreadCore.new(@brain, core_values)
    end

    def self.populate_queues
      @brain.populate_queues(@thread_core)
    end

    def self.adequate_disk_space?
      disk = DiskUtility.new
      disk.get_required_space(@brain.download_list)
      disk.adequate_disk_space?
    end

    def self.start_sync
      @brain.sync(@thread_core)
    end

    def self.sync
      parse_arguments
      validate_arguments
      setup
      select_items_to_sync
      create_thread_core
      populate_queues
      if adequate_disk_space?
        start_sync
      else
        puts 'ERROR: Not enough space on disk to sync assets!'
        puts 'Exiting...'
        exit(1)
      end
    end
  end
end