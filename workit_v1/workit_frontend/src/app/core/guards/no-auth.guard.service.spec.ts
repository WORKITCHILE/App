import {TestBed} from '@angular/core/testing';

describe('NoAuth.GuardService', () => {
  beforeEach(() => TestBed.configureTestingModule({}));

  it('should be created', () => {
    const service: NoAuthGuardService = TestBed.get(NoAuthGuardService);
    expect(service).toBeTruthy();
  });
});
