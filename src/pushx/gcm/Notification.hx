package pushx.gcm;

abstract Notification(NotificationBase) from NotificationBase to NotificationBase {
	@:from
	public static function fromNotification(n:pushx.Notification):Notification
		return n == null ? null : {
			title: n.title,
			body: n.body,
			icon: n.icon,
			click_action: n.action,
			sound: n.sound,
		}
}

typedef NotificationBase = {
	?title:String,
	?body:String,
	?icon:String,
	?click_action:String,
	?sound:String,
}