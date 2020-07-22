import { Component, OnInit } from '@angular/core';
import {RouterChangeService} from '@services/router-change.service';
import {AngularFireAuth} from '@angular/fire/auth';
import {LocalStorageService} from '@services/local-storage.service';
import {environment} from '@environments/environment';
import {Router} from '@angular/router';
declare var $: any;
@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {
  activeUrl = '/dashboard';

  constructor(private routerChangeService: RouterChangeService,
              private angularFireAuth: AngularFireAuth,
              private auth: LocalStorageService,
              private router: Router) { }

  ngOnInit() {
    this.routerChangeService.activeRoute.subscribe((e) => {
      this.activeUrl = e.url;
    });
  }


  showSubMenu($event) {
    const $activeItem = $($event.currentTarget);
    const dataItem = $activeItem.data('item');
    if (dataItem) {
      // $('.nav-item').removeClass('active');
      // $activeItem.addClass('disabled');
      $('.sidebar-left-secondary').addClass('open');
      $('.sidebar-overlay').addClass('open');
    } else {
      $('.sidebar-left-secondary').removeClass('open');
      $('.sidebar-overlay').removeClass('open');
    }

    $('.sidebar-left-secondary').find('.childNav').hide();
    $('.sidebar-left-secondary').find(`[data-parent="${dataItem}"]`).show();
  }

  closeSubMenu() {
    $('.sidebar-left-secondary').removeClass('open');
    $('.sidebar-overlay').removeClass('open');
  }

  signOut() {
    this.angularFireAuth.auth.signOut().then(function() {
      // Sign-out successful.
    }).catch(function(error) {
      // An error happened.
    });
    this.auth.remove(environment.adminId);
    this.router.navigate(['login']);
  }
}
