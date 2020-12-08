(function () {
  addEventListener('DOMContentLoaded', setupStatsCharts)

  function setupStatsCharts () {
    const statCharts = document.querySelectorAll("[data-chart='stats-chart']")

    for (let i = 0; i < statCharts.length; i++) {
      const chart = statCharts[i];
      const container = chart.id;
      const months = JSON.parse(chart.dataset.months);
      const maxValue = chart.dataset.maxValue;
      const series = JSON.parse(chart.dataset.series);
      const colors = JSON.parse(chart.dataset.colors);
      const format = JSON.parse(chart.dataset.format);
      statsCharts(container, months, maxValue, series, colors, format);
    }
  }

  function statsCharts (container, months, max_value, series, colors, format) {
    Highcharts.chart(container, {
      colors: colors,
      chart: {
        type: 'column'
      },
      title: {
        text: null
      },
      credits: {
        enabled: false
      },
      plotOptions: {
        series: {
          animation: false
        },
        column: {
          stacking: 'normal'
        }
      },
      tooltip: {
        pointFormat: format
      },
      xAxis: {
        categories: months,
        tickInterval: 1,
        min: 0,
        max: months.length - 1
      },
      yAxis: {
        title: null,
        max: max_value
      },
      legend: {
        enabled: true
      },
      series: series
    })
  }
})()
