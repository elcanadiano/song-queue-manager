module BandsHelper
  # Determines if the current user is a band admin.
  def is_band_admin?(band_id)
    member = Member.find_by({
      user_id: current_user.id,
      band_id: band_id
    })
  end
end
