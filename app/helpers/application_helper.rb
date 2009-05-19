module ApplicationHelper
  include TagsHelper
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
  
  def sidebar_popular_tags(tags)
    unless tags.blank?
      html = '<h2>按类别</h2>'
      html << '<ul class="popular-tags">'
      html << "<li class = #{"selected" unless params[:id]}>#{link_to '所有', root_path}</li>"
      tags.each do |tag|
        html << "<li class = #{"selected" if params[:id] == tag.name}>#{link_to h(tag.name), tag_path(tag)}</li>"
      end
      html << "<li class = \"more-tags\">#{link_to '更多 »', tags_path}</li>"
      html << "</ul>"
    end
  end
  
  def sidebar_popular_users(users)
    unless users.blank?
      html = '<h2>人气排行</h2>'
      html << '<ul class="popular-users">'
      users.each_with_index do |user, index|
        html << "<li class = #{cycle("odd","even")}>#{link_to image_tag(user.avatar.url(:tiny)), user_path(user)}<div class=\"details\"><h3>#{link_to h(user), user_path(user)}</h3><em>#{user.city}</em></div><div class=\"count\">##{index + 1}</div><div class=\"clear\"></div></li>"
      end
      html << "</ul>"
      html << "<div class=\"more\">#{link_to '全部用户', "#todo"}</div>"
      html << "<div class=\"sidebar-split\"></div>"
    end
  end
end
