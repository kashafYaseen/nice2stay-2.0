ActiveAdmin.register Review do
  permit_params :stars, :setting, :quality, :interior, :communication, :service, :suggetion, :title, :published, :perfect, :anonymous, :description

  filter :lodging
  filter :user
  filter :published
  filter :perfect
  filter :anonymous
  filter :created_at

  controller do
    def scoped_collection
      Review.includes(:translations, :reservation, :user, lodging: :translations)
    end
  end

  index do
    selectable_column
    id_column
    column :lodging
    column :user
    column :stars
    column :reservation
    column :published
    column :anonymous
    column :photos do |review|
      review.photos.attached? || review.thumbnails.present?
    end
    actions
  end

  show do
    attributes_table do
      row :lodging
      row :user
      row :reservation
      row :quality
      row :interior
      row :setting
      row :communication
      row :service
      row :published
      row :anonymous
      row :perfect
      row :description
      row :suggetion
      row :updated_at
      row :created_at

      row :photos do |review|
        photo_tags = ""
        review.photos.each do |photo|
          photo_tags += image_tag(photo, class: 'thumb')
        end if review.photos.attached?

        review.thumbnails.each do |photo|
          photo_tags += image_tag(photo, class: 'thumb')
        end if review.thumbnails.present?
        photo_tags.try :html_safe
      end
    end

    active_admin_comments
  end

  form do |f|
    inputs 'Review' do
      f.input :lodging, input_html: { disabled: true }
      f.input :user, input_html: { disabled: true }
      f.input :reservation_id, input_html: { disabled: true }
      f.input :title
      f.input :quality
      f.input :interior
      f.input :setting
      f.input :communication
      f.input :service
      f.input :published
      f.input :anonymous
      f.input :perfect
      f.input :description
      f.input :suggetion
    end

    f.actions do
      f.action :submit
    end
  end
end
