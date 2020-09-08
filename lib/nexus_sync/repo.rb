module NexusSync
  class Repo

    attr_accessor :name
    attr_accessor :format
    attr_accessor :type
    attr_reader   :items

    def initialize(repo_data)
      @name   = repo_data['name']
      @format = repo_data['format']
      @type   = repo_data['type']

      @items = []
    end

    def add(item)
      @items << item
    end

    # We don't include the type attribute in the equality
    # check since this varies per environment
    def eql?(repo)
      self.name == repo.name && self.format == repo.format
    end

    def hash
      name.hash + format.hash
    end

    def copy
      NexusSync::Repo.new({
        'name' => self.name,
        'format' => self.format,
        'type' => self.type
      })
    end
  end
end
