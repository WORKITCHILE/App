import {Component, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {SnotifyService} from 'ng-snotify';

@Component({
  selector: 'app-subcategory',
  templateUrl: './subcategory.component.html',
  styleUrls: ['./subcategory.component.css']
})
export class SubcategoryComponent implements OnInit {

  allSubcategories = [];
  subcategoryPage = 1;
  total;
  calling = false;



  constructor(private apiServices: ApiService,
              // private auth: AuthService,
              private snotifyService: SnotifyService,
              private router: Router,
              private route: ActivatedRoute) {
  }

  ngOnInit() {
    this.getSubcategories();
  }

  getSubcategories() {
    this.calling = true;
    this.apiServices.getSubcategories(this.subcategoryPage, 10).subscribe(res => {
      this.calling = false;
      this.allSubcategories = res.data;
      this.total = res.total;
    });
  }

  pageChangedSubCategory($event: number) {
    this.subcategoryPage = $event;
    this.getSubcategories();
  }
  deleteSubcategory(subcategoryId) {
    const data = {
      subcategory_id: subcategoryId,
    };
    this.snotifyService.confirm('Click Yes if You Want to Delete Subcategory', 'Are You Sure', {
      closeOnClick: false,
      buttons: [
        {
          text: 'Yes', action: () =>
            this.apiServices.deleteSubcategory(data).subscribe((res) => {
              this.snotifyService.remove();
              this.snotifyService.success('Deleted', 'Success');
              this.getSubcategories();
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

}
