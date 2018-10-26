require 'sidekiq/web'

authenticate :admin_user, lambda { |u| u.present? } do
  mount Sidekiq::Web => '/sidekiq'
end
