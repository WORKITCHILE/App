var admin = require("firebase-admin");

const routes = require('express').Router();
const collections = require('../collections');
const db = admin.firestore();
const {check, validationResult} = require('express-validator');
const checkIfAuthenticated = require('../middleware/CheckAuthentication').checkIfAuthenticated;
const sendNotification = require('../helper').sendNotification;
const sendEmailCommon = require('../helper').sendEmailCommon;
const saveJobEvents = require('../helper').saveJobEvents;

//Post a job
routes.post('/api/owner/post-job', /*checkIfAuthenticated,*/[
    //validation
    check('subcategory_name').not().isEmpty().withMessage('subcategory_name field is required'),
    check('category_name').not().isEmpty().withMessage('category_name field is required'),
    check('subcategory_id').not().isEmpty().withMessage('subcategory_id field is required'),
    check('category_id').not().isEmpty().withMessage('category_id field is required'),
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('job_name').not().isEmpty().withMessage('job_name field is required'),
    check('job_address').not().isEmpty().withMessage('job_address field is required'),
    check('job_date').not().isEmpty().withMessage('job_date field is required'),
    check('job_time').not().isEmpty().withMessage('job_time field is required'),
    check('initial_amount').not().isEmpty().withMessage('initial_amount field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            category_name,
            subcategory_name,
            category_id,
            subcategory_id,
            user_id,
            job_name,
            job_address,
            job_address_latitude,
            job_address_longitude,
            job_date,
            job_time,
            initial_amount,
            job_description,
            images,
            job_approach
        }
            = req.body;

        //job time condition
        if ((job_time - 7200) < (parseInt(Date.now() / 1000))) {
            return res.status(400).json({
                'data': [],
                'message': 'Job start time should be atleast 2 hrs from current time',
                'status': 400
            });
        }

        //month filter time (used for calender jobs)
        var year = new Date((job_time * 1000)).getFullYear();
        var month = new Date((job_time * 1000)).toLocaleString('en-US', {month: 'long'});
        var month_filter = month + '-' + year;

        // get day timestamp for job time
        var year_1 = new Date((job_time * 1000)).getFullYear();
        var month_1 = new Date((job_time * 1000)).getMonth() + 1;
        var day = new Date((job_time * 1000)).getDate();

        var day_timestamp = new Date(year_1 + "-" + month_1 + "-" + day).getTime() / 1000;

        // to get time 45 minutes before of start job
        var two_hours_remind = (job_time - 2700);

        // to get time 5 minute before of start job
        var five_minutes_remind = (job_time - 300);


        var jobRef = await db.collection(collections.jobsCollection).doc();

        jobRef.create({
            category_name: category_name,
            subcategory_name: subcategory_name,
            category_id: category_id,
            subcategory_id: subcategory_id,
            user_id: user_id,
            job_name: job_name,
            job_address: job_address,
            job_address_latitude: job_address_latitude,
            job_address_longitude: job_address_longitude,
            job_date: job_date,
            job_time: job_time,
            month_filter_time: month_filter,
            day_timestamp: day_timestamp,
//notify for start job (vendor) 45 minutes and 5 minutes before time
            start_notify_time_1_vendor: two_hours_remind,
            start_notify_time_2_vendor: five_minutes_remind,
//vendor flags (for notified about job start only one time for each 45 minutes before and 5 minutes)
            already_notified_time_1_vendor: "NO",
            already_notified_time_2_vendor: "NO",
//notify for start job (owner) 45 minutes and 5 minutes before time
            start_notify_time_1_owner: two_hours_remind,
            start_notify_time_2_owner: five_minutes_remind,
//owner flags (for notified about job start only one time for each 45 minutes before and 5 minutes)
            already_notified_time_1_owner: "NO",
            already_notified_time_2_owner: "NO",
            job_end_time: job_time + 3600, // this is not the real end time of job it's just used to check bids conflict at worker end.
            is_reposted: 0,
            started_by: null,
            canceled_by: null,
            initial_amount: initial_amount,
            service_amount: null,
            job_description: job_description,
            job_vendor_id: null,
            images: images,
            owner_rated: 0,
            vendor_rated: 0,
            status: 'POSTED',
            vendor_name: null,
            vendor_email: null,
            vendor_image: null,
            vendor_description: null,
            vendor_dob: null,
            vendor_occupation: null,
            job_approach: job_approach,
            created_at: Date.now(),
            updated_at: Date.now()
        });

        await db.collection(collections.usersCollection).doc(user_id).get().then(async userData => {

            await jobRef.update({
                user_name: userData.data().name,
                user_email: userData.data().email,
                user_image: userData.data().profile_picture,
                user_occupation: userData.data().occupation,
                user_description: userData.data().profile_description,
                user_dob: userData.data().date_of_birth,
                user_average_rating: userData.data().average_rating
            });

            var body = 'Your job ' + job_name + ' has been posted successfully';
            var receiver = userData.data().name;
            var subject = 'New job posted';

            sendEmailCommon(userData.data().email, body, receiver, subject);

            return true;
        }).catch(err => {
            console.log(err);
            return false;
        });
        let message = 'Job ' + job_name + ' has been posted successfully';

        saveJobEvents(job_name, jobRef.id, message, 'POSTED', null);

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});
//Release Job Payment

