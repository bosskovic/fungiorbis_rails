module V1
  module CustomDevise
    class RegistrationsController < Devise::RegistrationsController
      include CamelCaseConvertible

      respond_to :json

      acts_as_token_authentication_handler_for User, fallback_to_devise: false
      skip_before_filter :authenticate_entity_from_token!, only: [:create]
      skip_before_filter :authenticate_entity!, only: [:create]

      # POST /users
      def create
        build_resource(param_keys_to_snake_case(sign_up_params))
        resource.role = User::USER_ROLE

        if resource.save
          sign_up(resource_name, resource)
          render file: 'v1/custom_devise/registrations/create', status: :created
        else
          clean_up_passwords resource
          render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: {errors: resource.errors.full_messages}
        end
      end


      # DELETE /users/UUID
      def destroy
        resource.deactivated_at = DateTime.now
        resource.save!
        Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      end

      private

      def sign_up_params
        params.fetch(:user).permit([:password, :passwordConfirmation, :email, :firstName, :lastName])
      end

    end
  end
end
