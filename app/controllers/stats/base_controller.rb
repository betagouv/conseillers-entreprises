module Stats
  class BaseController < PagesController
    include StatsUtilities
    include StatsHelper
  end
end
