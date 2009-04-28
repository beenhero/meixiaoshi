module ApplicationHelper
  
  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end
  
  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, '<a onclick="$(\'flash_box\').hide();return false" href="#">X</a>' + html_escape(flash[msg.to_sym]), :id => "flash_box", :class=> "#{msg}") unless flash[msg.to_sym].blank?
    end
    messages << %(<script type="text/javascript">show_error_message();</script>)
    messages
  end
end
