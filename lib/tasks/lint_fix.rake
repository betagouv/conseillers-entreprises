namespace :lint_fix do
  desc 'run rubocop linter'
  task(:rubocop) { sh 'rubocop -a' }

  desc 'run i18n normalize'
  task(:i18n) { sh 'i18n-tasks normalize' }

  task all: %i[rubocop i18n]
end

desc 'run all rubocop, i18n and fix'
task lint_fix: %w[lint_fix:all]
