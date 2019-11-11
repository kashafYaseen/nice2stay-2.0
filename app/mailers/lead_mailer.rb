class LeadMailer < ApplicationMailer
  def send_offers(user_id, lead_id)
    @send_us_email = "mailto:finance@nice2stay.com"
    @user = User.find_by_id(user_id)
    @lead = @user.leads.find_by(id: lead_id)

    local = @user.language.presence || :nl

    I18n.with_locale(local.downcase) do
      make_bootstrap_mail(to: @user.email, subject: "Special offers for you")
    end
  end
end
