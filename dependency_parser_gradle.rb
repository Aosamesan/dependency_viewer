require"./dependency_parser.rb"
require"./dependency.rb"

class GradleDependencyParser < DependencyParser
	def parse script
		# remove comments and split words
		words = []
		is_multiline_comment = false
		script.each_line do |line|
			line.split.each do |word|
				if word.match(/\/{2,}[^*]*/) # single line comment
					break
				elsif word.match(/\/{1,}[*]{1,}/) # start of multiline comment
					is_multiline_comment = true
				elsif word.match(/[*]{1,}\/{1,}/) # end of multiline comment
					is_multiline_comment = false
				elsif not is_multiline_comment
					words << word
				end
			end
		end

		# get dependencies
		property_map = {}
		dependency_list = []
		bracket_depth = 0
		is_dependencies = false
		is_property = false
		is_dependency = false
		property_key = nil
		property_value = nil
		previous_word = nil

		words.each do |word|
			if word == "dependencies"
				is_dependencies = true
			elsif word == "dependencies{"
				is_dependencies = true
				bracket_depth += 1
			elsif word == "{"
				bracket_depth += 1
			elsif word.match(/.*}/)
				bracket_depth -= 1
				if bracket_depth == 0
					break
				end
			end

			if is_dependencies
				if word == "def"
					is_property = true
				elsif word.match(/[Cc]ompile$/)
					is_dependency = true
				end

				if is_property
					if previous_word == "def"
						if word.match(/=$/)
							property_key = word.gsub(/=$/, "")
							word = "="
						else
							property_key = word
						end
					elsif previous_word == "=" and word.match(/^\$["']/)
						property_value = word.gsub(/["']/, "").gsub(/^\$/, "")
						property_map[property_key] = property_value
						is_property = false
					elsif word.match(/^=[^=]{1,}/)
						property_value = word.gsub(/=/,"").gsub(/["']/,"")
						property_map[property_key] = property_value
						is_property = false
					end
				elsif is_dependency
					if previous_word.match(/[Cc]ompile/)
						ids = word.gsub(/["']/, "").split(/:/)
						scope = previous_word.match(/^[Cc]ompile$/) ? "???" : previous_word.gsub(/[Cc]ompile$/, "")
						if ids[2].match(/^\$/)
							dependency_list << (Dependency.new ids[0], ids[1], property_map[ids[2].gsub(/^$/,"")], scope)
						else
							dependency_list << (Dependency.new ids[0], ids[1], ids[2], scope)
						end
						is_dependency = false
					end
				end
			end
			previous_word = word
		end

		return dependency_list
	end
end
