module GuestCentricHelper
  def get_centric_param(key)
    params[key] || params[:reservation].present? ? params[:reservation][key] : nil
  end

  def render_guest_centric_images child, options = {}
    return image_tag image_path('default-lodging.png'), options unless child['fullImages'].present?
    tags = ''
    child['fullImages'].each { |image_path|  tags << image_tag(image_path, options) }
    tags.html_safe
  end

  def money_string_to_float value
    value.gsub('.', '').gsub(',', '.').to_f
  end

  def gc_cancel_policy cancel_policy
    return unless cancel_policy.present? && cancel_policy['cancelPolicyRules'].present?
    return t('guest_centric.cancellation_policy_1', amount: cancel_policy['cancelPolicyRules'][0]['AmountValue']) if cancel_policy['cancelPolicyRules'][0]['BeforeDays'] == '999'
    t('guest_centric.cancellation_policy_2', amount: cancel_policy['cancelPolicyRules'][0]['AmountValue'], days: cancel_policy['cancelPolicyRules'][0]['BeforeDays'])
  end
end
