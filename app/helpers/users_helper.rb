module UsersHelper

  def check_athourity
    if current_user.tier1? or current_user.customer? or current_user.organization?
      true
    end
  end

end
