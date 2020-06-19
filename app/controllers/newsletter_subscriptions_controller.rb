class NewsletterSubscriptionsController < ApplicationController
  def create
    subscription = NewsletterSubscription.find_or_initialize_by(newsletter_subscription_params)
    subscription.language = locale
    subscription.save
    redirect_to root_path, notice: "Welcome! thanks for subscribing!"
  end

  private
    def newsletter_subscription_params
      params.require(:newsletter_subscription).permit(
        :email,
      )
    end
end
