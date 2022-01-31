class NewsletterSubscriptionsController < ApplicationController
  def create
    @subscription = NewsletterSubscription.find_or_initialize_by(newsletter_subscription_params)
    @subscription.language = locale
    redirect_to root_path, notice: "Welcome! thanks for subscribing!" if verify_recaptcha(model: @subscription) && @subscription.save
  end

  private
    def newsletter_subscription_params
      params.require(:newsletter_subscription).permit(:email, :name)
    end
end
