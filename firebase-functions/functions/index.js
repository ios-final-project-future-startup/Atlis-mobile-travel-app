// Firebase Set Up
const functions = require('firebase-functions'); // Firebase SDK to create Cloud Functions and setup triggers.
var admin = require('firebase-admin');
const fetch = require('node-fetch');
admin.initializeApp(functions.config().firebase);
var db = admin.database();


// Twilio Send Message
const twilio = require('twilio');
const accountSid = functions.config().twilio.sid
const authToken  = functions.config().twilio.token

const client = new twilio(accountSid, authToken);

const twilioPhoneNumber = '+16506812714' // phone number that twilio gives us


//Algo 
//1. Go through outgoing requests dictionary, find all pairs that have the key as our phone number
//2. Append these UserIDs to an array 
//3. Call the Google Places API and get the JSON of the place and store values in an object
//4. Then, go through users dictionary to each user and add this object to their recommendations field
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
	const recommendation = req.query.recommendation
	const city = req.query.city
	var whoFrom = req.query.from; //eliminate blank space and add plus
	whoFrom = whoFrom.substring(1); 
	whoFrom = "+" + whoFrom;
	//console.log(whoFrom); 
	//console.log(recommendation + ":" + city + ":" + whoFrom);
	
	//revert string to include +'s instead of spaces for querying
	const convertRec = recommendation.replace(/\s+/g, "+"); 
	const convertCity = city.replace(/\s+/g, "+");
	const query = convertRec + "+" + convertCity; 
	
	// Using the fetch API to retrieve our Recommendation JSON object from Google API's 
	// 1. The following steps are: get the result as json, store it as a objects, then add it to the appropriate location
	fetch("https://maps.googleapis.com/maps/api/place/textsearch/json?query="+ query +"&key=AIzaSyBiDY9xYSfMh_VKXZ9cvo4BBItW96aqqig")
	.then(function(response) {
		return response.json(); 
	})
	.then (function(responseAsJSON){
		var place = responseAsJSON.results[0]; //this object stores all the data that we want
		//console.log(x["rating"]);
		//console.log(place);
		
		var ref = db.ref("/outgoing_requests/"); 
		ref.on("value",function(snap){
			var numbers = snap.val();
			for (var number in numbers){
				if(number === whoFrom){
					console.log("match");

					var userID = numbers[number]; //the userID where we will store this data (one that requested it)

					var placeID = place["id"]; //the ID of the place given by google, using this as the identifier in the dictionary
					// var nameOfFrom = getNamefromNumber(userID, whoFrom); 
					var nameOfFrom = ""; 
					var ref2 = db.ref("/users/"+userID+"/requesting_to/"+whoFrom);
					ref2.once("value",function(snap){
						nameOfFrom = snap.val(); 
						console.log(nameOfFrom); 
					});

					//data will now be stored, set will replace old data if given same placeID
					//notice the ref query string and how it is stores in the userID
					db.ref("/users/"+userID+"/saved_recommendations/"+placeID).set({
						   "name": place["name"],
						   "address": place["formatted_address"],
						   "icon": place["icon"] || -1, 
						   "price_level": place["price_level"] || -1,
						   "lat": place["geometry"]["location"]["lat"],
						   "lon" : place["geometry"]["location"]["lng"],
						   "rating" : place["rating"] || -1,
						   "from" : nameOfFrom || "ZK"
					});
	
				}
			}
		});  
		return; 
	})
	.catch(function(error) {
		console.log('Looks like there was a problem: \n', error);
	});
	
	const filterOpts = {
		to: whoFrom,
	  };
	
	var messages = []; 
	client.messages.each(filterOpts, (message) => messages.append(message.body));
	client.messages.each(filterOpts, (message) => console.log(message.body));

	//respond back to sender thanking them for their response 
	const responseText = 'Ah. ' + recommendation + ' is a sick recommendation. Thank you.' 
	const textMessage = {
		body: responseText,
		to: whoFrom,
		from: twilioPhoneNumber
	}
	return client.messages.create(textMessage)
	.then(message => console.log(message.sid, 'success'))
	.catch(err => console.log(err))
});

//FIX: NOT SURE WHY THIS IS RETURNING NULL 
//returns the full name of the user, given their phone number 
function getNamefromNumber(userId, number){
	var db = admin.database();
	var ref = db.ref("/users/"+userId+"/requesting_to/"+number) 
	ref.once("value",function(snap){
		const val = snap.val(); 
		console.log(val); 
		return val; 
	});
}