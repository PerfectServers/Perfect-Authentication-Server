//
//  ApplicationModAction.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-04.
//

import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication
import SwiftRandom


extension Handlers {

	static func applicationModAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			// Verify Admin
			Account.adminBounce(request, response)

			let obj = Application()
			var msg = ""

			if let id = request.urlVariables["id"] {
				try? obj.get(id)

				if obj.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid Application", template: request.documentRoot + "/views/applications.mustache")
				}
			} else if let id = request.param(name: "id"), !id.isEmpty {
				try? obj.get(id)
			}



			if let name = request.param(name: "name"), !name.isEmpty {
				obj.name = name

				obj.redirecturls = [String]() // empty out
				for ii in 0..<10 {
					if let redirect = request.param(name: "redirect\(ii)"), !redirect.isEmpty {
						obj.redirecturls.append(redirect)
					}
				}


				let r = URandom()

				if obj.clientid.isEmpty {
					obj.clientid = r.secureToken
				}
				if obj.clientsecret.isEmpty {
					obj.clientsecret = r.secureToken
				}

				if obj.id.isEmpty {
					obj.makeID()
					try? obj.create()
				} else {
					try? obj.save()
				}

			} else {
				msg = "Please enter the application's name."
				redirectRequest(request, response, msg: msg, template: request.documentRoot + "/views/applications.mustache", additional: [
					"mod?":"true",
					])
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
				"action": "Edit",
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

