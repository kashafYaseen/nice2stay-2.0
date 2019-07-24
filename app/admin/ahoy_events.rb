ActiveAdmin.register Ahoy::Event do
  actions :index, :show
  menu parent: 'Track', label: 'Events'

  filter :user
  filter :name
end
