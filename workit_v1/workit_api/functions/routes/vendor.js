var admin = require("firebase-admin");

const routes = require('express').Router();
const collections = require('../collections');
const db = admin.firestore();
const {check, validationResult} = require('express-validator');
const checkIfAuthenticated = require('../middleware/CheckAuthentication').checkIfAuthenticated;
const sendNotification = require('../helper').sendNotification;
const sendEmailCommon = require('../helper').sendEmailCommon;
const sendEmailVoucher = require('../helper').sendEmailVoucher;
const saveJobEvents = require('../helper').saveJobEvents;


//get jobs for worker
routes.post('/api/vendor/get-posted-jobs', /*checkIfAuthenticated,*/[
    //validation
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var jobs = [];
        var result = [];
        const current_latitude = req.body.current_latitude;
        const current_longitude = req.body.current_longitude;
        const job_approach = req.body.job_approach;
        const price = req.body.price;
        const distance = req.body.distance;
        const search = req.body.search;
        const date_filter = req.body.date_filter;
        const subcategory_id = req.body.subcategory_id;
        let postedRef = await db.collection(collections.jobsCollection).where('status', '==', 'POSTED');
        var searchRef;

        if (search) {
            searchRef = postedRef.where('job_name', '>=', search).where('job_name', '<=', search + '\uf8ff');
            // searchRef = postedRef.where('key', "array-contains-any", [search.toLowerCase(), search.toUpperCase()])
        } else {
            searchRef = postedRef;
        }
        let subcategoryRef;
        if (subcategory_id.length !== 0) {
            subcategoryRef = searchRef.where('subcategory_id', 'in', subcategory_id);
        } else {
            subcategoryRef = searchRef;
        }

        //for job_approach
        let filterRef_1;
        if (job_approach && job_approach !== 'All') {
            filterRef_1 = subcategoryRef.where('job_approach', '==', job_approach);
        } else {
            filterRef_1 = subcategoryRef;
        }
        //for price
        let filterRef_2;
        if (price && price !== "0.0") {
            filterRef_2 = filterRef_1.where('initial_amount', '<=', parseFloat(price));
        } else {
            filterRef_2 = filterRef_1;
        }
        //for date
        let filterRefDate
        if (date_filter) {
            var year_1 = new Date((date_filter * 1000)).getFullYear();
            var month_1 = new Date((date_filter * 1000)).getMonth() + 1;
            var day = new Date((date_filter * 1000)).getDate();

            var day_timestamp = new Date(year_1 + "-" + month_1 + "-" + day).getTime() / 1000;

            filterRefDate = filterRef_2.where('day_timestamp', '==', day_timestamp);
        } else {
            filterRefDate = filterRef_2;
        }
        //for distance
        let filterRef_3;

        if (distance && distance !== "0") {
            filterRef_3 = filterRefDate;

            var source_lat = req.body.address_latitude;
            var source_long = req.body.address_longitude;

            if (!(source_lat) || !(source_long)) {
                source_lat = current_latitude;
                source_long = current_longitude;
            }

            await filterRef_3.get().then(snapshot1 => {
                if (!snapshot1.size) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching jobs Found',
                        'status': 200
                    })
                }
                snapshot1.forEach(doc => {
                    //Start of code for calculating distance between two places
                    var lat2 = doc.data().job_address_latitude;
                    var lon2 = doc.data().job_address_longitude;

                    var R = 6371; // Radius of the earth in km
                    var dLat = deg2rad(lat2 - source_lat);  // deg2rad below
                    var dLon = deg2rad(lon2 - source_long);
                    var a =
                        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                        Math.cos(deg2rad(source_lat)) * Math.cos(deg2rad(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
                    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                    var d = R * c; // Distance in km

                    console.log(d);
                    if (d <= parseFloat(distance)) {
                        var obj = doc.data();
                        obj.job_id = doc.id;
                        result.push(obj);
                    }

                    function deg2rad(deg) {
                        return deg * (Math.PI / 180)
                    }

                    //End of code for calculating distance between two places
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
        } else {
            filterRef_3 = filterRefDate;
            await filterRef_3.get().then(snapshot1 => {
                if (!snapshot1.size) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching jobs Found',
                        'status': 200
                    })
                }
                snapshot1.forEach(doc => {
                    var lat2 = doc.data().job_address_latitude;
                    var lon2 = doc.data().job_address_longitude;
                    var dis = 40;
                    var R = 6371; // Radius of the earth in km
                    var dLat = deg2rad(lat2 - current_latitude);  // deg2rad below
                    var dLon = deg2rad(lon2 - current_longitude);
                    var a =
                        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                        Math.cos(deg2rad(current_latitude)) * Math.cos(deg2rad(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
                    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                    var d = R * c; // Distance in km

                    if (d <= parseFloat(dis)) {
                        var obj = doc.data();
                        obj.job_id = doc.id;
                        result.push(obj);
                    }

                    function deg2rad(deg) {
                        return deg * (Math.PI / 180)
                    }
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
        }
        return res.status(200).json({'data': result, 'message': 'Success', 'status': 200})
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//get running jobs worker

routes.get('/api/vendor/get-running-jobs', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var jobs = [];
        const user_id = req.query.user_id;
        let jobRef = await db.collection(collections.jobsCollection).where('job_vendor_id', '==', user_id).where('status', 'in', ['ACCEPTED', 'STARTED', 'FINISHED']).orderBy('created_at', 'desc');

        jobRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching jobs Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.job_id = doc.id;
                    jobs.push(obj);
                });

                return res.status(200).json({'data': jobs, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

routes.get('/api/vendor/get-completed-jobs', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var jobs = [];
        const user_id = req.query.user_id;
        let jobRef = await db.collection(collections.jobsCollection).where('job_vendor_id', '=', user_id).where('status', 'in', ['PAID', 'CANCELED']).orderBy('created_at', 'desc');

        jobRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching jobs Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.job_id = doc.id;
                    jobs.push(obj);
                });

                return res.status(200).json({'data': jobs, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//get single job for worker
routes.get('/api/vendor/get-single-job', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('user_id').not().isEmpty().withMessage('user_id field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var job;
        const job_id = req.query.job_id;
        const user_id = req.query.user_id;
        await db.collection(collections.jobsCollection).doc(job_id).get()
            .then(async snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching job Found',
                        'status': 200
                    })
                }
                job = snapshot.data();
                job.job_id = snapshot.id;
                var arr;
                var bid_check = await db.collection(collections.bidsCollection).where('job_id', '==', snapshot.id).where('vendor_id', '==', user_id).get()
                    .then(userSnapshot => {
                        userSnapshot.forEach(user => {
                            let obj = user.data();
                            obj.bid_id = user.id
                            job.my_bid = obj;
                        });
                        arr = userSnapshot.size;
                        return arr;
                    }).catch((err) => {
                        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
                    });
                // console.log(bid_check);
                var is_bid_placed;
                if (bid_check === 0) {
                    is_bid_placed = 0;
                } else {
                    is_bid_placed = 1;
                }
                job.is_bid_placed = is_bid_placed;

                return res.status(200).json({'data': job, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//place bid (place bid with counteroffer)
routes.post('/api/vendor/place-bid', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('vendor_id').not().isEmpty().withMessage('vendor_id field is required'),
    check('comment').not().isEmpty().withMessage('comment field is required'),
    check('counteroffer_amount').not().isEmpty().withMessage('counteroffer_amount field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {job_id, vendor_id, counteroffer_amount, comment} = req.body;
        var job_timestamp;
        var same_day_count = 0;

        //check for job conflict (current job should not occur between any other jobs of worker)
        await db.collection(collections.jobsCollection).doc(job_id).get().then(async jobDoc => {
            job_timestamp = jobDoc.data().job_time;
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        await db.collection(collections.jobsCollection).where('job_vendor_id', '==', vendor_id)
            .where('status', 'in', ['ACCEPTED', 'STARTED'])
            .get().then(allJobsRef => {
                allJobsRef.forEach(allJobDoc => {
                    if (allJobDoc.id !== job_id) {
                        if (allJobDoc.data().job_time <= job_timestamp && allJobDoc.data().job_end_time >= job_timestamp) {
                            same_day_count = same_day_count + 1;
                        }
                    }
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
        console.log(same_day_count);
        if (same_day_count > 0) {
            return res.status(400).json({
                'data': [],
                'message': 'You can\'t bid on this job as you already scheduled a job for this timing',
                'status': 400
            });
        }
        await db.collection(collections.jobsCollection).doc(job_id).get().then(job => {
            if (job.data().status === 'CANCELED') {
                return res.status(400).json({
                    'data': [],
                    'message': 'Disculpa, Este trabajo ha sido cancelado por el cliente.',
                    'status': 400
                });
            }
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        let bidRef = await db.collection(collections.bidsCollection).add({
            owner_status: "POSTED",
            vendor_status: "ACCEPTED",
            job_id: job_id,
            vendor_id: vendor_id,
            comment: comment,
            counteroffer_amount: counteroffer_amount,
            created_at: Date.now(),
            updated_at: Date.now()
        });
        let jobRef = await db.collection(collections.jobsCollection).doc(job_id);
        let jobDetailRef = await jobRef.get().then(async job_detail => {
            await db.collection(collections.usersCollection).doc(job_detail.data().user_id).get().then(userSnap => {
                bidRef.update({
                    job_name: job_detail.data().job_name,
                    job_description: job_detail.data().job_description,
                    job_approach: job_detail.data().job_approach,
                    job_address: job_detail.data().job_address,
                    job_time: job_detail.data().job_time,
                    job_end_time: job_detail.data().job_end_time,
                    job_date: job_detail.data().job_date,
                    job_day_timestamp: job_detail.data().day_timestamp,
                    initial_amount: job_detail.data().initial_amount,
                    user_id: userSnap.id,
                    user_name: userSnap.data().name + " " + userSnap.data().father_last_name,
                    user_image: userSnap.data().profile_picture,
                    user_occupation: userSnap.data().occupation,
                    user_description: userSnap.data().profile_description,
                    bid_show_status: "YES"
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
            return job_detail.data().bid_count;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        if (typeof jobDetailRef !== 'undefined') {
            // console.log( jobDetailRef);
            jobRef.update({bid_count: jobDetailRef + 1});
        } else {
            jobRef.update({bid_count: 1});
        }

        bidRef.get().then(async bidSnap => {
            await db.collection(collections.usersCollection).doc(bidSnap.data().vendor_id).get().then(async vendorSnap => {
                await db.collection(collections.jobsCollection).doc(job_id).get().then(async jobData => {
                    await db.collection(collections.usersCollection).doc(jobData.data().user_id).get().then(async userSnap => {

                        userSnap.data().fcm_token.forEach(token => {
                            const body = {
                                'to': token,
                                'notification': {
                                    title: vendorSnap.data().name + ' hizo una oferta en tu trabajo ',
                                    body: bidSnap.data().comment,
                                    type: 2,
                                    data: bidSnap.data().job_id,
                                    sound: 'default'
                                },
                                content_available: true,
                                mutable_content: true
                            };
                            sendNotification(body);

                        });

                        await db.collection(collections.notificationCollection).add({
                            sender_id: vendorSnap.id,
                            receiver_id: userSnap.id,
                            sender_name: vendorSnap.data().name,
                            sender_image: vendorSnap.data().profile_picture,
                            notification_body: vendorSnap.data().name + '  hizo una oferta en tu trabajo ',
                            notification_type: 2,
                            job_id: bidSnap.data().job_id,
                            created_at: Date.now(),
                            updated_at: Date.now(),
                        });

                        var body = vendorSnap.data().name + ' placed bid on your job ' + jobData.data().job_name;
                        var receiver = vendorSnap.data().name;
                        var subject = 'New bid received';

                        sendEmailCommon(userSnap.data().email, body, receiver, subject);

                        return userSnap.data();
                    }).catch(err => {
                        console.log(err.message);
                        return false;
                    });
                    return true;
                }).catch(err => {
                    console.log(err.message);
                    return false;
                });
                bidRef.update({
                    vendor_name: vendorSnap.data().name,
                    vendor_image: vendorSnap.data().profile_picture,
                    vendor_dob: vendorSnap.data().date_of_birth,
                    vendor_occupation: vendorSnap.data().occupation,
                    vendor_description: vendorSnap.data().profile_description
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200, 'type': 3});
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});
//job start or finish (job-action)

routes.post('/api/vendor/job-action', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('status').not().isEmpty().withMessage('status field is required'),

], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const job_id = req.body.job_id;
        // const vendor_id = req.body.vendor_id;
        const status = req.body.status;
        let jobRemoveRef = await db.collection(collections.jobsCollection).doc(job_id).get().then(jobDoc => {
            let object = {};
            object.job_id = jobDoc.id;
            object.job_name = jobDoc.data().job_name;
            object.job_address = jobDoc.data().job_address;
            object.job_time = jobDoc.data().job_time;
            object.job_date = jobDoc.data().job_date;
            object.user_id = jobDoc.data().user_id;
            object.status = jobDoc.data().status;
            return object;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        await db.collection(collections.jobsCollection).doc(job_id)
            .update({
                status: status,
                updated_at: Date.now()
            });
        if (status === 'FINISHED') {
            await db.collection(collections.jobsCollection).doc(job_id).get().then(async jobDetail => {
                let obj_2 = {};

                obj_2.job_id = jobDetail.id;
                obj_2.job_name = jobDetail.data().job_name;
                obj_2.job_address = jobDetail.data().job_address;
                obj_2.job_time = jobDetail.data().job_time;
                obj_2.job_date = jobDetail.data().job_date;
                obj_2.user_id = jobDetail.data().user_id;
                obj_2.status = jobDetail.data().status;


                var year = new Date((jobDetail.data().job_time * 1000)).getFullYear();
                var month = new Date((jobDetail.data().job_time * 1000)).toLocaleString('en-US', {month: 'long'});
                var month_filter = month + '-' + year;
                var day = new Date((jobDetail.data().job_time * 1000)).getDate();
                // user calender

                var docRef = await db.collection(collections.usersCollection).doc(jobDetail.data().user_id)
                    .collection(collections.calenderCollection).doc(month_filter);
                docRef.update({
                    [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveRef)
                });

                docRef.update({
                    [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
                });

                // worker calender
                var docRef_2 = await db.collection(collections.usersCollection).doc(jobDetail.data().job_vendor_id)
                    .collection(collections.calenderCollection).doc(month_filter);

                docRef_2.update({
                    [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveRef)
                });


                docRef_2.update({
                    [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
                });

                await db.collection(collections.usersCollection).doc(jobDetail.data().user_id).get().then(async userData => {
                    userData.data().fcm_token.forEach(token => {
                        const body = {
                            'to': token,
                            'notification': {
                                title: 'Your Job ' + jobDetail.data().job_name + ' is Finished',
                                body: 'Job Amount : ' + jobDetail.data().service_amount,
                                type: 6,
                                data: jobDetail.id,
                                sound: 'default'
                            },
                            content_available: true,
                            mutable_content: true
                        };
                        sendNotification(body);
                    });

                    await db.collection(collections.notificationCollection).add({
                        sender_id: jobDetail.data().user_id,
                        receiver_id: userData.id,
                        sender_name: jobDetail.data().user_name,
                        sender_image: jobDetail.data().user_image,
                        notification_body: 'Your Job ' + jobDetail.data().job_name + ' is Finished',
                        notification_type: 6,
                        job_id: jobDetail.id,
                        created_at: Date.now(),
                        updated_at: Date.now(),
                    });

//email to owner (common)
                    let body = 'Your Job ' + jobDetail.data().job_name + ' has been finished.';
                    let receiver = jobDetail.data().user_name;
                    let subject = 'Job finished';

                    sendEmailCommon(jobDetail.data().user_email, body, receiver, subject);
//email to owner (voucher)
                    var job_time = new Date(jobDetail.data().job_time * 1e3).toISOString().slice(-13, -5);
                    var voucher_body = {
                        job_name: jobDetail.data().job_name,
                        job_address: jobDetail.data().job_address,
                        job_date: jobDetail.data().job_date,
                        job_time: job_time,
                        job_amount: jobDetail.data().service_amount
                    };
                    var voucher_sub = 'Job receipt';
                    sendEmailVoucher(jobDetail.data().user_email, voucher_body, receiver, voucher_sub);

//email to vendor (common)
                    let vendor_body = 'Job ' + jobDetail.data().job_name + ' has been finished.';
                    let vendor_receiver = jobDetail.data().vendor_name;
                    let vendor_subject = 'Job finished';

                    sendEmailCommon(jobDetail.data().vendor_email, vendor_body, vendor_receiver, vendor_subject);
//email to vendor (voucher)
                    sendEmailVoucher(jobDetail.data().vendor_email, voucher_body, vendor_receiver, voucher_sub);

                    return true;
                }).catch(err => {
                    console.log(err.message);
                    return false;
                });
                let message = 'Job ' + jobDetail.data().job_name + ' has been completed successfully';

                saveJobEvents(jobDetail.data().job_name, jobDetail.id, message, 'FINISHED', jobDetail.data().vendor_name);

                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

            await db.collection(collections.messageListCollection).where('job_id', '==', job_id).get()
                .then(messageRef => {
                    messageRef.forEach(messageDoc => {
                        messageDoc.ref.delete();
                    });
                    return true;
                })
                .catch(err => {
                    console.log(err.message);
                    return false;
                });

        } else if (status === "STARTED") {
            await db.collection(collections.jobsCollection).doc(job_id).update({
                started_by: "WORK"
            });
            await db.collection(collections.jobsCollection).doc(job_id).get().then(async jobDetail => {
                let obj_2 = {};

                obj_2.job_id = jobDetail.id;
                obj_2.job_name = jobDetail.data().job_name;
                obj_2.job_address = jobDetail.data().job_address;
                obj_2.job_time = jobDetail.data().job_time;
                obj_2.job_date = jobDetail.data().job_date;
                obj_2.user_id = jobDetail.data().user_id;
                obj_2.status = jobDetail.data().status;


                var year = new Date((jobDetail.data().job_time * 1000)).getFullYear();
                var month = new Date((jobDetail.data().job_time * 1000)).toLocaleString('en-US', {month: 'long'});
                var month_filter = month + '-' + year;
                var day = new Date((jobDetail.data().job_time * 1000)).getDate();
                // user calender

                var docRef = await db.collection(collections.usersCollection).doc(jobDetail.data().user_id)
                    .collection(collections.calenderCollection).doc(month_filter);

                docRef.update({
                    [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveRef)
                });

                docRef.update({
                    [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
                });

                // worker calender
                var docRef_2 = await db.collection(collections.usersCollection).doc(jobDetail.data().job_vendor_id)
                    .collection(collections.calenderCollection).doc(month_filter);

                docRef_2.update({
                    [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveRef)
                });


                docRef_2.update({
                    [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
                });

                await db.collection(collections.usersCollection).doc(jobDetail.data().user_id).get().then(async userData => {
                    userData.data().fcm_token.forEach(token => {
                        console.log(token);
                        const body = {
                            'to': token,
                            'notification': {
                                title: 'Your Job ' + jobDetail.data().job_name + ' is Started by worker,now waiting for your approval.',
                                body: 'Job Amount : ' + jobDetail.data().service_amount,
                                type: 5,
                                data: jobDetail.id,
                                sound: 'default'
                            },
                            content_available: true,
                            mutable_content: true
                        };
                        sendNotification(body);
                    });
                    await db.collection(collections.notificationCollection).add({
                        sender_id: jobDetail.data().user_id,
                        receiver_id: userData.id,
                        sender_name: jobDetail.data().user_name,
                        sender_image: jobDetail.data().user_image,
                        notification_body: 'Your Job ' + jobDetail.data().job_name + ' is Started by worker,now waiting for your approval.',
                        notification_type: 5,
                        job_id: jobDetail.id,
                        created_at: Date.now(),
                        updated_at: Date.now(),
                    });


//email to owner
                    let body = 'Your Job ' + jobDetail.data().job_name + ' has been started by worker,now waiting for your approval.';
                    let receiver = jobDetail.data().user_name;
                    let subject = 'Job started';

                    sendEmailCommon(jobDetail.data().user_email, body, receiver, subject);


//email to vendor
                    let vendor_body = 'Job ' + jobDetail.data().job_name + ' has been started,now waiting for approval.';
                    let vendor_receiver = jobDetail.data().vendor_name;
                    let vendor_subject = 'Job started';

                    sendEmailCommon(jobDetail.data().vendor_email, vendor_body, vendor_receiver, vendor_subject);


                    return true;
                }).catch(err => {
                    console.log(err.message);
                    return false;
                });
                let message = 'Job ' + jobDetail.data().job_name + ' has been started successfully';
                saveJobEvents(jobDetail.data().job_name, jobDetail.id, message, 'STARTED', jobDetail.data().vendor_name);

                //     // bid show status changed
                //     var bidData;
                //     await db.collection(collections.bidsCollection).where('job_id', '==', jobDetail.id).where('owner_status', '==', "ACCEPTED").get().then(bidsRef => {
                //         bidsRef.forEach(bids => {
                //             bidData = bids.id;
                //         });
                //         return true;
                //     }).catch(err => {
                //         console.log(err.message);
                //         return false
                //     });
                //     if (bidData) {
                //         await db.collection(collections.bidsCollection).doc(bidData).update({
                //             bid_show_status: "NO"
                //         });
                //     }
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

        }

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});

    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

//get bids list
routes.get('/api/vendor/get-all-bids', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('type').not().isEmpty().withMessage('type field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var bids = [];
        const user_id = req.query.user_id;
        const type = req.query.type;

        await db.collection(collections.bidsCollection).where('vendor_id', '==', user_id).where('bid_show_status', '==', "YES").orderBy('created_at', 'desc').get()
            .then(async snapshot => {
                snapshot.forEach(async doc => {
                    if (doc.data().owner_status === type) {
                        let obj = doc.data();
                        obj.bid_id = doc.id;
                        bids.push(obj);
                    }
                });
                return res.status(200).json({data: bids, 'message': 'Success', 'status': 200})
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//get single bid
routes.get('/api/vendor/get-single-bid', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('bid_id').not().isEmpty().withMessage('bid_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const job_id = req.query.job_id;
        const bid_id = req.query.bid_id;
        await db.collection(collections.jobsCollection).doc(job_id).collection(collections.bidsCollection).doc(bid_id).get()
            .then(snapshot => {
                if (!snapshot.exists) {
                    return res.status(200).json({'data': [], 'message': 'bid not found', 'status': 200})
                }
                var obj = snapshot.data();
                obj.bid_id = snapshot.id;
                return true;
            })
            .catch(err => {
                console.log(err.message);
                return false;
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//cancel bid

routes.post('/api/vendor/cancel-bid', /*checkIfAuthenticated,*/[
    //validation
    check('bid_id').not().isEmpty().withMessage('bid_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const bid_id = req.body.bid_id;
        var jobData = {};
        await db.collection(collections.bidsCollection).doc(bid_id).get()
            .then(async snapshot => {
                if (!snapshot.exists) {
                    return res.status(200).json({'data': [], 'message': 'bid not found', 'status': 200})
                }
                jobData = await db.collection(collections.jobsCollection).doc(snapshot.data().job_id).get().then(job => {
                    return job.data();
                }).catch(err => {
                    console.log(err);
                    return false;
                });
                if (jobData.status !== "POSTED" && jobData.status !== "ACCEPTED") {
                    return res.status(400).json({
                        'data': [],
                        'message': 'You can not cancel this bid.',
                        'status': 400
                    });
                }
                await db.collection(collections.bidsCollection).doc(bid_id).update({
                    vendor_status: "CANCELED",
                    bid_show_status: "NO"
                });

                await db.collection(collections.jobsCollection).doc(snapshot.data().job_id).update({
                    bid_count: jobData.bid_count - 1
                });

                return res.status(200).json({'data': [], 'message': 'success', 'status': 200});
            })
            .catch(err => {
                console.log(err.message);
                return false;
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

//cancel a job

routes.post('/api/vendor/cancel-job', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const job_id = req.body.job_id;
        const user_id = req.body.user_id;
        var job_data = {};
        var user_data = {};
        var jobRemoveData = {};
        await db.collection(collections.jobsCollection).doc(job_id).get().then(jobDetail => {
            let obj_2 = {};

            obj_2.job_id = jobDetail.id;
            obj_2.job_name = jobDetail.data().job_name;
            obj_2.job_address = jobDetail.data().job_address;
            obj_2.job_time = jobDetail.data().job_time;
            obj_2.job_date = jobDetail.data().job_date;
            obj_2.user_id = jobDetail.data().user_id;
            obj_2.status = jobDetail.data().status;

            jobRemoveData = obj_2;
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        console.log(jobRemoveData);
        let jobRef = await db.collection(collections.jobsCollection).doc(job_id);

        await jobRef.update({
            status: 'CANCELED',
            canceled_by: 'WORK'
        });
        await jobRef.get().then(async doc => {
            let obj_3 = {};

            obj_3.job_id = doc.id;
            obj_3.job_name = doc.data().job_name;
            obj_3.job_address = doc.data().job_address;
            obj_3.job_time = doc.data().job_time;
            obj_3.job_date = doc.data().job_date;
            obj_3.user_id = doc.data().user_id;
            obj_3.status = doc.data().status;

            console.log(obj_3);
            var year = new Date((doc.data().job_time * 1000)).getFullYear();
            var month = new Date((doc.data().job_time * 1000)).toLocaleString('en-US', {month: 'long'});
            var month_filter = month + '-' + year;
            var day = new Date((doc.data().job_time * 1000)).getDate();
            // user calender

            var docRef = await db.collection(collections.usersCollection).doc(doc.data().user_id)
                .collection(collections.calenderCollection).doc(month_filter);
            docRef.update({
                [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveData)
            });

            docRef.update({
                [day]: admin.firestore.FieldValue.arrayUnion(obj_3)
            });

            // worker calender
            var docRef_2 = await db.collection(collections.usersCollection).doc(doc.data().job_vendor_id)
                .collection(collections.calenderCollection).doc(month_filter);

            docRef_2.update({
                [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveData)
            });

            docRef_2.update({
                [day]: admin.firestore.FieldValue.arrayUnion(obj_3)
            });

            let obj = doc.data();
            obj.job_id = doc.id;
            job_data = obj;

            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        await db.collection(collections.usersCollection).doc(job_data.user_id).get().then(userSnapshot => {
            let user_obj = userSnapshot.data();
            user_obj.user_id = userSnapshot.id;
            user_data = user_obj;
            return true;
        }).catch(() => {
            return {};
        });

        if (Object.keys(user_data).length !== 0) {
            user_data.fcm_token.forEach(token => {
                const body = {
                    'to': token,
                    'notification': {
                        title: 'Job ' + job_data.job_name + 'has been canceled by worker.',
                        body: job_data.job_name,
                        type: 14,
                        data: job_data.job_id,
                        sound: 'default'
                    },
                    content_available: true,
                    mutable_content: true
                };
                sendNotification(body);
            });

            await db.collection(collections.notificationCollection).add({
                sender_id: job_data.job_vendor_id,
                receiver_id: job_data.user_id,
                sender_name: job_data.vendor_name,
                sender_image: job_data.vendor_image,
                notification_body: 'Job ' + job_data.job_name + 'has been canceled by worker.',
                notification_type: 14,
                job_id: job_data.job_id,
                created_at: Date.now(),
                updated_at: Date.now(),
            });
        }
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});


module.exports = routes;
