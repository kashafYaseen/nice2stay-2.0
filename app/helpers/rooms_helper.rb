module RoomsHelper
  def is_checked?(value)
    params[:room_type_in].present? && params[:room_type_in].include?(value.to_s)
  end
end
