module Auth
  class SessionsController < ApplicationController
    def new
      redirect_to workspace_path if signed_in?
    end

    def create
      snapshot = Security::SignIn.call(email: session_params[:email], password: session_params[:password])
      Security::SessionStore.new(session:).persist!(snapshot:)

      redirect_to workspace_path, notice: t("auth.sessions.signed_in")
    rescue Security::SignIn::InvalidCredentialsError
      @email = session_params[:email]
      flash.now[:alert] = t("auth.sessions.invalid_credentials")
      render :new, status: :unprocessable_content
    rescue Backend::Errors::ContractMismatchError => e
      @email = session_params[:email]
      flash.now[:alert] = t("auth.sessions.contract_mismatch", message: e.message)
      render :new, status: :unprocessable_content
    end

    def destroy
      Security::SignOut.call(session:)
      redirect_to root_path, notice: t("auth.sessions.signed_out")
    end

    private

    def session_params
      params.permit(:email, :password)
    end
  end
end
