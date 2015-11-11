module UploaderHelper
  
  def root_path(a = nil)
    SiteConfig.first.name.gsub(/[^a-zA-Z0-9\- ]/, '')
  end
  
  def common_root_path(a = nil)
    SiteConfig.first.name.gsub(/[^a-zA-Z0-9\- ]/, '')
  end
  
end