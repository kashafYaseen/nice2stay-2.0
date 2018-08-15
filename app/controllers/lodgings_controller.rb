class LodgingsController < ApplicationController
  before_action :set_lodging, only: [:show, :edit, :update, :destroy, :price_details]

  # GET /lodgings
  # GET /lodgings.json
  def index
    @lodgings = SearchLodgings.call(params)
    @regions = Region.names_with_country
  end

  # GET /lodgings/1
  # GET /lodgings/1.json
  def show
    @reservation = @lodging.reservations.build
    @reviews = @lodging.reviews.page(params[:page]).per(2)
  end

  # GET /lodgings/new
  def new
    @lodging = Lodging.new
  end

  # GET /lodgings/1/edit
  def edit
  end

  # POST /lodgings
  # POST /lodgings.json
  def create
    @lodging = Lodging.new(lodging_params)

    respond_to do |format|
      if @lodging.save
        format.html { redirect_to @lodging, notice: 'Lodging was successfully created.' }
        format.json { render :show, status: :created, location: @lodging }
      else
        format.html { render :new }
        format.json { render json: @lodging.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lodgings/1
  # PATCH/PUT /lodgings/1.json
  def update
    respond_to do |format|
      if @lodging.update(lodging_params)
        format.html { redirect_to @lodging, notice: 'Lodging was successfully updated.' }
        format.json { render :show, status: :ok, location: @lodging }
      else
        format.html { render :edit }
        format.json { render json: @lodging.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lodgings/1
  # DELETE /lodgings/1.json
  def destroy
    @lodging.destroy
    respond_to do |format|
      format.html { redirect_to lodgings_url, notice: 'Lodging was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def price_details
    rates = @lodging.price_details(params[:values].split(','))
    render json: { rates: rates.inject(Hash.new(0)){ |h, i| h[i]+=1; h }, discount: @lodging.discount_details(params[:values].split(',')) }
  end

  def snippet_params
    params.require(:lodging).permit(:street, :city, :zip, :state, :beds, :baths, :sq__ft, :sale_date, :price, :latitude, :longitude)
  end

  

  

 def autocomplete
    render json: Lodging.searchable.search(params[:query], {
      fields: ["name"],
      match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 5}
    }).map(&:name)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lodging
      @lodging = Lodging.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lodging_params
      params.require(:lodging).permit({images: []}, :street, :city, :zip, :state, :beds, :baths, :sq__ft, :sale_date, :price, :latitude, :longitude, :adults, :children, :infants, :lodging_type, :owner_id)
    end
end
