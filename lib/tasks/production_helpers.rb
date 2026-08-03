require 'json'

# Shared between production_announcement.rake and push_to_production.rake to
# avoid making a separate gh api graphql call per PR from each task.
module ProductionHelpers
  def self.fetch_pr(pr_number)
    query = "{ repository(owner: \"betagouv\", name: \"conseillers-entreprises\") { pullRequest(number: #{pr_number}) { number title body closingIssuesReferences(first: 10) { nodes { title labels(first: 10) { nodes { name } } } } } } }"
    response = `gh api graphql -f query='#{query}' 2> /dev/null`
    return nil unless $?.success?
    JSON.parse(response).dig('data', 'repository', 'pullRequest')
  rescue JSON::ParserError
    nil
  end

  def self.closing_issues_labels(pr)
    pr['closingIssuesReferences']['nodes'].flat_map{ |issue| issue['labels']['nodes'].pluck('name') }.uniq
  end
end
