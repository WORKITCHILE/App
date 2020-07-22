var admin = require("firebase-admin");
var serviceAccount = require("./workit_permissions.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://workit-de544.firebaseio.com",
    storageBucket: "gs://workit-de544.appspot.com/"
});

const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
const collections = require('./collections');
const db = admin.firestore();
const sendNotification = require('./helper').sendNotification;

const app = express();


app.use(cors({origin: true}));


const adminPath = require('./routes/admin');
const usersPath = require('./routes/users');
const ownerPath = require('./routes/owner');
const vendorPath = require('./routes/vendor');


app.use('/', usersPath);
app.use('/', adminPath);
app.use('/', ownerPath);
app.use('/', vendorPath);


//schedule function (2 hrs before start job notification)(vendor)
exports.startTimeNotifyVendorFirst = functions.pubsub
    .schedule('* * * * *')
    .onRun(async () => {
        try {
            //
            var jobs = [];
            await db.collection(collections.jobsCollection).where('start_notify_time_1_vendor', '<=', parseInt(Date.now() / 1000)).where('already_notified_time_1_vendor', '==', "NO").where('status', '==', "ACCEPTED").get().then(jobSnap => {
                jobSnap.forEach(jobData => {
                    let obj = jobData.data();
                    obj.job_id = jobData.id;
                    jobs.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

            if (jobs !== "undefined" && jobs.length >= 1) {
                const jobPromises = jobs.map(async (job) => {
                    var obj = {};
                    // console.log(job);
                    var userDetail = await db.collection(collections.usersCollection).doc(job.job_vendor_id).get().then((userSnapshot) => {
                        obj = userSnapshot.data();
                        obj.user_id = userSnapshot.id;
                        return obj;
                    }).catch((err) => {
                        console.log(err);
                        return false;
                    });

                    userDetail.fcm_token.forEach(token => {
                        const body = {
                            // should be arrray
                            'to': token,
                            'notification': {
                                title: '45 minutes remaining for the job  ' + job.job_name + ' to start.',
                                body: job.job_name,
                                type: 8, //job start notify
                                data: job.job_id,
                                sound: 'default'
                            },
                            content_available: true,
                            mutable_content: true
                        };
                        sendNotification(body);
                        console.log(token);
                    });

                    db.collection(collections.jobsCollection).doc(job.job_id).update({
                        already_notified_time_1_vendor: "YES",
                        updated_at: Date.now(),
                    });

                    db.collection(collections.notificationCollection).add({
                        sender_id: job.user_id,
                        receiver_id: job.job_vendor_id,
                        sender_name: job.user_name,
                        sender_image: job.user_image,
                        notification_body: '45 minutes remaining for the job ' + job.job_name + ' to start',
                        notification_type: 8,
                        job_id: job.job_id,
                        created_at: Date.now(),
                        updated_at: Date.now(),
                    });

                });

                await Promise.all(jobPromises);
            }

            return true;
        } catch (error) {
            console.log(error);
            return false;
        }
    });

// 5 minute before start job notification

exports.startJobNotifyVendorSecond = functions.pubsub
    .schedule('* * * * *')
    .onRun(async () => {
        try {
            //
            var jobs = [];
            await db.collection(collections.jobsCollection).where('start_notify_time_2_vendor', '<=', parseInt(Date.now() / 1000)).where('already_notified_time_2_vendor', '==', "NO").where('status', '==', "ACCEPTED").get().then(jobSnap => {
                jobSnap.forEach(jobData => {
                    let obj = jobData.data();
                    obj.job_id = jobData.id;
                    jobs.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
            console.log(jobs);
            if (jobs !== "undefined" && jobs.length >= 1) {
                const jobPromisesNew = jobs.map(async (job) => {
                    var obj = {};
                    console.log(job);
                    var userDetail = await db.collection(collections.usersCollection).doc(job.job_vendor_id).get().then((userSnapshot) => {
                        obj = userSnapshot.data();
                        obj.user_id = userSnapshot.id;
                        return obj;
                    }).catch((err) => {
                        console.log(err);
                        return false;
                    });

                    userDetail.fcm_token.forEach(token => {
                        const body = {
                            // should be arrray
                            'to': token,
                            'notification': {
                                title: 'Five minutes remaining for the job  ' + job.job_name + ' to start.',
                                body: job.job_name,
                                type: 10, //job start notify
                                data: job.job_id,
                                sound: 'default'
                            },
                            content_available: true,
                            mutable_content: true
                        };
                        sendNotification(body);
                        console.log(token);
                    });

                    db.collection(collections.jobsCollection).doc(job.job_id).update({
                        already_notified_time_2_vendor: "YES",
                        updated_at: Date.now(),
                    });

                    db.collection(collections.notificationCollection).add({
                        sender_id: job.user_id,
                        receiver_id: job.job_vendor_id,
                        sender_name: job.user_name,
                        sender_image: job.user_image,
                        notification_body: 'Five minutes remaining for the job ' + job.job_name + ' to start',
                        notification_type: 10,
                        job_id: job.job_id,
                        created_at: Date.now(),
                        updated_at: Date.now(),
                    });

                });

                await Promise.all(jobPromisesNew);
            }

            return true;
        } catch (error) {
            console.log(error);
            return false;
        }
    });


//schedule function (2 hrs before start job notification)(owner)
exports.startTimeNotifyOwnerFirst = functions.pubsub
    .schedule('* * * * *')
    .onRun(async () => {
        try {
            //
            var jobs = [];
            await db.collection(collections.jobsCollection).where('start_notify_time_1_owner', '<=', parseInt(Date.now() / 1000)).where('already_notified_time_1_owner', '==', "NO").where('status', '==', "ACCEPTED").get().then(jobSnap => {
                jobSnap.forEach(jobData => {
                    let obj = jobData.data();
                    obj.job_id = jobData.id;
                    jobs.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

            if (jobs !== "undefined" && jobs.length >= 1) {
                const jobPromises = jobs.map(async (job) => {
                    var obj = {};
                    // console.log(job);
                    var userDetail = await db.collection(collections.usersCollection).doc(job.user_id).get().then((userSnapshot) => {
                        obj = userSnapshot.data();
                        obj.user_id = userSnapshot.id;
                        return obj;
                    }).catch((err) => {
                        console.log(err);
                        return false;
                    });

                    userDetail.fcm_token.forEach(token => {
                        const body = {
                            // should be arrray
                            'to': token,
                            'notification': {
                                title: '45 minutes remaining for the job  ' + job.job_name + ' to start.',
                                body: job.job_name,
                                type: 11, //job start notify
                                data: job.job_id,
                                sound: 'default'
                            },
                            content_available: true,
                            mutable_content: true
                        };
                        sendNotification(body);
                        console.log(token);
                    });

                    db.collection(collections.jobsCollection).doc(job.job_id).update({
                        already_notified_time_1_owner: "YES",
                        updated_at: Date.now(),
                    });

                    db.collection(collections.notificationCollection).add({
                        sender_id: job.job_vendor_id,
                        receiver_id: job.user_id,
                        sender_name: job.user_name,
                        sender_image: job.user_image,
                        notification_body: '45 minutes remaining for the job ' + job.job_name + ' to start',
                        notification_type: 11,
                        job_id: job.job_id,
                        created_at: Date.now(),
                        updated_at: Date.now(),
                    });


                });

                await Promise.all(jobPromises);
            }

            return true;
        } catch (error) {
            console.log(error);
            return false;
        }
    });

// 5 minute before start job notification (owner)

exports.startJobNotifyOwnerSecond = functions.pubsub
    .schedule('* * * * *')
    .onRun(async () => {
        try {
            //
            var jobs = [];
            await db.collection(collections.jobsCollection).where('start_notify_time_2_owner', '<=', parseInt(Date.now() / 1000)).where('already_notified_time_2_owner', '==', "NO").where('status', '==', "ACCEPTED").get().then(jobSnap => {
                jobSnap.forEach(jobData => {
                    let obj = jobData.data();
                    obj.job_id = jobData.id;
                    jobs.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
            console.log(jobs);
            if (jobs !== "undefined" && jobs.length >= 1) {
                const jobPromisesNew = jobs.map(async (job) => {
                    var obj = {};
                    console.log(job);
                    var userDetail = await db.collection(collections.usersCollection).doc(job.user_id).get().then((userSnapshot) => {
                        obj = userSnapshot.data();
                        obj.user_id = userSnapshot.id;
                        return obj;
                    }).catch((err) => {
                        console.log(err);
                        return false;
                    });

                    userDetail.fcm_token.forEach(token => {
                        const body = {
                            // should be arrray
                            'to': token,
                            'notification': {
                                title: 'Five minutes remaining for the job  ' + job.job_name + ' to start.',
                                body: job.job_name,
                                type: 12, //job start notify
                                data: job.job_id,
                                sound: 'default'
                            },
                            content_available: true,
                            mutable_content: true
                        };
                        sendNotification(body);
                        console.log(token);
                    });

                    db.collection(collections.jobsCollection).doc(job.job_id).update({
                        already_notified_time_2_owner: "YES",
                        updated_at: Date.now(),
                    });

                    db.collection(collections.notificationCollection).add({
                        sender_id: job.job_vendor_id,
                        receiver_id: job.user_id,
                        sender_name: job.user_name,
                        sender_image: job.user_image,
                        notification_body: 'Five minutes remaining for the job ' + job.job_name + ' to start',
                        notification_type: 12,
                        job_id: job.job_id,
                        created_at: Date.now(),
                        updated_at: Date.now(),
                    });
                });

                await Promise.all(jobPromisesNew);
            }

            return true;
        } catch (error) {
            console.log(error);
            return false;
        }
    });

//closed job
exports.CloseJob = functions.pubsub
    .schedule('* * * * *')
    .onRun(async () => {
        try {
            //
            var jobs = [];
            await db.collection(collections.jobsCollection).where('status', '==', 'POSTED').where('job_time', '<=', (parseInt(Date.now() / 1000))).get().then(jobSnap => {
                jobSnap.forEach(jobData => {
                    let obj = jobData.data();
                    obj.job_id = jobData.id;
                    jobs.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
            console.log(jobs);
            if (jobs !== "undefined" && jobs.length >= 1) {
                const jobPromises = jobs.map(async (job) => {
                    console.log(job.job_id);
                    await db.collection(collections.jobsCollection).doc(job.job_id).update({
                        status: "CLOSED",
                        updated_at: Date.now(),
                    });
                });
                await Promise.all(jobPromises);
            }
            return true;
        } catch (error) {
            console.log(error);
            return false;
        }
    });


exports.app = functions.https.onRequest(app);
