const admin = require('firebase-admin');
module.exports = {
    checkIfAuthenticated: (req, res, next) => {
        getAuthToken(req, res, async () => {
            try {
                const {authToken} = req;
                console.log(authToken);
                const userInfo = await admin
                    .auth()
                    .verifyIdToken(authToken);
                req.authId = userInfo.uid;
                return next();
            } catch (e) {
                console.log(e);
                return res
                    .status(401)
                    .json({'data': [], error: 'Unauthorized', 'status': 401});
            }
        });
    }
};
const getAuthToken = (req, res, next) => {
    if (
        req.headers.authorization &&
        req.headers.authorization.split(' ')[0] === 'Bearer'
    ) {
        req.authToken = req.headers.authorization.split(' ')[1];
    } else {
        req.authToken = null;
    }
    next();
};
