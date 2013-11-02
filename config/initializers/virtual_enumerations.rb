#
ActiveRecord::VirtualEnumerations.define do |config|
 config.define 'Enum',
    :table_name => 'enumrecord',:order => 'position ASC'
 
 config.define 'InviteStatus',
    :extends => 'Enum'
    
 config.define 'AcceptanceStatus',
    :extends => 'Enum'

 config.define 'PhoneTypes',
    :extends => 'Enum'

 config.define 'PersonItemRole',
    :extends => 'Enum'
    
 config.define 'PendingType',
    :extends => 'Enum'
    
 config.define 'MailUse',
    :extends => 'Enum'

 config.define 'EmailStatus',
    :extends => 'Enum'
    
 config.define 'AnswerType',
    :extends => 'Enum'
    
 config.define 'QuestionMapping',
    :extends => 'Enum'
end
