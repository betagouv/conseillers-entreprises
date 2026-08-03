require_relative 'production_helpers'

PRODUCTION_ANNOUNCEMENT_SECTION_BY_LABEL = {
  '🧑‍🏭 entreprises' => :entreprises,
  '🧑‍🔧 partenaires' => :partenaires,
  '👩‍💻 équipe CE' => :equipe,
  'tech | maintenance' => :tech
}.freeze

PRODUCTION_ANNOUNCEMENT_SECTION_TITLES = {
  entreprises: '**🧑‍🏭 Pour les entreprises**',
  partenaires: '**🧑‍🔧 Pour les partenaires**',
  equipe: "**👩‍💻 Pour l'équipe**",
  tech: "**⚙️ Tech** — *pas d'impact visible*"
}.freeze

PRODUCTION_ANNOUNCEMENT_BUG_LABEL = '🐛 bug'

# Builds and prints the release announcement. Callable directly with
# already-fetched PRs (used by push_to_production.rake to avoid re-fetching
# the same PRs from the GitHub API), or run standalone as a rake task.
module ProductionAnnouncement
  class << self
    def second_parent(ref)
      parents = `git show -s --pretty=%P #{ref}`.strip
      unless $?.success?
        puts "ERROR: git show failed for #{ref} (does the branch exist locally?). Exiting."
        exit
      end
      parents.split(' ')[1]
    end

    def deploy_range
      # Production tip is a merge of main into production: its second parent is the deployed main commit
      deployed = second_parent('production')
      if `git log --merges --oneline #{deployed}..main`.strip.empty?
        # Nothing new on main: announce the last deploy instead
        previously_deployed = second_parent('production^1')
        [previously_deployed, deployed]
      else
        [deployed, 'main']
      end
    end

    def merged_pr_numbers(range)
      `git log --merges --pretty=%s #{range.join('..')}`.scan(/pull request #(\d+)/).flatten
    end

    # Deterministic classification from the closing issues' labels. Returns nil
    # when no unambiguous label matched, meaning Claude has to decide instead.
    def classify_section(pr)
      labels = ProductionHelpers.closing_issues_labels(pr)
      PRODUCTION_ANNOUNCEMENT_SECTION_BY_LABEL.each do |label, section|
        return section if labels.include?(label)
      end
      nil
    end

    def describe_pr(pr)
      issues = pr['closingIssuesReferences']['nodes'].map do |issue|
        "Issue liée : #{issue['title']} — labels : #{issue['labels']['nodes'].pluck('name').join(', ')}"
      end
      is_bug = ProductionHelpers.closing_issues_labels(pr).include?(PRODUCTION_ANNOUNCEMENT_BUG_LABEL)
      lines = ["## PR ##{pr['number']} : #{pr['title']}", *issues]
      lines << 'Label : 🐛 bug' if is_bug
      [*lines, pr['body'].to_s[0, 1500]].join("\n")
    end

    # Groups PRs by their deterministic section, so Claude only has to write the
    # announcement lines and classify the few PRs left without a clear label.
    def build_digest(prs)
      by_section = prs.group_by{ |pr| classify_section(pr) }

      sections = PRODUCTION_ANNOUNCEMENT_SECTION_TITLES.filter_map do |key, title|
        section_prs = by_section[key]
        next if section_prs.blank?
        "### Section : #{title}\n\n#{section_prs.map{ |pr| describe_pr(pr) }.join("\n\n")}"
      end

      unclassified = by_section[nil]
      if unclassified.present?
        sections << "### À classer toi-même dans une des sections ci-dessus\n\n#{unclassified.map{ |pr| describe_pr(pr) }.join("\n\n")}"
      end

      sections.join("\n\n")
    end

    def generate_announcement(digest)
      prompt = File.read(File.expand_path('production_announcement_prompt.md', __dir__))
      output = IO.popen(['claude', '-p'], 'r+') do |io|
        io.write("#{prompt}\n\n---\n\n#{digest}")
        io.close_write
        io.read
      end
      output if $?.success? && output.present?
    rescue Errno::ENOENT
      nil
    end

    # prs: optional pre-fetched PR hashes (as returned by ProductionHelpers.fetch_pr),
    # to avoid re-fetching them when the caller already has them (see push_to_production.rake).
    def run(from: nil, to: nil, prs: nil)
      if prs.nil?
        range = from && to ? [from, to] : deploy_range
        puts "Generating announcement for #{range.join('..')}…"

        pr_numbers = merged_pr_numbers(range)
        prs = pr_numbers.filter_map{ |number| ProductionHelpers.fetch_pr(number) }
        if prs.empty?
          puts 'Could not fetch the PR details (is gh installed and authenticated?). Exiting.'
          exit
        end

        missing = pr_numbers.map(&:to_i) - prs.map{ |pr| pr['number'] }
        puts "WARNING: could not fetch #{missing.size} PR(s), they will be missing from the announcement: #{missing.join(', ')}" if missing.any?
      end

      announcement = generate_announcement(build_digest(prs))
      if announcement
        puts announcement
      else
        puts 'claude CLI unavailable, falling back to the raw PR list:'
        prs.each{ |pr| puts "* [##{pr['number']}](https://github.com/betagouv/conseillers-entreprises/pull/#{pr['number']}) #{pr['title']}" }
      end
    end
  end
end

desc "Generate the production release announcement for the team chat. Optional args: [from,to] commit range, e.g. rake 'production_announcement[abc123,def456]' to test by hand"
task :production_announcement, [:from, :to] do |_t, args|
  ProductionAnnouncement.run(from: args[:from], to: args[:to])
end
