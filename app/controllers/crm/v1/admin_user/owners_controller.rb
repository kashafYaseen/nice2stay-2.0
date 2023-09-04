class Crm::V1::AdminUser::OwnersController < Crm::V1::AdminUser::ApiController

  before_action :set_owner, only: %i[edit update destroy resend_invitation ]

  def index
    if params[:active].to_boolean
      @q = ransack_search_translated(Owner.active_partners, :first_name_or_last_name_or_business_name, query: params[:query])

    elsif !params[:active].to_boolean
      @q = ransack_search_translated(Owner.inactive_partners, :business_name_or_email, query: params[:query])

    end

    @pagy, @records = pagy(@q.result, items: params[:items], page: params[:page], items: params[:per_page])
    render json: Crm::V1::OwnerSerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok

  end

  def new
    render json: {
      admin_users: Crm::V1::AdminUserSerializer.new(AdminUser.all).serializable_hash,
      countries: Crm::V1::CountrySerializer.new(Country.all).serializable_hash,
      regions: Crm::V1::RegionSerializer.new(Region.all).serializable_hash
    }, status: :ok

  end

  def edit
  end

  def create
    @owner = Owner.new(owner_params)
    if @owner.save
      @owner.invite!
      render json: Crm::V1::OwnerSerializer.new(@owner).serialized_json, status: :ok
    else
      unprocessable_entity(@owner.errors)
    end
  end

  def update
    if @owner.update(owner_params)
      render json: Crm::V1::OwnerSerializer.new(@owner).serialized_json, status: :ok
    else
      unprocessable_entity(@region.errors)
    end
  end

  def destroy
    @owner.destroy
    render json: { removed: @owner.destroyed? }, status: :ok
  end

  def resend_invitation
    if @owner.invitation_accepted_at.nil?
      @owner.invite!
      render json: 'Invitation sent successfully', status: :ok

    else
      render json: {error: 'Invitation already accepted'}, status: :unprocessable_entity
    end

  end

  def active_partners
    @q = ransack_search_translated(Owner, :first_name_or_last_name_or_business_name, query: params[:query])
    @pagy, @records = pagy(@q.result, items: params[:items], page: params[:page], items: params[:per_page])

    render json: Crm::V1::OwnerSerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok

  end

  def commissions
    @q = ransack_search_translated(Owner, :business_name, query: params[:query])

    @owners_commissions = Owner.commission_by_years.where(id: @q.result.pluck(:id))
    @pagy, @records = pagy(@owners_commissions, items: params[:items], page: params[:page], items: params[:per_page])
    calculate_commissions(@owners_commissions)
    render_commissions_response
  end

  private
    def set_owner
      @owner = Owner.find(params[:id])
    end

    def owner_params
      params.require(:owner).permit(
        :first_name,
        :last_name,
        :email,
        :admin_user_id,
        :not_interested,
        :updating_availability,
        :automated_availability,
        :language,
        :email_boolean,
        :country_id,
        :region_id,
        :business_name,
        :account_id
      )
    end

    def render_commissions_response
      render json: Crm::V1::OwnerCommissionsSerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok
    end
  end
