class DashboardController < ApplicationController
  protect_from_forgery prepend: true, with: :exception

  before_action :authenticate_user!
  layout "dashboard"
  add_breadcrumb "Dashboard", :dashboard_path

  def index
    @title = 'Dashboard'
  end
end
