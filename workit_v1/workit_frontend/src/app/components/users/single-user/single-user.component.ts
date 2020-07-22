import {Component, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import * as moment from 'moment';
import {Location} from '@angular/common';
import {SnotifyService} from 'ng-snotify';

@Component({
  selector: 'app-single-user',
  templateUrl: './single-user.component.html',
  styleUrls: ['./single-user.component.css']
})
export class SingleUserComponent implements OnInit {
  id;
  singleUser: any = {
    projects: []
  };
  calling = false;


  constructor(private apiServices: ApiService,
              private router: Router,
              private snotifyService: SnotifyService,
              private route: ActivatedRoute,
              private location: Location
  ) {
    this.route.paramMap.subscribe(params => {
      this.id = params.get('doc_id');
      console.log(this.id);
      this.getSingleUser(this.id);
    });
  }

  ngOnInit() {
  }

  getSingleUser(id) {
    this.calling = true;
    this.apiServices.getSingleUser(id).subscribe(res => {
      this.calling = false;
      if (res.data) {
        this.singleUser = res.data;
        console.log(this.singleUser.date_of_birth);
        this.singleUser.date_of_birth = moment(this.singleUser.date_of_birth * 1000).toDate();
        console.log(this.singleUser.date_of_birth);
        this.singleUser.updated_at = moment(this.singleUser.updated_at).toDate();
        this.singleUser.projects = res.data.projects;
      }
    });
  }
  goBack() {
    this.location.back(); // <-- go back to previous location on cancel
  }
  disableUser(deactivate) {
    const data = {
      user_id: this.id,
      status: deactivate
    };
    this.snotifyService.confirm('Click Yes if You Want to Disable User', 'Are You Sure', {
      closeOnClick: false,
      buttons: [
        {
          text: 'Yes', action: () =>
            this.apiServices.manageAccount(data).subscribe((res) => {
              this.snotifyService.remove();
              this.snotifyService.success('User Disabled', 'Success');
              this.getSingleUser(this.id);
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

  enableUser(activate) {
    const data = {
      user_id: this.id,
      status: activate
    };
    this.apiServices.manageAccount(data).subscribe((res) => {
      this.getSingleUser(this.id);
      this.snotifyService.success('User Activated', 'Success');
    }, (err) => {
      this.snotifyService.error(err.error.message, 'Error');
    });
  }

}
