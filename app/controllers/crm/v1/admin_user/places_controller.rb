class Crm::V1::AdminUser::PlacesController < Crm::V1::ApiController
  respond_to :html, :js

  before_action :place_find, only: [:update, :edit, :destroy]

  def index
    render json: Crm::V1::PlaceSerializer.new(Place.all).serialized_json, status: :ok
  end

  def new
  end

  def create
    # @geo = true       #this is to enable the geo-location attributes (lat, long) on FE input form
    @place = Place.new(place_params)
    if @place.save
      set_image_sequence if !params[:sequence].blank?
      render json: Crm::V1::PlaceSerializer.new(@place).serialized_json, status: :ok
    else
      @geo = true
      unprocessable_entity(@place.errors)
    end
  end

  def edit
  end

  def update
    # @geo = true       #this is to enable the geo-location attributes (lat, long) on FE input form
    if @place.update(place_params)
      set_image_sequence if !params[:sequence].blank?
      render json: Crm::V1::PlaceSerializer.new(@place).serialized_json, status: :ok
    else
      unprocessable_entity(@place.errors)
    end
  end

  def destroy
    @place.destroy
    render json: { removed: @place.destroyed? }, status: :ok
  end

  def place_image
    if params[:place_id]
      @place = Place.find_by(slug: params[:place_id])
      @image = @place.images.create!(:image => params[:file])
    else
      @image = Image.create!(:image => params[:file])
    end
    @count = params[:count]
    @length = params[:length]
  end

  def image_delete
    @image = Image.find(params[:image_id])
    @image.delete
  end

  private

    def place_find
      @place = Place.friendly.find(params[:id])
    end

    def place_params
      params.require(:place).permit(
        :short_desc_nav,
        :short_desc,
        :header_dropdown,
        :name,
        :country_id,
        :region_id,
        :place_category_id,
        :description,
        :address,
        :spotlight,
        :publish,
        :slug,
        :location_attributes => [:lat, :lon, :id]
      )
    end

    #save image
    def set_image_sequence
      params[:sequence].each_with_index do |id,index|
        @image = Image.find(id)
        @image.sequence = index unless @image.sequence.to_i == index
        @image.imagable_id = @place.id unless @image.imagable_id
        @image.imagable_type = @place.class.to_s unless @image.imagable_type
        @image.save!
      end
    end
end