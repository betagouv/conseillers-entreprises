namespace :redis do
  desc "Show an analysis of the Redis keys"
  task analyze: :environment do
    @redis = Redis.new(url: ENV['REDIS_URL'])
    @stats = {
      total_keys: 0,
      expired_ttl: 0,
      idle_keys: 0,
      permanent_keys: 0,
      size_by_pattern_idle: Hash.new(0),
      size_by_pattern_expired: Hash.new(0),
      size_by_pattern_permanent: Hash.new(0)
    }
    @options = {
      idle_threshold: 86400 * 7 # 7 days
    }

    def analyze_keys
      cursor = 0

      loop do
        cursor, keys = @redis.scan(cursor, count: 1000)
        keys.each do |key|
          analyze_key(key)
        end

        break if cursor == "0"
      end
    end

    def analyze_key(key)
      @stats[:total_keys] += 1
      ttl = @redis.ttl(key)
      idle_time = @redis.object("idletime", key)
      pattern = extract_pattern(key)
      # https://redis.io/docs/latest/commands/ttl/
      if ttl == -1
        @stats[:permanent_keys] += 1
        @stats[:size_by_pattern_permanent][pattern] += 1
      elsif ttl == -2
        @stats[:expired_ttl] += 1
        @stats[:size_by_pattern_expired][pattern] += 1
      elsif idle_time && idle_time > @options[:idle_threshold]
        @stats[:idle_keys] += 1 if
        @stats[:size_by_pattern_idle][pattern] += 1
      end

    rescue Redis::CommandError => e
      puts "Error analyzing key #{key}: #{e.message}"
    end

    def extract_pattern(key)
      key.gsub(/:\d+/, ':*').gsub(/[a-f0-9]{32}/, '*')
    end

    def print_report
      puts "\n=== Redis Analysis Report ==="
      puts "Total keys analyzed: #{@stats[:total_keys]}"
      puts "Keys with expired TTL: #{@stats[:expired_ttl]}"
      puts "Permanent keys: #{@stats[:permanent_keys]}"
      puts "Keys idle > #{@options[:idle_threshold] / 86400} days: #{@stats[:idle_keys]}"

      puts "\nTop key expired patterns:"
      print_patterns(@stats[:size_by_pattern_expired])
      puts "----------"
      puts "\nTop key idle patterns:"
      print_patterns(@stats[:size_by_pattern_idle])
      puts "----------"
      puts "\nTop key permanent patterns:"
      print_patterns(@stats[:size_by_pattern_permanent])

      @stats
    end

    def print_patterns(patterns_hash)
      patterns_hash.sort_by { |_, v| -v }.first(10).each do |pattern, count|
        puts "  #{pattern}: #{count} keys"
      end
    end

    puts "Starting Redis analysis..."
    analyze_keys
    print_report
  end
end
