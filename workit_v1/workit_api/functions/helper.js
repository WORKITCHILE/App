const admin = require('firebase-admin');
const db = admin.firestore();
const request = require('request');
const collections = require('./collections');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const Hogan = require('hogan.js');
const fs = require('fs');


// read common template for send email
var common_template = fs.readFileSync('./views/common/common.hjs', 'utf-8');
// read job receipt template for send email
var owner_template = fs.readFileSync('./views/owner/job_receipt.hjs', 'utf-8');
// var worker_template = fs.readFileSync('./views/worker/job_receipt.hjs', 'utf-8');

var compiledTemplateCommon = Hogan.compile(common_template);
var compiledTemplateOwner = Hogan.compile(owner_template);
// var compiledTemplateWorker = Hogan.compile(worker_template);

module.exports = {
    //realtime notification function
    sendNotification: async (body) => {

        await db.collection('error')
        .add(body);

        /*
        request.post({
            url: 'https://fcm.googleapis.com/fcm/send',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'key=AAAAyRtgDSw:APA91bGhuuU1PC7HkVPUu2CO1Ynm454TTfNRs4oKkn4i3gEva4Pudm46wgSJOAfXcllpm4_f4eYjC0cUZyztHmw8lPevTIoyIHkY3pAthke0OETZ7HK9dgYsFIAJy_rqkrKhYOxOyPHv'
            },
            body: JSON.stringify(body)
        }, (error, response, body) => {
            console.log(body);
            // console.log('response  =>'+ response.message);
            console.log('err  =>' + error);
            
         await db.collection('error')
                .add({
                    error: error ? error : 'not error',
                    response: response ? response : 'not response'
                });

        });
        /*
    },
    //function for saving all job events (for showing events on admin side)
    saveJobEvents: async (job_name, job_id, message, status, vendor_name) => {
        await db.collection(collections.jobEventHistoryColleciton).doc().create({
            job_name: job_name,
            vendor_name: vendor_name,
            message: message,
            status: status,
            job_id: job_id,
            job_event_time: Date.now(),
            created_at: Date.now(),
            updated_at: Date.now()
        });

        return true;
    },
    // function to send job_receipt after job completion on email to owner and worker
    sendEmailVoucher: async (email, body, receiver_name, subject) => {
        // ADD SMTP CONFIG HERE
        var smtpConfig = {
            host: '', 
            service: "smtp",
            port: 465,
            secure: true, // use SSL
            auth: {
                user: '',
                pass: ''
            }
        };

        var transporter = nodemailer.createTransport(smtpConfig);
        var mailOptions = {
            from: "noreply@smtp.mail141.suw14.mailer.qualwebs.com", // sender address
            to: email, // list of receivers
            subject: subject, // Subject line
            html: compiledTemplateOwner.render({receiver_name: receiver_name, body: body}) // html body
        };
        transporter.sendMail(mailOptions, function (error, response) {
            if (error) {
                console.log(error);
            } else {
                console.log(response);
            }
            // if you don't want to use this transport object anymore, uncomment following line
            //smtpTransport.close(); // shut down the connection pool, no more messages
        });
    },

    md5: (string) => {
        return crypto.createHash('md5').update(string).digest('hex');
    },

    // function for send emails
    sendEmailCommon: async (email, body, receiver_name, subject) => {
        // ADD SMTP CONFIG HERE
        var smtpConfig = {
            host: '', 
            service: "smtp",
            port: 465,
            secure: true, // use SSL
            auth: {
                user: '',
                pass: ''
            }
        };
        var transporter = nodemailer.createTransport(smtpConfig);
        var mailOptions = {
            from: "noreply@smtp.mail141.suw14.mailer.qualwebs.com", // sender address
            to: email, // list of receivers
            subject: subject, // Subject line
            html: compiledTemplateCommon.render({receiver_name: receiver_name, body: body}) // html body
        };
        transporter.sendMail(mailOptions, function (error, response) {
            if (error) {
                console.log(error.message);
            } else {
                console.log(response);
            }
            // if you don't want to use this transport object anymore, uncomment following line
            //smtpTransport.close(); // shut down the connection pool, no more messages
        });
    }
};
