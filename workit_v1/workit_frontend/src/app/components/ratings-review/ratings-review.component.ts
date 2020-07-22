import {Component, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';


@Component({
  selector: 'app-ratings-review',
  templateUrl: './ratings-review.component.html',
  styleUrls: ['./ratings-review.component.css'],
})
export class RatingsReviewComponent implements OnInit {

  allRatings = [];
  total;
  calling = false;

  constructor(
    private apiServices: ApiService) {
  }

  ngOnInit() {
    this.getRatings();
  }

  getRatings() {
    this.calling = true;
    this.apiServices.getRatings().subscribe(res => {
      this.calling = false;
      this.allRatings = res.data;
      this.total = res.total;
    });
  }
  getFilter(id) {
  }
}
