module DiscountsHelper
  def reinder_discount(discount)
    return "#{discount.value}%" if discount.discount_type == "percentage"
    "€#{discount.value}"
  end
end
