json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
json.currentSelection @currentId if @currentId
    
json.rowdata @rooms do |room|
    
    json.partial! 'room', room: room 

end
