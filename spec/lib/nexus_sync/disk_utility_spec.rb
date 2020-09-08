require 'nexus_sync/disk_utility'

RSpec.describe NexusSync::DiskUtility do
  describe '#available' do
    it 'returns the amount of disk available' do
      disk = NexusSync::DiskUtility.new(available: 10)
      expect(disk.available).to eq(10)
    end

    it 'returns a number' do
      disk = NexusSync::DiskUtility.new
      expect(disk.available).to be_a(Integer)
    end
  end

  describe '#required' do
    it 'returns the amount of disk required' do
      disk = NexusSync::DiskUtility.new(required: 13)
      expect(disk.required).to eq(13)
    end

    it 'returns 0 when no items' do
      disk = NexusSync::DiskUtility.new
      disk.get_required_space([])
      expect(disk.required).to eq(0)
    end

    it 'returns item size' do
      item = double
      allow(item).to receive(:file_size) { 3333 }
      disk = NexusSync::DiskUtility.new
      disk.get_required_space([item])
      expect(disk.required).to eq(3333)
    end

    it 'returns multiple items size' do
      item1 = double
      item2 = double
      allow(item1).to receive(:file_size) { 3 }
      allow(item2).to receive(:file_size) { 2 }
      disk = NexusSync::DiskUtility.new
      disk.get_required_space([item1, item2])
      expect(disk.required).to eq(5)
    end
  end
end
