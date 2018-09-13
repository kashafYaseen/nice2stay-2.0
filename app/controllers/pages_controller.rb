class PagesController < ApplicationController
  def home
    @campaigns = Campaign.home_page
  end
end
