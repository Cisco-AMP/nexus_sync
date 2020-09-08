require 'nexus_sync/items/item'
require 'nexus_sync/items/docker_item'

RSpec.describe NexusSync::DockerItem do
  let(:component) { {'repository'=>''} }
  let(:asset)     { {'path'=>'','downloadUrl'=>'path/name'} }
  let(:download_location) { File.join(Dir.pwd, 'spec/downloads') }

  describe '#download' do
    it 'sends #download_docker_component to a connection object' do
      item = NexusSync::DockerItem.new(component, asset, download_location)
      connection = double
      expect(connection).to receive(:download_docker_component).and_return(true)
      expect(item.download(connection)).to be(true)
    end
  end

  describe '#upload' do
    it 'sends #upload_docker_component to a connection object' do
      item = NexusSync::DockerItem.new(component, asset, download_location)
      connection = double
      expect(connection).to receive(:upload_docker_component).and_return(true)
      expect(item.upload(connection)).to be(true)
    end
  end
end
