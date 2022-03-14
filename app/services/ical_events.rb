class IcalEvents
  attr_accessor :lodging
  attr_accessor :events

  def self.call(lodging)
    self.new(lodging).call
  end

  def initialize(lodging)
    @lodging = lodging
    @events = get_events_from_ical
  end

  def call
    not_available_days
  end

  private
    def get_events_from_ical
      begin
        url = lodging.ical.strip
        file = HTTParty.get(url, :headers => {"User-Agent" => "Mozilla/5.0 (Windows NT 6.3)" }, :verify => false) if valid_url?(url)
        cals = Icalendar::Calendar.parse(file)
        cal = cals.try(:first)
        events = cal.try(:events)
        return events
      rescue
        "Invalid URL/File..!!!"
      end
    end

    def valid_url?(url)
      url = URI.parse(url) rescue false
    end

    def not_available_days
      @not_aval_days = []
      unless @events.blank? || !(@events.class == Array)
        @events.each do |event|
          start_date = Icalendar::Values::Date.new(event.dtstart)
          end_date = Icalendar::Values::Date.new(event.dtend)
          @not_aval_days << (start_date..end_date).to_s
        end
      end
      return @not_aval_days
    end
end
