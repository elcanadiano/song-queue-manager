module EventsHelper
  # Default text for band selection in a Song Request.
  def bands_default_blank
    admin? ? "Select or Enter Band" : "Select Band"
  end
end
