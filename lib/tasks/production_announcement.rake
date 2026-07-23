desc 'Generate the production release announcement for the team chat'
task :production_announcement do
  require 'json'

  def deploy_range
    # Production tip is a merge of main into production: its second parent is the deployed main commit
    deployed = `git show -s --pretty=%P production | cut -d " " -f 2`.strip
    exit unless $?.success?
    if `git log --merges --oneline #{deployed}..main`.strip.empty?
      # Nothing new on main: announce the last deploy instead
      previously_deployed = `git show -s --pretty=%P production^1 | cut -d " " -f 2`.strip
      [previously_deployed, deployed]
    else
      [deployed, 'main']
    end
  end

  def merged_pr_numbers(range)
    `git log --merges --pretty=%s #{range.join('..')}`.scan(/pull request #(\d+)/).flatten
  end

  def fetch_pr(pr_number)
    query = "{ repository(owner: \"betagouv\", name: \"conseillers-entreprises\") { pullRequest(number: #{pr_number}) { number title body closingIssuesReferences(first: 10) { nodes { title labels(first: 10) { nodes { name } } } } } } }"
    response = `gh api graphql -f query='#{query}' 2> /dev/null`
    return nil unless $?.success?
    JSON.parse(response).dig('data', 'repository', 'pullRequest')
  end

  def describe_pr(pr)
    issues = pr['closingIssuesReferences']['nodes'].map do |issue|
      "Issue liée : #{issue['title']} — labels : #{issue['labels']['nodes'].pluck('name').join(', ')}"
    end
    ["## PR ##{pr['number']} : #{pr['title']}", *issues, pr['body'].to_s[0, 1500]].join("\n")
  end

  def generate_announcement(digest)
    prompt = File.read(File.expand_path('production_announcement_prompt.md', __dir__))
    output = IO.popen(['claude', '-p'], 'r+') do |io|
      io.write("#{prompt}\n\n---\n\n#{digest}")
      io.close_write
      io.read
    end
    output if $?.success?
  rescue Errno::ENOENT
    nil
  end

  range = deploy_range
  puts "Generating announcement for #{range.join('..')}…"

  prs = merged_pr_numbers(range).filter_map{ |number| fetch_pr(number) }
  if prs.empty?
    puts 'Could not fetch the PR details (is gh installed and authenticated?). Exiting.'
    exit
  end

  announcement = generate_announcement(prs.map{ |pr| describe_pr(pr) }.join("\n\n"))
  if announcement
    puts announcement
  else
    puts 'claude CLI unavailable, falling back to the raw PR list:'
    prs.each{ |pr| puts "* [##{pr['number']}](https://github.com/betagouv/conseillers-entreprises/pull/#{pr['number']}) #{pr['title']}" }
  end
end
