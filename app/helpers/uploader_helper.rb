module UploaderHelper
  
  def root_path
    SiteConfig.first.name
  end
  
  def common_root_path
    SiteConfig.first.name
  end
  
end