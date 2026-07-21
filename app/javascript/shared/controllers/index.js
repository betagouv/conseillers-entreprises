import { stimulus_app } from "../stimulus_app"

import BatchCheckController from "./batch_check_controller"
stimulus_app.register("batch-check", BatchCheckController)
import DirectSubmitController from "./direct_submit_controller"
stimulus_app.register("direct-submit", DirectSubmitController)
import FiltersController from "./filters_controller"
stimulus_app.register("filters", FiltersController)
import InseeCodeController from "./insee_code_controller"
stimulus_app.register("insee-code", InseeCodeController)
import SlimSelectController from "./slim_select_controller"
stimulus_app.register("slim-select", SlimSelectController)
import StatsChartsController from "./stats_charts_controller"
stimulus_app.register("stats-charts", StatsChartsController)

