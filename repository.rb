require 'json'

class Repository
	attr_reader :name, :full_name, :build_tool, :dependencies

	def initialize(name, full_name, build_tool, dependencies)
		@name = name
		@full_name = full_name
		@dependencies = dependencies
		@build_tool = build_tool
	end

	def to_hash
		return {"name" => @name, "full_name" => @full_name, "build_tool" => @build_tool, "dependencies" => @dependencies}
	end

	def to_json(options = {})
		return JSON.generate(to_hash, options)
	end
end
