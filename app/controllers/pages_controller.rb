class PagesController < ApplicationController
  def home
    @all_reviews = Review.homepage
    @reviews = @all_reviews.includes(:user, :translations, :reservation).page(params[:page]).per(2)
    @lead = Lead.new
  end
end
