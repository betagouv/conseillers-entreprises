import { Controller } from "stimulus"
import {percentageStatsCharts, statsCharts} from '../percentage_column_chart'

export default class extends Controller {
  static targets = ['graph']

  connect(event) {
    const chart = this.graphTarget;
    const container = chart.id;
    const months = JSON.parse(chart.dataset.months);
    const maxValue = chart.dataset.maxValue;
    const series = JSON.parse(chart.dataset.series);
    const colors = JSON.parse(chart.dataset.colors);
    const format = JSON.parse(chart.dataset.format);
    const subtitle = JSON.parse(chart.dataset.subtitle);
    percentageStatsCharts(container, months, maxValue, series, colors, format, subtitle);
  }
}
