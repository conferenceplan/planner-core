#
#
#
module JobUtils
  
  def getSiteConfig
    SiteConfig.find :first
  end
  
end
