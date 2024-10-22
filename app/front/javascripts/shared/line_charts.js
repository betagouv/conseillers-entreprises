export function LineCharts (container, months, max_value, series, colors, format, subtitle) {
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
      title: null,
      max: max_value,
      min: 0
    },
    xAxis: {
      categories: months,
      tickInterval: 1,
      min: 0,
      max: months.length - 1
    },
    series: series,

    responsive: {
      rules: [{
        condition: {
          maxWidth: 500
        },
        chartOptions: {
          legend: {
            layout: 'horizontal',
            align: 'center',
            verticalAlign: 'bottom'
          }
        }
      }]
    }
  });
}

