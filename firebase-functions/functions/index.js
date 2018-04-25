// Firebase Set Up
const functions = require('firebase-functions'); // Firebase SDK to create Cloud Functions and setup triggers.
var admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Twilio Send Message
const twilio = require('twilio');
const accountSid = functions.config().twilio.sid
const authToken  = functions.config().twilio.token

const client = new twilio(accountSid, authToken);

const twilioPhoneNumber = '+16506812714' // phone number that twilio gives us

exports.sendMessage = functions.https.onRequest((req,res)=> {
	const userName = req.body.userName; 
	const city = req.body.city;
	const questionText = 'Hey! This is ' + userName + "'s personal travel bot. " + userName + " is taking a trip to " + city + " soon and wanted a recommendation from you. What's your favorite 'hidden gem' of " + city + "? Just respond back with the name!" 
	const phoneNumber = '+19739862294'
	const textMessage = {
		body: questionText,
		to: phoneNumber,
		from: twilioPhoneNumber
	}
	return client.messages.create(textMessage)
	.then(message => console.log(message.sid, 'success'))
	.catch(err => console.log(err))
});

//we are given the body of the message, and from 
// lets search through our logs and find all that are 'to' the from number and are from the same city, if we find a match, then we know the number of who sent it
exports.receiveMessage = functions.https.onRequest((req,res)=> {
	console.log("Received!");
	const body = req.query.body.split(","); //text is sent in with a comma to separate between name and city  
	const nameOfPlace = body[0]; 
	const city = body[1];

	//tells us the number of who sent it 
	const whoFrom = req.query.from; 

	const filterOpts = {
		to: whoFrom,
	  };
	
	const messages = client.messages.each(filterOpts, (message) => console.log(message.body));

	//loop through the messages in the log that were sent to our number that responded, for every message that sent out 
	// with a matching city, then we know where to store 

	var matches = []; 
	for(var i=0; i<messages.length; i++){
		if(messages.body.includes(city)){ //will caps be an issue here? 
			matches.push(messages.from); 
		}
	}


	//respond back to sender thanking them for their response 
	const responseText = 'Ah. ' + nameOfPlace + ' is a sick recommendation. Thank you.' 
	const textMessage = {
		body: responseText,
		to: whoFrom,
		from: twilioPhoneNumber
	}
	return client.messages.create(textMessage)
	.then(message => console.log(message.sid, 'success'))
	.catch(err => console.log(err))
});