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
    @reviews = @all_reviews.includes(:user, :translations, :reservation).page(params[:page]).per(2)
    @lead = Lead.new
    @lodgings = Lodging.home_page
    @custom_texts = CustomText.home_page
  end

  def over_ons
  end

  def page_not_found
  end
end
