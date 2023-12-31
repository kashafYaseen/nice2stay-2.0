ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel 'Bookings per Day', class: 'async-panel', 'data-url': bookings_per_day_admin_user_charts_path
      end
    end

    br br

    columns do
      column do
        panel 'Bookings per Month', class: 'async-panel', 'data-url': bookings_per_month_admin_user_charts_path
      end
    end

    br br

    columns do
      column do
        panel 'User Registrations per Month', class: 'async-panel', 'data-url': users_by_month_admin_user_charts_path
      end
    end

    br br

    columns do
      column do
        panel 'User Visits per Month', class: 'async-panel', 'data-url': users_visits_admin_user_charts_path
      end
    end

    br br

    columns do
      column do
        panel 'Lodging Popularity of Last 30 Days', class: 'async-panel', 'data-url': top_lodgings_admin_user_charts_path
      end
    end

    br br

    columns do
      column do
        panel 'Registrations By Login Types', class: 'async-panel', 'data-url': users_by_login_admin_user_charts_path
      end

      column do
        panel 'Registrations By Social Media', class: 'async-panel', 'data-url': users_by_socials_admin_user_charts_path
      end
    end
  end
end
