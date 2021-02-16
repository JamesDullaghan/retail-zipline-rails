# One that matches records with the same email address
class EmailFinder < BaseFinder
  def initialize(value:)
		@value = Formatter.sanitize_email(value)
	end

	# We need to find all the partial match records and update those record UUID columns
	# def perform; end

	private

	attr_reader :value

	def collection
		Contact.emails(value)
	end
end