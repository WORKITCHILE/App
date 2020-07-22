import {Component, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import * as Highcharts from 'highcharts';

declare var $: any;
declare var require: any;

import ExportingModule from 'highcharts/modules/exporting';

ExportingModule(Highcharts);


@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.css']
})
export class HomeComponent implements OnInit {
  dashboardData: any = {
    total_users: '',
    total_bids: '',
    active_jobs: '',
    total_jobs: '',
    total_categories: '',
    hire_count: '',
    work_count: '',
    total_query: ''
  };
  recentJobs = [];
  recentSupport = [];
  // working
  Highcharts = Highcharts; // required
  chartConstructor = 'Total Users'; // optional string, defaults to 'chart'
  chartOptions = {
    title: {
      text: 'Total Users Per Month'
    },
    exporting: {
      enabled: false
    },
    chart: {
      type: 'column',
      marginLeft: 80
    },
    yAxis: {
      title: {
        text: 'Number of Employees'
      }
    },
    xAxis: {
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ],
    },
    // series: [{
    //   name: 'Users Per Month',
    //   data: [43, 52, 57, 69, 17, 11, 13, 15, 13, 43, 23, 32]
    // }, {
    //   name: 'Jobs Per Months',
    //   data: [24, 24, 29, 29, 32, 30, 38, 40]
    // }],
    series: [{
      type: 'column',
      name: 'Users Per Month',
      data:  [43, 52, 57, 69, 17, 11, 13, 15, 13, 43, 23, 32],
    }, {
      type: 'column',
      name: 'Jobs Per Months',
      data: [24, 24, 29, 29, 32, 30, 38, 40]
    }],
    responsive: {
      rules: [{
        condition: {
          maxWidth: 500
        },
      }]
    }
  };


  constructor(private apiServices: ApiService) {
    this.getDashboardCounts();
    this.getRecentJobs();
    this.getRecentSupports();
  }

  ngOnInit() {
    Highcharts.chart('grid', {
      chart: {
        type: 'column',
        marginLeft: 100
      },
      exporting: {
        enabled: false
      },
      title: {
        text: 'Categories allotted to job'
      },
      subtitle: {
        text: ''
      },
      xAxis: {
        type: 'category',
        title: {
          text: 'Categories',
          align: 'middle'
        },
        min: 0,
        max: 5,
        scrollbar: {
          enabled: true
        },
        tickLength: 0
      },
      yAxis: {
        min: 0,
        max: 1200,
        title: {
          text: 'Number Of Jobs',
          align: 'middle'
        }
      },
      plotOptions: {
        bar: {
          dataLabels: {
            enabled: true
          }
        }
      },
      legend: {
        enabled: false
      },
      credits: {
        enabled: false
      },
      series: [{
        type: 'column',
        name: 'Number Of Jobs',
        data: [
          ['Decoration', 1000],
          ['Autocalculation and plotting of trend lines', 575],
          ['Allow navigator to have multiple data series', 523],
          ['Implement dynamic font size', 427],
          ['Export charts in excel sheet', 239],
          ['Draggable points', 117]
        ]
      }]
    });
    Highcharts.chart('yearly', {
      title: {
        text: 'Jobs Per Year'
      },

      subtitle: {
        text: 'Yearly Data'
      },
      exporting: {
        enabled: false
      },
      yAxis: {
        title: {
          text: 'In Total'
        }
      },

      xAxis: {
        accessibility: {
          rangeDescription: 'Range: 2020 to 2025'
        }
      },

      legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle'
      },

      plotOptions: {
        series: {
          label: {
            connectorAllowed: false
          },
          pointStart: 2019
        }
      },

      series: [{
        type: 'line',
        name: 'Jobs',
        data: [550, 980, 559 , 696, 970, 119, 137, 417]
      }
      ],

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
// second chart
    Highcharts.chart('monthly', {
      title: {
        text: 'Jobs Per Month'
      },
      exporting: {
        enabled: false
      },
      subtitle: {
        text: 'Monthly data'
      },

      yAxis: {
        title: {
          text: 'In Total'
        }
      },

      xAxis: {
        categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
      },
      plotOptions: {
        series: {
          allowPointSelect: true
        }
      },

      series: [{
        type: 'line',
        name: 'Jobs',
        data: [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4]
      }
      ],

      legend: {
        layout: 'vertical',
        align: 'right',
        verticalAlign: 'middle'
      },

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
// third chart
    Highcharts.chart('weekly', {
     /* series: [{
        type: 'line',
        data: data3
      }],
      exporting: {
        enabled: false
      },

    });*/
      title: {
        text: 'Jobs Per Week'
      },
      exporting: {
        enabled: false
      },
      subtitle: {
        text: 'Weekly Data'
      },

      yAxis: {
        title: {
          text: 'In Total'
        }
      },

      xAxis: {
        type: 'datetime',
        dateTimeLabelFormats: {
          day: '%e of %b'
        }
      },

      series: [
        {
          name: 'Jobs',
          type: 'line',
          data: [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4],
          pointStart: Date.UTC(2020, 2, 20),
          pointInterval: 24 * 3600 * 1000 // one day
        }/*, {
          type: 'line',
          name: 'Users',
          data: [22.4, 79.5, 10.4, 29.2, 44.0, 76.0, 110.6, 168.5, 200.4, 124.1, 195.6, 154.4],
          pointStart: Date.UTC(2020, 2, 20),
          pointInterval: 24 * 3600 * 1000 // one day
        },*/
      ],

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
// TAB 1 and TAB 2 buttons handling charts
    const yearly = document.getElementById('tab1'),
      monthly = document.getElementById('tab2'),
      weekly = document.getElementById('tab3'),
      container1 = document.getElementById('yearly'),
      container2 = document.getElementById('monthly'),
      container3 = document.getElementById('weekly');

    yearly.addEventListener('click', function() {
      container1.style.display = 'block';
      container2.style.display = 'none';
      container3.style.display = 'none';
    });
    monthly.addEventListener('click', function() {
      container1.style.display = 'none';
      container2.style.display = 'block';
      container3.style.display = 'none';
    });
    weekly.addEventListener('click', function() {
      container1.style.display = 'none';
      container2.style.display = 'none';
      container3.style.display = 'block';
    });
    Highcharts.chart('earnings', {

      title: {
        text: 'Total Earnings'
      },
      exporting: {
        enabled: false
      },
      subtitle: {
        text: 'Work It Commission Data'
      },

      yAxis: {
        title: {
          text: 'In Total'
        }
      },

      xAxis: {
        type: 'datetime',
        dateTimeLabelFormats: {
          day: '%e of %b'
        }
      },

      series: [
        {
          name: 'Earnings',
          type: 'line',
          data: [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1, 95.6, 54.4],
          pointStart: Date.UTC(2020, 2, 20),
          pointInterval: 24 * 3600 * 1000 // one day
        }/*,{
        type: 'line',
      name: 'Users',
      data: [22.4, 79.5, 10.4, 29.2, 44.0, 76.0, 110.6, 168.5, 200.4, 124.1, 195.6, 154.4],
      pointStart: Date.UTC(2020, 2, 20),
      pointInterval: 24 * 3600 * 1000 // one day
  },*/
  ],

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
  getRecentJobs() {
    this.apiServices.getRecentJobs().subscribe(res => {
      if (res) {
        this.recentJobs = res.data;
      }
    });
  }
  getRecentSupports() {
    this.apiServices.getRecentSupport().subscribe(res => {
      if (res) {
        this.recentSupport = res.data;
      }
    });
  }

  getDashboardCounts() {
    this.apiServices.getDashboardCounts().subscribe(res => {
      if (res) {
        this.dashboardData = res;
        this.getPieChartData();
      }
    });
  }
  getPieChartData() {
    Highcharts.chart('pieCss', {
      chart: {
        type: 'pie',
        options3d: {
          enabled: true,
          alpha: 45,
          beta: 0
        }
      },
      title: {
        text: 'Users Available'
      },
      exporting: {
        enabled: false
      },
      tooltip: {
        pointFormat: '{series.name}: <br>{point.percentage:.1f} %<br>total: {point.total}'
      },
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          depth: 35,
          dataLabels: {
            enabled: true,
            format: '<b>{point.name}</b>:{point.y} <br> ({point.percentage:.1f} %)<br>Total: {point.total}',
          }
        }
      },
      series: [{
        type: 'pie',
        data: [{
          name: 'Hire',
          y: this.dashboardData.hire_count
        }, {
          name: 'Work',
          y: this.dashboardData.work_count
        }]
      }],
      annotations: [{
        labels: [{
          point: '3',
          text: 'd'
        }],
        draggable: '' // set by default
      }]
    });
  }

}
