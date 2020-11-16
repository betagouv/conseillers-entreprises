(function () {
  addEventListener("DOMContentLoaded", setupBasicColumnsCharts);

  function setupBasicColumnsCharts() {
    const statCharts = document.querySelectorAll("[data-chart='basic-columns-chart']");

    for (let chart of statCharts) {
      let container = chart.id;
      let months = JSON.parse(chart.dataset.months);
      let maxValue = chart.dataset.maxValue;
      let series = JSON.parse(chart.dataset.series);
      let colors = JSON.parse(chart.dataset.colors);
      basicColumnsChart(container, months, maxValue, series, colors);
    }
  }

  function basicColumnsChart(container, months, max_value, series, colors) {
    Highcharts.chart(container, {
      colors: colors,
      chart: {
        type: "column",
      },
      title: null,
      subtitle: null,
      xAxis: {
        categories: months,
        crosshair: true,
      },
      credits: {
        enabled: false,
      },
      yAxis: {
        min: 0,
        title: null,
      },
      tooltip: {
        pointFormat:
          '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b><br/>',
      },
      plotOptions: {
        column: {
          pointPadding: 0.2,
          borderWidth: 0,
        },
      },
      series: series,
    });
  }
})();