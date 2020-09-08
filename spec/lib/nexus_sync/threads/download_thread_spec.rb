require 'nexus_sync/threads/nexus_thread'
require 'nexus_sync/threads/download_thread'

RSpec.describe NexusSync::DownloadThread do
  describe '#decrease_total_count' do
    it 'sends decrease count messages to core' do
      core = double
      thread = NexusSync::DownloadThread.new(core)
      expect(core).to receive(:decrease_total_download_count)
      expect(core).to receive(:decrease_total_upload_count)
      thread.decrease_total_count
    end
  end

  describe '#move_successful?' do
    it 'sends the download message to core' do
      core = double
      thread = NexusSync::DownloadThread.new(core)
      expect(core).to receive(:download).with(nil)

      item = nil
      thread.move_successful?(item)
    end
  end

  describe '#post_process' do
    it 'sends synchronize to the upload_mutex' do
      core = double
      thread = NexusSync::DownloadThread.new(core)
      expect(core).to receive(:queue_upload)
      thread.post_process(nil)
    end
  end
end
