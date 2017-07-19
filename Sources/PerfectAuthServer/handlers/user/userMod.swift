//
//  userMod.swift
//  ServerMonitor
//
//  Created by Jonathan Guthrie on 2017-04-30.
//
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension Handlers {

	static func userMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Account()
			var action = "Create"

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid User", template: "views/user")
				}

				action = "Edit"
			}


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"usermod?":"true",
				"action": action,
				"username": user.username,
				"firstname": user.detail["firstname"] ?? "",
				"lastname": user.detail["lastname"] ?? "",
				"email": user.email,
				"id": user.id
			]

			switch user.usertype {
			case .standard:
				context["usertypestandard"] = " selected=\"selected\""
			case .admin:
				context["usertypeadmin"] = " selected=\"selected\""
			case .inactive:
				context["usertypeinactive"] = " selected=\"selected\""
			default:
				context["usertypeprovisional"] = " selected=\"selected\""
			}

			if contextAuthenticated {
				for i in Handlers.extras(request) {
					context[i.0] = i.1
				}
			}
			// add app config vars
			for i in Handlers.appExtras(request) {
				context[i.0] = i.1
			}
			response.render(template: "views/users", context: context)
		}
	}

}
