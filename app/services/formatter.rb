class Formatter
	# Implement some kind of further phone verification for twilio
	# https://www.twilio.com/verify
	def self.sanitize_phone(value)
		return unless value.present?

		value.gsub(/\D/, '')
	end

	# Implement some kind of email verification as well as validation
	# https://github.com/kamilc/email_verifier/blob/master/lib/email_verifier/checker.rb#L56
	def self.sanitize_email(value)
		return unless value.present?

		EmailAddress.canonical(value)
	end

	def self.sanitize_value(value)
		return unless value.present?

		digits = value.gsub(/\D/, '').to_i
		return sanitize_email(value) if digits.zero?

		sanitize_phone(value)
	end
end