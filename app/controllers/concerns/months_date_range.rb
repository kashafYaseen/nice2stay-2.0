module MonthsDateRange
  def params_wrt_flexible_type
    return params.clone unless (params[:flexible].present? || params[:flexible_arrival].present?) && params[:flexible_type].present? && params[:months].present?
    flexible_type_params = params.clone
    flexible_type_params = flexible_type_params.merge(minimum_stay: nights_wrt_flexible_type)
    dates = []
    checkin_dates = []
    months_date_range = dates_by_months
    months_date_range.each do |date_range|
      if params[:flexible_type] == 'week' || params[:flexible_type] == 'custom'
        dates += ((Date.parse(date_range[:start_date]))..(Date.parse(date_range[:end_date]))).map(&:to_s)
        checkin_dates += dates - ((Date.parse(date_range[:end_date]) - 7.days)..(Date.parse(date_range[:end_date]))).map(&:to_s)
      elsif params[:flexible_type] == 'weekend' || params[:flexible_type] == 'long_weekend'
        days = (params[:flexible_type] == 'weekend' && [5, 6, 7]) || [5, 6, 7, 1]
        dates += (Date.parse(date_range[:start_date])..Date.parse(date_range[:end_date])).select { |date| days.include?(date.cwday) }.map(&:to_s)
        checkin_dates += dates.select { |date| Date.parse(date).friday? }
      end
    end

    flexible_type_params.merge(dates_by_months: dates, checkin_dates: checkin_dates, flexible_dates: flexible_dates(months_date_range))
  end

  def dates_by_months
    return [] unless (params[:flexible].present? || params[:flexible_arrival].present?) && params[:flexible_type].present? && params[:months].present?

    months = params[:months].split(',').sort_by { |month| Date::MONTHNAMES.index(month.strip.capitalize) }
    dates = []
    months.each_with_index do |month, index|
      next if month.blank?

      month_index = Date::MONTHNAMES.index(month.strip.capitalize)
      prev_month_index = Date::MONTHNAMES.index(months[index - 1].strip.capitalize) unless index.zero?
      current_date = Date.today
      year = ((month_index < current_date.month) && current_date.year + 1) || current_date.year
      start_date = (month_index == current_date.month && Date.new(year, month_index, current_date.day)) || Date.new(year, month_index, 1)
      end_date = Date.new(year, month_index + 1, 1)
      _index = dates.size

      if prev_month_index.present? && ((end_date.year * 12 + end_date.month) - (dates[_index - 1][:end_date].to_date.year * 12 + dates[_index - 1][:end_date].to_date.month) == 1) #consecutive months
        dates[_index - 1] = dates[_index - 1].merge(end_date: end_date.to_s)
      else
        dates << { start_date: start_date.to_s, end_date: end_date.to_s }
      end
    end

    dates
  end

  def flexible_dates(months_date_range)
    dates = []
    if params[:flexible_type] == 'week' || params[:flexible_type] == 'custom'
      months_date_range.each do |date_range|
        checkin = date_range[:start_date].to_date
        checkout = checkin + nights_wrt_flexible_type
        (date_range[:start_date].to_date..(date_range[:end_date].to_date - nights_wrt_flexible_type)).map(&:to_date).size.times do |index|
          dates << { check_in: checkin.to_s, check_out: checkout.to_s }
          checkin += 1.day
          checkout += 1.day
        end
      end
    elsif params[:flexible_type] == 'weekend' || params[:flexible_type] == 'long_weekend'
      months_date_range.each do |date_range|
        checkin_day = 5  # Friday
        checkin = date_range[:start_date].to_date
        checkin = checkin.next_week if checkin.cwday > checkin_day
        checkin += ((checkin_day - checkin.cwday) % 7)
        loop do
          checkout = checkin + nights_wrt_flexible_type
          break if checkin > date_range[:end_date].to_date || checkout > date_range[:end_date].to_date
          dates << { check_in: checkin.to_s, check_out: checkout.to_s }
          checkin += 1.week
        end
      end
    end

    dates
  end

  def nights_wrt_flexible_type
    return 7 if params[:flexible_type] == 'week'
    return 3 if params[:flexible_type] == 'long_weekend'
    return 2 if params[:flexible_type] == 'weekend'
    params[:custom_stay].to_i if params[:flexible_type] == 'custom'
  end
end
