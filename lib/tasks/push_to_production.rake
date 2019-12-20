desc 'Setup and push reviewed code to production'
task :push_to_production do
  require 'json'
  require 'rest-client'
  require 'highline/import'

  def fetch_master_and_production
    puts 'Updating master and production…'
    `git fetch origin -u master:master production:production`
    exit unless $?.success?
  end

  def find_last_production_commit_on_master
    commit = `git show -s --pretty=%P production | cut -d " " -f 2`.strip
    exit unless $?.success?
    puts "Last production commit is #{commit}"
    commit
  end

  def retrieve_merge_commits_messages(last_commit)
    separator = '--------'
    messages = `git log --merges --pretty=%B#{separator} #{last_commit}..master`
    messages.split(separator)
  end

  def format_commit_messages(messages)
    def pr_number_and_title(message)
      message.match(/.*pull request #(?<pr>\d+).*\n*(?<title>.*)/)
    end

    def format_parts(parts)
      pull_request_url = 'https://github.com/betagouv/place-des-entreprises/pull/'
      "* [##{parts['pr']}](#{pull_request_url}#{parts['pr']}) #{parts['title'].strip}"
    end

    messages
      .map{ |message| pr_number_and_title(message) }
      .compact
      .map{ |parts| format_parts(parts) }
  end

  def prompt_for_confirmation(formatted)
    puts "About to merge #{formatted.count} PRs and push to production:"
    puts '🚀 '
    puts formatted.join("\n")
    if !agree("Proceed?")
      exit
    end
  end

  def ensure_clean_working_tree
    `git diff-index --quiet HEAD --`
    if !$?.success?
      puts 'Current working tree is dirty. Exiting.'
      exit
    end
  end

  def merge_master_to_production
    `git checkout production && git merge master --no-edit`
    exit unless $?.success?
  end

  def push_to_production
    `git push origin production`
    exit unless $?.success?
    puts 'Done!'
  end

  ensure_clean_working_tree
  fetch_master_and_production

  last_commit = find_last_production_commit_on_master
  merge_messages = retrieve_merge_commits_messages(last_commit)
  formatted = format_commit_messages(merge_messages)
  prompt_for_confirmation(formatted)

  ensure_clean_working_tree
  merge_master_to_production
  push_to_production
end
