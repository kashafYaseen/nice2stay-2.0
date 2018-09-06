class LodgingsController < ApplicationController
  before_action :set_lodging, only: [:show, :edit, :update, :destroy]
  before_action :set_parent, only: [:show]

  # GET /lodgings
  # GET /lodgings.json
  def index
    @lodgings = SearchLodgings.call(params)
  end

  # GET /lodgings/1
  # GET /lodgings/1.json
  def show
    @reservation = @lodging.reservations.build
    @reviews = @lodging.reviews.page(params[:page]).per(2)
    @lodging_children = @lodging.lodging_children.includes(:availabilities) if @lodging.as_parent?
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
    @lodging = Lodging.find(params[:values].split(',')[-1])
    results = @lodging.price_details(params[:values].split(','))

    if @lodging.flexible_search
      @rates = results.map{ |result| result[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }}
      @search_params = results.map{ |result| result[:search_params] }
      @valid = results.map{ |result| result[:valid] }
    else
      @rates = results[:rates].inject(Hash.new(0)){ |h, i| h[i]+=1; h }
      @search_params = results[:search_params]
      @valid = results[:valid]
    end
    @discount = @lodging.discount_details(params[:values].split(','))
  end

  def snippet_params
    params.require(:lodging).permit(:street, :city, :zip, :state, :beds, :baths, :sq__ft, :sale_date, :price, :latitude, :longitude)
  end

 def autocomplete
    search_data = Lodging.search(params[:query], {
      fields: ["name"],
      match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 5}
    }).map{ |lodging| { name: lodging.name, id: lodging.id, type: 'lodging', url: lodging_path(lodging.slug, locale: locale) } }

    search_data += Campaign.search(params[:query], {
      fields: ["title"],
      match: :word_start,
      limit: 10,
      load: false,
      misspellings: {below: 5}
    }).map{ |campaign| { name: campaign.title, id: campaign.id, type: 'campaign', url: campaign.url } }

    render json: search_data
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lodging
      @lodging = Lodging.friendly.find(params[:id])
    end

    def set_parent
      @lodging = @lodging.parent if @lodging.parent.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lodging_params
      params.require(:lodging).permit({images: []}, :street, :city, :zip, :state, :beds, :baths, :sq__ft, :sale_date, :price, :latitude, :longitude, :adults, :children, :infants, :lodging_type, :owner_id)
    end
end
