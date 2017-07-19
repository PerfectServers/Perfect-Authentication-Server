//
//  oAuth2ConvertToUser.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-07-19.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension Handlers {

	static func oAuth2ConvertToUser(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Account()
			guard let source = request.session?.data["loginType"] else {
				response.redirect(path: "/")
				response.completed()
				return
			}
			do {
				try user.find(["source": source, "remoteid": contextAccountID])
				if user.id.isEmpty {
					// no user, make one.
					user.makeID()
					user.usertype = .standard
					user.source = source as? String ?? "unknown"
					user.remoteid = contextAccountID // storing remote id so we can upgrade to user
					user.detail["firstname"] = request.session?.data["firstName"] as? String ?? ""
					user.detail["lastname"] = request.session?.data["lastName"] as? String ?? ""
					try user.create()
					request.session?.userid = user.id // storing new user id in session
				} else {
					// user exists, upgrade session to user.
					request.session?.userid = user.id
				}
			} catch {
				// no user
				print("something wrong finding user: \(error)")
				response.redirect(path: "/")
				response.completed()
				return
			}

			response.redirect(path: "/")
			response.completed()

		}
	}
}


