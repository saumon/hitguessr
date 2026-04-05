module Hitguessr
  module MailerSettings
    module_function

    def smtp_settings
      {
        address: setting(:smtp, :address, env: "SMTP_ADDRESS"),
        port: integer_setting(:smtp, :port, env: "SMTP_PORT"),
        domain: setting(:smtp, :domain, env: "SMTP_DOMAIN"),
        user_name: setting(:smtp, :user_name, env: "SMTP_USERNAME"),
        password: setting(:smtp, :password, env: "SMTP_PASSWORD"),
        authentication: symbol_setting(:smtp, :authentication, env: "SMTP_AUTHENTICATION", default: :plain),
        enable_starttls_auto: boolean_setting(:smtp, :enable_starttls_auto, env: "SMTP_ENABLE_STARTTLS_AUTO", default: true),
        openssl_verify_mode: setting(:smtp, :openssl_verify_mode, env: "SMTP_OPENSSL_VERIFY_MODE")
      }.compact
    end

    def smtp_configured?
      required_keys = %i[address port user_name password]
      required_keys.all? { |key| smtp_settings[key].present? }
    end

    def default_url_options(default_host:, default_port: nil, default_protocol: nil)
      {
        host: setting(:app, :host, env: "APP_HOST", default: default_host),
        port: integer_setting(:app, :port, env: "APP_PORT", default: default_port),
        protocol: setting(:app, :protocol, env: "APP_PROTOCOL", default: default_protocol)
      }.compact
    end

    def mailer_sender(default:)
      setting(:smtp, :sender, env: "SMTP_SENDER") ||
        setting(:mailer, :sender, env: "MAILER_SENDER") ||
        default
    end

    def setting(namespace, key, env:, default: nil)
      ENV[env].presence || Rails.application.credentials.dig(namespace, key).presence || default
    end

    def integer_setting(namespace, key, env:, default: nil)
      value = setting(namespace, key, env: env, default: default)
      value.present? ? value.to_i : nil
    end

    def boolean_setting(namespace, key, env:, default: nil)
      value = setting(namespace, key, env: env, default: default)
      return value if value == true || value == false
      return default if value.nil?

      ActiveModel::Type::Boolean.new.cast(value)
    end

    def symbol_setting(namespace, key, env:, default: nil)
      value = setting(namespace, key, env: env, default: default)
      value.present? ? value.to_sym : nil
    end

    # Feature toggle for account email confirmation (T009).
    # Resolution precedence: ENV ACCOUNT_EMAIL_CONFIRMATION_ENABLED → credentials features.account_email_confirmation_enabled → default.
    # Expected defaults: development = false, test/production = true.
    def confirmation_feature_enabled?(default:)
      boolean_setting(:features, :account_email_confirmation_enabled,
                      env: "ACCOUNT_EMAIL_CONFIRMATION_ENABLED",
                      default: default)
    end
  end
end
