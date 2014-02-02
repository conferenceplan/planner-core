json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
json.currentSelection @currentId if @currentId
    
json.rowdata @users do |user|
    
    json.partial! 'user', user: user 

end
