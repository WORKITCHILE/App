import { Component, OnInit } from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {SnotifyService} from 'ng-snotify';
declare var $: any;
@Component({
  selector: 'app-category',
  templateUrl: './category.component.html',
  styleUrls: ['./category.component.css']
})
export class CategoryComponent implements OnInit {

  allCategories = [];
  categoryPage = 1;
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
    this.getCategories();
  }

  getCategories() {
    this.calling = true;
    this.apiServices.getCategories(this.categoryPage, 10).subscribe(res => {
      this.calling = false;
      this.allCategories = res.data;
      this.total = res.total;
    });
  }
  pageChangedCategory($event: number) {
    this.categoryPage = $event;
    this.getCategories();
  }
  deleteCategory(categoryId) {
    const data = {
      category_id: categoryId
    };
    this.snotifyService.confirm('Click Yes if You Want to Delete Category', 'Are You Sure', {
      closeOnClick: false,
      buttons: [
        {
          text: 'Yes', action: () =>
            this.apiServices.deleteCategory(data).subscribe((res) => {
              this.snotifyService.remove();
              this.snotifyService.success('Deleted', 'Success');
              this.getCategories();
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

}
