function stats_charts(container, months, max_value, series) {
  Highcharts.chart(container, {
    colors: ['#0053b3', '#006be6', '#003b80', '#b4e1fa',
      '#ff9947', '#cc5c00', '#d63626', '#ab2b1e',
      '#ebeff3', '#c9d3df', '#adb9c9', '#8393a7',
      '#53657d', '#26353f', '#03bd5b', '#daf5e7',
    ],
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
      pointFormat: '{series.name} : <b>{point.y}</b> ({point.percentage:.0f}%)<br>',
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
  });
}
