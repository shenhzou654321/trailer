
import UIKit

final class WatchManager {

	static var backgroundTask = UIBackgroundTaskInvalid

	class func startBGTask() {
		backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithName("com.housetrip.Trailer.watchrequest", expirationHandler: {
			self.endBGTask()
		})
	}

	class func endBGTask() {
		if backgroundTask != UIBackgroundTaskInvalid {
			UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
			backgroundTask = UIBackgroundTaskInvalid
		}
	}

	class func handleWatchKitExtensionRequest(userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {

		startBGTask()

		if let command = userInfo?["command"] as? String {
			switch(command) {
			case "refresh":
				app.startRefresh()
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {

					let lastSuccessfulSync = Settings.lastSuccessfulRefresh ?? NSDate()

					while app.isRefreshing {
						NSThread.sleepForTimeInterval(0.1)
					}
					atNextEvent() {
						if Settings.lastSuccessfulRefresh == nil || lastSuccessfulSync.isEqualToDate(Settings.lastSuccessfulRefresh!) {
							reply(["status": "Refresh failed", "color": "red"])
						} else {
							reply(["status": "Success", "color": "green"])
						}
						self.endBGTask()
					}
				}
			case "openpr":
				if let itemId = userInfo?["id"] as? String {
					let m = popupManager.getMasterController()
					m.openPrWithId(itemId)
					DataManager.saveDB()
				}
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "openissue":
				if let itemId = userInfo?["id"] as? String {
					let m = popupManager.getMasterController()
					m.openIssueWithId(itemId)
					DataManager.saveDB()
				}
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "opencomment":
				if let itemId = userInfo?["id"] as? String {
					let m = popupManager.getMasterController()
					m.openCommentWithId(itemId)
					DataManager.saveDB()
				}
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "clearAllMerged":
				for p in PullRequest.allMergedRequestsInMoc(mainObjectContext) {
					mainObjectContext.deleteObject(p)
				}
				DataManager.saveDB()
				let m = popupManager.getMasterController()
				m.reloadDataWithAnimation(false)
				m.updateStatus()
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "clearAllClosed":
				for p in PullRequest.allClosedRequestsInMoc(mainObjectContext) {
					mainObjectContext.deleteObject(p)
				}
				for i in Issue.allClosedIssuesInMoc(mainObjectContext) {
					mainObjectContext.deleteObject(i)
				}
				DataManager.saveDB()
				let m = popupManager.getMasterController()
				m.reloadDataWithAnimation(false)
				m.updateStatus()
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "markPrRead":
				if let
					itemId = userInfo?["id"] as? String,
					oid = DataManager.idForUriPath(itemId),
					pr = mainObjectContext.existingObjectWithID(oid, error:nil) as? PullRequest {
						pr.catchUpWithComments()
						popupManager.getMasterController().reloadDataWithAnimation(false)
						DataManager.saveDB()
						app.updateBadge()
				}
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "markIssueRead":
				if let
					itemId = userInfo?["id"] as? String,
					oid = DataManager.idForUriPath(itemId),
					i = mainObjectContext.existingObjectWithID(oid, error:nil) as? Issue {
						i.catchUpWithComments()
						popupManager.getMasterController().reloadDataWithAnimation(false)
						DataManager.saveDB()
						app.updateBadge()
				}
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "markEverythingRead":
				PullRequest.markEverythingRead(PullRequestSection.None, moc: mainObjectContext)
				Issue.markEverythingRead(PullRequestSection.None, moc: mainObjectContext)
				popupManager.getMasterController().reloadDataWithAnimation(false)
				DataManager.saveDB()
				app.updateBadge()
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "markAllPrsRead":
				if let s = userInfo?["sectionIndex"] as? Int {
					PullRequest.markEverythingRead(PullRequestSection(rawValue: s)!, moc: mainObjectContext)
					popupManager.getMasterController().reloadDataWithAnimation(false)
					DataManager.saveDB()
					app.updateBadge()
				}
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			case "markAllIssuesRead":
				if let s = userInfo?["sectionIndex"] as? Int {
					Issue.markEverythingRead(PullRequestSection(rawValue: s)!, moc: mainObjectContext)
					popupManager.getMasterController().reloadDataWithAnimation(false)
					DataManager.saveDB()
					app.updateBadge()
				}
				atNextEvent() {
					reply(["status": "Success", "color": "green"])
					self.endBGTask()
				}
			default:
				atNextEvent() {
					self.endBGTask()
				}
			}
		}
	}
}
