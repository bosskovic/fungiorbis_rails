module V1
  module CustomDevise
    class ConfirmationsController < Devise::ConfirmationsController
      respond_to :json

      # GET /resource/confirmation?confirmation_token=abcdef
      def show
        self.resource = User.confirm_by_token(params[:confirmation_token])

        yield resource if block_given?

        if resource.errors.empty?
          render file: 'v1/custom_devise/sessions/create', locals: { current_user: resource, no_token: true }
        else
          render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: {errors: resource.errors.full_messages}
        end
      end

    end
  end
end