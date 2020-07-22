import {Component, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {SnotifyService} from 'ng-snotify';

declare var $: any;


@Component({
  selector: 'app-jobs',
  templateUrl: './jobs.component.html',
  styleUrls: ['./jobs.component.css']
})
export class JobsComponent implements OnInit {

  allJobs = [];
  jobPage = 1;
  total;
  calling = false;
  name = '';
  alerting = false;
  str;
  temp;
  end;

  constructor(private apiServices: ApiService,
              // private auth: AuthService,
              // private sharedService: SharedService,
              private router: Router,
              private snotifyService: SnotifyService,
              private route: ActivatedRoute) {
  }

  ngOnInit() {
    this.getJobs(this.name);

  }

  getJobs(name) {
    this.calling = true;
    this.apiServices.getJobs(this.jobPage, 10, name).subscribe(res => {
      this.calling = false;
      this.allJobs = res.data;
      this.total = res.total;
    });
  }

  pageChangedJob($event: number) {
    this.jobPage = $event;
    this.getJobs(this.name);
  }

  deleteJob(jobId) {
    this.snotifyService.confirm('Click Yes if You Want to Delete Job', 'Are You Sure', {
      closeOnClick: false,
      buttons: [
        {
          text: 'Yes', action: () =>
            this.apiServices.deleteJob(jobId).subscribe((res) => {
              this.snotifyService.remove();
              this.snotifyService.success('Deleted', 'Success');
              this.getJobs(this.name);
            }, (err) => {
              this.snotifyService.error(err.error.message, 'Error');
            })
          , bold: false
        },
        {
          text: 'No', action: () =>
            this.snotifyService.remove()
        },
      ]
    });
  }

  // copied(id) {
  //   this.alerting = true;
  //   window.setTimeout(function() {
  //     $('.alert').fadeTo(500, 0).slideUp(500, function() {
  //       $(this).remove();
  //     });
  //   }, 2000);
  //   console.log(id);
  // }
  /*  getDataDriver() {
      if (this.dateFilterFormDriver.invalid) {
        this.snotifyService.error('All Fields Are Mandatory', 'Error');
      } else {
        this.str = this.dateFilterFormDriver.get('start').value;
        this.end = this.dateFilterFormDriver.get('end').value;
        this.apiServices.getDriverRidesFilter(this.type, this.driverPage, this.str, this.end).subscribe((res) => {
            this.driverRides = res.response.data;
            this.driverTotal = res.response.total;
            this.tempDriver = false;
            this.snotifyService.success('Filtered Successfully', 'Success');
            this.router.navigate(['../dashboard/rides']);
          },
          (err) => {
            console.log(err);
          });
      }
    }*/
  getFilter(id) {
  }
}
