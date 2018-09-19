class PagesController < ApplicationController
  def home
    @all_reviews = Review.homepage.includes(:translations)
    @reviews = @all_reviews.page(params[:page]).per(2)
    @lead = Lead.new
  end
end
