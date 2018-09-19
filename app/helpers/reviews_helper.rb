module ReviewsHelper
  def rating_tag(rating, total, name)
    total = 1 if total == 0
    average, percentage = rating / total, (rating * 100) / (total * 5)

    " <label class='text-medium text-sm'>
        #{name} <span class='text-muted'>- #{average.round(2)}</span>
      </label>

    <div class='progress margin-bottom-1x'>
      <div class='progress-bar bg-warning' role='progressbar'
        style='width: #{percentage}%; height: 2px;'
        aria-valuenow='#{rating}' aria-valuemin='0'
        aria-valuemax='#{total}'>
      </div>
    </div>".html_safe
  end

  def remaining_star_tags(rating)
    fraction, star_tags, total_stars = (rating - rating.to_i).round(2), '', 5
    star_tags, total_stars = '<i class="material-icons star_half"></i>', 4 if fraction >= 0.3

    (total_stars-rating.to_i).times { |star| star_tags += '<i class="material-icons star_border"></i>' }
    star_tags.html_safe
  end
end
