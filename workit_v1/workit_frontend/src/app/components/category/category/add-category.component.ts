import {Component, NgZone, OnInit} from '@angular/core';
import {ApiService} from '@app/core/http/api.service';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import {SnotifyService} from 'ng-snotify';
import {Router} from '@angular/router';
import {AngularFireStorage} from '@angular/fire/storage';
import * as firebase from 'firebase';
import {snapshotChanges} from '@angular/fire/database';
import {async} from 'rxjs/internal/scheduler/async';


@Component({
  selector: 'app-add-category',
  templateUrl: './add-category.component.html',
  styleUrls: ['./add-category.component.css']
})
export class AddCategoryComponent implements OnInit {
  addCategoryFormGroup: FormGroup;
  downloadURL;
  ref;
  task;
  uploadProgress;
  image;

  constructor(private zone: NgZone,
              private apiServices: ApiService,
              private formBuilder: FormBuilder,
              private snotifyService: SnotifyService,
              private router: Router, private afStorage: AngularFireStorage) {
  }

  ngOnInit() {
    this.addCategoryFormGroup = this.formBuilder.group({
      category_name: ['', Validators.required],
      category_image: ['', Validators.required]
    });
  }

  async addCategory() {
    this.addCategoryFormGroup.value.category_image = await this.task.snapshot.ref.getDownloadURL();
    console.log(this.addCategoryFormGroup.value.category_image);
    this.apiServices.addCategory(this.addCategoryFormGroup.value).subscribe((res) => {
        this.snotifyService.success('Added Successfully', 'Success');
        this.router.navigate(['../dashboard/categories']);
      },
      (err) => {
        this.snotifyService.error(err.message, 'Error');
        console.log(err);
      });
  }

  addCategoryImage(eve) {
    const storage = firebase.storage();
    const storageRef = storage.ref();
    const filesRef = storageRef.child('/category_images/' + eve.target.files[0].name);
    this.task = filesRef.put(eve.target.files[0]);
    console.log(this.task);
    this.calling().then(r => this.calling());
    // this.zone.run(() => {
    //   this.downloadURL = this.task.snapshot.ref.getDownloadURL();
    //   // console.log(await this.snapshot.ref.getDownloadURL());
    //   console.log(this.downloadURL);
    //   console.log(this.downloadURL);
    //   // this.downloadURL = storageRef.child('/category_images/' + eve.target.files[0].name).getDownloadURL();
    // });
    /*console.log(this.downloadURL);
    console.log(this.downloadURL.a);
    console.log(this.downloadURL.i);*/
    /*    this.downloadURL = task.downloadURL();
        storageRef.child(eve.target.files[0].name).put(eve.target.files[0]);
        this.downloadURL = this.afStorage.ref('category_images' + '/' + eve.target.files[0].name).getDownloadURL();
        console.log(this.downloadURL);
        storageRef.child(eve.target.files[0].name).put(eve.target.files[0]);
        create a reference to the storage bucket location
        this.ref = this.afStorage.ref(randomId);
        the put method creates an AngularFireUploadTask
        and kicks off the upload
        this.downloadURL = this.afStorage.ref('category_images' + '/' + eve.target.files[0].name).getDownloadURL();
        this.afStorage.upload('/category_images/', eve.target.files[0].name);
        // create a reference to the storage bucket location
        this.ref = this.afStorage.ref('category_images' + '/' + eve.target.files[0].name);
        console.log(this.ref);
        // var file = eve.target.files[0].name;
        // // this.downloadURL = this.afStorage.ref('category_images' + '/' + eve.target.files[0].name).getDownloadURL();
        // // tslint:disable-next-line:only-arrow-functions
        // this.afStorage.ref.put(file).then(function(snapshot) {
        //   console.log('Uploaded a blob or file!');
        // });


        this.downloadURL = this.ref.put('/category_images/' + eve.target.files[0].name);
        // console.log('Uploaded a blob or file!');
        console.log(this.downloadURL);
        console.log(eve.target.files[0].name);*/
  }

  async calling() {
    console.log(await this.task.snapshot.ref.getDownloadURL());
    this.addCategoryFormGroup.value.category_image = await this.task.snapshot.ref.getDownloadURL();
    this.image = this.addCategoryFormGroup.value.category_image;
  }
}
