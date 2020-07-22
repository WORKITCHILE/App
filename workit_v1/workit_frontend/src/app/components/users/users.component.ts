import {Component, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {SnotifyService} from 'ng-snotify';
declare var $: any;

@Component({
  selector: 'app-users',
  templateUrl: './users.component.html',
  styleUrls: ['./users.component.css']
})
export class UsersComponent implements OnInit {
  allUsers = [];
  name;
  userPage = 1;
  total;
  calling = false;
  alerting = false;

  constructor(private apiServices: ApiService,
              // private auth: AuthService,
              private snotifyService: SnotifyService,
              private router: Router,
              private route: ActivatedRoute) {
  }

  ngOnInit() {
    this.getUser();
  }

  getUser() {
    this.calling = true;
    this.apiServices.getUsers(this.userPage, 10).subscribe(res => {
      this.calling = false;
      this.allUsers = res.data;
      this.total = res.total;
    });
  }
  pageChangedUser($event: number) {
    this.userPage = $event;
    this.getUser();
  }
  disableUser(userId, deactivate) {
    const data = {
      user_id: userId,
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
              this.getUser();
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

  enableUser(userId, activate) {
    const data = {
      user_id: userId,
      status: activate
    };
    this.apiServices.manageAccount(data).subscribe((res) => {
      this.getUser();
      this.snotifyService.success('User Activated', 'Success');
    }, (err) => {
      this.snotifyService.error(err.error.message, 'Error');
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
  getFilter(id) {
  }
}
