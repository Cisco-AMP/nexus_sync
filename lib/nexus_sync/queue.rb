module NexusSync
  class Queue
    attr_reader :name
    attr_reader :max_size
    attr_reader :items

    def initialize(name, max_size: -1, items: [])
      @name = name
      @max_size = max_size
      serialized_items = Marshal.dump(items)
      @items = Marshal.load(serialized_items)
    end

    def size
      @items.length
    end

    def empty?
      @items.empty?
    end

    def room_in_queue?
      return true if @max_size < 0
      size < @max_size
    end

    def queue(group)
      return @items if group.nil?
      if group.is_a?(Array)
        group.each do |item|
          insert(item)
        end
      else
        insert(group)
      end
    end

    def pop
      @items.pop
    end

    def next
      @items.last
    end


    private

    def insert(item)
       @items.insert(0, item) if room_in_queue?
    end
  end
end
