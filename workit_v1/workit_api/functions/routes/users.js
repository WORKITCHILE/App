var admin = require("firebase-admin");

const routes = require('express').Router();
const collections = require('../collections');
const db = admin.firestore();
const {check, validationResult} = require('express-validator');

const checkIfAuthenticated = require('../middleware/CheckAuthentication').checkIfAuthenticated;
const sendNotification = require('../helper').sendNotification;
const sendEmailCommon = require('../helper').sendEmailCommon;
const md5 = require('../helper').md5;

//delete job image
routes.post('/api/users/delete-job-image', [
    check('file_path').not().isEmpty().withMessage('file_path field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        const job_id = req.body.job_id;
        const url = req.body.url;
        const filepath = req.body.file_path;
        // await bucket.file(filepath).delete();
        if (typeof job_id !== 'undefined') {
            var jobRef = await db.collection(collections.jobsCollection).doc(job_id);

            jobRef.update({
                images: admin.firestore.FieldValue.arrayRemove(url)
            });
        }
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

//save message list (chat)
routes.post('/api/users/save-message-list',/*checkIfAuthenticated,*/[
    check('sender').not().isEmpty().withMessage('sender field is required'),
    check('receiver').not().isEmpty().withMessage('receiver field is required'),
    check('sender_type').not().isEmpty().withMessage('sender_type field is required'),
    check('receiver_type').not().isEmpty().withMessage('receiver_type field is required'),
    check('last_message').not().isEmpty().withMessage('last_message field is required'),
    check('last_message_by').not().isEmpty().withMessage('last_message_by field is required'),
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('message_type').not().isEmpty().withMessage('message_type field is required'),

], async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
        }
        var messageCheck;
        const {
            sender,
            receiver,
            sender_type,
            receiver_type,
            last_message,
            last_message_by,
            message_type,
            job_id
        }
            = req.body;
        await db.collection(collections.usersCollection).doc(sender).get().then(async senderData => {
            let notificationBody;
            if (message_type === 1) {
                notificationBody = last_message
            } else if (message_type === 2) {
                notificationBody = "New image received";

            }
            await db.collection(collections.usersCollection).doc(receiver).get().then(receiverDetails => {

                receiverDetails.data().fcm_token.forEach(token => {
                    const body = {
                        'to': token,
                        'notification': {
                            title: 'New Message From ' + senderData.data().name,
                            body: notificationBody,
                            type: 9,
                            data: last_message,
                            sound: 'default'
                        },
                        content_available: true,
                        mutable_content: true
                    };
                    sendNotification(body);
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

        let check = await db.collection(collections.messageListCollection).where('job_id', '==', job_id)
            .where('sender', '==', sender)
            .where('receiver', '==', receiver).get()
            .then(messageDetails => {
                messageDetails.forEach(data => {
                    messageCheck = data.data();
                    messageCheck.message_list_id = data.id;
                });
                return messageCheck;
            })
            .catch(err => {
                console.log(err.message);
                return false;
            });
        let chatRef;
        if (check) {
            chatRef = await db.collection(collections.messageListCollection).where('job_id', '==', job_id).get()
                .then(chatDoc => {
                    chatDoc.forEach(chat => {
                        const chatRef = db.collection(collections.messageListCollection).doc(chat.id);
                        chatRef.update({
                            last_message: last_message,
                            last_message_by: last_message_by,
                            updated_at: Date.now()
                        });
                    });
                    return true;
                })
                .catch(err => {
                    console.log(err.message);
                    return false;
                });
        } else {
            chatRef = await db.collection(collections.messageListCollection)
                .add({
                    sender: sender,
                    receiver: receiver,
                    sender_type: sender_type,
                    receiver_type: receiver_type,
                    last_message: last_message,
                    last_message_by: last_message_by,
                    job_id: job_id,
                    created_at: Date.now(),
                    updated_at: Date.now()
                });

            await db.collection(collections.usersCollection).doc(sender).get().then(senderDetails => {
                console.log(senderDetails.data());
                chatRef.update({
                    sender_name: senderDetails.data().name,
                    sender_image: senderDetails.data().profile_picture
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

            await db.collection(collections.usersCollection).doc(receiver).get().then(receiverDetails => {
                chatRef.update({
                    receiver_name: receiverDetails.data().name,
                    receiver_image: receiverDetails.data().profile_picture
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

            chatRef = await db.collection(collections.messageListCollection)
                .add({
                    sender: receiver,
                    receiver: sender,
                    sender_type: sender_type,
                    receiver_type: receiver_type,
                    last_message: last_message,
                    last_message_by: last_message_by,
                    job_id: job_id,
                    created_at: Date.now(),
                    updated_at: Date.now()
                });

            await db.collection(collections.usersCollection).doc(receiver).get().then(senderDetails => {
                console.log(senderDetails.data());
                chatRef.update({
                    sender_name: senderDetails.data().name,
                    sender_image: senderDetails.data().profile_picture
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

            await db.collection(collections.usersCollection).doc(sender).get().then(receiverDetails => {
                chatRef.update({
                    receiver_name: receiverDetails.data().name,
                    receiver_image: receiverDetails.data().profile_picture
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });

        }
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

// get message list
routes.get('/api/users/message-list', /*checkIfAuthenticated,*/ [
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    try {
        var list = [];
        var user_id = req.query.user_id;
        await db.collection(collections.messageListCollection).where('receiver', '==', user_id).get().then(snapshot => {
            snapshot.forEach(data => {
                list.push(data.data());
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        return res.status(200).json({'data': list, 'message': 'Success', 'status': 200});
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

//get user profile
routes.get('/api/users/get-profile', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var user;
        var user_id = req.query.user_id;
        await db.collection(collections.usersCollection).doc(user_id).get().then((snapshot) => {
            if (typeof snapshot.data() !== "undefined") {
                user = snapshot.data();
                user.user_id = snapshot.id;
                return res.status(200).json({'data': user, 'message': 'Success', 'status': 200})
            } else {
                return res.status(200).json({'data': [], 'message': 'User Not Found', 'status': 200});
            }

        }).catch(err => {
            return res.status(500).json({'data': [], 'message': err, 'status': 500})
        });
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});
//get categories
routes.get('/api/users/get-categories', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var categories = [];
        await db.collection(collections.categoriesCollection).get().then((snapshot) => {
            snapshot.docs.forEach(doc => {
                var obj = doc.data();
                obj.category_id = doc.id;
                categories.push(obj);
            });
            return res.status(200).json({'data': categories, 'message': 'Success', 'status': 200})
        }).catch(err => {
            return res.status(500).json({'data': [], 'message': err, 'status': 500})
        });
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});
//check user exists or not

routes.get('/api/users/check-user-exists', [
    check('type').not().isEmpty().withMessage('type field is required'),
    check('social_handle').not().isEmpty().withMessage('social_handle field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var user_detail;
        var existUserRef;
        const type = req.query.type;
        const social_handle = req.query.social_handle;
        if (type === "1" || type === 1) {
            existUserRef = await db.collection(collections.usersCollection).where('google_handle', '==', social_handle).get().then(user => {
                var obj = {};
                user.forEach(userData => {
                    obj = userData.data();
                    obj.user_id = userData.id;
                });
                return obj;

            }).catch(err => {
                console.log(err);
                return false;
            });
        } else if (type === "2" || type === 2) {
            existUserRef = await db.collection(collections.usersCollection).where('facebook_handle', '==', social_handle).get().then(user => {
                var obj = {};
                user.forEach(userData => {
                    obj = userData.data();
                    obj.user_id = userData.id;
                });
                return obj;
            }).catch(err => {
                console.log(err);
                return false;
            });
        }
        return res.status(200).json({'data': existUserRef, 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});


//user signup
routes.post('/api/users/sign-up', [
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
    check('id_image1').not().isEmpty().withMessage('id_image1 field is required'),
    check('profile_picture').not().isEmpty().withMessage('profile_picture field is required'),
    check('occupation').not().isEmpty().withMessage('occupation is required'),
    check('fcm_token').not().isEmpty().withMessage('fcm_token field is required'),
    check('password').not().isEmpty().withMessage('Password field is required').isLength({min: 5})
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            name,
            email,
            password,
            date_of_birth,
            address,
            contact_number,
            nationality,
            profile_description,
            father_last_name,
            mother_last_name,
            id_number,
            id_image1,
            credits,
            profile_picture,
            occupation,
            google_handle,
            facebook_handle,
            fcm_token
        }
            = req.body;
        const user = await admin.auth().createUser({
            email,
            password,
            phoneNumber: contact_number,
            displayName: name,
            photoURL: profile_picture
        });

        //store fcm in array

        var fcm_array = [fcm_token];

        await db.collection(collections.usersCollection).doc(user.uid)
            .create({
                name: name,
                email: email,
                date_of_birth: date_of_birth,
                address: address,
                contact_number: contact_number,
                nationality: nationality,
                profile_description: profile_description,
                father_last_name: father_last_name,
                mother_last_name: mother_last_name,
                profile_picture: profile_picture,
                id_number: id_number,
                id_image1: id_image1,
                credits: credits,
                occupation: occupation,
                fcm_token: fcm_array,
                google_handle: google_handle,
                facebook_handle: facebook_handle,
                average_rating: null,
                status: "ACTIVE",
                type: "HIRE",
                is_bank_details_added: 0,
                is_email_verified: 0,
                created_at: Date.now(),
                updated_at: Date.now()
            });


        var c_year = new Date().getFullYear();
        var c_month = new Date().getMonth() + 1;

        // do not uncomment the eslint-disable as it's written to use await in for loop eslint is disable for this perticular block of code.
        /* eslint-disable */

        for (let j = c_month; j <= 12; j++) {

            var month_obj = new Date(c_year + "-" + j + "-1").toLocaleString('en-US', {month: 'long'});
            var month_timestamp = month_obj + '-' + c_year;
            var total_days_in_month = new Date(c_year, j, 0).getDate();
            var i;
            await db.collection(collections.usersCollection).doc(user.uid).collection(collections.calenderCollection).doc(month_timestamp).set({});

            var docRef = await db.collection(collections.usersCollection).doc(user.uid).collection(collections.calenderCollection).doc(month_timestamp);
            for (i = 1; i <= total_days_in_month; i++) {
                docRef.update({
                    [i]: []
                });
            }
        }

        //for next year
        var n_year = c_year + 1;

        for (let m = 1; m <= 12; m++) {

            var n_month_obj = new Date(n_year + "-" + m + "-1").toLocaleString('en-US', {month: 'long'});
            var n_month_timestamp = n_month_obj + '-' + n_year;
            var n_total_days_in_month = new Date(n_year, m, 0).getDate();
            var d;
            await db.collection(collections.usersCollection).doc(user.uid).collection(collections.calenderCollection).doc(n_month_timestamp).set({});

            var newDocRef = await db.collection(collections.usersCollection).doc(user.uid).collection(collections.calenderCollection).doc(n_month_timestamp);
            for (d = 1; d <= n_total_days_in_month; d++) {
                newDocRef.update({
                    [d]: []
                });
            }
        }
        /* eslint-enable */
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        if (error.message === "TOO_SHORT" || error.message === "TOO_LONG") {
            return res.status(400).json({'data': [], 'message': 'Phone number is invalid', 'status': 400});
        }

        return res.status(400).json({'data': [], 'message': error.message, 'status': 400});
    }
});

//Add Bank Details
routes.post('/api/users/add-bank-details', /*checkIfAuthenticated,*/[
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('full_name').not().isEmpty().withMessage('full Name field is required'),
    check('RUT').not().isEmpty().withMessage('RUT field is required'),
    check('bank').not().isEmpty().withMessage('bank field is required'),
    check('account_type').not().isEmpty().withMessage('Account type field is required'),
    check('account_number').not().isEmpty().withMessage('Account number field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            user_id,
            full_name,
            RUT,
            bank,
            account_type,
            account_number
        }
            = req.body;

        let bankDetailRef = await db.collection(collections.bankDetailsCollection)
            .add({
                user_id: user_id,
                full_name: full_name,
                RUT: RUT,
                bank: bank,
                account_type: account_type,
                account_number: account_number,
                created_at: Date.now(),
                updated_at: Date.now()
            });

        await db.collection(collections.usersCollection).doc(user_id).get().then(user => {
            bankDetailRef.update({
                user_name: user.data().name
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        await db.collection(collections.usersCollection).doc(user_id).update({
            is_bank_details_added: 1
        });


        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(400).json({'data': [], 'message': error.message, 'status': 400});
    }
});

//edit bank details
routes.post('/api/users/edit-bank-details',/*checkIfAuthenticated,*/ [
    check('bank_detail_id').not().isEmpty().withMessage('bank_detail_id field is required'),
    check('full_name').not().isEmpty().withMessage('full Name field is required'),
    check('RUT').not().isEmpty().withMessage('RUT field is required'),
    check('bank').not().isEmpty().withMessage('bank field is required'),
    check('account_type').not().isEmpty().withMessage('Account type field is required'),
    check('account_number').not().isEmpty().withMessage('Account number field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            bank_detail_id,
            full_name,
            RUT,
            bank,
            account_type,
            account_number
        }
            = req.body;

        let bankDetailRef = await db.collection(collections.bankDetailsCollection).doc(bank_detail_id)
            .update({
                full_name: full_name,
                RUT: RUT,
                bank: bank,
                account_type: account_type,
                account_number: account_number,
                updated_at: Date.now()
            });

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(400).json({'data': [], 'message': error.message, 'status': 400});
    }
});

//get bank details
routes.get('/api/users/get-bank-details',/*checkIfAuthenticated,*/ [
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            user_id
        }
            = req.query;
        var data = [];
        await db.collection(collections.bankDetailsCollection).where('user_id', '==', user_id).get()
            .then(bankRef => {
                bankRef.forEach(doc => {
                    let obj = doc.data();
                    obj.bank_detail_id = doc.id;
                    data.push(obj);
                });
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
        return res.status(200).json({'data': data, 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(400).json({'data': [], 'message': error.message, 'status': 400});
    }
});

routes.post('/api/users/send-verification-mail', /*checkIfAuthenticated,*/ [
    check('email').not().isEmpty().withMessage('email field is required').isEmail().withMessage("Incorrect email"),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400)
            .json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const email = req.body.email;
        var user_name = '';

        // var check = await db.collection(collections.usersCollection).where('email', '==', email).get().then(user => {
        //     user.forEach(data => {
        //         user_name = data.data().name;
        //     });
        //     return user.size;
        //
        // }).catch(err => {
        //     console.log(err.message);
        //     return false;
        // });
        // if (check > 0) {
        //     return res.status(400).json({'data': [], 'message': 'Email already exist', 'status': 400});
        // }
        const verification_code = Math.floor(100000 + Math.random() * 900000);

        await db.collection(collections.emailVerificationCollection).doc().create({
            email: email,
            verification_code: verification_code,
            created_at: Date.now(),
            updated_at: Date.now()
        });

        var body = "Your email verification code is " + verification_code;
        var receiver = 'there';
        var subject = 'Email Verification';

        sendEmailCommon(email, body, receiver, subject);
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch
        (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});
//verify email

routes.post('/api/users/verify-email', /*checkIfAuthenticated,*/ [
    check('user_id').not().isEmpty().withMessage('user_id is required'),
    check('email').not().isEmpty().withMessage('email field is required').isEmail().withMessage("Incorrect email"),
    check('verification_code').not().isEmpty().withMessage('verification_code field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const user_id = req.body.user_id;
        const email = req.body.email;
        const verification_code = req.body.verification_code;
        var check = await db.collection(collections.emailVerificationCollection).where('email', '==', email).where('verification_code', '==', parseInt(verification_code)).get().then(user => {
            return user.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        if (check === 0 || check === '0') {
            return res.status(400).json({
                'data': [],
                'message': 'Sorry, Entered verification code not matched with our records',
                'status': 400
            });
        }
        var uid = {};
        await db.collection(collections.usersCollection).where('email', '==', email).get().then(user => {
            user.forEach(userDoc => {
                uid = userDoc.id;
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;

        });

        await admin.auth().updateUser(user_id, {
            email: email
        });

        await db.collection(collections.usersCollection).doc(user_id).update({
            is_email_verified: 1,
            email: email
        });

        var deleteCodeRef = await db.collection(collections.emailVerificationCollection).where('email', '==', email).where('verification_code', '==', parseInt(verification_code));
        deleteCodeRef.get().then(querySnapshot => {
            querySnapshot.forEach(doc => {
                doc.ref.delete();
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});


routes.post('/api/users/send-reset-mail', /*checkIfAuthenticated,*/ [
    check('email').not().isEmpty().withMessage('email field is required').isEmail().withMessage("Incorrect email"),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400)
            .json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const email = req.body.email;
        var user_name = '';
        var check = await db.collection(collections.usersCollection).where('email', '==', email).get().then(user => {

            user.forEach(data => {
                user_name = data.data().name;
            });
            return user.size;

        }).catch(err => {
            console.log(err.message);
            return false;
        });
        if (check <= 0) {
            return res.status(400).json({'data': [], 'message': 'Email not exist', 'status': 400});
        }

        const verification_code = Math.floor(100000 + Math.random() * 900000);

        db.collection(collections.passwordResetsCollection).doc().create({
            email: email,
            otp: verification_code,
            created_at: Date.now(),
            updated_at: Date.now()
        });

        var body = "Your OTP is " + verification_code;
        var subject = 'Reset password';

        sendEmailCommon(email, body, user_name, subject);
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch
        (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

routes.post('/api/users/reset-password', /*checkIfAuthenticated,*/ [
    check('email').not().isEmpty().withMessage('email field is required').isEmail().withMessage("Incorrect email"),
    check('otp').not().isEmpty().withMessage('otp field is required'),
    check('new_password').not().isEmpty().withMessage('New password field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const email = req.body.email;
        const otp = req.body.otp;
        const new_password = req.body.new_password;
        var uid;
        var check = await db.collection(collections.passwordResetsCollection).where('email', '==', email).where('otp', '==', parseInt(otp)).get().then(user => {

            return user.size;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        if (check === 0 || check === '0') {
            return res.status(400).json({
                'data': [],
                'message': 'Sorry, Entered otp not matched with our records',
                'status': 400
            });
        }
        await db.collection(collections.usersCollection).where('email', '==', email).get().then(userData => {
            userData.forEach(userDoc => {
                uid = userDoc.id
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        await admin.auth().updateUser(uid, {
            password: new_password
        });


        var deleteCodeRef = db.collection(collections.passwordResetsCollection).where('email', '==', email).where('otp', '==', parseInt(otp));
        deleteCodeRef.get().then(querySnapshot => {
            querySnapshot.forEach(doc => {
                doc.ref.delete();
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});


//test api for notification
routes.post('/api/users/send-notification', /*checkIfAuthenticated,*/ [
        check('user_id').not().isEmpty().withMessage('user_id field is required'),
    ], async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
        }
        try {
            const user_id = req.body.user_id;
            var userRef = await db.collection(collections.usersCollection).doc(user_id);

            var notificationRef = await userRef.get().then(notification => {
                return notification.data().fcm_token;

            }).catch(err => {
                console.log(err);
                return false;
            });
            if (typeof notificationRef !== 'undefined') {
                const body = {
                    'to': notificationRef,
                    'notification': {
                        title: 'Notification',
                        body: 'Message',
                        type: '1',
                        data: 'Data test',
                        sound: 'default'
                    },
                    content_available: true,
                    mutable_content: true
                };
                sendNotification(body);
            }
            return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
        } catch
            (error) {
            console.log(error);
            return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
        }
    }
);

//Generate fcm on login
routes.post('/api/users/add-fcm-token', /*checkIfAuthenticated,*/ [
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('fcm_token').not().isEmpty().withMessage('fcm_token field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        const FieldValue = admin.firestore.FieldValue;
        const user_id = req.body.user_id;
        const fcm_token = req.body.fcm_token;
        var userRef = await db.collection(collections.usersCollection).doc(user_id);

        userRef.update('fcm_token', FieldValue.arrayUnion(fcm_token));

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

// Remove fcm on logout
routes.post('/api/users/delete-fcm-token', /*checkIfAuthenticated,*/ [
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('fcm_token').not().isEmpty().withMessage('fcm_token field is required')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        let FieldValue = admin.firestore.FieldValue;

        const user_id = req.body.user_id;
        const fcm_token = req.body.fcm_token;
        var userRef = await db.collection(collections.usersCollection).doc(user_id);

        userRef.update('fcm_token', FieldValue.arrayRemove(fcm_token));
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

//support api
routes.post('/api/users/support', /*checkIfAuthenticated,*/ [
    check('user_id').not().isEmpty().withMessage('user_id'),
    check('message').not().isEmpty().withMessage('message')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        const user_id = req.body.user_id;
        const message = req.body.message;
        await db.collection(collections.usersCollection).doc(user_id).get().then(async user => {
            await db.collection(collections.supportsCollection).doc().create({
                user_id: user_id,
                message: message,
                user_email: user.data().email,
                user_name: user.data().name,
                user_image: user.data().profile_picture,
                user_phone: user.data().contact_number,
                status: "UNDER_REVIEW",  // 1 UNDER_REVIEW 2 INITIATED 3 DECLINED 4 RESOLVED
                created_at: Date.now(),
                updated_at: Date.now()
            });
            return true;
        }).catch(error => {
            console.log(error);
            return false;
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

//change user type

routes.post('/api/users/change-user-role', checkIfAuthenticated, [
    check('type').not().isEmpty().withMessage('Type field is required'),
    check('uid').not().isEmpty().withMessage('uid field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0], 'status': 400});
    }
    try {
        const uid = req.body.uid;
        const type = req.body.type;
        await db.collection(collections.usersCollection).doc(uid).update({
            type: type
        });
        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

//edit profile

routes.post('/api/users/edit-profile', /*checkIfAuthenticated,*/[
    //validation
    check('email').not().isEmpty().withMessage('Email field is required').isEmail()
        .withMessage("Incorrect email"),
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
    check('name').not().isEmpty().withMessage('name field is required'),
    check('address').not().isEmpty().withMessage('address field is required'),
    check('contact_number').not().isEmpty().withMessage('contact_number field is required'),
    check('profile_description').not().isEmpty().withMessage('profile_description field is required'),
    check('father_last_name').not().isEmpty().withMessage('father_last_name field is required'),
    check('mother_last_name').not().isEmpty().withMessage('mother_last_name field is required'),
    check('id_number').not().isEmpty().withMessage('id_number field is required'),
    check('id_image1').not().isEmpty().withMessage('id_image field is required'),
    check('nationality').not().isEmpty().withMessage('nationality field is required'),
    check('profile_picture').not().isEmpty().withMessage('profile_picture field is required')

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
            profile_description,
            father_last_name,
            mother_last_name,
            id_number,
            id_image1,
            nationality,
            profile_picture
        }
            = req.body;

        await admin.auth().updateUser(user_id, {
            email: email,
            emailVerified: true,
            displayName: name,
            photoURL: profile_picture,
            disabled: true
        }).then(async () => {
            await db.collection(collections.usersCollection).doc(user_id)
                .update({
                    name: name,
                    email: email,
                    date_of_birth: date_of_birth,
                    address: address,
                    contact_number: contact_number,
                    profile_description: profile_description,
                    father_last_name: father_last_name,
                    mother_last_name: mother_last_name,
                    profile_picture: profile_picture,
                    id_number: id_number,
                    id_image1: id_image1,
                    nationality: nationality,
                    updated_at: Date.now()
                });

            return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
        })
            .catch((error) => {
                return res.status(400).json({'data': [], 'message': error.message, 'status': 400});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

//get all categories (For users)
routes.get('/api/users/get-categories', /*checkIfAuthenticated,*/ async (req, res) => {
    try {
        var categories = [];
        await db.collection(collections.categoriesCollection).get().then((snapshot) => {
            snapshot.docs.forEach(doc => {
                var obj = doc.data();
                obj.category_id = doc.id;
                categories.push(obj);
            });
            return res.status(200).json({'data': categories, 'message': 'Success', 'status': 200})
        }).catch(err => {
            return res.status(500).json({'data': [], 'message': err, 'status': 500})
        });
    } catch (err) {
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500});
    }
});

//get subcategories (For User)
routes.get('/api/users/get-subcategories', /*checkIfAuthenticated,*/[
    //validation
    check('category_id').not().isEmpty().withMessage('category_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var subcategories = [];
        const category_id = req.query.category_id;
        let subcategoryRef = await db.collection(collections.subcategoriesCollection);
        subcategoryRef.where('category_id', '==', category_id).get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Matching SubCategories Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.subcategory_id = doc.id;
                    subcategories.push(obj);
                });
                return res.status(200).json({'data': subcategories, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

//get states (for user)
routes.get('/api/users/get-states', /*checkIfAuthenticated,*/[
    //validation
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var states = [];

        let statesRef = await db.collection(collections.statesCollection);
        statesRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'States not Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.state_id = doc.id;
                    states.push(obj);
                });
                return res.status(200).json({'data': states, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

//get cities (for user)
routes.get('/api/users/get-cities', /*checkIfAuthenticated,*/[
    //validation
    check('state_id').not().isEmpty().withMessage('state_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var cities = [];
        const state_id = req.query.state_id;
        let citiesRef = await db.collection(collections.citiesCollection);
        citiesRef.where('state_id', '==', state_id).get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'Cities not found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.city_id = doc.id;
                    cities.push(obj);
                });
                return res.status(200).json({'data': cities, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});
routes.post('/api/users/rate-user', /*checkIfAuthenticated,*/[
    //validation
    check('job_id').not().isEmpty().withMessage('job_id field is required'),
    check('rate_from').not().isEmpty().withMessage('rate_from field is required'),
    check('rate_to').not().isEmpty().withMessage('rate_to field is required'),
    check('rating').not().isEmpty().withMessage('rating field is required'),
    check('contact_outside').not().isEmpty().withMessage('contact_outside')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const {
            job_id,
            rate_from,
            rate_to,
            rating,
            contact_outside,
            comment
        }
            = req.body;
        var jobData = {};
        var rateUserData = {};
        let rateRef = await db.collection(collections.ratingsCollection).add({
            job_id: job_id,
            rate_from: rate_from,
            rate_to: rate_to,
            rating: rating,
            contact_outside: contact_outside,
            comment: comment,
            created_at: Date.now(),
            updated_at: Date.now()
        });
        rateRef.get().then(async rateDetail => {
            console.log(rateDetail.data());
            let jobRef = await db.collection(collections.jobsCollection).doc(rateDetail.data().job_id);

            jobRef.get().then(jobDetail => {
                rateRef.update({
                    job_name: jobDetail.data().job_name,
                    job_description: jobDetail.data().job_description,
                    job_date: jobDetail.data().job_date,
                    job_time: jobDetail.data().job_time,
                    job_address: jobDetail.data().job_address,
                    job_approach: jobDetail.data().job_approach,
                    job_amount: jobDetail.data().service_amount,
                    job_vendor_id: jobDetail.data().job_vendor_id,
                    job_owner_id: jobDetail.data().user_id
                });

                if (jobDetail.data().user_id === rate_from) {
                    jobRef.update({
                        owner_rated: 1
                    });
                } else if (jobDetail.data().job_vendor_id === rate_from) {
                    jobRef.update({
                        vendor_rated: 1
                    });
                }
                let obj = jobDetail.data();
                obj.job_id = jobDetail.id;
                jobData = obj;
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
            await db.collection(collections.usersCollection).doc(rateDetail.data().rate_from).get().then(rateUser => {
                rateRef.update({
                    rate_from_name: rateUser.data().name,
                    rate_from_image: rateUser.data().profile_picture,
                    rate_from_type: rateUser.data().type,
                });
                let obj = rateUser.data();
                obj.user_id = rateUser.id;
                rateUserData = obj;
                return true;
            }).catch(err => {
                console.log(err.message);
                return false;
            });
            await db.collection(collections.usersCollection).doc(rateDetail.data().rate_to).get().then(async ratedUser => {
                rateRef.update({
                    rate_to_name: ratedUser.data().name,
                    rate_to_image: ratedUser.data().profile_picture,
                    rate_to_type: ratedUser.data().type,
                });
// notification to rated user i.e. worker as only client can rate worker and worker can't.
                ratedUser.data().fcm_token.forEach(token => {
                    const body = {
                        'to': token,
                        'notification': {
                            title: 'You received an evaluation on ' + jobData.job_name + ' job.',
                            body: comment,
                            type: 15,
                            data: jobData.job_id,
                            sound: 'default'
                        },
                        content_available: true,
                        mutable_content: true
                    };
                    sendNotification(body);

                });
                await db.collection(collections.notificationCollection).add({
                    sender_id: rateUserData.user_id,
                    receiver_id: ratedUser.id,
                    sender_name: rateUserData.name,
                    sender_image: rateUserData.profile_picture,
                    notification_body: 'You received an evaluation on ' + jobData.job_name + ' job.',
                    notification_type: 15,
                    job_id: jobData.job_id,
                    created_at: Date.now(),
                    updated_at: Date.now(),
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

        await db.collection(collections.ratingsCollection).where('rate_to', '==', rate_to).get().then(async rateRef => {
            var sum = 0;
            rateRef.forEach(rateData => {
                sum = sum + parseInt(rateData.data().rating);
            });
            if (rateRef.size) {
                var rating = Math.round(sum / rateRef.size);
            }
            await db.collection(collections.usersCollection).doc(rate_to).update({
                average_rating: String(rating)
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
// get-ratings (user)

routes.get('/api/users/get-ratings', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var ratings = [];
        const type = req.query.type;
        const user_id = req.query.user_id;
        let rateRef = await db.collection(collections.ratingsCollection).where('rate_to', '==', user_id).orderBy('created_at', 'desc');

        let filterRef;
        if (type === "WORK") {
            filterRef = rateRef.where('job_vendor_id', '==', user_id);
        } else {
            filterRef = rateRef;
        }
        filterRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Ratings Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.rating_id = doc.id;
                    ratings.push(obj);
                });
                return res.status(200).json({'data': ratings, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

//get-notifications
routes.get('/api/users/get-notifications', /*checkIfAuthenticated,*/[
    //validation
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], error: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        var notifications = [];
        const user_id = req.query.user_id;
        let notificationRef = await db.collection(collections.notificationCollection).where('receiver_id', '==', user_id).orderBy('created_at', 'desc');
        notificationRef.get()
            .then(snapshot => {
                if (snapshot.empty) {
                    return res.status(200).json({
                        'data': [],
                        'message': 'No Notifications Found',
                        'status': 200
                    })
                }
                snapshot.forEach(doc => {
                    var obj = doc.data();
                    obj.notification_id = doc.id;
                    notifications.push(obj);
                });
                return res.status(200).json({'data': notifications, 'message': 'Success', 'status': 200});
            })
            .catch(err => {
                return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 1});
            });
    } catch (err) {
        console.log(err);
        return res.status(500).json({'data': [], 'message': err.message, 'status': 500, 'type': 2});
    }
});

// Add credit (Static add without payment)
routes.post('/api/users/add-credit', [
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const user_id = req.body.user_id;
        const amount = req.body.amount;
        let userRef = await db.collection(collections.usersCollection).doc(user_id);
        userRef.get().then(async userData => {
            userRef.update({
                credits: String(parseFloat(userData.data().credits) + parseFloat(amount))
            });
            await db.collection(collections.transactionsCollection).add({
                transaction_type: "CREDIT", //transaction type : CREDIT  DEBIT
                user_id: user_id,
                user_name: userData.data().name,
                user_image: userData.data().profile_picture,
                opposite_user: null,
                job_id: null,
                amount: String(amount),
                transaction_id: 'W' + Date.now(),
                transaction_for: "ADDED TO WALLET",     //JOB OR ADD TO WALLET
                commission: null,
                payment_option: "WALLET", //WALLET OR ANY PAYMENT API(PAYPAL)
                status: "SUCCESS",
                created_at: Date.now(),
                updated_at: Date.now(),
            });
            return true;

        }).catch(err => {
            console.log(err.message);
            return false;
        });

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

// Get credit with transactions(payment)
routes.get('/api/users/get-credits', [
    check('user_id').not().isEmpty().withMessage('user_id field is required'),
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({'data': [], errors: errors.array()[0]['msg'], 'status': 400});
    }
    try {
        const user_id = req.query.user_id;
        var user = {};
        await db.collection(collections.usersCollection).doc(user_id).get().then(userData => {
            user.credits = userData.data().credits;
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        user.transactions = [];
        await db.collection(collections.transactionsCollection).where('user_id', '==', user_id).orderBy('created_at', 'desc').get().then(transactions => {
            transactions.forEach(transactionData => {
                user.transactions.push(transactionData.data());
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });

        return res.status(200).json({'data': user, 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

// Get terms and conditions(payment)
routes.get('/api/users/get-tnc', async (req, res) => {
    try {
        var tnc = {};
        await db.collection(collections.termsAndConditionsCollection).get().then(tncRef => {
            tncRef.forEach(tncData => {
                tnc = tncData.data();
            });
            return true;
        }).catch(err => {
            console.log(err.message);
            return false;
        });
        return res.status(200).json({'data': tnc, 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

// testing scheduler code
routes.get('/api/users/test', async (req, res) => {
    // try {
    //
    // var jobs = [];
    // await db.collection(collections.jobsCollection).where('start_notify_time_1_vendor', '<=', (Date.now() / 1000)).where('already_notified_time_1_vendor', '==', "NO").where('status', '==', "ACCEPTED").get().then(jobSnap => {
    //     jobSnap.forEach(jobData => {
    //         let obj = jobData.data();
    //         obj.job_id = jobData.id;
    //         console.log(jobData.id);
    //         jobs.push(obj);
    //     });
    //     return true;
    // }).catch(err => {
    //     console.log(err.message);
    //     return false;
    // });


    //       if (jobs !== "undefined" && jobs.length >= 1) {
    //           const jobPromises = jobs.map(async (job) => {
    //               var obj = {};
    //               console.log(job);
    //               var userDetail = await db.collection(collections.usersCollection).doc(job.job_vendor_id).get().then((userSnapshot) => {
    //                   obj = userSnapshot.data();
    // console.log(userSnapshot.data());
    //                   obj.user_id = userSnapshot.id;
    //                   return obj;
    //               }).catch((err) => {
    //                   console.log(err);
    //                   return false;
    //               });
    //
    // console.log(userDetail);
    //               userDetail.fcm_token.forEach(token => {
    //                   const body = {
    //                       // should be arrray
    //                       'to': token,
    //                       'notification': {
    //                           title: 'Two hours remaining for the job  ' + job.job_name + ' to start.',
    //                           body: job.job_name,
    //                           type: 8, //job start notify
    //                           data: job.job_id,
    //                           sound: 'default'
    //                       },
    //                       content_available: true,
    //                       mutable_content: true
    //                   };
    //                   sendNotification(body);
    //                   console.log(token);
    //               });
    //
    //               db.collection(collections.notificationCollection).add({
    //                   sender_id: job.user_id,
    //                   receiver_id: job.job_vendor_id,
    //                   sender_name: job.user_name,
    //                   sender_image: job.user_image,
    //                   notification_body: 'Two hours remaining for the job ' + job.job_name + ' to start',
    //                   notification_type: 8,
    //                   job_id: job.job_id,
    //                   created_at: Date.now(),
    //                   updated_at: Date.now(),
    //               });
    //
    //               db.collection(collections.jobsCollection).doc(job.job_id).update({
    //                   already_notified_time_1_vendor: "YES",
    //                   updated_at: Date.now(),
    //               });
    //           });
    //
    //           await Promise.all(jobPromises);
    //       }

    //     return true;
    // } catch (error) {
    //     console.log(error);
    //     return false;
    // }
});

// test for email template

routes.get('/api/users/send', async (req, res) => {
    try {
//for current year
        var c_year = new Date().getFullYear();
        var c_month = new Date().getMonth() + 1;
        /* eslint-disable */

        (async () => {
            for (let j = c_month; j <= 12; j++) {

                var month_obj = new Date(c_year + "-" + j + "-1").toLocaleString('en-US', {month: 'long'});
                var month_timestamp = month_obj + '-' + c_year;
                var total_days_in_month = new Date(c_year, j, 0).getDate();
                var i;
                await db.collection(collections.usersCollection).doc('Hg3jhV94V6QdNZbyty2sWW2C8ez2').collection(collections.calenderCollection).doc(month_timestamp).set({});

                var docRef = await db.collection(collections.usersCollection).doc('Hg3jhV94V6QdNZbyty2sWW2C8ez2').collection(collections.calenderCollection).doc(month_timestamp);
                for (i = 1; i <= total_days_in_month; i++) {
                    docRef.update({
                        [i]: []
                    });
                }
            }
        })();

        //for next year
        var n_year = c_year + 1;

        (async () => {
            for (let m = 1; m <= 12; m++) {

                var n_month_obj = new Date(n_year + "-" + m + "-1").toLocaleString('en-US', {month: 'long'});
                var n_month_timestamp = n_month_obj + '-' + n_year;
                var n_total_days_in_month = new Date(n_year, m, 0).getDate();
                var d;
                await db.collection(collections.usersCollection).doc('Hg3jhV94V6QdNZbyty2sWW2C8ez2').collection(collections.calenderCollection).doc(n_month_timestamp).set({});

                var newDocRef = await db.collection(collections.usersCollection).doc('Hg3jhV94V6QdNZbyty2sWW2C8ez2').collection(collections.calenderCollection).doc(n_month_timestamp);
                for (d = 1; d <= n_total_days_in_month; d++) {
                    newDocRef.update({
                        [d]: []
                    });
                }
            }
        })();
        /* eslint-enable */

        return res.status(200).json({'data': [], 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

//
// routes.post('/api/users/delete-users', async (req, res) => {
//     try {
//         var users = [];
//         admin.auth().listUsers(1000)
//             .then(function(listUsersResult) {
//                 listUsersResult.users.forEach(function(userRecord) {
//                     console.log('user', userRecord.toJSON());
//                     users.push(userRecord);
//                 });
//                 if (listUsersResult.pageToken) {
//                     // List next batch of users.
//                     listAllUsers(listUsersResult.pageToken);
//                 }
//             })
//             .catch(function(error) {
//                 console.log('Error listing users:', error);
//             });
//
//         admin.auth().deleteUser('C5yvEYyYAsQIwbKTWjuNW7XJFR32')
//             .then(function() {
//                 console.log('Successfully deleted user');
//             })
//             .catch(function(error) {
//                 console.log('Error deleting user:', error);
//             });
//
//         return res.status(200).json({'data': users, 'message': 'Success', 'status': 200});
//     } catch (error) {
//         console.log(error);
//         return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
//     }
// });

//get jobs for calender
routes.get('/api/users/get-calender-jobs', async (req, res) => {
    try {
        // var jobs;
        var jobs = [];
        const month = req.query.month;
        const user_id = req.query.user_id;
        var year = new Date((month * 1000)).getFullYear();
        var month_name = new Date((month * 1000)).toLocaleString('en-US', {month: 'long'});
        var month_filter = month_name + '-' + year;

        await db.collection(collections.usersCollection).doc(user_id).collection(collections.calenderCollection).doc(month_filter).get()
            .then(doc => {
                let json = doc.data();
                Object.values(json).forEach((data) => {
                    let object = {};
                    object.job_data = data;
                    jobs.push(object);
                });
                return true;
            })
            .catch(err => {
                console.log(err.message);
                return false;
            });
        // console.log(jobs);
        return res.status(200).json({'data': jobs, 'message': 'Success', 'status': 200});
    } catch (error) {
        console.log(error);
        return res.status(500).json({'data': [], 'message': error.message, 'status': 500});
    }
});

module.exports = routes;

