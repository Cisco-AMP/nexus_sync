require 'nexus_sync/nexus_connection'

USERNAME = ENV['USERNAME']
PASSWORD = ENV['PASSWORD']
NEXUS_URL = ENV['NEXUS_URL']
DOCKER_PULL_URL = ENV['DOCKER_PULL_URL']
DOCKER_PUSH_URL = ENV['DOCKER_PUSH_URL']

RSpec.describe NexusSync::NexusConnection do
  describe 'with bad credentials' do
    before(:each) do
      config = {}
      config[:username] = 'bad'
      config[:password] = 'creds'
      config[:nexus_url] = NEXUS_URL
      config[:docker_pull_url] = DOCKER_PULL_URL
      config[:docker_push_url] = DOCKER_PUSH_URL
      @connection = NexusSync::NexusConnection.new(config:config)
    end

    describe '#verify_connection' do
      it 'raises an error' do
        VCR.use_cassette('bad_creds') do
          error = 'ERROR: Nexus connection not writable; likely bad credentials'
          expect { @connection.verify_connection }.to raise_error(RuntimeError, error)
        end
      end
    end
  end

  describe 'with fake credentials' do
    before(:each) do
      @api = double
      @connection = NexusSync::NexusConnection.new(api:@api)
    end

    describe '#get_components' do
      it 'returns an Array of items for a repo' do
        item = double
        expect(@api).to receive(:list_components).with({repository: [], paginate: true}).and_return([])
        expect(@api).to receive(:paginate?).and_return(false)
        expect(@connection.get_components([])).to be_a(Array)
      end
    end

    describe '#move' do
      it 'sends an action to an item' do
        item = double
        expect(item).to receive(:action).with(instance_of(NexusSync::NexusConnection)).and_return(true)
        expect(@connection.move(:action, item)).to be(true)
      end
    end

    describe '#get_file_size' do
      it 'returns the file size of a file at a URL' do
        expect(@api).to receive(:get_asset_size).and_return('5')
        expect(@connection.get_file_size('link')).to eq(5)
      end
    end

    describe '#get_repos' do
      it 'sends list_repositories message' do
        expect(@api).to receive(:list_repositories)
        @connection.get_repos
      end
    end

    describe '#get_asset' do
      it 'sends search_asset message' do
        name = 'asset1'
        format = 'format1'
        repo = 'repo1'
        sha1 = '321cba1'
        item = double
        allow(item).to receive(:name).and_return(name)
        allow(item).to receive(:format).and_return(format)
        allow(item).to receive(:repo).and_return(repo)
        allow(item).to receive(:sha1).and_return(sha1)
        allow(@api).to receive(:paginate?).and_return(true, false)
        expect(@api).to receive(:search_asset)
          .with({name: name, format: format, paginate: true, repository: repo, sha1: sha1})
          .and_return(['result'])
          .twice
        expect(@connection.get_asset(item)).to eq(['result', 'result'])
      end
    end

    describe '#download_docker_component' do
      it 'sends download_docker_component message' do
        expect(@api).to receive(:download_docker_component)
        @connection.download_docker_component('image', 'tag')
      end
    end

    describe '#upload_docker_component' do
      it 'sends upload_docker_component message' do
        expect(@api).to receive(:upload_docker_component)
        @connection.upload_docker_component('image', 'tag')
      end
    end

    describe '#download' do
      it 'sends download message' do
        expect(@api).to receive(:download)
        @connection.download('id', 'full_path')
      end
    end

    describe '#upload_maven_component' do
      it 'sends upload_maven_component message' do
        expect(@api).to receive(:upload_maven_component)
        @connection.upload_maven_component('repo', 'group_id', 'artifact_id', 'version', 'full_path')
      end
    end

    describe '#upload_npm_component' do
      it 'sends upload_npm_component message' do
        expect(@api).to receive(:upload_npm_component)
        @connection.upload_npm_component('repo', 'full_path')
      end
    end

    describe '#upload_pypi_component' do
      it 'sends upload_pypi_component message' do
        expect(@api).to receive(:upload_pypi_component)
        @connection.upload_pypi_component('repo', 'full_path')
      end
    end

    describe '#upload_raw_component' do
      it 'sends upload_raw_component message' do
        expect(@api).to receive(:upload_raw_component)
        @connection.upload_raw_component('repo', 'directory', 'full_path')
      end
    end

    describe '#upload_rubygems_component' do
      it 'sends upload_rubygems_component message' do
        expect(@api).to receive(:upload_rubygems_component)
        @connection.upload_rubygems_component('repo', 'full_path')
      end
    end

    describe '#upload_yum_component' do
      it 'sends upload_yum_component message' do
        expect(@api).to receive(:upload_yum_component)
        @connection.upload_yum_component('repo', 'directory', 'full_path')
      end
    end
  end
end
