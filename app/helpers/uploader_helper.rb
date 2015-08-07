module UploaderHelper
  
  def root_path
    SiteConfig.first.name.gsub(/[^a-zA-Z0-9\- ]/, '')
  end
  
  def common_root_path
    SiteConfig.first.name.gsub(/[^a-zA-Z0-9\- ]/, '')
  end
  
end