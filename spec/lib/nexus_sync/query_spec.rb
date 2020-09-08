require 'nexus_sync/item_validator'
require 'nexus_sync/item_generator'
require 'nexus_sync/query'
require 'mock_connection'

RSpec.describe NexusSync::Query do
  let(:download_location) { File.join(Dir.pwd, 'spec/downloads') }
  let(:repo_filters) { {} }
  let(:tags) { [] }

  describe '#fetch_repos' do
    it 'converts list of Nexus repositories into an array' do
      query = NexusSync::Query.new(download_location, MockConnection.new, repo_filters, tags)
      repos = query.fetch_repos
      expect(repos).to be_a(Array)
    end

    it 'array contains a NexusSync::Repo object' do
      query = NexusSync::Query.new(download_location, MockConnection.new, repo_filters, tags)
      repos = query.fetch_repos
      repos.each do |repo|
        expect(repo).to be_a(NexusSync::Repo)
      end
    end

    it 'returns all repos when no filters are specified' do
      seed_data = [
        {'type'=>'large','name'=>'red'},
        {'type'=>'medium','name'=>'blue'},
        {'type'=>'small','name'=>'green'},
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      repos = query.fetch_repos
      expect(repos.length).to eq(3)
    end

    it 'filters for large type repos' do
      repo_filters = {'type'=>['large']}
      seed_data = [
        {'type'=>'large'},
        {'type'=>'large'},
        {'type'=>'medium'},
        {'type'=>'small'},
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      repos = query.fetch_repos
      expect(repos.length).to eq(2)
      repos.each do |repo|
        expect(repo.type).to eq('large')
      end
    end

    it 'filters for large or medium type repos' do
      repo_filters = {'type'=>['large', 'medium']}
      seed_data = [
        {'type'=>'large'},
        {'type'=>'medium'},
        {'type'=>'small'},
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      repos = query.fetch_repos
      expect(repos.length).to eq(2)
      repos.each do |repo|
        expect(repo.type).not_to eq('small')
      end
    end

    it 'filters for repos named bluejay' do
      repo_filters = {'name'=>['bluejay']}
      seed_data = [
        {'name'=>'squirrel'},
        {'name'=>'bluejay'},
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      repos = query.fetch_repos
      expect(repos.length).to eq(1)
      expect(repos.first.name).to eq('bluejay')
    end

    it 'filters for repos named bluejay or parrot' do
      repo_filters = {'name'=>['bluejay', 'parrot']}
      seed_data = [
        {'name'=>'parrot'},
        {'name'=>'squirrel'},
        {'name'=>'bluejay'},
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      repos = query.fetch_repos
      expect(repos.length).to eq(2)
      repos.each do |repo|
        expect(repo.name).to eq('bluejay').or eq('parrot')
      end
    end

    it 'filters for oak formated repos' do
      repo_filters = {'format'=>['oak']}
      seed_data = [
        {'format'=>'oak'},
        {'format'=>'pine'},
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      repos = query.fetch_repos
      expect(repos.length).to eq(1)
      expect(repos.first.format).to eq('oak')
    end

    it 'filters for a small or large repo named squirrel with a pine format' do
      repo_filters = { 
        'name' => ['squirrel'],
        'type' => ['small','large'],
        'format' => ['pine'],
      }
      seed_data = [
        {'name'=>'squirrel','type'=>'small','format'=>'pine'}, # Expected to match
        {'name'=>'parrot','type'=>'small','format'=>'pine'},
        {'name'=>'squirrel','type'=>'medium','format'=>'pine'},
        {'name'=>'squirrel','type'=>'small','format'=>'oak'},
        {'name'=>'bluejay','type'=>'large','format'=>'pine'},
        {'name'=>'squirrel','type'=>'large','format'=>'pine'}, # Expected to match
        {'name'=>'parrot','type'=>'medium','format'=>'willow'},
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      repos = query.fetch_repos
      expect(repos.length).to eq(2)
      repos.each do |repo|
        expect(repo.name).to eq('squirrel')
        expect(repo.type).to eq('small').or eq('large')
        expect(repo.format).to eq('pine')
      end
    end

    it 'bad filter' do
      repo_filters = {'bad'=>['false']}
      seed_data = [{'format'=>'oak'}]
      query = NexusSync::Query.new(download_location, MockConnection.new(repos: seed_data), repo_filters, tags)
      expect{ query.fetch_repos }.to raise_error(RuntimeError, 'Filter \'bad\' is not supported by NexusSync::Repo')
    end
  end

  describe '#fetch_item_metadata' do
    let(:repos) { [NexusSync::Repo.new({'type'=>'mammals','format'=>'raw'})] }

    it 'Repo object contains an array' do
      query = NexusSync::Query.new(download_location, MockConnection.new, repo_filters, tags)
      items = query.fetch_item_metadata(repos).first.items
      expect(items).to be_a(Array)
    end

    it 'array contains a NexusSync::Item object' do
      items = [{'assets'=>[{'id'=>'1'}]}]
      query = NexusSync::Query.new(download_location, MockConnection.new(items: items), repo_filters, tags)
      item = query.fetch_item_metadata(repos).first.items.first
      expect(item).to be_a(NexusSync::Item)
    end

    describe 'filters items based on tags' do
      before(:each) do
        @items = [
          {'assets'=>[{'id'=>'1'}], 'tags'=>['red']},
          {'assets'=>[{'id'=>'2'}], 'tags'=>['blue']},
          {'assets'=>[{'id'=>'3'}], 'tags'=>['red','blue']},
          {'assets'=>[{'id'=>'4'}, {'id'=>'5'}], 'tags'=>['blue']},
          {'assets'=>[{'id'=>'6'}, {'id'=>'7'}], 'tags'=>['green','yellow']},
        ]
      end

      it 'returns all items when there are no tags' do
        query = NexusSync::Query.new(download_location, MockConnection.new(items: @items), repo_filters, tags)
        items = query.fetch_item_metadata(repos).first.items
        expect(items.length).to eq(7)
      end

      it 'returns only the items that match the tag' do
        tags = ['blue']
        query = NexusSync::Query.new(download_location, MockConnection.new(items: @items), repo_filters, tags)
        items = query.fetch_item_metadata(repos).first.items
        expect(items.length).to eq(4)
      end

      it 'returns only the items that match the set of tags' do
        tags = ['yellow', 'red']
        query = NexusSync::Query.new(download_location, MockConnection.new(items: @items), repo_filters, tags)
        items = query.fetch_item_metadata(repos).first.items
        expect(items.length).to eq(4)
      end

      it 'returns no items when no tag matches' do
        tags = ['black']
        query = NexusSync::Query.new(download_location, MockConnection.new(items: @items), repo_filters, tags)
        items = query.fetch_item_metadata(repos).first.items
        expect(items.length).to eq(0)
      end

      it 'returns no items when none of the tags match' do
        tags = ['black', 'white']
        query = NexusSync::Query.new(download_location, MockConnection.new(items: @items), repo_filters, tags)
        items = query.fetch_item_metadata(repos).first.items
        expect(items.length).to eq(0)
      end

      it 'returns only the matching items when some tags match' do
        tags = ['black', 'green']
        query = NexusSync::Query.new(download_location, MockConnection.new(items: @items), repo_filters, tags)
        items = query.fetch_item_metadata(repos).first.items
        expect(items.length).to eq(2)
      end
    end
  end

  describe '#get_list_to_sync' do
    it 'gets a list of the item from the repo' do
      repos = [NexusSync::Repo.new({'name'=>'one'})]
      query = NexusSync::Query.new(download_location, MockConnection.new(items: ['assets'=>[{'id'=>'robin'}]]), repo_filters, tags)
      repo_list = query.fetch_item_metadata(repos)
      list = query.get_list_to_sync(repo_list)
      expect(list.length).to eq(1)
      expect(list.last.id).to eq('robin')
    end

    it 'gets a list of all items from the repo' do
      repos = [
        NexusSync::Repo.new({'name'=>'one'})
      ]
      items = [
        {'assets'=>[{'id'=>'bat'}]},
        {'assets'=>[{'id'=>'crow'}]}
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(items: items), repo_filters, tags)
      repo_list = query.fetch_item_metadata(repos)
      list = query.get_list_to_sync(repo_list)
      expect(list.length).to eq(2)
      expect(list.first.id).to eq('bat')
      expect(list.last.id).to eq('crow')
    end 

    it 'gets a list of all items from all repos' do
      repos = [
        NexusSync::Repo.new({'name'=>'one'}),
        NexusSync::Repo.new({'name'=>'two'})
      ]
      query = NexusSync::Query.new(download_location, MockConnection.new(items: ['assets'=>[{'id'=>'raven'}]]), repo_filters, tags)
      repo_list = query.fetch_item_metadata(repos)
      list = query.get_list_to_sync(repo_list)
      expect(list.length).to eq(2)
      list.each do |item|
        expect(item.id).to eq('raven')
      end
    end
  end

  describe 'NexusConnection calls' do
    before(:example) do
      @connection = double
      @query = NexusSync::Query.new(download_location, @connection, repo_filters, tags)
    end

    def connection_send(label)
      item = double
      allow(@connection).to receive(:move).with(label, item).and_return(true)
      expect(@query.send(label, item)).to be(true)      
    end

    describe '#download' do
      it 'sends the message download to a connection with an id' do
        connection_send(:download)
      end
    end

    describe '#upload' do
      it 'sends the message upload to a connection with an id' do
        connection_send(:upload)
      end
    end

    describe '#get_hash' do
      before(:each) do
        @sha = '1'
        @item = double
        allow(@item).to receive(:path).and_return('path/to/item')
        @result = {"checksum" => {"sha1" => @sha}}
      end

      it 'sends :get_asset to a connection object' do
        expect(@connection).to receive(:get_asset).with(@item).and_return([@result])
        expect(@query.get_hash(@item)).to eq(@sha)
      end

      it 'outputs an error when no asset found' do
        expect(@connection).to receive(:get_asset).exactly(3).times.with(@item).and_return([])
        expect(@query.get_hash(@item)).to eq('no_search_results')
      end

      it 'outputs an error when more than 1 asset found' do
        expect(@connection).to receive(:get_asset).exactly(1).times.with(@item).and_return([@result, @result])
        expect(@query.get_hash(@item)).to eq('multiple_matches_found')
      end
    end
  end
end
