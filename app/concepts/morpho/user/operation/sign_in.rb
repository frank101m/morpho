module Morpho
  class User::Operation::SignIn < Trailblazer::Operation
    step :validate
    fail :not_valid, fail_fast: true
    step :find
    fail :not_found, fail_fast: true
    step :check_active
    fail :not_active, fail_fast: true
    step :check_unlocked
    fail :locked, fail_fast: true
    step :check_password
    fail :wrong_password, fail_fast: true
    step :generate_refresh_token
    step :register_last_login_activity
    step :authentication_token

    def validate (options, **)
      options['contract'] = Morpho::User::Contract::SignIn.new(OpenStruct.new)
      options['contract'].validate(options['data'])
    end

    def find (options, **)
      options['model'] = Morpho::User.find_by(email: options['data']['email'])
    end

    def check_active (options, **)
      options['model'].active?
    end

    def check_unlocked (options, **)
      options['model'].unlocked?
    end

    def check_password (options, **)
      options['model'].valid_password?(options['data']['password'])
    end

    def generate_refresh_token (options, **)
      options['model'].generate_refresh_token!
    end

    def register_last_login_activity (options, **)
      options['model'].register_last_login_activity!(options['ip'])
    end

    def not_valid (options, **)
      options['error'] = :not_valid
    end

    def not_found (options, **)
      options['error'] = :not_found
    end

    def not_active (options, **)
      options['error'] = :not_active
    end

    def locked (options, **)
      options['error'] = :locked
    end

    def wrong_password (options, **)
      options['model'].register_failed_login!
      options['error'] = :wrong_password
    end

    def authentication_token (options, **)
      options['token'] = Morpho::JWT::Payload.new(options['model'])
    end
  end
end