routes.post('/api/owner/release-job-payment', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            job_id,
        }
            = req.body;
        var vendorData = {};
        var transactions = {};
        var jobRemoveData = {};
        let jobData = await db.collection(collections.jobsCollection).doc(job_id).get().then(jobDoc => {
            let object = {};
            object.job_id = jobDoc.id;
            object.job_name = jobDoc.data().job_name;
            object.job_address = jobDoc.data().job_address;
            object.job_time = jobDoc.data().job_time;
            object.job_date = jobDoc.data().job_date;
            object.user_id = jobDoc.data().user_id;
            object.status = jobDoc.data().status;
            jobRemoveData = object;

            let obj = jobDoc.data();
            obj.job_id = jobDoc.id;
            return obj;
        }).catch(
            err => {
                console.log(err.message);
                return false;
            });

        await db.collection(collections.transactionsCollection).where('job_id', '==', job_id).where('transaction_for', '==', 'JOB').where('status', '==', 'SUCCESS').where('transaction_type', '==', 'DEBIT').get().then(jobDoc => {
            jobDoc.forEach(doc => {
                let obj = doc.data();
                obj.doc_id = doc.id;
                transactions = obj;
            });
            return true;
        }).catch(
            err => {
                console.log(err.message);
                return false;
            });

        let userRef = await db.collection(collections.usersCollection).doc(jobData.job_vendor_id);
        userRef.get().then(userDoc => {
            userRef.update({
                credits: String(parseFloat(userDoc.data().credits) + parseFloat(jobData.service_amount))
            });
            vendorData = userDoc.data();
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        //commission part remaining

        await db.collection(collections.transactionsCollection).add({
            transaction_type: "CREDIT", //transaction type : CREDIT  DEBIT
            user_id: jobData.job_vendor_id,
            user_name: jobData.vendor_name,
            user_image: jobData.vendor_image,
            opposite_user: jobData.user_name,
            job_id: jobData.job_id,
            amount: String(jobData.service_amount),
            transaction_id: transactions.transaction_id,
            transaction_for: "JOB",     //JOB OR ADD TO WALLET
            commission: null,
            payment_option: transactions.payment_option, //WALLET OR ANY PAYMENT API(PAYPAL)
            bank_name: transactions.bank_name,
            account_number: transactions.account_number,
            status: "SUCCESS",
            created_at: Date.now(),
            updated_at: Date.now(),
        });

        await db.collection(collections.jobsCollection).doc(job_id).update({
            status: "PAID"
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
                [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveData)
            });

            docRef.update({
                [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
            });

            // worker calender
            var docRef_2 = await db.collection(collections.usersCollection).doc(jobDetail.data().job_vendor_id)
                .collection(collections.calenderCollection).doc(month_filter);

            docRef_2.update({
                [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveData)
            });

            docRef_2.update({
                [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        vendorData.fcm_token.forEach(token => {
            const body = {
                'to': token,
                'notification': {
                    title: 'Payment on job ' + jobData.job_name + ' has been released.',
                    body: jobData.job_name,
                    type: 7,
                    data: jobData.job_id,
                    sound: 'default'
                },
                content_available: true,
                mutable_content: true
            };
            sendNotification(body);
        });

        await db.collection(collections.notificationCollection).add({
            sender_id: jobData.user_id,
            receiver_id: jobData.job_vendor_id,
            sender_name: jobData.user_name,
            sender_image: jobData.user_image,
            notification_body: 'Payment on job ' + jobData.job_name + ' has been released.',
            notification_type: 7,
            job_id: jobData.job_id,
            created_at: Date.now(),
            updated_at: Date.now(),
        });

//email to vendor
        let vendor_body = 'Payment on job ' + jobData.job_name + ' has been released.';
        let vendor_receiver = jobData.vendor_name;
        let vendor_subject = 'Job payment released';

        sendEmailCommon(jobData.vendor_email, vendor_body, vendor_receiver, vendor_subject);


        let message = 'Payment on job' + jobData.job_name + ' has been released.';


        saveJobEvents(jobData.job_name, jobData.job_id, message, 'PAID', jobData.vendor_name);

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

//Job Payment

routes.post('/api/owner/job-payment', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('vendor_name').not().isEmpty().withMessage('vendor_name field is required'),
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('job_amount').not().isEmpty().withMessage('job_amount field is required'),
    check('payment_option').not().isEmpty().withMessage('payment_option field is required'),
    check('transaction_id').not().isEmpty().withMessage('transaction_id field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            user_id,
            job_id,
            payment_option,
            bank_detail_id,
            transaction_id,
            job_amount,
            vendor_name
        }
            = req.body;
        let jobData = await db.collection(collections.jobsCollection).doc(job_id).get().then(jobDoc => {
            let obj = jobDoc.data();
            obj.job_id = jobDoc.id;
            return obj;
        }).catch(
            err => {
                console.log(err.message);
                return false;
            });

        let userRef = await db.collection(collections.usersCollection).doc(user_id);
        let userData = await userRef.get().then(userDoc => {
            if (payment_option === "WALLET") {
                if (parseFloat(userDoc.data().credits) < parseFloat(job_amount)) {
                    return res.status(400).json({
                        'data': [],
                        'message': 'Insufficient balance,Please add balance in wallet ',
                        'status': 400
                    });
                }
                userRef.update({
                    credits: String(parseFloat(userDoc.data().credits) - parseFloat(job_amount))
                });
            }
            return userDoc.data();
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        var bank_name;
        var account_number;
        if (payment_option === "BANK") {
            await db.collection(collections.bankDetailsCollection).doc(bank_detail_id).get().then(bankDetail => {
                bank_name = bankDetail.data().bank;
                account_number = bankDetail.data().account_number;
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
        } else {
            bank_name = null;
            account_number = null;
        }

        await db.collection(collections.transactionsCollection).add({
            transaction_type: "DEBIT", //transaction type : CREDIT  DEBIT
            user_id: user_id,
            user_name: userData.name,
            user_image: userData.profile_picture,
            opposite_user: vendor_name,
            job_id: jobData.job_id,
            amount: String(job_amount),
            transaction_id: transaction_id,
            transaction_for: "JOB",     //JOB OR ADD TO WALLET
            commission: null,
            payment_option: payment_option, //WALLET OR ANY PAYMENT API(PAYPAL)
            bank_name: bank_name,
            account_number: account_number,
            status: "SUCCESS",
            created_at: Date.now(),
            updated_at: Date.now(),
        });

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});


//get posted jobs
routes.get('/api/owner/get-posted-jobs', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        let jobs = [];
        const user_id = req.query.user_id;
        let jobsRef = await db.collection(collections.jobsCollection);
        jobsRef.where('user_id', '==', user_id).where('status', 'in', ['POSTED']).orderBy('created_at', 'desc').get()
            .then(async snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching Jobs Found',
                        'status': 200
                    })
                }
                snapshot.forEach(async doc => {
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

//get running jobs

routes.get('/api/owner/get-running-jobs', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var jobs = [];
        const user_id = req.query.user_id;
        let jobsRef = await db.collection(collections.jobsCollection);
        jobsRef.where('user_id', '==', user_id).where('status', 'in', ['ACCEPTED', 'STARTED', 'FINISHED']).orderBy('created_at', 'desc').get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching Jobs Found',
                        'status': 200
                    })
                }
                snapshot.forEach(async doc => {
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
//job history owner

routes.get('/api/owner/get-completed-jobs', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var jobs = [];
        const user_id = req.query.user_id;
        let jobsRef = await db.collection(collections.jobsCollection);
        jobsRef.where('user_id', '==', user_id).where('status', 'in', ['PAID', 'CANCELED', 'CLOSED']).orderBy('created_at', 'desc').get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching Jobs Found',
                        'status': 200
                    })
                }
                snapshot.forEach(async doc => {
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


//get single job
routes.get('/api/owner/get-single-job', /*checkIfAuthenticated,*/ [
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var jobs;
        var obj;
        const user_id = req.query.user_id;
        const job_id = req.query.job_id;
        let jobsRef = await db.collection(collections.jobsCollection).doc(job_id);
        jobsRef.get()
            .then(async snapshot => {
                    if (!snapshot.exists) {
                        return res.status(200).json({'data': [], 'message': 'job not found', 'status': 200})
                    }
                    jobs = snapshot.data();
                    jobs.job_id = snapshot.id;
                    jobs.bids = [];
                    await db.collection(collections.bidsCollection).where('job_id', '==', snapshot.id).get()
                        .then(async snapshot2 => {
                            snapshot2.forEach(async doc2 => {
                                if (doc2.data().vendor_status !== 'CANCELED') {
                                    obj = doc2.data();
                                    obj.bid_id = doc2.id;
                                    jobs.bids.push(obj);
                                }
                            });
                            return true;
                        }).catch(err => {
                            console.log(err.message);
                            return false;
                        });

                    return res.status(200).json({data: jobs, 'message': 'Success', 'status': 200})
                }
            ).catch(err => {
            return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//Edit job
routes.post('/api/owner/edit-job', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('category_id').not().isEmpty().withMessage('category_id field is required'),
    check('category_name').not().isEmpty().withMessage('category_name field is required'),
    check('subcategory_name').not().isEmpty().withMessage('subcategory_name field is required'),
    check('subcategory_id').not().isEmpty().withMessage('subcategory_id field is required'),
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('job_name').not().isEmpty().withMessage('job_name field is required'),
    check('job_approach').not().isEmpty().withMessage('job_approach field is required'),
    check('job_address').not().isEmpty().withMessage('job_address field is required'),
    check('job_date').not().isEmpty().withMessage('job_date field is required'),
    check('job_time').not().isEmpty().withMessage('job_time field is required'),
    check('initial_amount').not().isEmpty().withMessage('initial_amount field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            job_id,
            category_id,
            category_name,
            subcategory_name,
            subcategory_id,
            user_id,
            job_name,
            job_approach,
            job_address,
            job_address_latitude,
            job_address_longitude,
            job_date,
            job_time,
            initial_amount,
            job_description,
            images
        }
            = req.body;

        //2 hrs restriction managed at front end (for edit job)

        // if ((job_time - 7200) < (parseInt(Date.now() / 1000))) {
        //     return res.status(400).json({
        //         'data': [],
        //         'message': 'Job start time should be atleast 2 hrs from current time',
        //         'status': 400
        //     });
        // }

        // to get time 45 minutes before of start job
        var two_hours_remind = (job_time - 2700);

        // // to get time 5 minute before of start job
        var five_minutes_remind = (job_time - 300);


        //month filter time
        var year = new Date((job_time * 1000)).getFullYear();
        var month = new Date((job_time * 1000)).toLocaleString('en-US', {month: 'long'});
        var month_filter = month + '-' + year;

        //
        var year_1 = new Date((job_time * 1000)).getFullYear();
        var month_1 = new Date((job_time * 1000)).getMonth() + 1;
        var day = new Date((job_time * 1000)).getDate();

        var day_timestamp = new Date(year_1 + "-" + month_1 + "-" + day).getTime() / 1000;


        await db.collection(collections.jobsCollection).doc(job_id)
            .update({
                category_name: category_name,
                subcategory_name: subcategory_name,
                category_id: category_id,
                subcategory_id: subcategory_id,
                user_id: user_id,
                job_name: job_name,
                job_approach: job_approach,
                job_address: job_address,
                job_address_latitude: job_address_latitude,
                job_address_longitude: job_address_longitude,
                job_date: job_date,
                job_time: job_time,
                month_filter_time: month_filter,
                day_timestamp: day_timestamp,
                start_notify_time_1_vendor: two_hours_remind,
                start_notify_time_2_vendor: five_minutes_remind,
                start_notify_time_1_owner: two_hours_remind,
                start_notify_time_2_owner: five_minutes_remind,
                initial_amount: initial_amount,
                job_description: job_description,
                images: images,
                updated_at: Date.now()
            });

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});


//cancel a job

routes.post('/api/owner/cancel-job', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const job_id = req.body.job_id;
        const user_id = req.body.user_id;
        var job_data = {};
        var vendor_data = {};
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

        let jobRef = await db.collection(collections.jobsCollection).doc(job_id);

        await jobRef.update({
            status: 'CANCELED',
            canceled_by: 'HIRE'
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

            if (doc.data().status !== 'POSTED') {
                var remaining_amount = (doc.data().service_amount - ((doc.data().service_amount) * 15 / 100));
                await db.collection(collections.usersCollection).doc(doc.data().user_id).get().then(async userDoc => {
                    await db.collection(collections.usersCollection).doc(doc.data().user_id).update({
                        credits: String(parseFloat(userDoc.data().credits) + parseFloat(remaining_amount))
                    });
                    return true;
                }).catch((err) => {
                    console.log(err.message);
                    return false;
                });

            }
            let obj = doc.data();
            obj.job_id = doc.id;
            job_data = obj;
            if (doc.data().job_vendor_id !== null) {
                vendor_data = await db.collection(collections.usersCollection).doc(doc.data().job_vendor_id).get().then(userSnapshot => {
                    obj = userSnapshot.data();
                    obj.user_id = userSnapshot.id;
                    return obj;
                }).catch(() => {
                    return {};
                });
            }
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        if (Object.keys(vendor_data).length !== 0) {
            vendor_data.fcm_token.forEach(token => {
                const body = {
                    'to': token,
                    'notification': {
                        title: 'Job ' + job_data.job_name + 'has been canceled by owner.',
                        body: job_data.job_name,
                        type: 13,
                        data: job_data.job_id,
                        sound: 'default'
                    },
                    content_available: true,
                    mutable_content: true
                };
                sendNotification(body);
            });

            await db.collection(collections.notificationCollection).add({
                sender_id: job_data.user_id,
                receiver_id: job_data.job_vendor_id,
                sender_name: job_data.user_name,
                sender_image: job_data.user_image,
                notification_body: 'Job ' + job_data.job_name + 'has been canceled by owner.',
                notification_type: 13,
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


// bid-action (accept or reject)
routes.post('/api/owner/bid-action', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('bid_id').not().isEmpty().withMessage('bid_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const job_id = req.body.job_id;
        const bid_id = req.body.bid_id;
        const status = req.body.status;

        var jobRemoveRef = await db.collection(collections.jobsCollection).doc(job_id).get().then(jobSnapshot => {
            let obj = {};
            obj.job_id = jobSnapshot.id;
            obj.job_name = jobSnapshot.data().job_name;
            obj.job_address = jobSnapshot.data().job_address;
            obj.job_time = jobSnapshot.data().job_time;
            obj.job_date = jobSnapshot.data().job_date;
            obj.user_id = jobSnapshot.data().user_id;
            obj.status = jobSnapshot.data().status;
            return obj;
        }).catch(() => {
            return {};
        });
        await db.collection(collections.bidsCollection).doc(bid_id).update({
            owner_status: status,
            updated_at: Date.now()
        });
        await db.collection(collections.bidsCollection).doc(bid_id).get()
            .then(async snapshot => {
                    if (!snapshot.exists) {
                        return res.status(200).json({'data': [], 'message': 'bid not found', 'status': 200})
                    }
                    var obj = {};
                    var userDetail = await db.collection(collections.usersCollection).doc(snapshot.data().vendor_id).get().then(userSnapshot => {
                        obj = userSnapshot.data();
                        obj.user_id = userSnapshot.id;
                        return obj;
                    }).catch(() => {
                        return {};
                    });

                    if (status === "ACCEPTED") {

                        await db.collection(collections.jobsCollection).doc(job_id).update({
                            status: status,
                            job_vendor_id: snapshot.data().vendor_id,
                            vendor_name: userDetail.name,
                            vendor_email: userDetail.email,
                            vendor_image: userDetail.profile_picture,
                            vendor_description: userDetail.profile_description,
                            vendor_occupation: userDetail.occupation,
                            vendor_dob: userDetail.date_of_birth,
                            vendor_average_rating: userDetail.average_rating,
                            service_amount: snapshot.data().counteroffer_amount,
                            comment: snapshot.data().comment,
                            updated_at: Date.now()
                        });

                        await db.collection(collections.bidsCollection).doc(bid_id).update({
                            bid_show_status: "NO"
                        });

                        let jobDetails = await db.collection(collections.jobsCollection).doc(job_id).get().then(async jobDoc => {
                            let obj_2 = {};
                            obj_2.job_id = jobDoc.id;
                            obj_2.job_name = jobDoc.data().job_name;
                            obj_2.job_address = jobDoc.data().job_address;
                            obj_2.job_time = jobDoc.data().job_time;
                            obj_2.job_date = jobDoc.data().job_date;
                            obj_2.user_id = jobDoc.data().user_id;
                            obj_2.status = jobDoc.data().status;

                            var year = new Date((jobDoc.data().job_time * 1000)).getFullYear();
                            var month = new Date((jobDoc.data().job_time * 1000)).toLocaleString('en-US', {month: 'long'});
                            var month_filter = month + '-' + year;
                            var day = new Date((jobDoc.data().job_time * 1000)).getDate();
                            // user calender

                            var docRef = await db.collection(collections.usersCollection).doc(jobDoc.data().user_id)
                                .collection(collections.calenderCollection).doc(month_filter);

                            docRef.update({
                                [day]: admin.firestore.FieldValue.arrayRemove(jobRemoveRef)
                            });

                            docRef.update({
                                [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
                            });

                            // worker calender
                            var docRef_2 = await db.collection(collections.usersCollection).doc(snapshot.data().vendor_id)
                                .collection(collections.calenderCollection).doc(month_filter);

                            docRef_2.update({
                                [day]: admin.firestore.FieldValue.arrayUnion(obj_2)
                            });

                            var jobData = jobDoc.data();
                            jobData.job_id = jobDoc.id;
                            return jobData;
                        }).catch(err => {
                            console.log(err.message);
                            return false;
                        });
                        // console.log(jobDetails);

                        // Other bids that not get accepted yet and conflict with current job's job_time gets deleted with given code

                        await db.collection(collections.bidsCollection).where('vendor_id', '==', snapshot.data().vendor_id)
                            .where('vendor_status', '==', 'ACCEPTED')
                            .where('owner_status', '==', 'POSTED')
                            .get()
                            .then(removeBids => {
                                removeBids.forEach(rmBid => {
                                    //delete other bids of worker which conflict with current job_time
                                    if (snapshot.data().job_time <= rmBid.data().job_time && ((snapshot.data().job_end_time + 3600) >= rmBid.data().job_time)) {
                                        rmBid.ref.delete();
                                    }
                                });
                                return true;
                            }).catch(err => {
                                console.log(err.message);
                                return false;
                            })

                        userDetail.fcm_token.forEach(token => {
                            const body = {
                                'to': token,
                                'notification': {
                                    title: 'Your bid accepted by ' + jobDetails.user_name,
                                    body: jobDetails.job_name,
                                    type: 3,
                                    data: jobDetails.job_id,
                                    sound: 'default'
                                },
                                content_available: true,
                                mutable_content: true
                            };
                            sendNotification(body);
                        });

                        await db.collection(collections.notificationCollection).add({
                            sender_id: jobDetails.user_id,
                            receiver_id: userDetail.user_id,
                            sender_name: jobDetails.user_name,
                            sender_image: jobDetails.user_image,
                            notification_body: 'Your bid accepted by ' + jobDetails.user_name,
                            notification_type: 3,
                            job_id: jobDetails.job_id,
                            created_at: Date.now(),
                            updated_at: Date.now(),
                        });
                        let message = 'Bid On job' + jobDetails.job_name + ' has been accepted successfully';


                        saveJobEvents(jobDetails.job_name, jobDetails.job_id, message, 'ACCEPTED', userDetail.name);


                        let body = 'Congratulations, Your bid on job ' + jobDetails.job_name + ' has been accepted successfully';
                        let receiver = userDetail.name;
                        let subject = 'Bid accepted';

                        sendEmailCommon(userDetail.email, body, receiver, subject);

                    } else if (status === "REJECTED") {
                        let jobData;
                        let jobDetails = await db.collection(collections.jobsCollection).doc(job_id).get().then(jobDoc => {
                            jobData = jobDoc.data();
                            jobData.job_id = jobDoc.id;
                            return jobData;
                        }).catch(err => {
                            console.log(err.message);
                            return false;
                        });
                        console.log(jobDetails);

                        userDetail.fcm_token.forEach(token => {
                            const body = {
                                'to': token,
                                'notification': {
                                    title: 'Your bid Rejected by ' + jobDetails.user_name,
                                    body: jobDetails.job_name,
                                    type: 4,
                                    data: jobDetails.job_id,
                                    sound: 'default'
                                },
                                content_available: true,
                                mutable_content: true
                            };
                            sendNotification(body);

                        });
                        await db.collection(collections.notificationCollection).add({
                            sender_id: jobDetails.user_id,
                            receiver_id: userDetail.user_id,
                            sender_name: jobDetails.user_name,
                            sender_image: jobDetails.user_image,
                            notification_body: 'Your bid Rejected by ' + jobDetails.user_name,
                            notification_type: 4,
                            job_id: jobDetails.job_id,
                            created_at: Date.now(),
                            updated_at: Date.now(),
                        });


                        let body = 'Your bid on job ' + jobDetails.job_name + ' has been rejected.';
                        let receiver = userDetail.name;
                        let subject = 'Bid rejected';

                        sendEmailCommon(userDetail.email, body, receiver, subject);

                    }

                    return res.status(200).json({data: [], 'message': 'Success', 'status': 200})
                }
            )
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

//manage repost data for jobs

routes.post('/api/owner/manage-job-repost', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const job_id = req.body.job_id;
        await db.collection(collections.jobsCollection).doc(job_id).update({
            is_reposted: 1
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

//job start confirmation

routes.post('/api/owner/start-approval', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const job_id = req.body.job_id;
        var jobData = {};
        var vendorData = {};
        await db.collection(collections.jobsCollection).doc(job_id).update({
            started_by: "HIRE"
        });

        await db.collection(collections.jobsCollection).doc(job_id).get().then(jobDoc => {
            let obj = jobDoc.data();
            obj.job_id = jobDoc.id;
            jobData = obj;
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        await db.collection(collections.usersCollection).doc(jobData.job_vendor_id).get().then(userDoc => {
            let obj2 = userDoc.data();
            obj2.vendor_id = userDoc.id;
            vendorData = obj2;
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        vendorData.fcm_token.forEach(token => {
            const body = {
                'to': token,
                'notification': {
                    title: 'Your job ' + jobData.job_name + ' has been approved for start',
                    body: jobData.job_name,
                    type: 16,
                    data: jobData.job_id,
                    sound: 'default'
                },
                content_available: true,
                mutable_content: true
            };
            sendNotification(body);
        });

        await db.collection(collections.notificationCollection).add({
            sender_id: jobData.user_id,
            receiver_id: jobData.job_vendor_id,
            sender_name: jobData.user_name,
            sender_image: jobData.user_image,
            notification_body: 'Your job ' + jobData.job_name + ' has been approved for start',
            notification_type: 16,
            job_id: jobData.job_id,
            created_at: Date.now(),
            updated_at: Date.now(),
        });

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});


module.exports = routes;
