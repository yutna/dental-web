module Auth
  class SessionsController < ApplicationController
    def new
      redirect_to root_path if signed_in?
    end

    def create
      snapshot = Security::SignIn.call(
        username: session_params[:username],
        password: session_params[:password]
      )
      Security::SessionStore.new(session:).persist!(snapshot:)

      redirect_to root_path, notice: t("auth.sessions.signed_in")
    rescue Security::SignIn::InvalidCredentialsError
      @username   = session_params[:username]
      @auth_error = t("auth.sessions.invalid_credentials")
      render :new, status: :unprocessable_content
    rescue Security::SignIn::ServiceUnavailableError
      @username   = session_params[:username]
      @auth_error = t("auth.sessions.service_unavailable")
      render :new, status: :unprocessable_content
    rescue Backend::Errors::ContractMismatchError => e
      @username   = session_params[:username]
      @auth_error = t("auth.sessions.contract_mismatch", message: e.message)
      render :new, status: :unprocessable_content
    end

    def destroy
      Security::SignOut.call(session:)
      redirect_to root_path, notice: t("auth.sessions.signed_out")
    end

    private

    def session_params
      params.permit(:username, :password)
    end
  end
end
