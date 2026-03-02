class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Require authentication for all actions by default
  before_action :authenticate_user!

  # Configure permitted parameters for Devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # Shared authorization helpers (feature 012-team-member-autonomy)
  # Reject if current user is not a member of the given team.
  def authorize_team_member_on!(team)
    return if team.members.include?(current_user)
    redirect_to teams_path, alert: I18n.t("authorization.not_team_member")
  end

  # Reject if current user is not the organizer of the given team.
  def authorize_team_organizer_on!(team)
    return if team.organizer == current_user
    redirect_to team, alert: I18n.t("authorization.organizer_only")
  end
end
