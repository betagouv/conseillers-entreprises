# Counts real SQL queries issued inside a block, ignoring schema/transaction statements and cached queries
class QueryCounter
  IGNORED_STATEMENTS = /\A\s*(BEGIN|COMMIT|ROLLBACK|SAVEPOINT|RELEASE|SET|SHOW)/i
  IGNORED_NAMES = %w[SCHEMA TRANSACTION].freeze

  def self.count(&block)
    counter = new
    counter.count(&block)
  end

  def count
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      payload = args.last
      next if payload[:cached]
      next if IGNORED_NAMES.include?(payload[:name])
      next if payload[:sql].to_s.match?(IGNORED_STATEMENTS)

      queries += 1
    end

    yield
    queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
