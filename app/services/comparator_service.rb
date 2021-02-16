require 'csv'

class ComparatorService
	def initialize(filename:, type:, value:)
		@filename = filename
		@type = type
		@value = value
	end

	def perform
		File.delete(filepath) if File.exist?(filepath)

    accum = []

		# Import the CSV provided
    ::CSV.foreach(path, headers: true) do |row|
    	attributes = CsvParser.new(row: row).perform
      accum << attributes
    end

		# Insert everything in a way that is performant
    ::Contact.bulk_insert do |worker|
      accum.each { |attrs| worker.add(attrs) }
    end

		# Find the partial matches in the finder with provided value operating on imported records
		# Either phone_finder, email_finder or both_finder
		data = "#{type}_finder".classify.constantize.new(value: value).perform
		# After data has been funged with found records, we are going to re-export!
		generate_csv(filename: filename)
		# Cleanup all data after the fact
		::Contact.delete_all
		# Taking iti back to 0
	  ActiveRecord::Base.connection.reset_sequence!('contacts', 'id')
	end

	private

	attr_reader :filename, :type, :value

	def filepath
		Rails.root.join('test', 'fixtures', 'files', "#{filename}.csv")
	end

	def path
		Rails.root.join('test', 'fixtures', 'files', 'originals', "#{filename}.csv")
	end

  def to_csv(filename:)
    CSV.generate(headers: true) do |csv|
    	# Modify headers back to original state
      csv << csv_attributes[filename].map { |header| header.to_s.classify }

      ::Contact.all.each do |member|
        csv << csv_attributes[filename].map do |attr|
        	member.send(attr)
        end
      end
    end
  end

  def generate_csv(filename:)
    filepath = Rails.root.join('test', 'fixtures', 'files', "#{filename}.csv")

    File.open(filepath, 'w') do |file|
      file.write(to_csv(filename: filename))
    end
  end

	def csv_attributes
		{
			input1: %i(uuid first_name last_name phone email zip),
			input2: %i(uuid first_name last_name phone1 phone2 email1 email2 zip),
			input3: %i(uuid first_name last_name phone1 phone2 email1 email2 zip)
		}.with_indifferent_access
	end
end