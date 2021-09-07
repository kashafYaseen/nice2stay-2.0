class CacheLodgingsJob < ApplicationJob
  queue_as :cache
  include MonthsDateRange

  def perform
    SearchAnalytic.all.each do |search_analytic|
      search_params = search_analytic.params.with_indifferent_access[:lodgings]
      next if search_params.blank?
      next if search_params[:check_in].present? && params[:check_in].to_date < Date.today
      if search_params[:action] == 'index'
        dates = dates_by_months(search_params)
        ::V2::SearchLodgings.call(search_params.clone.merge(months_date_range: dates, flexible_dates: flexible_dates(dates, search_params)), search_analytic, nil)
      else
        Lodging.calculate_prices(params_wrt_flexible_type(search_params), search_params[:ids].try(:split, ','), search_analytic)
      end
    end
  end
end
