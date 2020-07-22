import { Component, OnInit } from '@angular/core';
import {HttpClient} from '@angular/common/http';
import {ApiService} from '@app/core/http/api.service';

@Component({
  selector: 'app-add-t-and-c',
  templateUrl: './add-t-and-c.component.html',
  styleUrls: ['./add-t-and-c.component.css']
})
export class AddTAndCComponent implements OnInit {

  adding;
  constructor(private http: HttpClient, private apiService: ApiService) { }

  ngOnInit() {
  }
  addTnc() {
    const data = {
      terms_and_conditions: this.adding
    };
    this.apiService.addTnC(data).subscribe((res) => {
      console.log(res);
    });
  }

}
