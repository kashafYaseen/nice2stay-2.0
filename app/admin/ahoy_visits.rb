ActiveAdmin.register Ahoy::Visit do
  actions :index, :show
  menu parent: 'Track', label: 'Visits'

  filter :user
  filter :device_type
  filter :started_at

  index do
    selectable_column
    id_column
    column :user
    column :ip
    column :landing_page, class: "max-width-400"
    column :device_type
    column :started_at

    actions
  end
end
