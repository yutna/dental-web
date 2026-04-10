class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_locale
  before_action :hydrate_current_principal
  before_action :ensure_fresh_session!

  helper_method :current_principal, :signed_in?

  rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized

  private

  def set_locale
    I18n.locale = locale_from_params || I18n.default_locale
  end

  def locale_from_params
    locale = params[:locale]
    return if locale.blank?

    locale = locale.to_sym
    locale if I18n.available_locales.include?(locale)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def hydrate_current_principal
    session_snapshot = Security::SessionStore.new(session:).read
    Current.principal = session_snapshot.principal
  end

  def ensure_fresh_session!
    return unless signed_in?

    result = Security::RefreshSession.call(session:)
    hydrate_current_principal if result == :refreshed
  rescue Security::RefreshSession::RefreshFailedError
    Security::SessionStore.new(session:).clear!
    redirect_to new_session_path, alert: t("auth.sessions.session_expired")
  end

  def current_principal
    Current.principal || Security::Principal.guest
  end

  def signed_in?
    !current_principal.guest?
  end

  def require_signed_in!
    return if signed_in?

    redirect_to new_session_path
  end

  def pundit_user
    current_principal
  end

  def handle_not_authorized
    redirect_params = {}
    redirect_params[:reason] = "workspace_denied" if controller_name == "workspace"

    redirect_to root_path(redirect_params), alert: t("auth.sessions.not_authorized")
  end
end
