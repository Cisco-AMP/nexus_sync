require 'nexus_sync/repo'

RSpec.describe NexusSync::Repo do
  before(:each) do
    @repo1 = NexusSync::Repo.new({
      'name' => 'name',
      'format' => 'format',
      'type' => 'type'
    })
    @repo2 = NexusSync::Repo.new({
      'name' => 'name',
      'format' => 'format',
      'type' => 'type'
    })
  end

  describe '#name' do  
    it 'returns the repo\'s name' do
      repo = NexusSync::Repo.new({ 'name' => 'a_name' })
      expect(repo.name).to eq('a_name')
    end
  end

  describe '#format' do
    it 'returns the repo\'s format' do
      repo = NexusSync::Repo.new({ 'format' => 'a_format' })
      expect(repo.format).to eq('a_format')
    end
  end

  describe '#type' do
    it 'returns the repo\'s type' do
      repo = NexusSync::Repo.new({ 'type' => 'a_type' })
      expect(repo.type).to eq('a_type')
    end
  end

  describe '#items' do
    it 'lists the items' do
      repo = NexusSync::Repo.new({})
      expect(repo.items).to eq([])
    end
  end

  describe '#add' do
    it 'adds an item to the list' do
      repo = NexusSync::Repo.new({})
      repo.add('')
      expect(repo.items).to eq([''])
    end
  end

  describe '#eql?' do
    it 'returns true when two different repos are equal' do
      expect(@repo1.eql?(@repo2)).to be true
    end

    it 'returns false when repos names are not equal' do
      @repo2.name = 'eman'
      expect(@repo1.eql?(@repo2)).to be false
    end

    it 'returns false when repo formats are not equal' do
      @repo2.format = 'tamrof'
      expect(@repo1.eql?(@repo2)).to be false
    end

    it 'returns true when repo types are not equal' do
      @repo2.type = 'epyt'
      expect(@repo1.eql?(@repo2)).to be true
    end
  end

  describe '#hash' do
    it 'returns the same hash for a combination of name, format, and type' do
      expect(@repo1.hash).to eq(@repo2.hash)
    end

    it 'returns different hashes when repos names are not equal' do
      @repo2.name = 'eman'
      expect(@repo1.hash).to_not eq(@repo2.hash)
    end

    it 'returns different hashes when repo formats are not equal' do
      @repo2.format = 'tamrof'
      expect(@repo1.hash).to_not eq(@repo2.hash)
    end

    it 'returns the same hash when repo types are not equal' do
      @repo2.type = 'epyt'
      expect(@repo1.hash).to eq(@repo2.hash)
    end
  end

  describe '#copy' do
    it 'creates a new repo with the same fields as the source' do
      repo2 = @repo1.copy
      expect(repo2.name).to eq(@repo1.name)
      expect(repo2.format).to eq(@repo1.format)
      expect(repo2.type).to eq(@repo1.type)
      expect(repo2.object_id).to_not eq(@repo1.object_id)
    end

    it 'does not copy repo items' do
      @repo1.add(1)
      expect(@repo1.items).to eq([1])
      repo2 = @repo1.copy
      expect(repo2.items).to eq([])
    end
  end
end
