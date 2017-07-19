//
//  configGet.swift
//  APIDocumentationServer
//
//  Created by Jonathan Guthrie on 2017-06-04.
//
//

import PerfectHTTP
import PerfectLogger


extension Handlers {

	static func configGet(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true"
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

			response.render(template: "views/config", context: context)
		}
	}
	
}
