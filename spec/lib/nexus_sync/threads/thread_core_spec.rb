require 'nexus_sync/threads/thread_core'

RSpec.describe NexusSync::ThreadCore do
  before(:each) do
    @brain = double
    @core_values = {}
    @core_values[:verbose] = true
  end

  describe '#verbose' do
    it 'returns true if set' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.verbose).to be true
    end

    it 'returns false if not set' do
      @core_values[:verbose] = false
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.verbose).to be false
    end
  end

  describe '#download_queue_mutex' do
    it 'returns a mutex' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.download_queue_mutex).to be_a(Mutex)
    end
  end

  describe '#upload_queue_mutex' do
    it 'returns a mutex' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.upload_queue_mutex).to be_a(Mutex)
    end
  end

  describe '#download_queue' do
    it 'returns a NexusSync::Queue' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.download_queue).to be_a(NexusSync::Queue)
    end
  end

  describe '#upload_queue' do
    it 'returns a NexusSync::Queue' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.upload_queue).to be_a(NexusSync::Queue)
    end
  end

  describe '#failed_queue' do
    it 'returns a NexusSync::Queue' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.failed_queue).to be_a(NexusSync::Queue)
    end
  end

  describe '#docker_locked' do
    it 'returns false by default' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.docker_locked).to be false
    end
  end

  describe '#lock' do
    before(:each) do
      @mutex = Mutex.new
      @proc = Proc.new {}
    end

    it 'locks a mutex' do
      expect(@mutex).to receive(:synchronize)
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.lock(@mutex, @proc)
    end

    it 'calls a proc' do
      expect(@proc).to receive(:call)
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.lock(@mutex, @proc)
    end
  end

  describe '#download' do
    it 'sends download to brain' do
      expect(@brain).to receive(:download)
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.download(nil)
    end
  end

  describe '#upload' do
    it 'sends upload to brain' do
      expect(@brain).to receive(:upload)
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.upload(nil)
    end
  end

  describe '#compare_hash' do
    before(:each) do
      @sha_1 = '123'
      @sha_2 = '234'
      @item = double
      allow(@item).to receive(:sha1).and_return(@sha_1)
      @core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(@core.corrupted_queue.empty?).to be true
    end

    it 'does not add an item with matched shas to the corrupted queue' do
      expect(@brain).to receive(:destination_sha).with(@item).and_return(@sha_1)
      @core.compare_hash(@item)
      expect(@core.corrupted_queue.empty?).to be true     
    end

    it 'adds an item with mismatched shas to the corrupted queue' do
      expect(@brain).to receive(:destination_sha).with(@item).and_return(@sha_2)
      @core.compare_hash(@item)
      expect(@core.corrupted_queue.items).to eq([{
          item: @item,
          source: @sha_1,
          destination: @sha_2
        }])
    end
  end

  describe '#total_download_count' do
    it 'returns the total download count' do
      @core_values[:download_count] = 2
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.total_download_count).to eq(2)
    end
  end

  describe '#decrease_total_download_count' do
    it 'decrements the total download count' do
      @core_values[:download_count] = 4
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.decrease_total_download_count
      expect(core.total_download_count).to eq(3)
    end
  end

  describe '#downloaded_count' do
    it 'initially returns 0' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.downloaded_count).to eq(0)
    end
  end

  describe '#increment_downloaded_count' do
    it 'increments the current count' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.increment_downloaded_count
      expect(core.downloaded_count).to eq(1)
    end
  end

  describe '#total_upload_count' do
    it 'returns the total upload count' do
      @core_values[:upload_count] = 6
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.total_upload_count).to eq(6)
    end
  end

  describe '#decrease_total_upload_count' do
    it 'decrements the total upload count' do
      @core_values[:upload_count] = 8
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.decrease_total_upload_count
      expect(core.total_upload_count).to eq(7)
    end
  end

  describe '#uploaded_count' do
    it 'initially returns 0' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.uploaded_count).to eq(0)
    end
  end

  describe '#increment_uploaded_count' do
    it 'increments the current count' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.increment_uploaded_count
      expect(core.uploaded_count).to eq(1)
    end
  end

  describe '#queue_upload' do
    it 'queues an item in the upload queue' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.upload_queue.size).to eq(0)
      core.queue_upload('item')
      expect(core.upload_queue.size).to eq(1)
    end
  end

  describe '#queue_failed' do
    it 'queues an item in the failed queue' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.failed_queue.size).to eq(0)
      core.queue_failed('item')
      expect(core.failed_queue.size).to eq(1)
    end
  end

  describe '#show_queues' do
    it 'prints a string if verbose is set' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect { core.show_queues }.to output.to_stdout
    end

    it 'does not print a string if verbose is not set' do
      @core_values[:verbose] = false
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect { core.show_queues }.not_to output.to_stdout
    end
  end

  describe '#reserve_docker' do
    it 'returns true and locks when not reserved' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      expect(core.docker_locked).to be(false)
      expect(core.reserve_docker).to be(true)
      expect(core.docker_locked).to be(true)
    end

    it 'returns false when already reserved' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.reserve_docker
      expect(core.reserve_docker).to be(false)
    end
  end

  describe '#release_docker' do
    it 'sets docker_locked to false' do
      core = NexusSync::ThreadCore.new(@brain, @core_values)
      core.reserve_docker
      expect(core.docker_locked).to be(true)
      core.release_docker
      expect(core.docker_locked).to be(false)
    end
  end
end
