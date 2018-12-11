module ReviewsHelper
  def rating_tag(rating, name)
    rating_tag_html(name, rating)
  end

  def avgerage_rating_tag(rating, total, name)
    total = 1 if total == 0
    rating_tag_html(name, (rating / total))
  end

  def rating_tag_html(name, rating)
    percentage = rating * (100 / 5)

    " <label class='text-medium text-sm'>
        #{t("reviews.#{name}")} <span class='text-muted'>- #{rating.round(2)}</span>
      </label>

    <div class='progress margin-bottom-1x'>
      <div class='progress-bar bg-warning' role='progressbar'
        style='width: #{percentage}%; height: 2px;'
        aria-valuenow='#{rating}' aria-valuemin='0'
        aria-valuemax='5'>
      </div>
    </div>".html_safe
  end

  def render_stars_tag(rating)
    return if rating.nan?
    fraction, star_tags, total_stars = (rating - rating.to_i).round(2), '', 5
    rating.to_i.times { |star| star_tags += "<i class='material-icons star'></i>" }

    if fraction >= 0.3
      star_tags += '<i class="material-icons star_half"></i>'
      total_stars = 4
    end

    (total_stars-rating.to_i).times { |star| star_tags += '<i class="material-icons star_border"></i>' }
    star_tags.html_safe
  end
end
