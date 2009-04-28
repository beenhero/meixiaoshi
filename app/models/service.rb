class Service < ActiveRecord::Base
  
  belongs_to :user
  has_many :schedules
  
  validates_presence_of :begin_date_time, :end_date_time, :user_id
  validates_presence_of :begin_date_time, :end_date_time, :if => :time_required
  validates_presence_of :repeat_until, :if => Proc.new{|c| c.is_recurring}
  validates_numericality_of :repeat_every, :greater_than => 0, :if => Proc.new{|c| c.is_recurring}
  validates_inclusion_of :repeat_cycle, :in => %w( daily weekly monthly yearly ), :if => Proc.new{|c| c.is_recurring}
  validates_inclusion_of :repeat_type, :in => %w( day_of_week day_of_month ), :if => Proc.new{|c| c.repeat_cycle == 'monthly'}
  validate :valid_time_span
  
  before_validation :set_date_time
  before_save :setup_repeat
  after_save :create_instances
  
  acts_as_taggable_on :tags
  
  def setup_repeat
    case self.repeat_kinds
    when ""
      return
    when "daily"
      self.is_recurring = true
      self.repeat_cycle = "daily"
      self.repeat_every = 1
    when "workday"
      self.is_recurring = true
      self.repeat_cycle = "weekly"
      self.repeat_every = 1
      self.monday = true
      self.tuesday = true
      self.wednesday = true
      self.thursday = true
      self.friday = true
    when "weekend"
      self.is_recurring = true
      self.repeat_cycle = "weekly"
      self.repeat_every = 1
      self.saturday = true
      self.sunday = true
    when "weekly"
      self.is_recurring = true
      self.repeat_cycle = "weekly"
      self.repeat_every = 1
      case self.begin_date_time.wday
      when 0
        self.sunday = true
      when 1
        self.monday = true
      when 2
        self.tuesday = true
      when 3
        self.wednesday = true
      when 4
        self.thursday = true
      when 5
        self.friday = true
      when 6
        self.saturday = true
      end
    when "monthly"
      self.is_recurring = true
      self.repeat_cycle = "monthly"
      self.repeat_every = 1
      self.repeat_type = "day_of_month"
    when "yearly"
      self.is_recurring = true
      self.repeat_cycle = "yearly"
      self.repeat_every = 1
    else
      raise "Undefined repeat kind."
    end
  end
  
  def set_date_time
    self.begin_date_time = Time.mktime(*ParseDate.parsedate("#{self.begin_date_string} #{self.begin_time_string}"))
    self.end_date_time = Time.mktime(*ParseDate.parsedate("#{self.end_date_string} #{self.end_time_string}"))
  end

  def time_required
    not self.is_all_day
  end
  
  def begin_date_string=(date)
    @begin_date = Date.parse(date) rescue nil
  end

  def end_date_string=(date)
    @end_date = Date.parse(date) rescue nil
  end

  def begin_time_string=(time)
    time_params = ParseDate.parsedate("#{Time.now.to_date} #{time}")
    @begin_time = Time.mktime(*time_params).to_s(:time) # * explodes an array
  rescue
    @begin_time = nil
  end

  def end_time_string=(time)
    time_params = ParseDate.parsedate("#{Time.now.to_date} #{time}")
    @end_time = Time.mktime(*time_params).to_s(:time) # * explodes an array
  rescue
    @end_time = nil
  end

  def begin_date_string
    @begin_date || (self.begin_date_time ? self.begin_date_time.strftime("%Y-%m-%d") : "") 
  end

  def end_date_string
    @end_date || (self.end_date_time ? self.end_date_time.strftime("%Y-%m-%d") : "")  
  end

  def begin_time_string
    @begin_time || (self.begin_date_time ? self.begin_date_time.strftime("%H:00"): "")
  end

  def end_time_string
    @end_time || (self.end_date_time ? self.end_date_time.strftime("%H:00") : "")
  end

  def to_s
    time = self.is_all_day ? '全天' : "#{self.begin_time_string.gsub(/^0/, '')}-#{self.end_time_string.gsub(/^0/, '')}"

    if self.is_recurring
      case self.repeat_kinds
      when "daily"
        "每天 #{time}"
      when "workday"
        "工作日 #{time}"
      when "weekend"
        "周末 #{time}"
      else
        "#{self.days.to_sentence} #{time}"
      end
    else
      if self.begin_date_string == self.end_date_string
        "#{self.begin_date_string} #{time}"
      else
        "#{self.begin_date_string} #{time}"
        #keep one day span "#{self.begin_date_string} #{time} - #{self.end_date_string} #{time}"
      end
    end
  end
  
  def display_name 
    self.name.blank? ? self.to_s : self.name
  end
  
  def days
    days = []
    days << '周一' if self.monday
    days << '周二' if self.tuesday
    days << '周三' if self.wednesday
    days << '周四' if self.thursday
    days << '周五' if self.friday
    days << '周六' if self.saturday
    days << '周日' if self.sunday

    return days
  end
  
  def time_drawing(day)
    return nil unless self.schedule_days.include?(day.to_s)
    klass = day < Date.today ? "overdue" : "available" #TODO
    begin_time = self.begin_time_string.to_i == 0 ? 0 : self.begin_time_string.to_i
    end_time = self.end_time_string.to_i == 0 ? 24 : self.end_time_string.to_i
    height = (end_time - begin_time)*10
    top = (begin_time - 0)*10
    return [klass, "height:#{height}px;top:#{top}px;"]
  end
  
  def schedule_days
    @days ||= self.schedules.collect { |s| s.begin_date_time.strftime("%Y-%m-%d") }
  end
  
  protected

  def create_instances
    self.schedules.destroy_all

    date = self.begin_date_time.to_date

    if self.is_recurring
      end_date = self.repeat_until.to_date
      
      case self.repeat_cycle
      when 'daily'
        while date <= end_date do
          start_time, end_time = get_start_end_for_date(date)
          self.schedules.create(:begin_date_time => start_time, :end_date_time => end_time)
          date += repeat_every.days
        end
      when 'weekly'
        week_start = date - date.wday.days
        while date <= end_date do
          if (date.wday == 0 and self.sunday) or (date.wday == 1 and self.monday) or
             (date.wday == 2 and self.tuesday) or (date.wday == 3 and self.wednesday) or
             (date.wday == 4 and self.thursday) or (date.wday == 5 and self.friday) or (date.wday == 6 and self.saturday)
          
             start_time, end_time = get_start_end_for_date(date)
             self.schedules.create(:begin_date_time => start_time, :end_date_time => end_time)
           end
          
          if date.wday < 6
            date = date.next
          else
            week_start += repeat_every.weeks
            date = week_start
          end
        end
      when 'monthly'
        original_wday, original_ordinal = get_wday_ordinal(date)
        while date <= end_date do
          if self.repeat_type == 'day_of_month'
            start_time, end_time = get_start_end_for_date(date)
            self.schedules.create(:begin_date_time => start_time, :end_date_time => end_time)
            date += repeat_every.months
          else
            wday, ordinal = get_wday_ordinal(date)
            if wday == original_wday and ordinal == original_ordinal
              start_time, end_time = get_start_end_for_date(date)
              self.schedules.create(:begin_date_time => start_time, :end_date_time => end_time)
              date = date.beginning_of_month + self.repeat_every.months
            else
              date = (date == date.end_of_month) ? date.begining_of_month + self.repeat_every.months : date.next
            end
          end
        end
      when 'yearly'
        while date <= end_date do
          start_time, end_time = get_start_end_for_date(date)
          self.schedules.create(:begin_date_time => start_time, :end_date_time => end_time)
          date += repeat_every.years
        end
      end
    else
      self.schedules.create(:begin_date_time => self.begin_date_time, :end_date_time => self.end_date_time)
    end
  end
  
  def duration
    @duration ||= self.end_date_time - self.begin_date_time
  end
  
  def get_wday_ordinal(date)
    wday = date.wday
    ordinal = (date.mday.to_f / 7.0).ceil
    
    return wday, ordinal
  end

  def get_start_end_for_date(date)
    start_time = Time.mktime(*ParseDate.parsedate("#{date.to_s(:standard)} #{@begin_time}"))
    end_time = start_time + self.duration

    return start_time, end_time
  end
  
  def valid_time_span
    errors.add_to_base("结束时间要比开始时间晚才行。") if (begin_date_time > end_date_time)
  end
end