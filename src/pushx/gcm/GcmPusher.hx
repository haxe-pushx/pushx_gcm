package pushx.gcm;

import haxe.io.Bytes;
import haxe.Json;
import tink.http.Header;
import tink.http.Fetch.*;

using tink.CoreApi;

class GcmPusher<Data:{}> implements pushx.Pusher<Data> {
	
	var url = 'https://gcm-http.googleapis.com/gcm/send';
	var key:String;
	
	public function new(key)
		this.key = key;
	
	public function single(id:String, payload:pushx.Payload<Data>):Promise<pushx.Result>
		return multiple([id], payload);
	
	public function multiple(ids:Array<String>, payload:pushx.Payload<Data>):Promise<pushx.Result> {
		var promises = [];
		for(i in 0...Math.ceil(ids.length / 1000)) { // max 1000 ids per batch
			var payload:Payload = {
				registration_ids: ids.slice(i * 1000, (i + 1) * 1000),
				notification: payload.notification,
				data: payload.data,
			}
			
			promises.push(send(payload));
		}
		
		return Promise.inParallel(promises)
			.next(function(res) {
				var result = null;
				for(s in res) 
					if(result == null) result = s;
					else {
						result.canonical_ids += s.canonical_ids;
						result.failure += s.failure;
						result.success += s.success;
						result.results = result.results.concat(s.results);
					}
				return {
					errors: [for(i in 0...result.results.length) if(result.results[i].error != null) {id: ids[i], error: new Error(500, result.results[i].error)}],
				}
			});
	}
	
	public function topic(topic:String, payload:pushx.Payload<Data>):Promise<pushx.Result> {
		var payload:Payload = {
			to: topic,
			notification: payload.notification,
			data: payload.data,
		}
		
		return send(payload).next(function(res) return {errors: [/*TODO*/]});
	}
	
	function send(payload:Payload):Promise<Response> {
		var json = Json.stringify(payload);
		var body = Bytes.ofString(json);
		
		return fetch(url, {
			method: POST,
			headers: [
				new HeaderField('Content-Type', 'application/json'),
				new HeaderField('Content-Length', Std.string(body.length)),
				new HeaderField('Authorization', 'key=$key'),
			],
			body: body,
		})
			.all()
			.next(function(res) {
				return try {
					Success(Json.parse(res.body));
				} catch(e:Dynamic) {
					Failure(new Error(UnprocessableEntity, '$e - source: ${res.body}'));
				}
			});
	}
}
