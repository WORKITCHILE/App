import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AddPrivacyPolicyComponent } from './add-privacy-policy.component';

describe('AddPrivacyPolicyComponent', () => {
  let component: AddPrivacyPolicyComponent;
  let fixture: ComponentFixture<AddPrivacyPolicyComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AddPrivacyPolicyComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AddPrivacyPolicyComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
