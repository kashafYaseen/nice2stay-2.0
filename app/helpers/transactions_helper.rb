module TransactionsHelper
  def is_checked?(value)
    params[:transaction_type_in].present? && params[:transaction_type_in].include?(value.to_s)
  end
end
