module UsersHelper
  def render_user_image(user, options = {})
    return image_tag(user.image_url, options) if user.image?
    image_tag('avatar.png', options)
  end
end
