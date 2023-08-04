class Crm::V1::AdminUser::OwnersController < Crm::V1::AdminUser::ApiController

before_action :set_owner, only: %i[edit update destroy resend_invitation]

def index
  @q = Owner.ransack(first_name_or_last_name_cont: params[:query])
  @pagy, @records = pagy(@q.result(distinct: true), items: params[:items], page: params[:page], items: params[:per_page])

  render json: Crm::V1::OwnerSerializer.new(@records).serializable_hash.merge(count: @q.result.count), status: :ok
end

def new
  render json: Crm::V1::AdminUserSerializer.new(AdminUser.all).serializable_hash, status: :ok
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
    render json: Crm::V1::RegionSerializer.new(@owner).serialized_json, status: :ok
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

private

  def set_owner
    @owner = Owner.find(params[:id])
  end

  def owner_params
    params.require(:owner).permit(
      :first_name,
      :last_name,
      :email,
      :pre_payment,
      :final_payment,
      :admin_user_id
    )
  end

end
