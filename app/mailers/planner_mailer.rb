class PlannerMailer < ActionMailer::Base
  
  # TODO
  def send_email(args, content)
    message = mail args
    message.content_type 'multipart/alternative'

    # addHTMLPart(message, content)
    addTextPart(message, content)

    message
  end
  
  def addHTMLPart(message, content)
    message.add_part(Mail::Part.new(
      content_type: 'text/html',
      body: content
    ))
  end
  
  def addTextPart(message, content)

    body_parts = []
    Nokogiri::HTML(content).traverse do |node|
      if node.text? and ! (content = node.content ? node.content.strip : nil).blank?
        body_parts << content
      elsif node.name == "a" && (href = node.attr("href")) && href.match(/^https?:/)
        body_parts << href
      end
    end
    
    message.add_part(Mail::Part.new(
      content_type: 'text/plain',
      body: body_parts.uniq.join("\n") #.encode("ISO-8859-1")
    ))
  end
  
end
