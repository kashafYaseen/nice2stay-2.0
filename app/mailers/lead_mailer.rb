class LeadMailer < ApplicationMailer
  def send_offers(user_id, lead_id)
    @user = User.find_by_id(user_id)
    @lead = @user.leads.find_by(id: lead_id)
    @owner = @lead.admin_user

    local = @user.language.presence || :nl

    I18n.with_locale(local.downcase) do
      bootstrap_mail(
        from: @owner.email,
        to: @user.email,
        cc: "support@nice2stay.com",
        subject: "Special offers for you"
      )
    end
  end
end
