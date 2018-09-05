class DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"
  add_breadcrumb "Dashboard", :dashboard_path

  def index
    @title = 'Dashboard'
  end
end
