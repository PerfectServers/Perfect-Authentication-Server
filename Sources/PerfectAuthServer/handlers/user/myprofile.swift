//
//  myprofile.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-07-19.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication


extension Handlers {

	static func profile(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			var msg = ""

			let user = Account()
			try? user.get(contextAccountID)

			var template = "/views/myprofileoauth.mustache"
			if user.source == "local" {
				template = "/views/myprofilelocal.mustache"
			}

			if request.method == .post {
				// handle save

				user.email = request.param(name: "email", defaultValue: "") ?? ""
				user.detail["firstname"] = request.param(name: "firstname", defaultValue: "")
				user.detail["lastname"] = request.param(name: "lastname", defaultValue: "")

				if user.source == "local" {
					if let pwd = request.param(name: "pw"), !pwd.isEmpty {
						user.makePassword(pwd)
					}
				}

				do {
					try user.save()
					msg = "Saved"
				} catch {
					msg = "\(error)"
				}
			}


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"username": user.username,
				"firstname": user.detail["firstname"] ?? "",
				"lastname": user.detail["lastname"] ?? "",
				"email": user.email,
				"id": user.id,
				"msg": msg
			]

			if contextAuthenticated {
				for i in Handlers.extras(request) {
					context[i.0] = i.1
				}
			}
			// add app config vars
			for i in Handlers.appExtras(request) {
				context[i.0] = i.1
			}
			response.renderMustache(template: request.documentRoot + template, context: context)
		}
	}

}

