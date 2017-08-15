//
//  oAuth2UpgradeToUser.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-15.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication
import OAuth2


extension Handlers {

	// Upgrade a supplied access token to a VALIDATED user
	// Note that this is conducted via API only. The Convert2User method is for Web
	static func oAuth2UpgradeToUser(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let provider 		= request.urlVariables["provider"] ?? ""
			let accessToken 	= request.urlVariables["token"] ?? ""

			var userProfile = [String:Any]()
			// initially supporting Facebook, Linkedin, Google.
			switch provider {
			case "facebook":
				userProfile = Facebook(clientID: "",clientSecret: "").getUserData(accessToken)
			case "linkedin":
				userProfile = Linkedin(clientID: "",clientSecret: "").getUserData(accessToken)
			case "google":
				userProfile = Google(clientID: "",clientSecret: "").getUserData(accessToken)
			default:
				response.completed(status: .badRequest)
				return
			}

			let userid = userProfile["userid"] as? String ?? ""
			if userid.isEmpty {
				response.completed(status: .badRequest)
				return
			}

			let user = Account()

			do {
				try user.find(["source": provider, "remoteid": userid])
				//print("FOUND \(provider) user \(userid), id is \(user.id)")
				if user.id.isEmpty {
					// no user, make one.
					user.makeID()
					user.usertype = .standard
					user.source = provider
					user.remoteid = userid // storing remote id so we can upgrade to user
					user.detail["firstname"] = userProfile["first_name"] as? String ?? ""
					user.detail["lastname"] = userProfile["last_name"] as? String ?? ""
					try user.create()
					request.session?.userid = user.id // storing new user id in session
				} else {
					// user exists, upgrade session to user.
					request.session?.userid = user.id
				}
			} catch {
				// no user
				print("something wrong finding user: \(error)")
				response.completed(status: .badRequest)
				return
			}

			let _ = try? response.setBody(json: ["userid": user.id, "firstname": user.detail["firstname"], "lastname": user.detail["lastname"]])
			response.completed()

		}
	}



}
