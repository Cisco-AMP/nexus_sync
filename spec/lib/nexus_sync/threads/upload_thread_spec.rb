require 'nexus_sync/threads/nexus_thread'
require 'nexus_sync/threads/upload_thread'

RSpec.describe NexusSync::UploadThread do
  describe '#decrease_total_count' do
    it 'sends the decrease_total_upload_count message to core' do
      core = double
      thread = NexusSync::UploadThread.new(core)
      expect(core).to receive(:decrease_total_upload_count)
      thread.decrease_total_count
    end
  end

  describe '#move_successful?' do
    it 'sends the upload message to core' do
      core = double
      thread = NexusSync::UploadThread.new(core)
      expect(core).to receive(:upload).with(nil) 

      item = nil
      thread.move_successful?(item)
    end
  end

  describe '#post_process' do
    it 'sends :compare_hash with the sha1 of an item to core' do
      item = double
      core = double
      expect(core).to receive(:compare_hash).with(item)
      thread = NexusSync::UploadThread.new(core)
      thread.post_process(item)
    end
  end
end
