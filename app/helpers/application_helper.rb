module ApplicationHelper
  def bootstrap_class_for(flash_type)
    {
      success: "alert-success",
      error: "alert-danger",
      alert: "alert-warning",
      notice: "alert-info"
    }.stringify_keys[flash_type.to_s] || flash_type.to_s
  end

  def rendom_id object, key=''
    "#{dom_id(object, key)}_#{rand}"
  end

  def render_date(date)
    date.strftime("%d/%m/%Y") if date.present?
  end

  def render_datetime(datetime)
    datetime.strftime("%d/%m/%Y %I:%M %p") if datetime.present?
  end

  def render_title
    return @title if @title.present?
    default_meta_title
  end

  def default_meta_title
    return 'Nice2stay - Hand-picked collection villas, apartments and boutique hotels' if locale == :en
    'Nice2stay - Hand-picked collectie vakantiehuizen, appartementen en boutique hotels'
  end

  def default_meta_description
    return 'We have selected the finest villas, holiday homes, apartments and boutique hotels. Our team offers you dependable service &amp; the best rates guaranteed. Explore our exceptional collection in Italy, France, Spain and Portugal.' if locale == :en
    'Wij hebben de mooiste vakantiehuizen, appartementen en boutique hotels geselecteerd. Of u nu op zoek bent naar een luxe villa, stijlvolle vakantiewoning of een boutique hotel, dit is de collectie die u moet bekijken bij het plannen en boeken van uw vakantie. Ons team helpt u graag!'
  end

  def languages
    [[t('locale.en'),'en'], [t('locale.nl'),'nl']]
  end

  def render_logo_tag
    logo = current_page?(root_path) || current_page?(root_en_path) || current_page?(root_nl_path) ? 'logo_white_small.png' : 'site-logo.png'
    image_tag(logo, class: "site-logo")
  end
end
