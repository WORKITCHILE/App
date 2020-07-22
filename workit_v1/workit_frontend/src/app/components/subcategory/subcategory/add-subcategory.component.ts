import {Component, NgZone, OnInit} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {ApiService} from '@app/core/http/api.service';
import {SnotifyService} from 'ng-snotify';
import {Router} from '@angular/router';
import {AngularFireStorage} from '@angular/fire/storage';
import * as firebase from 'firebase';

@Component({
  selector: 'app-add-subcategory',
  templateUrl: './add-subcategory.component.html',
  styleUrls: ['./add-subcategory.component.css']
})
export class AddSubcategoryComponent implements OnInit {

  addSubCategoryFormGroup: FormGroup;
  ref;
  task;
  allCategories = [];
  categoryPage = 1;
  total;
  image;

  constructor(private apiServices: ApiService,
              private formBuilder: FormBuilder,
              private snotifyService: SnotifyService,
              private router: Router, private afStorage: AngularFireStorage) {
  }

  ngOnInit() {
    this.getCategories();
    this.addSubCategoryFormGroup = this.formBuilder.group({
      category_id: ['', Validators.required],
      subcategory_name: ['', Validators.required],
      subcategory_image: ['', Validators.required]
    });
  }

  async addSubCategory() {
    this.addSubCategoryFormGroup.value.subcategory_image = await this.task.snapshot.ref.getDownloadURL();
    console.log(this.addSubCategoryFormGroup.value.subcategory_image);
    this.apiServices.addSubCategory(this.addSubCategoryFormGroup.value).subscribe((res) => {
        this.snotifyService.success('Added Successfully', 'Success');
        this.router.navigate(['../dashboard/subcategories']);
      },
      (err) => {
        console.log(err);
      });
  }
  getCategories() {
    this.apiServices.getCategories(this.categoryPage, 10).subscribe(res => {
      this.allCategories = res.data;
      this.total = res.total;
    });
  }

  addSubCategoryImage(eve) {
    const storage = firebase.storage();
    const storageRef = storage.ref();
    const filesRef = storageRef.child('/subcategory_images/' + eve.target.files[0].name);
    this.task = filesRef.put(eve.target.files[0]);
    console.log(this.task);
    this.calling().then(r => this.calling());
  }

  async calling() {
    console.log(await this.task.snapshot.ref.getDownloadURL());
    this.addSubCategoryFormGroup.value.subcategory_image = await this.task.snapshot.ref.getDownloadURL();
    this.image = this.addSubCategoryFormGroup.value.subcategory_image
  }
}

