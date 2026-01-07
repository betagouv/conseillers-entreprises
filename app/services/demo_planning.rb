class DemoPlanning
  def initialize
    @dates = YAML.load_file("#{Rails.root.join("config", "data", "demo_planning.yml")}", permitted_classes: [Date])
  end

  def call
    next_dates(4)
  end

  private

  def next_dates(number)
    today = Date.today
    @dates.select { |date| date > today }.first(number)
  end
end
