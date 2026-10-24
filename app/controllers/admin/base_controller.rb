module Admin
  class BaseController < ApplicationController
    before_action :require_user!
    before_action :require_admin!

    private

    def require_admin!
      return if current_user&.role == "admin"

      redirect_to root_path, alert: "No tienes permiso para acceder al panel."
    end
  end
end
