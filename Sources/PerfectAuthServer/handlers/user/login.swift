//
//  login.swift
//  APIDocumentationServer
//
//  Created by Jonathan Guthrie on 2017-05-09.
//
//


import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL
import LocalAuthentication

extension Handlers {

	public static func login(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			var context: [String : Any] = ["title": "Perfect API Documentation Server"]
			if let i = request.session?.userid, !i.isEmpty { context["authenticated"] = true }
			context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""

			// add app config vars
			for i in Handlers.appExtras(request) {
				context[i.0] = i.1
			}

			response.render(template: "views/login", context: context)
		}
	}

}
