require 'nexus_sync/queue'

RSpec.describe NexusSync::Queue do
  describe '#name' do
    it 'returns the name of the queue' do
      queue_name = 'road_runner'
      queue = NexusSync::Queue.new(queue_name)
      expect(queue.name).to eq(queue_name)
    end
  end

  describe '#max_size' do
    it 'returns the items in the queue' do
      max_size = 21
      queue = NexusSync::Queue.new('', max_size: max_size)
      expect(queue.max_size).to eq(max_size)
    end
  end

  describe '#items' do
    it 'returns the items in the queue' do
      items = ['dog']
      queue = NexusSync::Queue.new('', items: items)
      expect(queue.items).to eq(items)
    end
  end

  describe '#size' do
    it 'returns the length of the queue' do
      items = ['toad', 'ferret']
      queue = NexusSync::Queue.new('', items: items)
      expect(queue.size).to eq(2)
    end
  end

  describe '#empty?' do
    it 'returns true if the queue is empty' do
      queue = NexusSync::Queue.new('', items: [])
      expect(queue.empty?).to be(true)
    end

    it 'returns false if the queue is not empty' do
      queue = NexusSync::Queue.new('', items: ['frog'])
      expect(queue.empty?).to be(false)
    end
  end

  describe '#room_in_queue?' do
    it 'returns true if the queue is not full' do
      items = ['a', 'b', 'c']
      queue = NexusSync::Queue.new('', max_size: 4, items: items)
      expect(queue.room_in_queue?).to be(true)
    end

    it 'returns false if the queue is full' do
      items = ['a', 'b', 'c']
      queue = NexusSync::Queue.new('', max_size: 3, items: items)
      expect(queue.room_in_queue?).to be(false)
    end

    it 'returns false if the queue is over full' do
      items = ['a', 'b', 'c']
      queue = NexusSync::Queue.new('', max_size: 2, items: items)
      expect(queue.room_in_queue?).to be(false)
    end

    it 'returns true if the queue is unbounded' do
      items = ['a', 'b', 'c']
      queue = NexusSync::Queue.new('', items: items)
      expect(queue.room_in_queue?).to be(true)
    end

    it 'returns true if the queue max size is negative' do
      items = ['a', 'b', 'c']
      queue = NexusSync::Queue.new('', max_size: -9, items: items)
      expect(queue.room_in_queue?).to be(true)
    end
  end

  describe '#queue' do
    it 'adds item to the beginning of the queue' do
      queue = NexusSync::Queue.new('', items: ['mouse','rabbit'])
      queue.queue('cat')
      expect(queue.items).to eq(['cat','mouse','rabbit'])
    end

    it 'adds items to the beginning of the queue' do
      queue = NexusSync::Queue.new('', items: ['mouse','rabbit'])
      queue.queue('cat')
      queue.queue('dog')
      expect(queue.items).to eq(['dog','cat','mouse','rabbit'])
    end

    it 'adds a set with one item to the beginning of the queue' do
      queue = NexusSync::Queue.new('', items: ['mouse','rabbit'])
      queue.queue(['cat'])
      expect(queue.items).to eq(['cat','mouse','rabbit'])
    end

    it 'adds a set of items to the beginning of the queue one at a time starting with the first item' do
      queue = NexusSync::Queue.new('', items: ['mouse','rabbit'])
      queue.queue(['cat','dog'])
      expect(queue.items).to eq(['dog','cat','mouse','rabbit'])
    end

    it 'does nothing if items is empty' do
      queue = NexusSync::Queue.new('')
      queue.queue([])
      expect(queue.items).to eq([])
    end

    it 'does nothing if items is nil' do
      queue = NexusSync::Queue.new('')
      queue.queue(nil)
      expect(queue.items).to eq([])
    end

    it 'adds an item to the beginning of a bounded queue' do
      queue = NexusSync::Queue.new('', max_size: 10, items: ['b','a'])
      queue.queue('c')
      expect(queue.items).to eq(['c','b','a'])
    end

    it 'cannot add more items than the max queue size' do
      queue = NexusSync::Queue.new('', max_size: 2, items: ['b','a'])
      queue.queue('c')
      expect(queue.items).to eq(['b','a'])
    end
  end

  describe '#pop' do
    it 'removes and returns the item from the end of the queue' do
      items = ['hamster', 'snake']
      queue = NexusSync::Queue.new('', items: items)
      expect(queue.pop).to eq('snake')
      expect(queue.size).to eq(1)
    end
  end

  describe '#next' do
    it 'returns the next item to be popped from the queue' do
      items = ['toad', 'ferret']
      queue = NexusSync::Queue.new('', items: items)
      expect(queue.next).to eq('ferret')
      expect(queue.size).to eq(2)
    end
  end
end
