require 'nexus_sync/items/item'
require 'nexus_sync/items/npm_item'

RSpec.describe NexusSync::NpmItem do
  let(:component) { {'repository'=>''} }
  let(:asset)     { {'path'=>'','downloadUrl'=>'path/name'} }
  let(:download_location) { File.join(Dir.pwd, 'spec/downloads') }

  describe '#download' do
    it 'sends #download to a connection object' do
      item = NexusSync::NpmItem.new(component, asset, download_location)
      connection = double
      allow(connection).to receive(:download).and_return(true)
      expect(item.download(connection)).to be(true)
    end
  end

  describe '#upload' do
    it 'sends #upload_npm_component to a connection object' do
      item = NexusSync::NpmItem.new(component, asset, download_location)
      connection = double
      allow(connection).to receive(:upload_npm_component).and_return(true)
      expect(item.upload(connection)).to be(true)
    end
  end
end
