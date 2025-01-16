namespace :redis do
  desc "Show an analysis of the Redis keys"
  task analyze: :environment do
    @redis = Redis.new(url: ENV['REDIS_URL'])
    @stats = {
      total_keys: 0,
      expired_ttl: 0,
      idle_keys: 0,
      size_by_pattern: Hash.new(0)
    }
    @options = {
      idle_threshold: 86400 * 7, # 7 days
      extract_patterns: ENV['EXTRACT_PATTERNS'] == 'true'
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

      @stats[:expired_ttl] += 1 if ttl < 0
      @stats[:idle_keys] += 1 if idle_time && idle_time > @options[:idle_threshold]

      if @options[:extract_patterns]
        pattern = extract_pattern(key)
        @stats[:size_by_pattern][pattern] += 1
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
      puts "Keys idle > #{@options[:idle_threshold] / 86400} days: #{@stats[:idle_keys]}"

      if @options[:extract_patterns]
        puts "\nTop key patterns:"
        @stats[:size_by_pattern].sort_by { |_, v| -v }.first(10).each do |pattern, count|
          puts "  #{pattern}: #{count} keys"
        end
      end

      @stats
    end

    puts "Starting Redis analysis..."
    analyze_keys
    print_report
  end
end
