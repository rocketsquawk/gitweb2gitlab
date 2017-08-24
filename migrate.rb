require 'nokogiri'
require 'open-uri'
require 'rest_client'
require 'json'

## Let's pretend this is FOO-3 feature code
## And this is FOO-4 automated tests

# Handy global slugs
gitlab_url = 'http://rocketsquawk.dyndns.org/api/v3/'
api_key = 'oWMTPkERQxKcTenV2aNT'
gitweb_url = 'http://git/git'

begin
	gitweb_home = Nokogiri::HTML(open(gitweb_url))
rescue
	puts "Something very bad happened; I couldn't even connect to the Git server."
end

gitweb_home.css('a.list').each do |project|
	# We only care about the nodes that have git repo names
	if project.content.end_with?('.git')
		
		begin
			# Some handy project-level slugs
			p = project.content.chomp('.git')
			cd = 'cd ' + p + ' && '
			
			# Get the repo description
			proj_page = Nokogiri::HTML(open(gitweb_url + '/?p=' + project.content + ';a=summary'))
			desc = proj_page.css('tr#metadata_desc').inner_text.gsub(/\Adescription/, '')
			
			# Clone the repo and switch to dev branch
			system('git clone git@git:' + p)
			system(cd + 'git checkout dev')

			# Create project in GitLab
			r = RestClient.post(gitlab_url + 'projects', \
				{:name => p, :description => desc, :namespace_id => 'GLN'}, \
				{:'PRIVATE-TOKEN' => api_key})

			# Get the project ID from the JSON response
			id =JSON.parse(r)["id"]

			# Add user_id 2 (ricky) to the project team
			# One could make an API call to discover the user_id, but I already know it
			RestClient.post(gitlab_url + 'projects/' + id.to_s + '/members', \
				{:id => id, :user_id => '2', :access_level => '40'}, \
				{:'PRIVATE-TOKEN' => api_key})

			# Add GitLab as a remote and push 
			system(cd + 'git remote add gitlab git@rocketsquawk.dyndns.org:' + \
				p.downcase.gsub('.', '-') + '.git') # If your repos have periods in their names, you need this
			system(cd + 'git push -u gitlab --all')
			system(cd + 'git push -u gitlab --tags')
			
			# Lock down the master branch
			RestClient.put(gitlab_url + 'projects/' + id.to_s + \
					'/repository/branches/master/protect', \
				{:id => id, :branch => 'master'}, \
				{:'PRIVATE-TOKEN' => api_key})
		rescue => e 
			puts "### WOOPS! ### Something went wrong: " + e.message
		end
	end
end

