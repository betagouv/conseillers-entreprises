class DemoPlanning
  def initialize
    @dates = YAML.load_file("#{Rails.root.join("config", "data", "demo_planning.yml")}")
  end

  def call
    @dates = cast_dates
    return next_dates(4)
  end

  private

  def cast_dates
    list = @dates["demo_planning"].map{ |date| Date.parse(date) }
  end

  def next_dates(number)
    today = Date.today
    @dates.select { |date| date > today }.first(number)
  end
end
