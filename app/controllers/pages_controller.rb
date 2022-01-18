class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:home]

  def show
    add_breadcrumb "Home", :root_path
    @page = Page.friendly.find(params[:id])
    @title = @page.title
    add_breadcrumb @title, page_path(@page)
  end

  def home
    @all_reviews = Review.homepage
    @reviews = @all_reviews.includes(:user, :translations, :reservation).page(review_page).per(2)
    @lead = Lead.new
    @lodgings = Lodging.home_page
    @custom_texts = CustomText.home_page
    @campaigns = Campaign.spotlight
    @slider_campaigns = Campaign.menu
    @regions = Region.active
    flash.now[:notice] = 'Voucher was created successfully.' if params[:code].present?
  end

  def page_not_found
  end

  def loader
    render layout: false
  end

  private
    def review_page
      return params[:page] if params[:page].present?
      1
    end
end
