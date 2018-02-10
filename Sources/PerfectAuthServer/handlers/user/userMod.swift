//
//  userMod.swift
//  ServerMonitor
//
//  Created by Jonathan Guthrie on 2017-04-30.
//
//


import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication


extension Handlers {

	static func userMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			// Verify Admin
			Account.adminBounce(request, response)

			let user = Account()
			var action = "Create"

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid User", template: request.documentRoot + "/views/user.mustache")
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
			case .admin1:
				context["usertypeadmin1"] = " selected=\"selected\""
			case .admin2:
				context["usertypeadmin2"] = " selected=\"selected\""
			case .admin3:
				context["usertypeadmin3"] = " selected=\"selected\""
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
			response.renderMustache(template: request.documentRoot + "/views/users.mustache", context: context)
		}
	}

}
