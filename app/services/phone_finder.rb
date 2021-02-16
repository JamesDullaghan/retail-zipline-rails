class PhoneFinder < BaseFinder
	def initialize(value:)
		@value = Formatter.sanitize_phone(value)
	end

	# Fuzzy find matching records with the phone number provided
	# def perform; end

	private

	attr_reader :value

	def collection
		Contact.phones(value)
	end
end