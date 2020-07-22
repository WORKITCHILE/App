import { Component, OnInit } from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {Location} from '@angular/common';


@Component({
  selector: 'app-single-job',
  templateUrl: './single-job.component.html',
  styleUrls: ['./single-job.component.css']
})
export class SingleJobComponent implements OnInit {

  id;
  calling = false;
  singleJob = {
    doc_id: '',
    status: '',
    type: '',
    job_name: '',
    initial_amount: '',
    subcategory_name: '',
    service_amount: '',
    category_name: '',
    job_description: '',
    job_address: '',
    user_id: '',
    job_date: '',
    job_vendor_id: '',
    user_name: '',
    vendor_name: '',
    job_time: '',
    bid_count: '',
    created_at: '',
    bids: [{
      user_name: ''
    }] ,
    images: []
  };
  timeline = [];

  constructor(private apiServices: ApiService,
              private router: Router,
              private location: Location,
              private route: ActivatedRoute,
  ) {
    this.route.paramMap.subscribe(params => {
      this.id = params.get('doc_id');
      this.getSingleJob(this.id);
    });
  }

  ngOnInit() {
    this.getEventHistory();
  }

  getSingleJob(id) {
    this.calling = true;
    this.apiServices.getSingleJob(id).subscribe(res => {
      this.calling = false;
      if (res.data) {
        this.singleJob = res.data;
      }
    });
  }
  getEventHistory() {
    this.apiServices.getEventHistory(this.id).subscribe(res => {
      if (res) {
        this.timeline = res.data;
      }
    });
  }

  goBack() {
    this.location.back(); // <-- go back to previous location on cancel
  }
}
