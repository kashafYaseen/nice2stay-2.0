class ManageMollieCustomer
  attr_reader :user
  attr_reader :customer

  def initialize(user)
    @user = user
    @customer = find_or_create
  end

  private
    def find_or_create
      return Mollie::Customer.get(user.mollie_id, api_key: ENV['MOLLIE_API_KEY']) if user.mollie_id?
      create
    end

    def create
      customer = Mollie::Customer.create(api_key: ENV['MOLLIE_API_KEY'], name: user.full_name, email: user.email)
      user.update_column :mollie_id, customer.id
      return customer
    end
end
