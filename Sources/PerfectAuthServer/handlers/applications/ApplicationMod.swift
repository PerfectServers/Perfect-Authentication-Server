//
//  ApplicationMod.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-04.
//

import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication


extension Handlers {

	static func applicationMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			// Verify Admin
			Account.adminBounce(request, response)

			let obj = Application()
			var action = "Create"

			if let id = request.urlVariables["id"] {
				try? obj.get(id)

				if obj.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Application", template: request.documentRoot + "/views/application.mustache")
				}

				action = "Edit"
			}

			//show message: it's not saved so all good!
			if obj.clientid.isEmpty {
				obj.clientid = "To be assigned"
			}
			if obj.clientsecret.isEmpty {
				obj.clientsecret = "To be assigned"
			}

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"mod?":"true",
				"action": action,
				"name": obj.name,
				"clientid": obj.clientid,
				"clientsecret": obj.clientsecret,
				"id": obj.id
			]
			for (index, value) in obj.redirecturls.enumerated() {
				context["redirect\(index)"] = value
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
			response.renderMustache(template: request.documentRoot + "/views/applications.mustache", context: context)
		}
	}

}

