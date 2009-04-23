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
  
  # Returns an HTML week-view calendar. In its simplest form, this method generates a plain
  # calendar (which can then be customized using CSS) for a given span of days.
  # However, this may be customized in a variety of ways -- changing the default CSS
  # classes, generating the individual day entries yourself, and so on.
  # 
  # The following options are required:
  #  :start_date
  #  :end_date
  # 
  # The following are optional, available for customizing the default behaviour:
  #   :table_class       => "week-view"        # The class for the <table> tag.
  #   :day_name_class    => "dayName"         # The class is for the names of the days, at the top.
  #   :day_class         => "day"             # The class for the individual day number cells.
  #                                             This may or may not be used if you specify a block (see below).
  #   :show_today        => true              # Highlights today on the calendar using the CSS class 'today'. 
  #                                           # Defaults to true.
  #   :previous_span_text   => nil            # Displayed left if set
  #   :next_span_text   => nil                # Displayed right if set
  #
  # For more customization, you can pass a code block to this method, that will get two argument, both DateTime objects,
  # and return a values for the individual table cells. The block can return an array, [cell_text, cell_attrs],
  # cell_text being the text that is displayed and cell_attrs a hash containing the attributes for the <td> tag
  # (this can be used to change the <td>'s class for customization with CSS).
  # This block can also return the cell_text only, in which case the <td>'s class defaults to the value given in
  # +:day_class+. If the block returns nil, the default options are used.
  # 
  # Example usage:
  #   week_view(:start_date => (Date.today - 5), :end_date => Date.today) # This generates the simplest possible week-view.
  #   week_view(:start_date => (Date.today - 5), :end_date => Date.today, :table_class => "calendar_helper"}) # This generates a week-view, as
  #                                                                             # before, but the <table>'s class
  #                                                                             # is set to "calendar_helper".
  #   week_view(:start_date => (Date.today - 5), :end_date => Date.today) do |s| # This generates a simple week-view, but gives special spans
  #     if listOfSpecialSpans.include?(s)          # (spans that are in the array listOfSpecialSpans) one CSS class,
  #       ["", {:class => "specialSpan"}]      # "specialSpan", and gives the rest of the spans another CSS class,
  #     else                                      # "normalSpan". You can also use this to highlight the current time differently
  #       ["", {:class => "normalSpan"}]       # from the rest of the days, etc.
  #     end
  #   end
  #
  # For consistency with the themes provided in the calendar_styles generator, use "specialSpan" as the CSS class for marked days.
  # 
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
    
		if options[:url]
      next_start_date = options[:end_date] + 1
      next_end_date   = next_start_date + 5
      next_link = link_to('>>', url_for(options[:url].merge(:start_date => next_start_date, :end_date => next_end_date)) + options[:url_append])
      prev_start_date = options[:start_date] - span
      prev_end_date = options[:start_date] - 1
      prev_link = link_to('<<', url_for(options[:url].merge(:start_date => prev_start_date, :end_date => prev_end_date)) + options[:url_append])
		end

    # TODO Use some kind of builder instead of straight HTML
    cal = %(<table class="#{options[:table_class]}">\n)
    cal << %(\t<thead>\n\t\t<tr>\n)
    cal << %(\t\t\t<th colspan="2" class='previous-week'>&laquo;</th><th colspan="3" class="current-date">#{Date.today}</th><th colspan="2"  class='next-week'>&raquo;</th>\n)
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

      cal << "\t\t\t<td><div class='float-cell'><span #{cell_attrs}>\n#{cell_text}&nbsp;\t\t\t</span></div></td>\n"
    end
    
    cal << %(\t\t</tr>)
    cal << "\n\t</tbody>\n</table>"
  end
  
  def show_status_proc(service)
    lambda do |day|
      klass, style = service.time_drawing(day)
      ["10:00~12:00", { :class => klass, :style => style }]  unless klass.blank? && style.blank?
    end
  end
  
end