function stats_charts(container, months, max_value, series, colors) {
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
