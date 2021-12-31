class Dashboard::VouchersController < DashboardController
  def index
    @title = 'Vouchers'
    add_breadcrumb @title, dashboard_vouchers_path

    @unsed_vouchers = current_user.vouchers_unsed.page(params[:unsed_vouchers_page]).per(5)
    @old_vouchers = current_user.vouchers_old.page(params[:old_vouchers_page]).per(5)
  end
end
