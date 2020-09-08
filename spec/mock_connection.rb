class MockConnection
  def initialize(repos: [{}], items: [{}])
    default_asset = {
      'downloadUrl'=>'url',
      'path'=>'',
      'id'=>'',
      'repository'=>'',
      'format'=>'raw',
      'checksum'=>{
        'md5'=>''
      }
    }

    default_item = {
      'id'=>'',
      'repository'=>'',
      'format'=>'raw',
      'group'=>'',
      'name'=>'',
      'version'=>'',
      'assets'=>[],
      'tags'=>[],
    }
    
    @repos = repos
    @items = items.map do |item|
      complete_item = default_item.merge(item)
      complete_item['assets'] = complete_item['assets'].map do |asset|
        default_asset.merge(asset)
      end
      complete_item
    end
  end

  def get_repos
    @repos
  end

  def get_components(repo)
    @items
  end

  def get_file_size(link)
    1
  end
end