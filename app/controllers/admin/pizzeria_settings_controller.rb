module Admin
  class PizzeriaSettingsController < BaseController
    def edit
      @setting = PizzeriaSetting.instance
    end

    def update
      @setting = PizzeriaSetting.instance
      if @setting.update(setting_params)
        redirect_to admincp_path, notice: "Pizzeria location updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def setting_params
      params.require(:pizzeria_setting).permit(:address, :latitude, :longitude)
    end
  end
end
