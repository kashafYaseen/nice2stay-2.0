class IcalEvents
  attr_accessor :lodging, :events

  def initialize(lodging)
    @lodging = lodging
    @events = get_events_from_ical
  end

  def build_ical_blocked_dates
    build_blocked_dates
  end

  private
    def get_events_from_ical
      begin
        url = lodging.ical.strip
        file = HTTParty.get(url, headers: {"User-Agent" => "Mozilla/5.0 (Windows NT 6.3)" }, verify: false) if valid_url?(url)
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

    def build_blocked_dates
      ical_blocked_dates = []
      unless @events.blank? || !(@events.class == Array)
        @events.each do |event|
          start_date = Icalendar::Values::Date.new(event.dtstart).to_date
          end_date = Icalendar::Values::Date.new(event.dtend).to_date
          date_range = start_date..end_date
          ical_blocked_dates << date_range
        end
      end
      return ical_blocked_dates
    end
end
