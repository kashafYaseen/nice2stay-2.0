module ReviewsHelper
  def rating_tag(lodging, total_reviews, stars)
    rating = lodging.rating_for stars
    total_reviews = 1 if total_reviews == 0

    " <label class='text-medium text-sm'>#{stars} stars
        <span class='text-muted'>- #{rating}</span>
      </label>

      <div class='progress margin-bottom-1x'>
        <div class='progress-bar bg-warning' role='progressbar'
          style='width: #{(rating * 100) / total_reviews}%; height: 2px;'
          aria-valuenow='#{rating}' aria-valuemin='0'
          aria-valuemax='#{total_reviews}'>
        </div>
      </div>".html_safe
  end
end
