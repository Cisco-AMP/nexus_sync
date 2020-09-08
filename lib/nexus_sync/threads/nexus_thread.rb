module NexusSync
  class NexusThread
    def initialize(core)
      @core   = core
      @thread = Thread.new{ start }
    end

    def start
      raise "ERROR: The method NexusSync::NexusThread.start hasn't yet been implemented for #{self.class}"
    end

    def join
      @thread.join
    end


    private

    def requeue(mutex, queue, item)
      mutex.synchronize { queue.queue(item) }
    end

    def pause
      sleep(0.001)
    end

    def move_item(mutex, queue)
      success = false
      need_to_release = false
      item = mutex.synchronize { queue.pop unless queue.empty? }

      unless item.nil?
        if item.docker_format?
          if @core.reserve_docker
            need_to_release = true
          else
            requeue(mutex, queue, item)
            pause
            return
          end
        end

        if move_successful?(item)
          success = true
          puts "#{queue.name} #{item.name}"
          post_process(item)
        else
          if item.requeue?
            puts "#{queue.name} #{item.name} failed. Requeuing..."
            requeue(mutex, queue, item)
          else
            puts "Failed to #{queue.name.downcase} #{item.name} too many times; Skipping..."
            decrease_total_count
            @core.queue_failed(item)
          end
        end
        @core.release_docker if need_to_release
        @core.show_queues
      end
      pause unless success
    end
  end
end
