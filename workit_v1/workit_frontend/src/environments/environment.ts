// This file can be replaced during build by using the `fileReplacements` array.
// `ng build --prod` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
  production: true,
  apiPrefix: 'https://us-central1-workit-de544.cloudfunctions.net/app/api/admin/',
  assetsUrl: 'https://api.qualwebs.com/workit/public/storage',
  authKey: 'workit_token',
  adminId: 'admin_id',
  firebase: {
    apiKey: 'AIzaSyC_7ANWluYUB9Y2kv_VR_lq8VXwZWh8m9U',
    authDomain: 'workit-de544.firebaseapp.com',
    databaseURL: 'https://workit-de544.firebaseio.com',
    projectId: 'workit-de544',
    storageBucket: 'workit-de544.appspot.com',
    messagingSenderId: '863747706156',
    appId: '1:863747706156:web:66559822273345f72c7089',
    measurementId: 'G-EW6WLBTQM3'
  },

};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/dist/zone-error';  // Included with Angular CLI.
