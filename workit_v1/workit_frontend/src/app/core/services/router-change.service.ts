import {EventEmitter, Injectable} from '@angular/core';
import {NavigationEnd, Router} from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class RouterChangeService {
  activeRoute = new EventEmitter<any>();

  constructor(private route: Router) {
    this.routeEvent(this.route);
  }

  routeEvent(router: Router) {
    router.events.subscribe(e => {
      if (e instanceof NavigationEnd) {
        this.activeRoute.emit(e);
      }
    });
  }
}
