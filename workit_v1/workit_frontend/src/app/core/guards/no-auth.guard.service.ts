import {Injectable} from '@angular/core';
import {ActivatedRouteSnapshot, Router, RouterStateSnapshot} from '@angular/router';
import {Observable} from 'rxjs';
import {environment} from '@environments/environment';
import {LocalStorageService} from '@services/local-storage.service';

@Injectable()
export class NoAuthGuardService {

  constructor(private router: Router, public auth: LocalStorageService) {
  }

  canActivate(next: ActivatedRouteSnapshot, state: RouterStateSnapshot): Observable<boolean> | Promise<boolean> | boolean {
    const user = !!this.auth.getValue(environment.adminId, false);
    if (!user) {
      return true;
    } else {
      this.router.navigate(['/']);
      return false;
    }
  }
}
