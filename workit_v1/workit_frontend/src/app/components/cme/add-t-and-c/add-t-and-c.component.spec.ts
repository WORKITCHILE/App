import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AddTAndCComponent } from './add-t-and-c.component';

describe('AddTAndCComponent', () => {
  let component: AddTAndCComponent;
  let fixture: ComponentFixture<AddTAndCComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AddTAndCComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AddTAndCComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
