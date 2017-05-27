package pushx.gcm;

typedef Response = {
	multicast_id:Int,
	success:Int,
	failure:Int,
	canonical_ids:Int,
	results: Array<{message_id:String, ?registration_id:String, ?error:String}>,
}