# Gitweb2GitLab

A migration script written in Ruby that scrapes a gitweb instance and moves all its repositories to a GitLab instance.

This code is quick and dirty. It's not pretty. It's not elegant. In a nutshell, it:

* Uses Nokogiri to find all the repo names on the gitweb home page
* Uses Nokogiri again to access each repo summary page in gitweb to get the description
* Clones each repo (uses SSh, so gitolite or equivalent is assumed)
* Uses RestClient to create a GitLab project
* Sets up the GitLab server as a remote in the new clone
* Pushes the dev and master branches and all tags to GitLab
* Sets some branch permissions and manipulates the project's users
* Rinse and repeat

As mentioned, no style points will be awarded, but this got the job done for me with about 200 projects.

## Dependencies

* Gitlab >5.0
* Ruby 1.9.3
* Nokogiri, RestClient, and JSON gems
* A gitweb instance to migrate from (duh)

## Notes

Look up `ssh-agent`; it is your friend and will remember your SSH key passphrase for you.

Change the handy slugs to suit your environment:
```ruby
# Handy global slugs
gitlab_url = 'http://rocketsquawk.dyndns.org/api/v3/'
api_key = 'oWMTPkERQxKcTenV2aNT'
gitweb_url = 'http://git/git'
```
#### gitlab_url

The URL to your GitLab instance including the API version number

#### api_key

Use the GitLab admin user's API key

#### gitweb_url

The URL to your gitweb instance

## Oh, and ...

No, none of the URLs or API keys in this script are valid anymore :P
