require 'json'

class Dependency
	attr_reader :group_id, :artifact_id, :version, :scope

	def initialize(group_id, artifact_id, version, scope)
		@group_id = group_id
		@artifact_id = artifact_id
		@version = version
		@scope = scope
	end

	def to_hash
		return {"group_id" => @group_id, "artifact_id" => @artifact_id, "version" => @version, "scope" => @scope}
	end

	def to_json(options = {})
		return JSON.generate(to_hash, options)
	end
end
