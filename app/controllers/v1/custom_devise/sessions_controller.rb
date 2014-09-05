module V1
  module CustomDevise
    class SessionsController < Devise::SessionsController
      respond_to :json

      acts_as_token_authentication_handler_for User, fallback_to_devise: false
      skip_before_filter :authenticate_entity_from_token!, only: [:create]
      skip_before_filter :authenticate_entity!, only: [:create]

      ACCOUNT_DEACTIVATED_ERROR = 'Account deactivated. Please reactivate the account before signing in.'

      # POST /users/sign_in
      def create
        allow_params_authentication!
        self.resource = warden.authenticate!(auth_options)

        if resource.active?
          reset_token resource
          render file: 'v1/custom_devise/sessions/create', locals: { no_token: false }
        else
          render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: [ACCOUNT_DEACTIVATED_ERROR] }
        end
      end


      # DELETE /users/sign_out
      def destroy
        warden.authenticate!
        reset_token current_user
      end

      private

      def sign_in_params
        params.fetch(:user).permit([:password, :email])
      end

      def reset_token(resource)
        resource.authentication_token = nil
        resource.save!
      end
    end
  end
end