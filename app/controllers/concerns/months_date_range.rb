module MonthsDateRange
  def params_wrt_flexible_type
    return params.clone unless (params[:flexible].present? || params[:flexible_arrival].present?) && params[:flexible_type].present? && params[:months].present?
    flexible_type_params = params.clone
    flexible_type_params = flexible_type_params.merge(minimum_stay: 7) if params[:flexible_type] == 'week'
    dates = []
    checkin_dates = []
    months_date_range = dates_by_months
    months_date_range.each do |date_range|
      if params[:flexible_type] == 'week'
        dates += ((Date.parse(date_range[:start_date]))..(Date.parse(date_range[:end_date]))).map(&:to_s)
        checkin_dates += dates - ((Date.parse(date_range[:end_date]) - 7.days)..(Date.parse(date_range[:end_date]))).map(&:to_s)
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

      if prev_month_index.present? && ((end_date.year * 12 + end_date.month) - (dates[index - 1][:end_date].to_date.year * 12 + dates[index - 1][:end_date].to_date.month) == 1) #consecutive months
        dates[index - 1] = dates[index - 1].merge(end_date: end_date.to_s)
      else
        dates << { start_date: start_date.to_s, end_date: end_date.to_s }
      end
    end

    dates
  end

  def flexible_dates(months_date_range)
    dates = []
    if params[:flexible_type] == 'week'
      months_date_range.each do |date_range|
        checkin = date_range[:start_date].to_date
        checkout = checkin + 7.days
        (date_range[:start_date].to_date..(date_range[:end_date].to_date - 7.days)).map(&:to_date).size.times do |index|
          dates << { check_in: checkin.to_s, check_out: checkout.to_s }
          checkin += 1.day
          checkout += 1.day
        end
      end
    end

    dates
  end
end
