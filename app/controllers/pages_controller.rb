class PagesController < ApplicationController
  def home
    @reviews = Review.homepage
  end
end
