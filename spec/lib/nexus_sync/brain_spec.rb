require 'nexus_sync/nexus_connection'
require 'nexus_sync/query'
require 'nexus_sync/queue'
require 'nexus_sync/brain'
require 'nexus_sync/threads'
require 'mock_connection'

RSpec.describe NexusSync::Brain do

  before(:each) do
    @source_query = double
    @destination_query = double
    @thread_num = 4
    @brain = NexusSync::Brain.new(@source_query, @destination_query, {parallelization: @thread_num, verbose: false})

    @item_cached1 = double
    allow(@item_cached1).to receive(:full_path).and_return('spec/downloads/cached_item')
    allow(@item_cached1).to receive(:name).and_return('cached_item')
    allow(@item_cached1).to receive(:repo).and_return('fake_repo')
    allow(@item_cached1).to receive(:sha1).and_return('da39a3ee5e6b4b0d3255bfef95601890afd80709')
  end

  describe 'brain getters and setters' do
    describe '#shared_repos' do
      it 'is initialized with []' do
        expect(@brain.shared_repos).to eq([])
      end
    end

    describe '#download_list' do
      it 'is initialized with []' do
        expect(@brain.download_list).to eq([])
      end
    end

    describe '#upload_list' do
      it 'is initialized with []' do
        expect(@brain.upload_list).to eq([])
      end
    end
  end

  describe '#download_count' do
    it 'is initialized to 0' do
      expect(@brain.download_count).to eq(0)
    end

    it 'returns the total item count' do
      item1 = item2 = double
      allow(item1).to receive(:full_path).and_return('/fake_path')
      allow(@source_query).to receive(:fetch_item_metadata).and_return([])
      allow(@destination_query).to receive(:fetch_item_metadata).and_return([])
      allow(@source_query).to receive(:get_list_to_sync).and_return([item1, item2])
      allow(@destination_query).to receive(:get_list_to_sync).and_return([])
      @brain.get_items_to_sync
      expect(@brain.download_count).to eq(2)
    end
  end

  describe '#upload_count' do
    it 'is initialized to 0' do
      expect(@brain.upload_count).to eq(0)
    end

    it 'returns the total item count' do
      allow(@source_query).to receive(:fetch_item_metadata).and_return([])
      allow(@destination_query).to receive(:fetch_item_metadata).and_return([])
      allow(@source_query).to receive(:get_list_to_sync).and_return([@item_cached1])
      allow(@destination_query).to receive(:get_list_to_sync).and_return([])
      @brain.get_items_to_sync
      expect(@brain.upload_count).to eq(1)
    end
  end
  
  describe '#download' do
    it 'downloads an item' do
      item = double
      expect(@source_query).to receive(:download).with(item)
      @brain.download(item)
    end
  end

  describe '#upload' do
    it 'uploads an item' do
       item = double
       expect(@destination_query).to receive(:upload).with(item)
       @brain.upload(item)
    end
  end

  describe '#destination_sha' do
    it 'gets the destination sha for an item' do
       item = double
       expect(@destination_query).to receive(:get_hash).with(item)
       @brain.destination_sha(item)
    end
  end

  describe '#get_common_repos' do
    before(:each) do
      @one   = NexusSync::Repo.new({'name'=>'1','type'=>'number','format'=>'int'})
      @two   = NexusSync::Repo.new({'name'=>'2','type'=>'number','format'=>'int'})
      @three = NexusSync::Repo.new({'name'=>'3','type'=>'number','format'=>'int'})
      @four  = NexusSync::Repo.new({'name'=>'4','type'=>'number','format'=>'big_int'})
      @five  = NexusSync::Repo.new({'name'=>'5','type'=>'number','format'=>'big_int'})
    end

    it 'returns only common repos when destination has extra' do
      allow(@source_query).to receive(:fetch_repos).and_return([@one, @two, @three])
      allow(@destination_query).to receive(:fetch_repos).and_return([@one, @two, @three, @four, @five])
      @brain.get_common_repos
      expect(@brain.shared_repos).to eq([@one, @two, @three])
    end

    it 'returns only common repos when source has extra' do
      allow(@source_query).to receive(:fetch_repos).and_return([@one, @two, @three, @four, @five])
      allow(@destination_query).to receive(:fetch_repos).and_return([@one, @two, @three])
      @brain.get_common_repos
      expect(@brain.shared_repos).to eq([@one, @two, @three])
    end

    it 'returns only common repos when source and destination have extra' do
      allow(@source_query).to receive(:fetch_repos).and_return([@one, @two, @three])
      allow(@destination_query).to receive(:fetch_repos).and_return([@three, @four, @five])
      @brain.get_common_repos
      expect(@brain.shared_repos).to eq([@three])
    end

    it 'returns nothing when there are no common repos' do
      allow(@source_query).to receive(:fetch_repos).and_return([@one, @three, @five])
      allow(@destination_query).to receive(:fetch_repos).and_return([@two, @four])
      @brain.get_common_repos
      expect(@brain.shared_repos).to eq([])
    end

    it 'returns everything when all repos match' do
      allow(@source_query).to receive(:fetch_repos).and_return([@one, @two, @three, @four, @five])
      allow(@destination_query).to receive(:fetch_repos).and_return([@one, @two, @three, @four, @five])
      @brain.get_common_repos
      expect(@brain.shared_repos).to eq([@one, @two, @three, @four, @five])
    end
  end

  describe '#get_items_to_sync' do
    before(:each) do
      expect(@source_query).to receive(:fetch_item_metadata).and_return([])
      expect(@destination_query).to receive(:fetch_item_metadata).and_return([])

      @item1 = double
      @item2 = double
      @item3 = double
      @item4 = double
      @item5 = double
      @item6 = double
      allow(@item1).to receive(:full_path).and_return('/fake_path')
      allow(@item2).to receive(:full_path).and_return('/fake_path')
      allow(@item3).to receive(:full_path).and_return('/fake_path')
      allow(@item4).to receive(:full_path).and_return('/fake_path')
      allow(@item5).to receive(:full_path).and_return('/fake_path')
      allow(@item6).to receive(:full_path).and_return('/fake_path')
    end

    it 'gets unique items from source when destination is empty' do
      expect(@source_query).to receive(:get_list_to_sync).and_return([@item1, @item2, @item3])
      expect(@destination_query).to receive(:get_list_to_sync).and_return([])
      @brain.get_items_to_sync
      expect(@brain.download_list).to eq([@item1, @item2, @item3])
    end

    it 'gets unique items from source when destination has some overlap' do
      expect(@source_query).to receive(:get_list_to_sync).and_return([@item1, @item2, @item3])
      expect(@destination_query).to receive(:get_list_to_sync).and_return([@item2, @item3, @item4])
      expect(@brain).to receive(:print_skipped_items)
      @brain.get_items_to_sync
      expect(@brain.download_list).to eq([@item1])
    end

    it 'gets unique items from source when destination has no overlap' do
      expect(@source_query).to receive(:get_list_to_sync).and_return([@item1, @item2, @item3])
      expect(@destination_query).to receive(:get_list_to_sync).and_return([@item4, @item5, @item6])
      @brain.get_items_to_sync
      expect(@brain.download_list).to eq([@item1, @item2, @item3])
    end

    it 'gets nothing from source when it contains nothing' do
      expect(@source_query).to receive(:get_list_to_sync).and_return([])
      expect(@destination_query).to receive(:get_list_to_sync).and_return([@item2, @item3, @item4])
      @brain.get_items_to_sync
      expect(@brain.download_list).to eq([])
    end

    it 'gets a list of items already downloaded to disk' do
      expect(@source_query).to receive(:get_list_to_sync).and_return([@item1, @item2, @item_cached1])
      expect(@destination_query).to receive(:get_list_to_sync).and_return([])
      @brain.get_items_to_sync
      expect(@brain.download_list).to eq([@item1, @item2])
      expect(@brain.upload_list).to eq([@item_cached1])
    end

    it 'gets a list of items already downloaded to disk if they are not in the destination' do
      expect(@source_query).to receive(:get_list_to_sync).and_return([@item1, @item2, @item_cached1])
      expect(@destination_query).to receive(:get_list_to_sync).and_return([@item_cached1])
      @brain.get_items_to_sync
      expect(@brain.download_list).to eq([@item1, @item2])
      expect(@brain.upload_list).to eq([])
    end
  end

  describe '#populate_queues' do
    it 'passes an item list to the thread core' do
      core = double
      download_queue = NexusSync::Queue.new('download')
      upload_queue = NexusSync::Queue.new('upload')
      
      expect(core).to receive(:download_queue).and_return(download_queue)
      expect(core).to receive(:upload_queue).and_return(upload_queue)
      @brain.populate_queues(core)
    end
  end

  describe '#sync' do
    let(:core) { NexusSync::ThreadCore.new(@brain, 
      {
        verbose: false,
        download_count: @brain.download_count,
        upload_count: @brain.upload_count
      }) 
    }

    it 'creates and starts threads' do
      download_thread = upload_thread = double
      expect(NexusSync::DownloadThread).to receive(:new).and_return(download_thread).exactly(@thread_num).times
      expect(NexusSync::UploadThread).to receive(:new).and_return(upload_thread).exactly(@thread_num).times
      expect(download_thread).to receive(:join).exactly(@thread_num).times
      expect(upload_thread).to receive(:join).exactly(@thread_num).times
      @brain.sync(core)
    end

    it 'prints list of items that failed to sync' do
      expect(@brain).to receive(:print_failed_items).with(core)
      @brain.sync(core)
    end

    it 'prints list of items that failed to sync' do
      expect(@brain).to receive(:print_corrupted_items).with(core)
      @brain.sync(core)
    end
  end
end
