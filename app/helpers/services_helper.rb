module ServicesHelper
  def hour_options
    [ 
      ['凌晨 0:00', "00:00"],
      ['凌晨 1:00', "01:00"],
      ['凌晨 2:00', "02:00"],
      ['凌晨 3:00', "03:00"],
      ['凌晨 4:00', "04:00"],
      ['凌晨 5:00', "05:00"],
      ['上午 6:00', "06:00"],
      ['上午 7:00', "07:00"],
      ['上午 8:00', "08:00"],
      ['上午 9:00', "09:00"],
      ['上午 10:00', "10:00"],
      ['上午 11:00', "11:00"],
      ['下午 12:00', "12:00"],
      ['下午 1:00', "13:00"],
      ['下午 2:00', "14:00"],
      ['下午 3:00', "15:00"],
      ['下午 4:00', "16:00"],
      ['下午 5:00', "17:00"],
      ['晚上 6:00', "18:00"],
      ['晚上 7:00', "19:00"],
      ['晚上 8:00', "20:00"],
      ['晚上 9:00', "21:00"],
      ['晚上 10:00', "22:00"],
      ['晚上 11:00', "23:00"]
    ]
  end
  
  def repeat_options
    [
      ["不重复", nil],
      ["每天", "daily"],
      ["每个工作日", "workday"],
      ["每个周末", "weekend"],
      ["每周", "weekly"],
      ["每月", "monthly"]
    ]
  end
  
  def unit_options
    [
      ["每小时", "每小时"],
      ["每次", "每次"],
      ["每天", "每天"],
      ["每周", "每周"],
      ["每月", "每月"],
      ["每年", "每年"],
      ["公益", "公益"],
      ["赠予", "赠予"]
    ]
  end
  
  def radius_options
    [
      ["不限", nil],
      ["3公里以内", 3],
      ["10公里以内", 10],
      ["20公里以内", 20],
      ["50公里以内", 50],
      ["100公里以内", 100]
    ]
  end

  # hand craft week_view for service's schedules.
  # NOT very flexible, need to improve ongoing. 27/04/09 by ben
  
  def week_view(options = {}, &block)
    raise(ArgumentError, "No start date given")  unless options.has_key?(:start_date)
    raise(ArgumentError, "No end date given") unless options.has_key?(:end_date)
    dates = (options[:start_date]..options[:end_date])
    block                        ||= Proc.new {|d| nil}
    defaults = {
      :table_class => 'week-view',
      :day_name_class => 'dayName',
      :day_class => 'day',
      :show_today => true,
      :previous_span_text => nil,
      :next_span_text => nil
    }
    options = defaults.merge options
    
    day_names = I18n.translate(:'date.abbr_day_names')
    
		if options[:prev_week] && options[:next_week]
      next_link = options[:next_week].respond_to?(:call) ? options[:next_week].call : ''
      prev_link = options[:prev_week].respond_to?(:call) ? options[:prev_week].call : ''
		end
    
    select_date = calendar_date_select_tag "selet_date", "", :hidden => true, :onchange => "#{options[:move_to_date].call}" if options[:move_to_date] && options[:move_to_date].respond_to?(:call)
    
    # TODO Use some kind of builder instead of straight HTML
    cal = %(<table class="#{options[:table_class]}">\n)
    cal << %(\t<thead>\n\t\t<tr>\n)
    cal << %(\t\t\t<th colspan="2" class='previous-week'>#{prev_link}</th><th colspan="3" class="current-date">今天 #{Date.today} #{select_date}</th><th colspan="2"  class='next-week'>#{next_link}</th>\n)
    cal << %(\t\t</tr>\n\t\t<tr class="day-names">)
    dates.each do |d|
      cal << "\t\t\t<th#{Date.today == d ? " class='today'" : ""}>#{day_names[d.wday]}<br /><span>#{d.strftime("%m/%d")}</span></th>\n"
    end
    cal << "\t\t</tr>\n\t</thead>\n\t<tbody>\n"
    
    cal << %(\t\t<tr class="day-times">\n)
    
    options[:start_date].upto(options[:end_date]) do |d|
      # cell_attrs should return a hash.
      cell_text, cell_attrs = block.call(d)
      cell_text ||= ""
      cell_attrs ||= {}
      cell_attrs[:class] = cell_attrs[:class].to_s + " time"
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      span = "<span #{cell_attrs}>\n#{cell_text}&nbsp;\t\t\t</span>" unless cell_text.blank?
      cal << "\t\t\t<td><div class='float-cell'>#{span}</div></td>\n"
    end
    
    cal << %(\t\t</tr>)
    cal << "\n\t</tbody>\n</table>"
  end
  
  # callback block of week_view.
  def show_status_proc(service)
    lambda do |day|
      klass, style = service.time_drawing(day)
      ["#{service.begin_time_string}~#{service.end_time_string}<span class=\"tip\">#{service.begin_time_string}~#{service.end_time_string} #{service.name}</span>", { :class => klass, :style => style }]  unless klass.blank? && style.blank?
    end
  end
  
  # to generate week_view's option
  def calendar_options(service)
    {       
      :start_date => @start_date,
      :end_date => @start_date + 6,
      :prev_week => lambda {link_to_remote("&laquo;上周", {:update => "schedules", :url => schedules_service_path(service, :start_date => (@start_date-1).beginning_of_week), :complete =>"show_week_view_details()", :method => :get})},                                               
      :next_week => lambda {link_to_remote("下周&raquo;", {:update => "schedules", :url => schedules_service_path(service, :start_date => @start_date.next_week), :complete =>"show_week_view_details()", :method => :get})},
      :move_to_date => lambda { remote_function(:update => "schedules", :url => schedules_service_path(service), :complete =>"show_week_view_details()", :method => :get, :with => "'start_date='+ $F(this)")}
    }
  end
  
  
end