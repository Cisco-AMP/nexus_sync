require 'nexus_sync/item_validator'

RSpec.describe NexusSync::ItemValidator do
  describe '.valid?' do
    it 'accepts a docker item' do
      asset = {'format'=>'docker', 'downloadUrl'=>'docker'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(true)
    end

    it 'accepts a maven item' do
      asset = {'format'=>'maven2', 'downloadUrl'=>'maven2'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(true)
    end

    it 'does not accept a maven .md5 item' do
      asset = {'format'=>'maven2', 'downloadUrl'=>'maven2.md5'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'does not accept a maven .sha1 item' do
      asset = {'format'=>'maven2', 'downloadUrl'=>'maven2.sha1'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'does not accept a maven .xml item' do
      asset = {'format'=>'maven2', 'downloadUrl'=>'maven2.xml'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'only accepts npm .tgz items' do
      asset = {'format'=>'npm', 'downloadUrl'=>'npm.tgz'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(true)
    end

    it 'does not accept non .tgz npm items' do
      asset = {'format'=>'npm', 'downloadUrl'=>'npm'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'accepts a pypi item' do
      asset = {'format'=>'pypi', 'downloadUrl'=>'pypi'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(true)
    end

    it 'accepts a raw item' do
      asset = {'format'=>'raw', 'downloadUrl'=>'raw'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(true)
    end

    it 'accepts a rubygems item' do
      asset = {'format'=>'rubygems', 'downloadUrl'=>'rubygems'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(true)
    end

    it 'does not accept a rubygems gemspec.rz item' do
      asset = {'format'=>'rubygems', 'downloadUrl'=>'gemspec.rz'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'does not accept a rubygems .ruby item' do
      asset = {'format'=>'rubygems', 'downloadUrl'=>'rubygems.ruby'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'does not accept a rubygems .gz item' do
      asset = {'format'=>'rubygems', 'downloadUrl'=>'rubygems.gz'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'accepts a yum item' do
      asset = {'format'=>'yum', 'downloadUrl'=>'yum'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(true)
    end

    it 'does not accept a yum .xml item' do
      asset = {'format'=>'yum', 'downloadUrl'=>'yum.xml'}
      expect(NexusSync::ItemValidator.valid?(asset)).to be(false)
    end

    it 'raises an error when there is no asset format' do
      error = 'ERROR: Couldn\'t validate an Item with no asset format: {}'
      expect{ NexusSync::ItemValidator.valid?({}) }.to raise_error(RuntimeError, error)
    end

    it 'raises an error when there is no asset download url' do
      error = 'ERROR: Couldn\'t validate an Item with no asset downloadUrl: {"format"=>""}'
      expect{ NexusSync::ItemValidator.valid?({'format'=>''}) }.to raise_error(RuntimeError, error)
    end

    it 'raises an error when there is an unexpected asset format' do
      error = 'ERROR: Couldn\'t validate an Item for fake type.'
      expect{ NexusSync::ItemValidator.valid?({'format'=>'fake', 'downloadUrl'=>''}) }.to raise_error(RuntimeError, error)
    end
  end
end
