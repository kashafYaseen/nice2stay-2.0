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
    @lodgings = (Ahoy::Event.where("name = ? and time >= ? ", 'Lodgings Search', 1.month.ago).where_props(action: 'show').group("properties -> 'id'").count).sort_by { |k,v| -v }.first(10)
    render layout: false
  end

  collection_action :bookings_per_month do
    @bookings = [
      {name: "Total", data: Booking.confirmed.not_by_partners.group_by_month(:created_at, last: 12).sum("pre_payment + final_payment")},
      {name: "By Customers", data: Booking.confirmed.customer.group_by_month(:created_at, last: 12).sum("pre_payment + final_payment")},
      {name: "By Nice2Stay", data: Booking.confirmed.nice2stay.group_by_month(:created_at, last: 12).sum("pre_payment + final_payment")},
    ]

    render layout: false
  end

  collection_action :bookings_per_day do
    @bookings = [
      {name: "Total", data: Booking.confirmed.not_by_partners.group_by_day(:created_at, last: 30, format: "%d %b").sum("pre_payment + final_payment")},
      {name: "By Customers", data: Booking.confirmed.customer.group_by_day(:created_at, last: 30, format: "%d %b").sum("pre_payment + final_payment")},
      {name: "By Nice2Stay", data: Booking.confirmed.nice2stay.group_by_day(:created_at, last: 30, format: "%d %b").sum("pre_payment + final_payment")},
    ]

    render layout: false
  end
end
