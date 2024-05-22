desc 'Setup and push reviewed code to production'
task :push_to_production do
  require 'highline/import'

  def fetch_main_and_production
    puts 'Updating main and production…'
    `git fetch origin -u main:main production:production`
    exit unless $?.success?
  end

  def find_last_production_commit_on_main
    commit = `git show -s --pretty=%P production | cut -d " " -f 2`.strip
    exit unless $?.success?
    puts "Last production commit is #{commit}"
    commit
  end

  def retrieve_merge_commits_messages(last_commit)
    separator = '--------'
    messages = `git log --merges --pretty=%B#{separator} #{last_commit}..main`
    messages.split(separator)[0...-2]
  end

  def format_commit_messages(messages)
    def pr_number_and_title(message)
      message.match(/.*pull request #(?<pr>\d+).*\n*(?<title>.*)/)
    end

    def format_parts(parts)
      pull_request_url = 'https://github.com/betagouv/conseillers-entreprises/pull/'
      "* [##{parts['pr']}](#{pull_request_url}#{parts['pr']}) #{parts['title'].strip}"
    end

    messages
      .filter_map{ |message| pr_number_and_title(message) }
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

  def merge_main_to_production
    `git checkout production && git merge main --no-edit`
    exit unless $?.success?
  end

  def push_to_production
    `git push origin production`
    exit unless $?.success?
    puts 'Done!'
  end

  ensure_clean_working_tree
  fetch_main_and_production

  last_commit = find_last_production_commit_on_main
  merge_messages = retrieve_merge_commits_messages(last_commit)
  formatted = format_commit_messages(merge_messages)
  prompt_for_confirmation(formatted)

  ensure_clean_working_tree
  merge_main_to_production
  push_to_production
end
