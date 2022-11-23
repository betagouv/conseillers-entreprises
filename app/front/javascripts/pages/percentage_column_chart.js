(function () {
  addEventListener('DOMContentLoaded', setupPercentageColumnCharts)

  function setupPercentageColumnCharts () {
    const percentageColumnCharts = document.querySelectorAll("[data-chart='percentage-column-chart']")

    for (let i = 0; i < percentageColumnCharts.length; i++) {
      const chart = percentageColumnCharts[i];
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
      xAxis: {
        categories: months,
        tickInterval: 1,
        min: 0,
        max: months.length - 1
      },
      yAxis: {
        min: 0,
        title: {
          text: null
        },
        labels: {
          format: '{value} %'
        }
      },
      tooltip: {
        pointFormat: format,
      },
      plotOptions: {
        column: {
          stacking: 'percent'
        },
        itemMarginTop: 5,
        itemMarginBottom: 5
      },
      legend: {
        itemHiddenStyle: {
          color: '#565656'
        }
      },
      series: series
    });
  }
})()
