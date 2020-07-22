import {Observable} from 'rxjs';
import {Injectable} from '@angular/core';
import {LocalStorageService} from '@services/local-storage.service';
import {ActivatedRouteSnapshot, CanActivate, Router, RouterStateSnapshot} from '@angular/router';
import {environment} from '@environments/environment';

@Injectable()
export class AuthGuardService {
  modules: any = [];

  constructor(private router: Router, public auth: LocalStorageService) {
    // console.log(this.router, 'gaurd');
    // console.log(this.modules.indexOf(this.router.url));
    // console.log(this.modules);
  }

  canActivate(next: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<boolean> | Promise<boolean> | boolean {
    const user = !!this.auth.getValue(environment.adminId, false);
    if (user) {
      return true;
    } else {
      this.router.navigate(['/login']);
      return false;
    }
  }
}
