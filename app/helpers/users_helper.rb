module UsersHelper
  
  #
  # Use this to wrap view elements that the user can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%= if_authorized?(:index,   User)  do link_to('List all users', users_path) end %> |
  # <%= if_authorized?(:edit,    @user) do link_to('Edit this user', edit_user_path) end %> |
  # <%= if_authorized?(:destroy, @user) do link_to 'Destroy', @user, :confirm => 'Are you sure?', :method => :delete end %> 
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  #
  # Link to user's page ('users/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of user.login', escaped with
  #   the standard h() function.
  # * :content_method => :user_instance_method_to_call_for_content_text
  # * :title_method => :user_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_user @user
  #   # => <a href="/users/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_user user, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, user.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/users/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_user @user, :content_text => 'Your user page'
  #   # => <a href="/users/3" title="barmy" class="nickname">Your user page</a>
  #
  def link_to_user(user, options={})
    raise "Invalid user" unless user
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text      = options.delete(:content_text)
    content_text    ||= user.send(options.delete(:content_method))
    options[:title] ||= user.send(options.delete(:title_method))
    link_to h(content_text), user_path(user), options
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address 
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={}
    ip_addr           = request.remote_ip
    content_text    ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current user's page (using link_to_user) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_user(options={})
    if current_user
      link_to_user current_user, options
    else
      content_text = options.delete(:content_text) || 'not signed in'
      # kill ignored options from link_to_user
      [:content_method, :title_method].each{|opt| options.delete(opt)} 
      link_to_login_with_IP content_text, options
    end
  end
  
  def gender_options
    [
    ['男', 0],
    ['女', 1],
    ['保密', 2]
    ]
  end
  
  def add_contact_link(form_builder, container)
    link_to_function '添加', :class => 'add-btn' do |page|
      form_builder.fields_for :phone_numbers, PhoneNumber.new, :child_index => 'NEW_RECORD' do |f|
        html = render(:partial => 'contact', :locals => { :form => f, :type => container.upcase })
        page << "$('#{container}').insert({ bottom: '#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()) });"
      end
    end
  end
  
  def remove_contact_link(form_builder)
    if form_builder.object.new_record?
      # If the task is a new record, we can just remove the div from the dom
      link_to_function("删除", "$(this).up('.contact').remove();");
    else
      # However if it's a "real" record it has to be deleted from the database,
      # for this reason the new fields_for, accept_nested_attributes helpers give us _delete,
      # a virtual attribute that tells rails to delete the child record.
      form_builder.hidden_field(:_delete) +
      link_to_function("删除", "$(this).up('.contact').hide(); $(this).previous().value = '1'")
    end
  end
  
  # User monthly calendar show
  # callback block of week_view.
  def monthly_status_proc(user)
    lambda do |day|
      klass, text = user.get_services_on(day)
      str = "#{day.mday}"
      str << "<span style='display:none'>#{text}</span>" unless text.blank?
      [str, { :class => klass }]
    end
  end
  
  def montnly_calendar_options(user)
    prevd = @display_date - 1
    nextd = @display_date + 31
    {
      :previous_month => lambda { link_to_remote("&laquo;上月", {:update => "calendar", :url => calendar_user_path(user, :year => prevd.year, :month => prevd.month), :complete =>"show_calendar_details()", :method => :get}, :class => 'prev-next') },                                               
      :next_month => lambda { link_to_remote("下月&raquo;", {:update => "calendar", :url => calendar_user_path(user, :year => nextd.year, :month => nextd.month), :complete =>"show_calendar_details()", :method => :get}, :class => 'prev-next')},
      :first_day_of_week => 1
    }
  end
  
  # User's information, like phone_numbers, IMs, SNSs
  def phone_numbers_list(user, privacy = true)
    ul = ''
    lists = privacy ? user.phone_numbers.public : user.phone_numbers
    unless lists.blank?
      ul = '<ul class="phone">'
      lists.each do |l|
        ul << "<li>#{l.label}: #{l.value}</li>"
      end  
    end
    return ul << '</ul>' unless ul.blank?
  end
  
  def im_list(user, privacy = true)
      ul = ''
      lists = privacy ? user.instant_messages.public : user.instant_messages
      unless lists.blank?
        ul = '<ul class="im">'
        lists.each do |l|
          ul << "<li>#{l.label}: #{l.value}</li>"
        end  
      end
      return ul << '</ul>' unless ul.blank?
    end
    
  def sns_list(user, privacy = true)
    ul = ''
    lists = privacy ? user.snses.public : user.snses
    unless lists.blank?
      ul = '<ul class="sns">'
      lists.each do |l|
        ul << "<li>#{l.label}: #{l.value}</li>"
      end  
    end
    return ul << '</ul>' unless ul.blank?
  end
  
end
