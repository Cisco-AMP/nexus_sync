module NexusSync
  class DownloadThread < NexusThread
    def initialize(core)
      super
    end

    def until_finished
      until @core.total_download_count.eql?(@core.downloaded_count)
        yield
      end
    end

    def start
      until_finished do
        move_item(@core.download_queue_mutex, @core.download_queue)
      end
    end

    def decrease_total_count
      @core.decrease_total_download_count
      @core.decrease_total_upload_count
    end

    def move_successful?(item)
      success = @core.download(item)
      if success
        @core.increment_downloaded_count
      end
      success
    end

    def post_process(item)
      @core.queue_upload(item)
    end
  end
end
