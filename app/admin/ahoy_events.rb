ActiveAdmin.register Ahoy::Event do
  actions :index, :show
  menu parent: 'Track', label: 'Events'
end
