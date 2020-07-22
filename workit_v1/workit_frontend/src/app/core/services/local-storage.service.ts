import {Injectable} from '@angular/core';

@Injectable()
export class LocalStorageService {

  public getValue(key, toJson): string {
    const value = localStorage.getItem(key);
    return toJson ? JSON.parse(value) : value;
  }

  public setValue(key, value): any {
    value = typeof value === 'object' ? JSON.stringify(value) : value;
    return localStorage.setItem(key, value);
  }

  public remove(key): void {
    localStorage.removeItem(key);
  }

  public hasValue(key): boolean {
    return localStorage.getItem(key) !== null;
  }
}
