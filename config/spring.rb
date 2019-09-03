# frozen_string_literal: true

%w[
  .ruby-version
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }

# For rubymine 2019.2 with rails 6.0.0
Spring.after_fork do
  if ENV['DEBUGGER_STORED_RUBYLIB']
    ENV['DEBUGGER_STORED_RUBYLIB'].split(File::PATH_SEPARATOR).each do |path|
      next unless /ruby-debug-ide/.match?(path)
      load path + '/ruby-debug-ide/multiprocess/starter.rb'
    end
  end
end
