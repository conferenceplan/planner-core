#
#
#

module TagsService

  def self.getTagCounts(classname, context)

    # slow mechanism
    #eval(className).tag_counts_on( context ).order('count desc')
    
    query = tagCountSql(classname, context) 

    ActiveRecord::Base.connection.select_all tagCountSql(classname, context)

  end

protected  
  def self.tagCountSql(classname, context)
    @@TAG_COUNT_QUERY_PT1 + "taggings.taggable_type = '" + classname + "' AND taggings.context = '" + context + "'" + @@TAG_COUNT_QUERY_PT2
  end

private

@@TAG_COUNT_QUERY_PT1 = <<"EOS"
  SELECT tags.*, taggings.tags_count AS count FROM `tags` 
  JOIN (SELECT taggings.tag_id, COUNT(taggings.tag_id) AS tags_count FROM `taggings` 
  INNER JOIN people ON people.id = taggings.taggable_id 
  WHERE ( 
EOS

@@TAG_COUNT_QUERY_PT2 = <<"EOS"
  ) 
  GROUP BY taggings.tag_id HAVING COUNT(taggings.tag_id) > 0) AS taggings ON taggings.tag_id = tags.id ORDER BY count desc;
EOS
  
end
