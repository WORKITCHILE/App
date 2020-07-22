import { Component, OnInit } from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';

@Component({
  selector: 'app-support',
  templateUrl: './support.component.html',
  styleUrls: ['./support.component.css']
})
export class SupportComponent implements OnInit {

  supportMessages = [];
  supportPage = 1;
  total;
  calling = false;
  constructor(private apiServices: ApiService,
              private router: Router,
              private route: ActivatedRoute) { }

  ngOnInit() {
    this.getSupport();
  }

  getSupport() {
    this.calling = true;
    this.apiServices.getSupport(this.supportPage, 10).subscribe(res => {
      this.calling = false;
      this.supportMessages = res.data;
      this.total = res.total;
    });
  }
  pageChangedSupport($event: number) {
    this.supportPage = $event;
    this.getSupport();
  }
  changeSupportStatus(id, statusValue) {
    const data = {
      support_id: id,
      status: statusValue
    };
    this.apiServices.supportAction(data).subscribe((res) => {
      this.getSupport();
      console.log(res);
      },
      (err) => {
        console.log(err);
      }
    );
  }

}
