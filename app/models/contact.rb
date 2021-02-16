require 'securerandom'
require 'csv'

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
		filepath = Rails.root.join('test', 'fixtures', 'files', "#{filename}.csv")

		if File.exist?(filepath)
			File.delete(filepath)
		end
		# service = ComparisonService.new(filename: filename, type: type, value: value).perform
    path = Rails.root.join('test', 'fixtures', 'files', 'originals', "#{filename}.csv")
    accum = []

		# Import the CSV provided
    ::CSV.foreach(path, headers: true) do |row|
    	row = row.to_hash.deep_transform_keys! { |key| key.to_s.underscore }.with_indifferent_access

			email  = Formatter.sanitize_email(row.fetch(:email, nil))
			email1 = Formatter.sanitize_email(row.fetch(:email1, nil))
			email2 = Formatter.sanitize_email(row.fetch(:email2, nil))

			phone  = Formatter.sanitize_phone(row.fetch(:phone, nil))
			phone1 = Formatter.sanitize_phone(row.fetch(:phone1, nil))
			phone2 = Formatter.sanitize_phone(row.fetch(:phone2, nil))

			first_name = row.fetch(:first_name, nil)
			last_name  = row.fetch(:last_name, nil)
			zip        = row.fetch(:zip, nil)

			# Can contain either of the followingi
			# FirstName,LastName,Phone,Email,Zip
			# FirstName,LastName,Phone1,Phone2,Email1,Email2,Zip
      attributes = {
      	first_name: first_name,
      	last_name: last_name,
      	phone: phone,
      	phone1: phone1,
      	phone2: phone2,
      	email: email,
      	email1: email1,
      	email2: email2,
      	zip: zip
      }

      attributes = attributes.delete_if { |k, v| v.nil? }
      accum << attributes
    end

    ::Contact.bulk_insert do |worker|
      accum.each do |attrs|
        worker.add(attrs)
      end
    end

		# Find the partial matches in the finder with provided value operating on imported records
		# Either phone_finder, email_finder or both_finder
		data = "#{type}_finder".classify.constantize.new(value: value).perform

		# After data has been funged with found records, we are going to re-export!
		generate_csv(filename: filename)
		# Cleanup all data after the fact
		Contact.delete_all
		# Taking iti back to 0
	  ActiveRecord::Base.connection.reset_sequence!('contacts', 'id')
	end

	# Set the UUID column for matched records!
	def set_uuid
		self[:uuid] = SecureRandom.uuid
		save(validate: false)
		self
	end

	private

  def self.to_csv(filename:)
    CSV.generate(headers: true) do |csv|
    	# Modify headers back to original state
      csv << csv_attributes[filename].map { |header| header.to_s.classify }

      all.each do |member|
        csv << csv_attributes[filename].map do |attr|
        	member.send(attr)
        end
      end
    end
  end

  def self.generate_csv(filename:)
    filepath = Rails.root.join('test', 'fixtures', 'files', "#{filename}.csv")

    File.open(filepath, 'w') do |file|
      file.write(to_csv(filename: filename))
    end
  end

	def self.csv_attributes
		{
			input1: %i(uuid first_name last_name phone email zip),
			input2: %i(uuid first_name last_name phone1 phone2 email1 email2 zip),
			input3: %i(uuid first_name last_name phone1 phone2 email1 email2 zip)
		}.with_indifferent_access
	end
end