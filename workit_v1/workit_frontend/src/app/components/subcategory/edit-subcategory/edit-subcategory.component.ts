import { Component, OnInit } from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {ApiService} from '@app/core/http/api.service';
import {SnotifyService} from 'ng-snotify';
import {ActivatedRoute, Router} from '@angular/router';
import {AngularFireStorage} from '@angular/fire/storage';
import * as firebase from 'firebase';

@Component({
  selector: 'app-edit-subcategory',
  templateUrl: './edit-subcategory.component.html',
  styleUrls: ['./edit-subcategory.component.css']
})
export class EditSubcategoryComponent implements OnInit {

  editSubCategoryFormGroup: FormGroup;
  ref;
  task;
  allCategories = [];
  categoryPage = 1;
  total;
  id;
  singleSubcategory;
  loading = false;
  image;

  constructor(private apiServices: ApiService,
              private formBuilder: FormBuilder,
              private route: ActivatedRoute,
              private snotifyService: SnotifyService,
              private router: Router, private afStorage: AngularFireStorage) {
    this.route.paramMap.subscribe(params => {
      this.id = params.get('doc_id');
      this.getSingleSubcategory(this.id);
    });
  }

  ngOnInit() {
    this.getCategories();
    this.editSubCategoryFormGroup = this.formBuilder.group({
      category_id: ['', Validators.required],
      subcategory_name: ['', Validators.required],
      subcategory_image: ['', Validators.required]
    });
  }

  async editSubCategory() {
    this.editSubCategoryFormGroup.value.subcategory_image = await this.task.snapshot.ref.getDownloadURL();
    const data = Object.assign({}, this.editSubCategoryFormGroup.value, {subcategory_id: this.id});
    this.apiServices.updateSubcategory(data).subscribe((res) => {
        this.snotifyService.success('Updated Successfully', 'Success');
        this.router.navigate(['../dashboard/subcategories']);
      },
      (err) => {
        console.log(err);
      });
  }
  getCategories() {
    this.loading = true;
    this.apiServices.getCategories(this.categoryPage, 10).subscribe(res => {
      this.loading = false;
      this.allCategories = res.data;
      this.total = res.total;
    });
  }
  getSingleSubcategory(subCatId) {
    this.apiServices.getSingleSubcategory(subCatId).subscribe(res => {
      if (res.data) {
        this.singleSubcategory = res.data;
        this.editSubCategoryFormGroup.patchValue({
          category_name: res.data.category_name,
          category_id: res.data.category_id,
          subcategory_name: res.data.subcategory_name,
          // subcategory_image: res.data.subcategory_image,
          subcategory_id: subCatId,
        });
      }
      this.image = res.data.subcategory_image;
    });
  }
  updateSubCategoryImage(eve) {
    const storage = firebase.storage();
    const storageRef = storage.ref();
    const filesRef = storageRef.child('/subcategory_images/' + eve.target.files[0].name);
    this.task = filesRef.put(eve.target.files[0]);
    console.log(this.task);
    this.calling().then(r => this.calling());
  }

  async calling() {
    console.log(await this.task.snapshot.ref.getDownloadURL());
    this.editSubCategoryFormGroup.value.subcategory_image = await this.task.snapshot.ref.getDownloadURL();
    this.image = this.editSubCategoryFormGroup.value.subcategory_image;
  }

}
