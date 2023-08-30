(function () {
  addEventListener('DOMContentLoaded', setupLineCharts)

  function setupLineCharts () {
    const statCharts = document.querySelectorAll("[data-chart='line-chart']")

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
      yAxis: {
        title: null
      },
      xAxis: {
        categories: months
      },
      legend: {
        enabled: true,
        itemHiddenStyle: {
          color: '#565656'
        },
        itemMarginTop: 10,
        itemMarginBottom: 10
      },
      plotOptions: {
        series: {
          animation: false,
          label: {
            connectorAllowed: false
          }
        }
      },
      series: series,
    });
  }
})()
