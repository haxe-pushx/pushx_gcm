package pushx.gcm;

typedef Payload = {
	?to:String,
	?registration_ids:Array<String>,
	?data:{},
	?notification:Notification,
}