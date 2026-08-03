require_relative 'production_helpers'

desc 'Setup and push reviewed code to production'
task :push_to_production do
  require 'highline/import'

  def fetch_main_and_production
    puts 'Updating main and production…'
    `git fetch origin -u main:main production:production`
    unless $?.success?
      puts 'ERROR: git fetch failed. Exiting.'
      exit
    end
  end

  def find_last_production_commit_on_main
    parents = `git show -s --pretty=%P production`.strip
    unless $?.success?
      puts 'ERROR: git show failed for production (does the branch exist locally?). Exiting.'
      exit
    end
    commit = parents.split(' ')[1]
    puts "Last production commit is #{commit}"
    commit
  end

  def retrieve_merge_commits_messages(last_commit)
    separator = '--------'
    messages = `git log --merges --pretty=%B#{separator} #{last_commit}..main`
    messages.split(separator)[0...-2]
  end

  def pr_number_and_title(message)
    message.match(/.*pull request #(?<pr>\d+).*\n*(?<title>.*)/)
  end

  # Fetches each merged PR once: its data is reused both for the confirmation
  # prompt preview below and for the production announcement afterwards.
  def fetch_merged_prs(messages)
    messages
      .filter_map{ |message| pr_number_and_title(message) }
      .filter_map{ |parts| ProductionHelpers.fetch_pr(parts['pr']) }
  end

  # Labels of the issues closed by the PR (bug, entreprises…), to give more context in the confirmation prompt
  def format_pr(pr)
    pull_request_url = 'https://github.com/betagouv/conseillers-entreprises/pull/'
    labels = ProductionHelpers.closing_issues_labels(pr).map{ |label| "`#{label}`" }.join(' ')
    "* [##{pr['number']}](#{pull_request_url}#{pr['number']}) #{pr['title'].strip} #{labels}".strip
  end

  def prompt_for_confirmation(prs)
    puts "About to merge #{prs.count} PRs and push to production:"
    puts '🚀 '
    puts prs.map{ |pr| format_pr(pr) }.join("\n")
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
    unless $?.success?
      puts 'ERROR: merge of main into production failed (conflict?). Repo is left on the production branch — resolve or abort the merge manually.'
      exit
    end
  end

  def push_to_production
    `git push origin production`
    unless $?.success?
      puts 'ERROR: git push to production failed. Exiting.'
      exit
    end
    puts 'Done!'
  end

  ensure_clean_working_tree
  fetch_main_and_production

  last_commit = find_last_production_commit_on_main
  merge_messages = retrieve_merge_commits_messages(last_commit)
  prs = fetch_merged_prs(merge_messages)
  prompt_for_confirmation(prs)

  ensure_clean_working_tree
  merge_main_to_production
  push_to_production

  ProductionAnnouncement.run(prs: prs)
end
