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

//we are given the body of the message, and from 
// lets search through our logs and find all that are 'to' the from number and are from the same city, if we find a match, then we know the number of who sent it
exports.receiveMessage = functions.https.onRequest((req,res)=> {
    const text = req.query.text.split(","); //text is sent in with a comma to separate between name and city  
	const nameOfPlace = text[0]; 
	const city = text[1];

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
	const questionText = 'Ah. ' + text + ' is a fine recommendation. Thank you.' 
	const textMessage = {
		body: questionText,
		to: whoFrom,
		from: twilioPhoneNumber
	}
	return client.messages.create(textMessage)
	.then(message => console.log(message.sid, 'success'))
	.catch(err => console.log(err))
});