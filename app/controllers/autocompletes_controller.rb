class AutocompletesController < ApplicationController
  def index
    render json: GetAutocompleteData.call(params, locale)
  end
end
