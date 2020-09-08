module NexusSync
  class UploadThread < NexusThread
    def initialize(core)
      super
    end

    def until_finished
      until @core.total_upload_count.eql?(@core.uploaded_count)
        yield
      end
    end

    def start
      until_finished do
        move_item(@core.upload_queue_mutex, @core.upload_queue)
      end
    end

    def decrease_total_count
      @core.decrease_total_upload_count
    end

    def move_successful?(item)
      success = @core.upload(item)
      if success
        @core.increment_uploaded_count
      end
      success
    end

    def post_process(item)
      @core.compare_hash(item)
    end
  end
end
