package com.app.workit.util;

import io.reactivex.Observable;
import io.reactivex.subjects.BehaviorSubject;
import io.reactivex.subjects.PublishSubject;

public class RxBus {
    private static RxBus instance;

    private PublishSubject<Object> subject = PublishSubject.create();

    private BehaviorSubject<Object> behaviorSubject = BehaviorSubject.create();

    public static RxBus getInstance() {
        if (instance == null) {
            instance = new RxBus();
        }
        return instance;
    }

    /**
     * Pass any event down to event listeners.
     */
    public void setEvent(Object object) {
        subject.onNext(object);
    }


    /**
     * Event when no subscribers are present
     */
    public void setIntentEvent(Object object) {
        behaviorSubject.onNext(object);
    }


    /**
     * Subscribe to this Observable. On event, do something
     * e.g. replace a fragment
     */
    public Observable<Object> getEvents() {
        return subject;
    }


}
