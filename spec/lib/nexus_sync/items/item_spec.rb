require 'nexus_sync/items/item'

RSpec.describe NexusSync::Item do
  before(:all) do
    @component = @asset = {}
    @download_location = File.join(Dir.pwd, 'spec/downloads')
  end

  describe '#id' do
    it 'returns the item\'s id' do
      item = NexusSync::Item.new(@component, { 'id' => '11' }, @download_location)
      expect(item.id).to eq('11')
    end
  end

  describe '#path' do
    it 'returns the item\'s path' do
      item = NexusSync::Item.new(@component, { 'path' => '/path/to/success' }, @download_location)
      expect(item.path).to eq('/path/to/success')
    end
  end

  describe '#download_link' do
    it 'returns the item\'s download_link' do
      item = NexusSync::Item.new(@component, { 'downloadUrl' => 'link' }, @download_location)
      expect(item.download_link).to eq('link')
    end
  end

  describe '#name' do
    it 'returns the item\'s name' do
      item = NexusSync::Item.new(@component, { 'downloadUrl' => 'link/name' }, @download_location)
      expect(item.name).to eq('name')
    end
  end

  describe '#sha1' do
    it 'returns the item\'s sha1' do
      item = NexusSync::Item.new(@component, { 'checksum' => {'sha1'=>'a1b2c3'} }, @download_location)
      expect(item.sha1).to eq('a1b2c3')
    end

    it 'returns nil when no checksum is present' do
      item = NexusSync::Item.new(@component, { 'sha1' => 'a1b2c3' }, @download_location)
      expect(item.sha1).to eq(nil)
    end
  end

  describe '#format' do
    it 'returns the item\'s format' do
      item = NexusSync::Item.new({ 'format' => 'red' }, @asset, @download_location)
      expect(item.format).to eq('red')
    end
  end

  describe '#repo' do
    it 'returns the item\'s repo' do
      item = NexusSync::Item.new({ 'repository' => 'repo' }, @asset, @download_location)
      expect(item.repo).to eq('repo')
    end
  end

  describe '#tags' do
    it 'returns the item\'s tags' do
      item = NexusSync::Item.new({ 'tags' => 'tags' }, @asset, @download_location)
      expect(item.tags).to eq('tags')
    end
  end

  describe '#file_size' do
    it 'returns the file size' do
      item = NexusSync::Item.new(@component, @asset, @download_location)
      item.file_size = 10
      expect(item.file_size).to eq(10)
    end
  end

  describe '#download' do
    it 'raise an unimplemented error' do
      item = NexusSync::Item.new(@component, @asset, @download_location)
      connection = double
      error = "ERROR: #download is not defined in NexusSync::Item.\nThis method needs to be defined in every subclass of NexusSync::Item"
      expect{ item.download(connection) }.to raise_error(RuntimeError, error)
    end
  end

  describe '#upload' do
    it 'raise an unimplemented error' do
      item = NexusSync::Item.new(@component, @asset, @download_location)
      connection = double
      error = "ERROR: #upload is not defined in NexusSync::Item.\nThis method needs to be defined in every subclass of NexusSync::Item"
      expect{ item.upload(connection) }.to raise_error(RuntimeError, error)
    end
  end

  describe '#requeue?' do
    it 'returns true if the item can be requeued' do
      item = NexusSync::Item.new(@component, @asset, @download_location)
      expect(item.requeue?).to be true
    end

    it 'returns false if the item can not be requeued' do
      item = NexusSync::Item.new(@component, @asset, @download_location)
      item.requeue?
      item.requeue?
      item.requeue?
      expect(item.requeue?).to be false
    end
  end

  describe '#docker_format?' do
    it 'returns true when the item has the format docker' do
      item = NexusSync::Item.new({'format' => 'docker'}, @asset, @download_location)
      expect(item.docker_format?).to be(true)
    end

    it 'returns false when the item does not have the format docker' do
      item = NexusSync::Item.new({'format' => 'rubygems'}, @asset, @download_location)
      expect(item.docker_format?).to be(false)
    end
  end

  describe 'object equivalency' do
    before(:each) do
      @component = {'format'=>'colour', 'repository'=>'blue'}
      @asset = {'id'=>'123', 'path'=>'/root' , 'downloadUrl'=>'url/name', 'checksum'=>{'sha1'=>'321'} }
      @item1 = NexusSync::Item.new(@component, @asset, @download_location)
      @item2 = NexusSync::Item.new(@component, @asset, @download_location)
    end

    describe '#eql?' do
      it 'returns true when two different items are equal' do
        expect(@item1.eql?(@item2)).to be true
      end

      it 'returns true when only the item ids are different' do
        @asset['id'] = '456'
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.eql?(item2)).to be true
      end

      it 'returns false when the item paths are different' do
        @asset['path'] = '/opt'
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.eql?(item2)).to be false
      end

      it 'returns true when only the item download_links are different' do
        @asset['downloadUrl'] = 'other_url/name'
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.eql?(item2)).to be true
      end

      it 'returns false when the item names are different' do
        @asset['downloadUrl'] = 'url/other_name'
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.eql?(item2)).to be false
      end

      it 'returns false when the item sha1s are different' do
        @asset['checksum'] = {'sha1'=>'654'}
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.eql?(item2)).to be false
      end

      it 'returns false when the item formats are different' do
        @component['format'] = 'shape'
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.eql?(item2)).to be false
      end

      it 'returns false when the item repositories are different' do
        @component['repository'] = 'red'
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.eql?(item2)).to be false
      end
    end

    describe '#hash' do
      it 'returns the same hash for equal items' do
        expect(@item1.hash).to eq(@item2.hash)
      end

      it 'returns a different hash for different items' do
        @component['repository'] = 'red'
        item2 = NexusSync::Item.new(@component, @asset, @download_location)
        expect(@item1.hash).to_not eq(item2.hash)
      end
    end
  end
end
