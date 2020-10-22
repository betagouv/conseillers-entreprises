function stats_charts(container, months, max_value, series) {
  Highcharts.chart(container, {
    colors: [
      '#60bbff',
      '#208bff', '#006be6', '#0033e4', '#0500e2',
      '#3b00e0', '#7000dd', '#a400db', '#d700d9',
      '#d700a4', '#d5006f', '#d3003b', '#d00007',
      '#ce2b00', '#cc5c00', '#ab2b1e',
      '#56656f'
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
      pointFormat: '{series.name} : <b>{point.y}</b> ({point.percentage:.0f}%)<br>Total: {point.stackTotal}',
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
