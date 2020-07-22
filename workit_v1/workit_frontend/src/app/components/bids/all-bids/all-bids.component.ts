import {Component, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
declare var $: any;
@Component({
  selector: 'app-all-bids',
  templateUrl: './all-bids.component.html',
  styleUrls: ['./all-bids.component.css']
})
export class AllBidsComponent implements OnInit {
  calling = false;
  allBids = [];
  name;
  alerting = false;

  constructor(private apiServices: ApiService) {
  }

  ngOnInit() {
    this.getAllBids();
  }

  getAllBids() {
    this.calling = true;
    this.apiServices.getAllBids().subscribe(res => {
      this.calling = false;
      this.allBids = res.data;
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
