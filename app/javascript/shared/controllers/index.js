import { stimulus_app } from "../stimulus_app"

import BatchCheckController from "./batch_check_controller"
stimulus_app.register("batch-check", BatchCheckController)
import FiltersController from "./filters_controller"
stimulus_app.register("filters", FiltersController)
import InseeCodeController from "./insee_code_controller"
stimulus_app.register("insee-code", InseeCodeController)
import StatsChartsController from "./stats_charts_controller"
stimulus_app.register("stats-charts", StatsChartsController)

