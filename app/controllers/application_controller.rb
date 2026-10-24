class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?
  around_action :switch_locale

  rescue_from ActiveRecord::RecordNotFound do
    redirect_to root_path, alert: I18n.t("flash.not_found")
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_user!
    return if logged_in?

    redirect_to new_session_path, alert: I18n.t("flash.sign_in_required")
  end

  helper_method :biker?, :admin?

  def biker?
    current_user&.role == "biker"
  end

  def admin?
    current_user&.role == "admin"
  end

  def switch_locale(&action)
    requested_locale = params[:locale].presence || session[:locale] || I18n.default_locale
    locale = I18n.available_locales.map(&:to_sym).include?(requested_locale.to_sym) ? requested_locale.to_sym : I18n.default_locale
    session[:locale] = locale.to_s
    I18n.with_locale(locale, &action)
  end
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
