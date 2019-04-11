ActiveAdmin.register Ahoy::Visit do
  actions :index, :show
  menu parent: 'Track', label: 'Visits'

  index do
    selectable_column
    id_column
    column :user
    column :ip
    column :landing_page
    column :device_type
    column :started_at

    actions
  end
end
