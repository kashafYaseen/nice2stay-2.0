ActiveAdmin.register User, as: "UserCharts" do
  menu false

  collection_action :users_by_month do
    @users = User.group_by_month(:created_at, range: '2019-01-1'.to_date..Time.now).count
    render layout: false
  end

  collection_action :users_by_login do
    @users = User.group(:creation_status).count
    render layout: false
  end

  collection_action :users_by_socials do
    @users = SocialLogin.group(:provider).count
    render layout: false
  end

  collection_action :users_visits do
    @users = Ahoy::Visit.group_by_day(:started_at).count
    render layout: false
  end

  collection_action :top_lodgings do
    @lodgings = (Ahoy::Event.where("name = ? and time >= ? ", 'Lodgings Search', 1.month.ago).where_props(action: 'show').group("properties -> 'id'").count).sort_by { |k,v| -v }.first(10)#Ahoy::Visit.group_by_day(:started_at).count
    render layout: false
  end
end
