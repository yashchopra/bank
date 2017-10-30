class ApplicationController < ActionController::Base
  # before_action :set_cache_buster
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_cache_headers

  def user_not_authorized
  	flash[:alert] = "No no no, turn back."
  	redirect_to (request.referrer || root_path)
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end


  # private
  # def set_cache_buster
  #   response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
  #   response.headers["Pragma"] = "no-cache"
  #   response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  # end

end
