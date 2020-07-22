import {Component, OnInit} from '@angular/core';
// import * as firebase from 'firebase';
import {AngularFireAuth} from '@angular/fire/auth';
import {LocalStorageService} from '@services/local-storage.service';
import {environment} from '@environments/environment';
import {Router} from '@angular/router';
import {SnotifyService} from 'ng-snotify';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  userObj = {
    email: '',
    password: ''
  };

  constructor(private angularFireAuth: AngularFireAuth,
              private snotifyService: SnotifyService,
              private auth: LocalStorageService,
              private router: Router) {
  }

  ngOnInit() {
    /*    let firebase = require('firebase');
        let firebaseui = require('firebaseui');
        let ui = new firebaseui.auth.AuthUI(firebase.auth());
        ui.start('#firebaseui-auth-container', {
          signInOptions: [
            {
              provider: firebase.auth.EmailAuthProvider.PROVIDER_ID,
              requireDisplayName: false
            }
          ]
        });*/
  }

  // createUser() {
  //   this.angularFireAuth.auth.createUserWithEmailAndPassword(this.userObj.email, this.userObj.password).then(value => {
  //     console.log('Success!', value);
  //   })
  //     .catch(err => {
  //       console.log('Something went wrong:', err.message);
  //     });
  //   /*  console.log(firebase.auth());
  //     console.log(firebase);*/
  //     // Handle Errors here.
  // }
  SignIn() {
    console.log(this.userObj.email);
    this.angularFireAuth.auth.signInWithEmailAndPassword(this.userObj.email, this.userObj.password).then(value => {
      // console.log('Success!', value);
      // console.log('Success!', value.user.uid);
      if (value.user.uid == 'TwFSa64QSch5DCGkKrfakDcBdqb2') {
        this.auth.setValue(environment.adminId, value.user.uid);
        this.router.navigate(['/dashboard']);
      }
      // this.auth.setValue(environment.authKey, res.response.token);
      // this.auth.setValue(environment.adminId, res.response.admin_id);
    })
      .catch(err => {
        this.snotifyService.error(err.message, 'Error');
        console.log('Something went wrong:', err.message);
      });
    // Handle Errors here.
    // ...
  }
}
