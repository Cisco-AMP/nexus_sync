require 'digest'

module NexusSync
  class Brain
    attr_reader :shared_repos
    attr_reader :download_list
    attr_reader :upload_list

    def initialize(source_query, destination_query, options)
      @source_query = source_query
      @destination_query = destination_query

      @parallelization = options[:parallelization]
      @verbose = options[:verbose]

      @shared_repos = []
      @download_list = []
      @upload_list = []
    end

    def download_count
      @download_list.size
    end

    def upload_count
      @upload_list.size + download_count
    end

    def download(item)
      @source_query.download(item)
    end

    def upload(item)
      @destination_query.upload(item)
    end

    def destination_sha(item)
      @destination_query.get_hash(item)
    end

    def get_common_repos
      timer('repository compare') do
        puts "Sync will take place between the following repos:"
        puts "(If a repo is missing check your filters in cli.rb or"
        puts "that the repo exists in both source and destination)"
        @shared_repos = @source_query.fetch_repos & @destination_query.fetch_repos
        @shared_repos.each do |repo|
          puts "  - #{repo.name} (format: #{repo.format})"
        end
      end
    end

    def get_items_to_sync
      source_list = []
      destination_list = []
      timer('source list creation') { source_list = fetch_item_list(@source_query) }
      timer('destination list creation') { destination_list = fetch_item_list(@destination_query) }
      timer('list dedupping') do
        item_list = source_list - destination_list
        @upload_list = get_cached_items(item_list)
        @download_list = item_list - @upload_list

        print_skipped_items(source_list - item_list)
      end
    end

    def populate_queues(core)
      timer('filling queues') do
        core.download_queue.queue(@download_list)
        core.upload_queue.queue(@upload_list)
      end
    end

    def sync(core)
      timer('sync') do
        download_threads = create_multiple { NexusSync::DownloadThread.new(core) }
        upload_threads   = create_multiple { NexusSync::UploadThread.new(core) }

        do_concurrently { |index| download_threads[index].join }
        do_concurrently { |index| upload_threads[index].join }
      end

      print_failed_items(core)
      print_corrupted_items(core)
    end


    private

    def fetch_item_list(query)
      repos = query.fetch_item_metadata(@shared_repos)
      query.get_list_to_sync(repos)
    end

    def get_cached_items(item_list)
      cached_list = item_list.select do |item|
        path = item.full_path
        if File.exist?(path)
          sha_on_disk = Digest::SHA1.file(path)
          if sha_on_disk == item.sha1
            puts "Skipping #{item.name} download since it is already cached on disk"
            true
          else
            puts "A copy of #{item.name} was found on disk but with a different SHA1: #{sha_on_disk}"
            puts "Re-downloading #{item.name} from source"
            false
          end
        else
          false
        end
      end
    end

    def print_skipped_items(skipped)
      puts "\nSkipping the following items since they already exist in the destination:" unless skipped.empty?
      skipped.each do |item|
        puts "  #{item.repo}: #{item.name}"
      end
      puts "\nTotal Items to Download: #{download_count}"
      puts   "Total Items to Upload: #{upload_count}"
    end

    def print_failed_items(core)
      failed_items = core.failed_queue.items
      puts "\nFailed to sync the following items:" unless failed_items.empty?
      failed_items.each do |item|
        puts "  - #{item.download_link}"
      end
    end

    def print_corrupted_items(core)
      corrupted_items = core.corrupted_queue.items
      puts "\nThe following items have a different hash after copy:" unless corrupted_items.empty?
      corrupted_items.each_entry do |set|
        puts "  - #{set[:item].download_link}"
        puts "    - source:      #{set[:source]}"
        puts "    - destination: #{set[:destination]}"
      end
    end

    def timer(name)
      start = Time.now
      puts "\nStart #{name} at #{start}"

      yield

      finish = Time.now
      puts "\nFinished #{name} at #{finish}"
      
      print_time_taken(start, finish)
    end

    def print_time_taken(start, finish)
      diff    = finish - start
      hours   = (diff/3600).to_i

      diff    = diff - (hours * 3600)
      minutes = (diff/60).to_i

      seconds = diff - (minutes * 60)
      puts "Duration was #{hours}h #{minutes}m #{seconds.round(2)}s\n\n"
    end

    def create_multiple
      (1..@parallelization).map do
        yield
      end
    end

    def do_concurrently
      (1..@parallelization).each do |index|
        yield(index - 1)
      end
    end
  end
end
