require 'octokit'
require 'base64'

class GitConnector
	attr_accessor :git_client

	def initialize api_endpoint, login, access_token
		Octokit.configure do |c|
			c.api_endpoint = api_endpoint
			c.auto_paginate = true
		end
		@git_client = Octokit::Client.new(:login => login, :access_token => access_token)
	end

	def my_repositories
		return (@git_client.repositories :user => @git_client.user)
	end

	def org_repositories org_name
		return (@git_client.org_repos org_name, {:type => "all"})
	end
end
