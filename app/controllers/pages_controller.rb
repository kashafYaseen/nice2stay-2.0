class PagesController < ApplicationController
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
  end

  def over_ons
  end
end
