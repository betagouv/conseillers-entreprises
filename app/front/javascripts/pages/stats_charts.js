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
      const subtitle = JSON.parse(chart.dataset.subtitle);
      statsCharts(container, months, maxValue, series, colors, format, subtitle);
    }
  }

  function statsCharts (container, months, max_value, series, colors, format, subtitle) {
    Highcharts.chart(container, {
      colors: colors,
      chart: {
        type: 'column'
      },
      title: {
        text: null
      },
      subtitle: {
        text: subtitle,
        align: 'left',
        y: 10
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
        enabled: true,
        itemHiddenStyle: {
          color: '#565656'
        },
        itemMarginTop: 10,
        itemMarginBottom: 10
      },
      series: series
    })
  }
})()
