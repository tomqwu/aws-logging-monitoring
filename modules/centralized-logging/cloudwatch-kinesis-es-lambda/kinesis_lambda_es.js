/* == Imports == */
const AWS = require("aws-sdk");
const path = require("path");
const zlib = require("zlib");
const isGzip = require("is-gzip");

/* == Globals == */
var esDomain = {
  region: process.env.ES_REGION,
  endpoint: "https://" + process.env.ES_ENDPOINT,
  doctype: "logs",
  es_index: "default_logs_index"
};

var endpoint = new AWS.Endpoint(esDomain.endpoint);

/*
 * The AWS credentials are picked up from the environment.
 * They belong to the IAM role assigned to the Lambda function.
 * Since the ES requests are signed using these credentials,
 * make sure to apply a policy that allows ES domain operations
 * to the role.
 */
var creds = new AWS.EnvironmentCredentials("AWS");

/* Lambda "main": Execution begins here */
exports.handler = function(event, context) {
  //console.log(esDomain);
  //console.log(JSON.stringify(event, null, "  "));
  //console.log(JSON.stringify(context));

  event.Records.forEach(function(record) {
    var jsonDoc = new Buffer(record.kinesis.data, "base64");

    //console.log(JSON.stringify(jsonDoc));

    if (isGzip(jsonDoc)) {
      console.log("found gzip buffer stream");
      unzipData(jsonDoc, context);
    } else {
      console.log("non gzip buffer stream");
      postToES(JSON.stringify(jsonDoc), context, esDomain.es_index);
    }
  });
};

function isJson(item) {
  item = typeof item !== "string" ? JSON.stringify(item) : item;

  try {
    item = JSON.parse(item);
  } catch (e) {
    return false;
  }

  if (typeof item === "object" && item !== null) {
    return true;
  }

  return false;
}

function unzipData(data, context) {
  zlib.gunzip(data, function(e, result) {
    if (e) {
      context.fail(e);
    } else {
      var result = JSON.parse(result.toString("ascii"));
      console.log("Event Data:", JSON.stringify(result, null, 2));

      // re-construct log based on logEvents
      result.logEvents.forEach(function(logEvent) {
        var logEventObj = new Object();
        logEventObj.owner = result.owner;
        logEventObj.logGroup = result.logGroup;
        logEventObj.logStream = result.logStream;
        logEventObj.subscriptionFilters = result.subscriptionFilters;

        // parse if message is json format
        if (isJson(logEvent.message)) {
          logEventObj = {...logEventObj, ...JSON.parse(logEvent.message)};
        } else {
          logEventObj.message = logEvent.message;
        }

        // convert cloudwatch epoch time to timestamp
        // The 0 there is the key, which sets the date to the epoch
        var d = new Date(logEvent.timestamp);
        logEventObj.strict_timestamp = d;

        var logEventString = JSON.stringify(logEventObj);

        // Dynamic index based on cloudwatch logGroup name

        var es_index = "";

        if (result.logGroup.startsWith("/")) {
          // starts with /aws/lambda/....
          es_index = result.logGroup.replace(/\//g, "_").slice(1);
        } else {
          // starts with normal chars
          es_index = result.logGroup;
        }

        console.log(logEventString);

        postToES(logEventString, context, es_index.toLowerCase());
      });

      context.succeed();
    }
  });
}

/*
 * Post the given document to Elasticsearch
 */
function postToES(doc, context, index) {
  var req = new AWS.HttpRequest(endpoint);

  req.method = "POST";
  req.path = path.join("/", index, esDomain.doctype);
  req.region = esDomain.region;
  req.headers["presigned-expires"] = false;
  req.headers["Host"] = endpoint.host;
  req.headers["Content-Type"] = "application/json";
  req.body = doc;

  var signer = new AWS.Signers.V4(req, "es"); // es: service code
  signer.addAuthorization(creds, new Date());

  var send = new AWS.NodeHttpClient();
  send.handleRequest(
    req,
    null,
    function(httpResp) {
      var respBody = "";
      httpResp.on("data", function(chunk) {
        respBody += chunk;
      });
      httpResp.on("end", function(chunk) {
        console.log("Response: " + respBody);
        context.succeed("Lambda added document " + doc);
      });
    },
    function(err) {
      console.log("Error: " + err);
      context.fail("Lambda failed with error " + err);
    }
  );
}
