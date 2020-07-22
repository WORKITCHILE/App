var admin = require("firebase-admin");

const routes = require('express').Router();
const collections = require('../collections');
const db = admin.firestore();
const {check, validationResult} = require('express-validator');
const checkIfAuthenticated = require('../middleware/CheckAuthentication').checkIfAuthenticated;
const sendNotification = require('../helper').sendNotification;


//get all Users
routes.get('/api/admin/get-' + collections.usersCollection, /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var users = [];
        let usersRef = await db.collection(collections.usersCollection);
        usersRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Users Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.user_id = doc.id;
                    users.push(obj);
                });
                return res.status(200).json({'data': users, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//add category
routes.post('/api/admin/add-category', /*checkIfAuthenticated,*/[
    //validation
    check('category_name').not().isEmpty().withMessage('category_name field is required'),
    check('category_image').not().isEmpty().withMessage('category_image field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            category_name,
            category_image,
        }
            = req.body;
        await db.collection(collections.categoriesCollection)
            .add({
                category_name: category_name,
                category_image: category_image,
                created_at: Date.now(),
                updated_at: Date.now()
            });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});
//add subcategory
routes.post('/api/admin/add-subcategory', /*checkIfAuthenticated,*/[
    //validation
    check('subcategory_name').not().isEmpty().withMessage('subcategory_name field is required'),
    check('subcategory_image').not().isEmpty().withMessage('subcategory_image field is required'),
    check('category_id').not().isEmpty().withMessage('category_id field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            subcategory_name,
            subcategory_image,
            category_id
        }
            = req.body;
        await db.collection(collections.categoriesCollection).doc(category_id).get().then(async category => {
            await db.collection(collections.subcategoriesCollection)
                .add({
                    subcategory_name: subcategory_name,
                    subcategory_image: subcategory_image,
                    category_id: category_id,
                    category_name: category.data().category_name,
                    created_at: Date.now(),
                    updated_at: Date.now()
                });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});
// BY KAPIL
routes.get('/api/admin/get-' + collections.jobsCollection, /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var users = [];
        let usersRef = await db.collection(collections.usersCollection);
        usersRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Users Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.user_id = doc.id;
                    users.push(obj);
                });
                return res.status(200).json({'data': users, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

routes.get('/api/admin/get-collection-by-name/:name/:page/:per_page', /*checkIfAuthenticated,*/ async (req, res) => {

    try {
        let collectionName = req.params.name;
        let page = parseInt(req.params.page);
        let per_page = parseInt(req.params.per_page);
        let startAt;
        let count;
        let search = req.query.search;
        var data = [];
        if (page === 1) {
            startAt = 1;
        } else {
            startAt = (page - 1) * per_page + 1;
        }

        let collectionRef = await db.collection(collectionName).orderBy('created_at', 'desc').offset(startAt - 1).limit(per_page);
        //  let searchRef;
        //   if(collectionName === 'users')
        //   {
        // searchRef = collectionRef.where('name', '>=', search).where('name', '<=', search + '\uf8ff');
        //   }
        //   else if(collectionName === 'jobs')
        //   {
        //       searchRef = collectionRef.where('job_name', '>=', search).where('job_name', '<=', search + '\uf8ff');
        //   }
        //   else if(collectionName === 'bids')
        //   {
        //       searchRef = collectionRef.where('job_name', '>=', search).where('job_name', '<=', search + '\uf8ff');
        //   }

        collectionRef.get()
            .then(async snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No data Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    console.log(doc.data());
                    var obj = doc.data();
                    obj.doc_id = doc.id;
                    data.push(obj);
                });
                await db.collection(collectionName).get().then(countSnap => {
                    count = countSnap.size;
                    return true
                }).catch(err => {
                    console.log(err);
                    return false;
                });
                return res.status(200).json({'data': data, 'total': count, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

routes.get('/api/admin/get-single-document-by-id/:name/:id', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        let collectionName = req.params.name;
        let docId = req.params.id;
        let collectionRef = await db.collection(collectionName).doc(docId);
        collectionRef.get()
            .then(async snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No data Found',
                        'status': 200
                    })
                }
                let data = snapshot.data();
                data.doc_id = snapshot.id;
                if (collectionName === 'jobs') {
                    data.bids = [];
                    await db.collection(collections.bidsCollection).where('job_id', '==', snapshot.id).get()
                        .then(snapshot2 => {
                            snapshot2.forEach(doc2 => {
                                data.bids.push(doc2.data());
                                return true;
                            });
                            return true;
                        }).catch(err => {
                            console.log(err);
                            return false;
                        });
                }
                if (collectionName === 'users') {
                    data.projects = [];
                    await db.collection(collections.jobsCollection).where('user_id', '==', snapshot.id).get()
                        .then(snapshot2 => {
                            snapshot2.forEach(doc2 => {
                                let obj = doc2.data();
                                obj.project_id = doc2.id;
                                data.projects.push(obj);
                                return true;
                            });
                            return true;
                        }).catch(err => {
                            console.log(err);
                            return false;
                        });
                }
                return res.status(200).json({'data': data, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
// terms and conditions

routes.post('/api/admin/tnc', /*checkIfAuthenticated,*/[
    //validation
    check('terms_and_conditions').not().isEmpty().withMessage('terms_and_conditions field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            terms_and_conditions,
        }
            = req.body;

        var tncObject;
        let tncData = await db.collection(collections.termsAndConditionsCollection).get().then(tnc => {
            tnc.forEach(tncRef => {
                var obj = tncRef.data();
                obj.tnc_id = tncRef.id;
                tncObject = obj;
            });
            return tncObject;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        if (typeof tncData === "undefined") {
            console.log(tncData);
            await db.collection(collections.termsAndConditionsCollection)
                .add({
                    terms_and_conditions: terms_and_conditions,
                    created_at: Date.now(),
                    updated_at: Date.now()
                });
        } else {
            await db.collection(collections.termsAndConditionsCollection).doc(tncData.tnc_id)
                .update({
                    terms_and_conditions: terms_and_conditions,
                    updated_at: Date.now()
                });
        }
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

routes.post('/api/admin/edit-user', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('email').not().isEmpty().withMessage('email field is required').isEmail().withMessage("Incorrect email"),
    check('name').not().isEmpty().withMessage('name field is required'),
    check('date_of_birth').not().isEmpty().withMessage('date_of_birth field is required'),
    check('address').not().isEmpty().withMessage('address field is required'),
    check('contact_number').not().isEmpty().withMessage('contact_number field is required'),
    check('nationality').not().isEmpty().withMessage('nationality field is required'),
    check('profile_description').not().isEmpty().withMessage('profile_description field is required'),
    check('father_last_name').not().isEmpty().withMessage('father_last_name field is required'),
    check('mother_last_name').not().isEmpty().withMessage('mother_last_name field is required'),
    check('id_number').not().isEmpty().withMessage('id_number field is required'),
    check('occupation').not().isEmpty().withMessage('occupation is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            user_id,
            name,
            email,
            date_of_birth,
            address,
            contact_number,
            nationality,
            profile_description,
            father_last_name,
            mother_last_name,
            id_number,
            occupation,
        }
            = req.body;

        await admin.auth().updateUser(user_id, {
            email,
            phoneNumber: contact_number,
            displayName: name
        });

        await db.collection(collections.usersCollection).doc(user_id)
            .update({
                name: name,
                email: email,
                date_of_birth: date_of_birth,
                address: address,
                contact_number: contact_number,
                nationality: nationality,
                profile_description: profile_description,
                father_last_name: father_last_name,
                mother_last_name: mother_last_name,
                id_number: id_number,

                occupation: occupation,
                updated_at: Date.now()
            });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

routes.post('/api/admin/edit-category', /*checkIfAuthenticated,*/[
    //validation
    check('category_id').not().isEmpty().withMessage('category_id field is required'),
    check('category_name').not().isEmpty().withMessage('category_name field is required'),
    check('category_image').not().isEmpty().withMessage('category_image field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            category_id,
            category_name,
            category_image
        }
            = req.body;

        await db.collection(collections.categoriesCollection).doc(category_id)
            .update({
                category_name: category_name,
                category_image: category_image,
                updated_at: Date.now()
            });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});


routes.post('/api/admin/edit-subcategory', /*checkIfAuthenticated,*/[
    //validation
    check('subcategory_id').not().isEmpty().withMessage('subcategory_id field is required'),
    check('category_id').not().isEmpty().withMessage('category_id field is required'),
    check('subcategory_name').not().isEmpty().withMessage('subcategory_name field is required'),
    check('subcategory_image').not().isEmpty().withMessage('subcategory_image field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            subcategory_id,
            category_id,
            subcategory_name,
            subcategory_image
        }
            = req.body;

        await db.collection(collections.subcategoriesCollection).doc(subcategory_id)
            .update({
                category_id: category_id,
                subcategory_name: subcategory_name,
                subcategory_image: subcategory_image,
                updated_at: Date.now()
            });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

routes.get('/api/admin/get-dashboard-counts', /*checkIfAuthenticated,*/ async (req, res) => {
    try {

        let jobsCount = await db.collection(collections.jobsCollection).get().then(jobs => {
            return jobs.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        let activeJobsCount = await db.collection(collections.jobsCollection).where('status', 'in', ['POSTED', 'ACCEPTED', 'STARTED']).get().then(jobs => {
            return jobs.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        let bidsCount = await db.collection(collections.bidsCollection).get().then(bids => {
            return bids.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        let QueryCount = await db.collection(collections.supportsCollection).get().then(support => {
            return support.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        let usersCount = await db.collection(collections.usersCollection).get().then(users => {
            return users.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        let categories = await db.collection(collections.categoriesCollection).get().then(categories => {
            return categories.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        let hireUsersCount = await db.collection(collections.usersCollection).where('type', '=', 'HIRE').get().then(users => {
            return users.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        let workUsersCount = await db.collection(collections.usersCollection).where('type', '=', 'WORK').get().then(users => {
            return users.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });


        return res.status(200).json({
            'total_users': usersCount,
            'total_jobs': jobsCount,
            'active_jobs': activeJobsCount,
            'total_bids': bidsCount,
            'total_query': QueryCount,
            'total_categories': categories,
            'hire_count': hireUsersCount,
            'work_count': workUsersCount,
            'message': 'Success',
            'status': 200
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
//get job event history
routes.get('/api/admin/get-event-history', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }

    try {
        const job_id = req.query.job_id;
        var job_history = [];
        let eventHistory = await db.collection(collections.jobEventHistoryColleciton).where('job_id', '=', job_id).get().then(history => {
            history.forEach(data => {
                let obj = data.data();
                obj.doc_id = data.id;
                job_history.push(obj);
            });
            return true;

        }).catch(err => {
            console.log(err.message);
            return false;
        });
        return res.status(200).json({
            'data': job_history,
            'message': 'Success',
            'status': 200
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});


routes.get('/api/admin/get-all-bids', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var bids = [];
        const search = req.query.search;
        // var filter = req.query.filter;
        // var start_at = req.query.start_at;
        // var end_at = req.query.end_at;

        // search code
        // let searchRef;
        //
        // if(search){
        //     searchRef = bidRef.where('job_name', '>=', search).where('job_name', '<=', search + '\uf8ff');
        // }
        // else{
        //     searchRef = bidRef;
        // }
        let bidRef = await db.collection(collections.bidsCollection).get().then(bidsSnap => {
            bidsSnap.forEach(bidsData => {
                let obj = bidsData.data();
                obj.bid_id = bidsData.id;
                bids.push(obj);
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        return res.status(200).json({
            'data': bids,
            'message': 'Success',
            'status': 200
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

routes.post('/api/admin/manage-user-account', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id').withMessage('user_id field is required'),
    check('status').not().isEmpty().withMessage('status').withMessage('status field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            user_id,
            status
        }
            = req.body;
        if (status === 'INACTIVE') {
            await admin.auth().updateUser(user_id, {
                disabled: true
            });

            await db.collection(collections.usersCollection).doc(user_id).update({
                status: "INACTIVE"
            });


        } else if (status === "ACTIVE") {
            await admin.auth().updateUser(user_id, {
                disabled: false
            });

            await db.collection(collections.usersCollection).doc(user_id).update({
                status: "ACTIVE"
            });
        }
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

routes.get('/api/admin/get-ratings', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var ratings = [];

        await db.collection(collections.ratingsCollection).get().then(ratingSnap => {

            ratingSnap.forEach(ratingData => {

                let obj = ratingData.data();
                obj.rating_id = ratingData.id;
                ratings.push(obj);

            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        return res.status(200).json({
            'data': ratings,
            'message': 'Success',
            'status': 200
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

routes.get('/api/admin/recent-activities-by-collection/:name', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var name = req.params.name;
        var data = [];
        if (name === "jobs") {
            await db.collection(collections.jobsCollection).orderBy('created_at', 'desc').limit(8).get().then(jobSnap => {

                jobSnap.forEach(jobData => {

                    let obj = jobData.data();
                    obj.job_id = jobData.id;
                    data.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

        } else if (name === "supports") {
            await db.collection(collections.supportsCollection).orderBy('created_at', 'desc').limit(8).get().then(supportSnap => {

                supportSnap.forEach(supportData => {
                    let obj = supportData.data();
                    obj.support_id = supportData.id;
                    data.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

        }

        return res.status(200).json({
            'data': data,
            'message': 'Success',
            'status': 200
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

routes.get('/api/admin/recent-activities-by-collection/:name', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var name = req.params.name;
        var data = [];
        if (name === "jobs") {
            await db.collection(collections.jobsCollection).orderBy('created_at', 'desc').limit(8).get().then(jobSnap => {

                jobSnap.forEach(jobData => {

                    let obj = jobData.data();
                    obj.job_id = jobData.id;
                    data.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

        } else if (name === "supports") {
            await db.collection(collections.supportsCollection).orderBy('created_at', 'desc').limit(8).get().then(supportSnap => {

                supportSnap.forEach(supportData => {
                    let obj = supportData.data();
                    obj.support_id = supportData.id;
                    data.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

        }

        return res.status(200).json({
            'data': data,
            'message': 'Success',
            'status': 200
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

//category delete by admin api
routes.post('/api/admin/delete-category', /*checkIfAuthenticated,*/ [
    check('category_id').not().isEmpty().withMessage('category_id'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        const category_id = req.body.category_id;
        await db.collection(collections.categoriesCollection).doc(category_id).delete();
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});
//subcategory delete by admin api
routes.post('/api/admin/delete-subcategory', /*checkIfAuthenticated,*/ [
    check('subcategory_id').not().isEmpty().withMessage('subcategory_id'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        const subcategory_id = req.body.subcategory_id;
        await db.collection(collections.subcategoriesCollection).doc(subcategory_id).delete();
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});


//support action by admin api
routes.post('/api/admin/support-action', /*checkIfAuthenticated,*/ [
    check('support_id').not().isEmpty().withMessage('support_id'),
    check('status').not().isEmpty().withMessage('status')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        const support_id = req.body.support_id;
        const status = req.body.status;

        await db.collection(collections.supportsCollection).doc(support_id).update({
            status: status,  // 1 UNDER_REVIEW 2 INITIATED 3 DECLINED 4 RESOLVED
            updated_at: Date.now()
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

//Graph data (issue with graph data)
routes.get('/api/admin/graphs-data', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var categories = [];
        var data = [];
        //categories allotted to jobs
        await db.collection(collections.categoriesCollection).get().then(catRef => {
            catRef.forEach(cat => {
                var obj = cat.data();
                obj.category_id = cat.id;
                categories.push(obj);
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        var jobRef = await db.collection(collections.jobsCollection);

        for (var category of categories) {
            jobRef.where('category_id', '==', category.category_id)
                .get()
                .then(jobCount => {
                    var obj = {};
                    obj.category = category.category_name;
                    obj.total = jobCount.size;
                    data.push(obj);
                    console.log(data);
                    return true;
                }).catch(err => {
                console.log(err.message);
                return false;
            });
            console.log(data);
        }
        return res.status(200).json({
            'data': data,
            'message': 'Success',
            'status': 200
        });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});


module.exports = routes;

