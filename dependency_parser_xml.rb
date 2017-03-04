require"./dependency_parser.rb"
require'nokogiri'

class XmlDependencyParser < DependencyParser
	def parse script
		return "maven"
	end
end
