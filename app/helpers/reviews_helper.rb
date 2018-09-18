module ReviewsHelper
  def rating_tag(lodging, total_reviews, stars)
    rating_tag_html(lodging.rating_for(stars), total_reviews, stars)
  end

  def average_rating_tag(total, type)
    rating_tag_html(Review.sum(type), total, type.to_s.humanize)
  end

  def rating_tag_html(rating, total, name)
    total = 1 if total == 0

    " <label class='text-medium text-sm'>
        #{name} <span class='text-muted'>- #{rating}</span>
      </label>

    <div class='progress margin-bottom-1x'>
      <div class='progress-bar bg-warning' role='progressbar'
        style='width: #{(rating * 100) / total}%; height: 2px;'
        aria-valuenow='#{rating}' aria-valuemin='0'
        aria-valuemax='#{total}'>
      </div>
    </div>".html_safe
  end

  def remaining_star_tags(rating)
    fraction, star_tags = (rating - rating.to_i).round(2), ''
    star_tags += '<i class="material-icons star_half"></i>' if fraction >= 0.3
    (5-rating.to_i).times { |star| star_tags += '<i class="material-icons star_border"></i>' }
    star_tags.html_safe
  end
end
