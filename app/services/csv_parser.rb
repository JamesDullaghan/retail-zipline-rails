class CsvParser
	def initialize(row: row)
		@row = row.
			to_hash.
			deep_transform_keys! { |key| key.to_s.underscore }.
			with_indifferent_access
	end

	# Can contain either of the following
	# FirstName,LastName,Phone,Email,Zip
	# FirstName,LastName,Phone1,Phone2,Email1,Email2,Zip
	def perform
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
    attributes
	end

	private

	attr_reader :row

	def email
		Formatter.sanitize_email(row.fetch(:email, nil))
	end

	def email1
		Formatter.sanitize_email(row.fetch(:email1, nil))
	end

	def email2
		Formatter.sanitize_email(row.fetch(:email2, nil))
	end

	def phone
		Formatter.sanitize_phone(row.fetch(:phone, nil))
	end

	def phone1
		Formatter.sanitize_phone(row.fetch(:phone1, nil))
	end

	def phone2
		Formatter.sanitize_phone(row.fetch(:phone2, nil))
	end

	def first_name
		row.fetch(:first_name, nil)
	end

	def last_name
		row.fetch(:last_name, nil)
	end

	def zip
		row.fetch(:zip, nil)
	end
end