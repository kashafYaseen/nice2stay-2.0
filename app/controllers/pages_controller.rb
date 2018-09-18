class PagesController < ApplicationController
  def home
    @reviews = Review.homepage.page(params[:page]).per(2)
    @lead = Lead.new
  end
end
