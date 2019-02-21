namespace :lint do
  task(:rubocop) { sh 'rubocop' }
  task(:haml) { sh 'haml-lint --report progress' }
  task(:i18n) { sh 'i18n-tasks health' }
  task(:brakeman) { sh 'brakeman --quiet' }

  task all: %i[rubocop haml i18n brakeman]
end

task lint: %w[lint:all]
