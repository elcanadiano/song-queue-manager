module BandsHelper
  # Checks to see if you can manage the member. Criteria is one of:
  #
  # - Current user is a band admin AND the member is not currently the current
  #   user.
  # - Current user is a user admin.
  #
  # WARNING: This does not check to see if the member is not an admin, which is
  # required, so you must do this separately.
  def can_manage_member?(member)
    admin? || (@current_member && @current_member.is_admin? && !current_user?(member.user))
  end

  # Checks to see if you can manage the admin. Criteria is one of:
  #
  # - Member is the current user AND there are at least two admins.
  # - Current user is a user admin.
  #
  # WARNING: This does not check to see if the member is an admin, which is
  # required, so you must do this separately.
  def can_manage_admin?(member)
    admin? || (current_user?(member.user) && @num_admins >= 2)
  end

  def is_band_admin?
    admin? || (@current_member && @current_member.is_admin?)
  end
end
