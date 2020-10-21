function basic_columns_chart(container, months, max_value, series, colors) {
  Highcharts.chart(container, {
    colors: colors,
    chart: {
      type: 'column'
    },
    title: null,
    subtitle: null,
    xAxis: {
      categories: months,
      crosshair: true
    },
    credits: {
      enabled: false
    },
    yAxis: {
      min: 0,
      title: null
    },
    tooltip: {
      pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b><br/>'
    },
    plotOptions: {
      column: {
        pointPadding: 0.2,
        borderWidth: 0
      }
    },
    series: series
  })
}
