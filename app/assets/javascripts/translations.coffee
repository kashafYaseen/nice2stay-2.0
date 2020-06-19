(->
  window.Translation or (window.Translation = {})

  Translation.init = (default_locale, current_locale) ->
    I18n.defaultLocale = default_locale
    I18n.locale = current_locale

).call this
