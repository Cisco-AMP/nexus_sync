module NexusSync
  class DiskUtility
    attr_reader :required
    attr_reader :available

    def initialize(required: nil, available: nil)
      @required  = required
      @available = available || get_available_space
    end

    def adequate_disk_space?
      available > required
    end

    def get_required_space(items)
      space_required = 0
      items.each do |item|
        space_required += item.file_size
      end
      @required = space_required
    end


    private

    def get_available_space
      `df -P . | awk 'NR==2 {print $4}'`.to_i
    end
  end
end