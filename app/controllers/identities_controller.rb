class IdentitiesController < ApplicationController

  def destroy
    provider = params.require(:provider)
    identity = Identity.find_by_provider_and_user_id(provider, current_user.id)
    identity.destroy
    redirect_to root_url, notice: "Disconnect!"
  end
end
