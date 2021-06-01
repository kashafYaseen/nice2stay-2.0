class ManageMollieCustomer
  include MollieCredentials
  attr_reader :user,
              :customer,
              :params

  def initialize(user, params = nil)
    @user = user
    @customer = find_or_create
    @params = params
  end

  private
    def find_or_create
      return Mollie::Customer.get(user.mollie_id, api_key: api_key(params.present? && params[:requesting_site])) if user.mollie_id?
      create
    end

    def create
      customer = Mollie::Customer.create(name: user.full_name, email: user.email)
      user.update_column :mollie_id, customer.id
      return customer
    end
end
