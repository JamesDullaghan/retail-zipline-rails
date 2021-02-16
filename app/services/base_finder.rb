class BaseFinder
	# Map the returned members and set the uuid for re-insertion into a new CSV
	def perform
		collection.map do |member|
			member.set_uuid
		end
	end

	def collection
		raise NotImplementedError, 'Please implement the collection method'
	end
end