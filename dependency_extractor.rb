require "./git_connector.rb"
require "./repository.rb"
require "./dependency.rb"
require "./dependency_parser_xml.rb"
require "./dependency_parser_gradle.rb"
require "json"

class Extractor
	attr_reader :access_token, :login, :org_name, :connector, :xml_parser, :gradle_parser

	def initialize login, access_token, org_name, api_endpoint
		@access_token = access_token
		@login = login
		@org_name = org_name
		@connector = GitConnector.new api_endpoint, @login, @access_token
		@xml_parser = XmlDependencyParser.new
		@gradle_parser = GradleDependencyParser.new
	end

	def extract
		repositories = []
		(@connector.org_repositories @org_name).each do |repo|
			content = get_pom_xml repo
			repo_name = repo[:name]
			repo_full_name = repo[:full_name]
			repo_type = "none"
			dependencies = []
			if content != nil
				repo_type = "maven"
				dependencies = @xml_parser.parse content
			elsif ((content = get_build_gradle repo) != nil)
				repo_type = "gradle"
				dependencies = @gradle_parser.parse content
			end
			repositories << (Repository.new repo_name, repo_full_name, repo_type, dependencies)
		end
		return repositories
	end

	def get_pom_xml repo
		content = nil
		begin
			hash_content = Octokit.content(repo[:full_name],
			:login => @login,
			:access_token => @access_token,
			:path => 'pom.xml');
			content= Base64.decode64(hash_content[:content])
		rescue
			content = nil
		end
		return content
	end

	def get_build_gradle repo
		content = nil
		begin
			hash_content = Octokit.content(repo[:full_name],
			:login => @login,
			:access_token => @access_token,
			:path => "build.gradle");
			content = Base64.decode64(hash_content[:content])
		rescue
			content = nil
		end
		return content
	end
end
