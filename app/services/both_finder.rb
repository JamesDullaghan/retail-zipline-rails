class BothFinder < BaseFinder
	attr_reader :value

	def initialize(value:)
		@value = Formatter.sanitize_value(value)
	end

	# Fuzzy search both records based on provided value
	# def perform; end

	private

	def collection
		Contact.both(value)
	end
end