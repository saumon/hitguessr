# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # Resend cooldown: one confirmation email per account every 5 minutes (T040).
  RESEND_COOLDOWN_SECONDS = 300

  # POST /users/confirmation
  # Resend confirmation instructions with anti-enumeration semantics (T039).
  # Returns an identical generic redirect regardless of whether the email is found,
  # already confirmed, or within the resend cooldown window.
  def create
    self.resource = resource_class.new
    email = params.dig(resource_name, :email).to_s.strip.downcase

    if email.present?
      user = resource_class.find_by(email: email)

      if user && !user.confirmed?
        if resend_throttled?(user)
          # Within cooldown window: log but give the same generic response (T040).
          log_confirmation_event(:resend_throttled, email)
        else
          # Send new confirmation instructions; Devise replaces the previous token (T041).
          user.resend_confirmation_instructions
          log_confirmation_event(:confirmation_email_resent, email)
        end
      elsif user&.confirmed?
        log_confirmation_event(:resend_for_already_confirmed, email)
      else
        log_confirmation_event(:resend_unknown_email, email)
      end
    end

    # Generic response regardless of actual outcome — prevents account enumeration (T039).
    set_flash_message(:notice, :send_paranoid_instructions)
    redirect_to new_user_session_path
  end

  # GET /users/confirmation?confirmation_token=TOKEN
  # Confirm account with explicit, localised success/failure feedback (T025).
  # Latest-token semantics are enforced by Devise's confirm_by_token (T041):
  # regenerating a token via resend invalidates all previous tokens.
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      log_confirmation_event(:confirmation_succeeded, resource.email)
      set_flash_message!(:notice, :confirmed)
      sign_in(resource_name, resource)
      redirect_to after_confirmation_path_for(resource_name, resource)
    else
      log_confirmation_event(:confirmation_failed_invalid_or_expired,
                             params[:confirmation_token].to_s.first(8))
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Returns true if the user's last confirmation email was sent within the cooldown window (T040).
  def resend_throttled?(user)
    user.confirmation_sent_at.present? &&
      user.confirmation_sent_at > RESEND_COOLDOWN_SECONDS.seconds.ago
  end

  # Structured audit log for confirmation lifecycle events (T042).
  # Events: confirmation_email_resent, confirmation_succeeded, confirmation_failed_invalid_or_expired,
  #         resend_throttled, resend_for_already_confirmed, resend_unknown_email.
  def log_confirmation_event(event, ref)
    Rails.logger.info "[confirmation] event=#{event} ref=#{ref}"
  end
end
