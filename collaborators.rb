require 'octokit'

Octokit.auto_paginate = true

class Collaborator
  def self.add(repo_name:, issue_num:, team_num:)
    # Get Issue Commenters and Add as Collaborators
    successfully_added_users = []
    current_collaborators = get_current_collaborators(repo_name)
    begin
      client.issue_comments(repo_name, issue_num).each do |comment|
        userPending = false
        username = comment[:user][:login]
        puts "adding #{username}"
        next if current_collaborators[username] # skip adding if already a collaborator
        begin
        next if client.team_membership(team_num, username)
        rescue Octokit::NotFound
          puts "do nothing, add the user"
        end
        if user_added = client.add_team_membership(team_num, username, options={role: 'member'})
          puts "added #{username}"
          successfully_added_users << username
        else
          puts "Failed to add #{username} as a collaborator (check: is githubteacher repository owner?)"
        end # ends if chain
      end # ends loop
    rescue Octokit::NotFound
      abort "[404] - Repository not found:\nIf #{repo_name || "nil"} is correct, are you using the right Auth token?"
    rescue Octokit::UnprocessableEntity
      abort "[422] - Unprocessable Entity:\nAre you trying to add collaborators to an org-level repository?"
    end #ends block

    if successfully_added_users.any?
      begin
        names = "@#{successfully_added_users.first}"
        verb  = "is"
        num   = "a"
        noun  = "member"

        if successfully_added_users.size > 1
          verb  = "are"
          num   = ""
          noun  = "members"

          if successfully_added_users.size == 2
            names = "@#{successfully_added_users.first} and @#{successfully_added_users.last}"
          else
            at_mentions = successfully_added_users.map { |name| "@#{name}" }
            names = "#{at_mentions[0...-1].join(", ")}, and #{at_mentions[-1]}"
          end
        end

        message = ":tada: #{names} #{verb} now #{num} team #{noun}. :balloon: Please [accept the invitation](https://github.com/orgs/cop1000/invitation) or use the link in your email."
        client.add_comment repo_name, issue_num, message
      rescue => e
        abort "ERR posting comment (#{e.inspect})"
      end
    end
  end

  def self.access_token
    ENV['POSTER_TOKEN'] || raise("You need an access token")
  end

  def self.client
    @_client ||= Octokit::Client.new :access_token => access_token
  end

  def self.get_current_collaborators(repo_name)
    Hash[client.collaborators(repo_name).map { |collaborator|
      [collaborator[:login], collaborator[:login]]
    }]
  end
end
