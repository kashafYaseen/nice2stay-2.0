ActiveAdmin.register Review do
  permit_params :stars, :setting, :quality, :interior, :communication, :service, :suggetion, :title, :published, :perfect, :anonymous
end
