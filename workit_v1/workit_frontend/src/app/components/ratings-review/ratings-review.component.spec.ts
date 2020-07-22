import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { RatingsReviewComponent } from './ratings-review.component';

describe('RatingsReviewComponent', () => {
  let component: RatingsReviewComponent;
  let fixture: ComponentFixture<RatingsReviewComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ RatingsReviewComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(RatingsReviewComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
