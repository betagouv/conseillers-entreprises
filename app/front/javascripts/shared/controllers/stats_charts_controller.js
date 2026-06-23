import { Controller } from "stimulus"
import { columnCharts } from '../column_charts'
import { lineCharts } from "../line_charts"
import { percentageColumnCharts } from "../percentage_column_chart"

export default class extends Controller {
  static targets = ['graph']

  connect() {
    const chart = this.graphTarget;
    const container = chart.id;
    const type = chart.dataset.type;
    const months = JSON.parse(chart.dataset.months);
    const maxValue = chart.dataset.maxValue;
    const series = JSON.parse(chart.dataset.series);
    const colors = JSON.parse(chart.dataset.colors);
    const format = JSON.parse(chart.dataset.format);
    const subtitle = JSON.parse(chart.dataset.subtitle);
    const chartFunctions = {
      'percentage-column-chart': percentageColumnCharts,
      'column-chart': columnCharts,
      'line-chart': lineCharts
    }
    chartFunctions[type](container, months, maxValue, series, colors, format, subtitle);
  }
}
