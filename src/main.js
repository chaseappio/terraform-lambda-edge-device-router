'use strict';



/* This is an origin request function */
exports.handler = (event, context, callback) => {

    let path = require('path');
    let {readFileSync} = require('fs');

    const params = path.resolve('params.json');

    const configString = readFileSync(params).toString();
    const config = JSON.parse(configString);

    const request = event.Records[0].cf.request;
    const headers = request.headers;

    const isMobile = headers['cloudfront-is-mobile-viewer'] &&
                    headers['cloudfront-is-mobile-viewer'][0].value === 'true';

    if(!isMobile) {

      const response = {
        status: '302',
        statusDescription: 'Found',
        headers: {
            location: [{
                key: 'Location',
                value: config.redirectUrl,
            }],
        },
      }




      callback(null,response);
      return;
    }

    callback(null,request);
};
