require 'nexus_sync/queue'

module NexusSync
  class ThreadCore
    attr_reader :verbose
    attr_reader :download_queue_mutex
    attr_reader :upload_queue_mutex
    attr_reader :download_queue
    attr_reader :upload_queue
    attr_reader :failed_queue
    attr_reader :corrupted_queue
    attr_reader :docker_locked

    def initialize(brain, core_values)
      @brain = brain
      @verbose = core_values[:verbose]
      @total_download_count = core_values[:download_count]
      @total_upload_count   = core_values[:upload_count]
      @downloaded_count     = 0
      @uploaded_count       = 0
      @docker_locked        = false

      @total_download_count_mutex = Mutex.new
      @total_upload_count_mutex = Mutex.new
      @downloaded_count_mutex = Mutex.new
      @uploaded_count_mutex = Mutex.new
      @download_queue_mutex = Mutex.new
      @upload_queue_mutex = Mutex.new
      @failed_queue_mutex = Mutex.new
      @docker_mutex = Mutex.new

      @download_queue  = NexusSync::Queue.new('Download')
      @upload_queue    = NexusSync::Queue.new('Upload')
      @failed_queue    = NexusSync::Queue.new('Failed')
      @corrupted_queue = NexusSync::Queue.new('Corrupted')
    end

    def lock(mutex, proc)
      mutex.synchronize do
        proc.call
      end
    end

    def download(item)
      @brain.download(item)
    end

    def upload(item)
      @brain.upload(item)
    end

    def compare_hash(item)
      source_sha = item.sha1
      destination_sha = @brain.destination_sha(item)
      unless source_sha == destination_sha
        corrupted_queue.queue({
          item: item,
          source: source_sha,
          destination: destination_sha
        })
      end
    end

    def total_download_count
      proc = Proc.new { @total_download_count }
      lock_total_download_count(proc)
    end

    def decrease_total_download_count
      proc = Proc.new { @total_download_count -= 1 }
      lock_total_download_count(proc)
    end

    def downloaded_count
      proc = Proc.new { @downloaded_count }
      lock_downloaded_count(proc)
    end

    def increment_downloaded_count
      proc = Proc.new { @downloaded_count += 1 }
      lock_downloaded_count(proc)
    end

    def total_upload_count
      proc = Proc.new { @total_upload_count }
      lock_total_upload_count(proc)
    end

    def decrease_total_upload_count
      proc = Proc.new { @total_upload_count -= 1 }
      lock_total_upload_count(proc)
    end

    def uploaded_count
      proc = Proc.new { @uploaded_count }
      lock_uploaded_count(proc)
    end

    def increment_uploaded_count
      proc = Proc.new { @uploaded_count += 1 }
      lock_uploaded_count(proc)
    end

    def queue_upload(item)
      proc = Proc.new { @upload_queue.queue(item) }
      lock_upload_queue_mutex(proc)
    end

    def queue_failed(item)
      proc = Proc.new { @failed_queue.queue(item) }
      lock_failed_queue_mutex(proc)
    end

    def show_queues
      if verbose
        puts "\n"
        puts "Download Queue: #{download_queue.items.map{|item| item.name}}"
        puts   "Upload Queue: #{upload_queue.items.map{|item| item.name}}"
        puts "Total to Download: #{total_download_count}  "\
                    "Downloaded: #{downloaded_count}  "\
               "Total to Upload: #{total_upload_count}  "\
                      "Uploaded: #{uploaded_count}"
        puts "\n"
      end
    end

    def reserve_docker
      proc = Proc.new do
        if @docker_locked
          return false
        end
        @docker_locked = true
        return true
      end
      lock_docker_mutex(proc)
    end

    def release_docker
      proc = Proc.new { @docker_locked = false }
      lock_docker_mutex(proc)
    end

    private

    def lock_total_download_count(proc)
      lock(@total_download_count_mutex, proc)
    end

    def lock_total_upload_count(proc)
      lock(@total_upload_count_mutex, proc)
    end

    def lock_downloaded_count(proc)
      lock(@downloaded_count_mutex, proc)
    end

    def lock_uploaded_count(proc)
      lock(@uploaded_count_mutex, proc)
    end

    def lock_upload_queue_mutex(proc)
      lock(@upload_queue_mutex, proc)
    end

    def lock_failed_queue_mutex(proc)
      lock(@failed_queue_mutex, proc)
    end

    def lock_docker_mutex(proc)
      lock(@docker_mutex, proc)
    end
  end
end