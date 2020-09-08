require 'nexus_sync/item_generator'
require 'nexus_sync/items'

RSpec.describe NexusSync::ItemGenerator do
  describe '.create' do
    it 'creates a docker item' do
      item = NexusSync::ItemGenerator.create({'format'=>'docker'}, {}, '')
      expect(item).to be_a(NexusSync::DockerItem)
    end

    it 'creates a maven item' do
      item = NexusSync::ItemGenerator.create({'format'=>'maven2'}, {}, '')
      expect(item).to be_a(NexusSync::MavenItem)
    end

    it 'creates a npm item' do
      item = NexusSync::ItemGenerator.create({'format'=>'npm'}, {}, '')
      expect(item).to be_a(NexusSync::NpmItem)
    end

    it 'creates a pypi item' do
      item = NexusSync::ItemGenerator.create({'format'=>'pypi'}, {}, '')
      expect(item).to be_a(NexusSync::PypiItem)
    end

    it 'creates a raw item' do
      item = NexusSync::ItemGenerator.create({'format'=>'raw'}, {}, '')
      expect(item).to be_a(NexusSync::RawItem)
    end

    it 'creates a rubygems item' do
      item = NexusSync::ItemGenerator.create({'format'=>'rubygems'}, {}, '')
      expect(item).to be_a(NexusSync::RubygemsItem)
    end

    it 'creates a yum item' do
      item = NexusSync::ItemGenerator.create({'format'=>'yum'}, {}, '')
      expect(item).to be_a(NexusSync::YumItem)
    end

    it 'raises an error when there is no format' do
      error = 'ERROR: Couldn\'t generate an Item with no component format: {}'
      expect{ NexusSync::ItemGenerator.create({}, {}, '') }.to raise_error(RuntimeError, error)
    end

    it 'raises an error when there is an unexpected format' do
      error = 'ERROR: Couldn\'t generate an Item for fake type.'
      expect{ NexusSync::ItemGenerator.create({'format'=>'fake'}, {}, '') }.to raise_error(RuntimeError, error)
    end
  end
end
