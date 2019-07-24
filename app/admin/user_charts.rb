ActiveAdmin.register User, as: "UserCharts" do
  menu false

  collection_action :users_by_month do
    @users = User.group_by_month(:created_at, range: '2019-01-1'.to_date..Time.now).count
    render layout: false
  end

  collection_action :users_by_login do
    @users = (User.group(:creation_status).count).merge((SocialLogin.group(:provider).count))
    render layout: false
  end
end
