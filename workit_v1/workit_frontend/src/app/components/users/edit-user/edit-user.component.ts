import {Component, OnInit} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from '@angular/forms';
import * as moment from 'moment';
import {ApiService} from '@app/core/http/api.service';
import {ActivatedRoute, Router} from '@angular/router';
import {DatePipe, Location} from '@angular/common';
import {SnotifyService} from 'ng-snotify';

@Component({
  selector: 'app-edit-user',
  templateUrl: './edit-user.component.html',
  styleUrls: ['./edit-user.component.css'],
  providers: [DatePipe]
})
export class EditUserComponent implements OnInit {
  editUserFormGroup: FormGroup;
  id;
  singleUser: any = {
    dob: '',
    updated_at: '',
    projects: []
  };
  loading = false;
  date;

  constructor(private formBuilder: FormBuilder,
              private apiServices: ApiService,
              private router: Router,
              private route: ActivatedRoute,
              private location: Location,
              private snotifyServices: SnotifyService,
              private datePipe: DatePipe
  ) {
    this.route.paramMap.subscribe(params => {
      this.id = params.get('doc_id');
      this.getSingleUser(this.id);

    });
  }

  ngOnInit() {
    this.editUserFormGroup = this.formBuilder.group({
      address: ['', Validators.required],
      nationality: ['', Validators.required],
      contact_number: ['', Validators.required],
      credits: ['', Validators.required],
      occupation: ['', Validators.required],
      email: ['', Validators.required],
      father_last_name: ['', Validators.required],
      mother_last_name: ['', Validators.required],
      name: ['', Validators.required],
      id_number: ['', Validators.required],
      date_of_birth: ['', Validators.required],
      profile_description: ['', Validators.required],
    });
  }

  getSingleUser(id) {
    this.loading = true;
    this.apiServices.getSingleUser(id).subscribe(res => {
      this.loading = false;
      if (res.data) {
        this.singleUser = res.data;
        this.editUserFormGroup.value.date_of_birth = res.data.date_of_birth;
        this.editUserFormGroup.value.date_of_birth = moment(this.editUserFormGroup.value.date_of_birth * 1000).toDate();
        this.date = this.editUserFormGroup.value.date_of_birth;
        console.log(this.editUserFormGroup.value.date_of_birth);
        this.editUserFormGroup.patchValue({
          name: res.data.name,
          address: res.data.address,
          nationality: res.data.nationality,
          contact_number: res.data.contact_number,
          date_of_birth: res.data.date_of_birth,
          occupation: res.data.occupation,
          father_last_name: res.data.father_last_name,
          mother_last_name: res.data.mother_last_name,
          email: res.data.email,
          credits: res.data.credits,
          id_number: res.data.id_number,
          profile_description: res.data.profile_description,
          user_id: this.id,
        });
        // this.singleUser.dob = moment(this.singleUser.dob).toDate();
        // this.singleUser.updated_at = moment(this.singleUser.updated_at).toDate();
        // this.singleUser.projects = res.data.projects;
      }
    });
  }

  editUser() {
    const inputData = Object.assign({}, {user_id: this.id}, this.editUserFormGroup.value);
    this.apiServices.updateUser(inputData).subscribe((res) => {
      this.router.navigate(['../dashboard/users']);
      this.snotifyServices.success('Profile Updated', 'Success');
    }, (error) => {
      this.snotifyServices.error(error.error, 'Error');
    });
  }
}
