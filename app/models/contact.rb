require 'securerandom'

class Contact < ApplicationRecord
	scope :emails, -> (value) do
	  where(
	  	'contacts.email LIKE (:value) OR contacts.email1 LIKE (:value) OR contacts.email2 LIKE (:value)',
	  	{ value: "%#{value}%" }
  	)
	end

	scope :phones, -> (value) do
	  where(
	  	'contacts.phone LIKE (:value) OR contacts.phone1 LIKE (:value) OR contacts.phone2 LIKE (:value)',
	  	{ value: "%#{value}%" }
  	)
	end

	scope :both, -> (value) { emails(value).or(phones(value)) }

	# Convenience method for email compare
	#
	# @param [filename] filename for use with comparator
	# @param [value] value for use with the comparator
	#
	# Examples:
	#
	# Contact.email_compare(filename: 'input1', value: '@home.com')
	def self.email_compare(filename:, value:)
		compare(filename: filename, type: 'email', value: value)
	end

	# Convenience method for phone compare
	#
	# @param [filename] filename for use with comparator
	# @param [value] value for use with the comparator
	#
	# Examples:
	#
	# Contact.phone_compare(filename: 'input1', value: '1-855-404-7690')
	def self.phone_compare(filename:, value:)
		compare(filename: filename, type: 'phone', value: value)
	end

	# Convenience method for the phone or email comparators
	#
	# @param [filename] filename for use with comparator
	# @param [value] value for use with the comparator
	#
	# Examples:
	#
	# Contact.both_compare(filename: 'input1.csv', value: '@home.com')
	def self.both_compare(filename:, value:)
		compare(filename: filename, type: 'both', value: value)
	end

	# One file at a time
	# Fuzzy match on columns for a partial match inside of file provided
	#
	# @param [filename] filename for use with comparator

	# @param [value] value for use with the comparator
	# @param [type] value for selection of matching service
	#
	# Examples:
	#
	# Contact.compare(filename: 'input1', type: 'email', value: '@home.com')
	# Contact.compare(filename: 'input2', type: 'phone', value: '@home.com')
	# Contact.compare(filename: 'input3', type: 'both', value: '1-855-404-7690')
	def self.compare(filename:, type:, value:)
		service = ComparatorService.new(
			filename: filename,
			type: type,
			value: value
		)

		service.perform
	end

	# Set the UUID column for matched records!
	def set_uuid
		self[:uuid] = SecureRandom.uuid
		save(validate: false)
		self
	end
end