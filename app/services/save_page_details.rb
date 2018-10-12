class SavePageDetails
  attr_reader :params
  attr_reader :page

  def self.call(params)
    self.new(params).call
  end

  def initialize(params)
    @params = params
    @page = Page.find_or_initialize_by(slug: page_params[:slug])
  end

  def call
    save_page
    update_translations
    page
  end

  private
    def save_page
      page.attributes = page_params
      page.save
    end

    def update_translations
      return unless params[:translations].present?
      params[:translations].each do |translation|
        _translation = page.translations.find_or_initialize_by(locale: translation[:locale])
        _translation.attributes = translation_params(translation)
        _translation.save
      end
    end

    def page_params
      params.require(:page).permit(
        :title,
        :meta_title,
        :short_desc,
        :content,
        :category,
        :slug,
        :header_dropdown,
        :rating_box,
        :homepage,
        { images: [] }
      )
    end

    def translation_params(translation)
      translation.permit(
        :title,
        :meta_title,
        :short_desc,
        :content,
        :category,
        :slug,
        :locale,
      )
    end
end

