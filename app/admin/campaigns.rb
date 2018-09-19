ActiveAdmin.register Campaign do
  permit_params :title, :slug, :crm_urls, :url, :article_spotlight, :description, :slider_desc, :price, :slider, :spotlight, :popular_search, :popular_homepage, :collection

  index do
    selectable_column
    id_column
    column :title
    column :url
    column :article_spotlight
    column :slider
    column :spotlight
    column :popular_search
    column :popular_homepage
    column :collection

    actions
  end

  show do
    attributes_table do
      row :title
      row :slug
      row :crm_urls
      row :url
      row :article_spotlight
      row :publish
      row :images
      row :description
      row :slider_desc
      row :price
      row :slider
      row :spotlight
      row :popular_search
      row :popular_homepage
      row :collection
      row :thumbnails
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  form do |f|
    inputs 'Rule' do
      f.input :title
      f.input :slug
      f.input :crm_urls
      f.input :url
      f.input :article_spotlight
      f.input :description
      f.input :slider_desc
      f.input :price
      f.input :slider
      f.input :spotlight
      f.input :popular_search
      f.input :popular_homepage
      f.input :collection
    end

    f.actions do
      f.action :submit
    end
  end
end
