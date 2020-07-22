import {Component, OnInit} from '@angular/core';
import {FormBuilder, FormGroup, Validators, NG_VALUE_ACCESSOR, ControlValueAccessor} from '@angular/forms';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {Location} from '@angular/common';
import {SnotifyService} from 'ng-snotify';
import * as firebase from 'firebase';

@Component({
  selector: 'app-edit-category',
  templateUrl: './edit-category.component.html',
  styleUrls: ['./edit-category.component.css']
})

export class EditCategoryComponent implements OnInit {
  editCategoryFormGroup: FormGroup;
  id = '';
  singleCategory = {};
  ref;
  task;
  image;

  constructor(private formBuilder: FormBuilder,
              private apiServices: ApiService,
              private router: Router,
              private route: ActivatedRoute,
              private location: Location,
              private snotifyServices: SnotifyService
  ) {
    this.route.paramMap.subscribe(params => {
      this.id = params.get('doc_id');
      this.getSingleCategory(this.id);
    });
  }

  ngOnInit() {
    this.editCategoryFormGroup = this.formBuilder.group({
      category_name: ['', Validators.required],
      category_image: ['', Validators.required],
    });
  }

  getSingleCategory(id) {
    this.apiServices.getSingleCategory(id).subscribe(res => {
      if (res.data) {
        this.singleCategory = res.data;
        this.editCategoryFormGroup.patchValue({
          category_name: res.data.category_name,
          // category_image: res.data.category_image,
          category_id: id,
        });
        this.image = res.data.category_image;
      }
    });
  }

  async editCategory() {
    this.editCategoryFormGroup.value.category_image = await this.task.snapshot.ref.getDownloadURL();
    const inputData = Object.assign({}, {category_id: this.id}, this.editCategoryFormGroup.value);
    this.apiServices.updateCategory(inputData).subscribe((res) => {
      this.snotifyServices.success('Category Updated', 'Success');
      this.router.navigate(['../dashboard/categories']);
    }, (error) => {
      this.snotifyServices.error(error.error.message, 'Error');
    });
  }

  addCategoryImage(eve) {
    const storage = firebase.storage();
    const storageRef = storage.ref();
    const filesRef = storageRef.child('/category_images/' + eve.target.files[0].name);
    this.task = filesRef.put(eve.target.files[0]);
    console.log(this.task);
    this.calling().then(r => this.calling());
  }

  async calling() {
    console.log(await this.task.snapshot.ref.getDownloadURL());
    this.editCategoryFormGroup.value.category_image = await this.task.snapshot.ref.getDownloadURL();
    this.image = this.editCategoryFormGroup.value.category_image;

  }
}

