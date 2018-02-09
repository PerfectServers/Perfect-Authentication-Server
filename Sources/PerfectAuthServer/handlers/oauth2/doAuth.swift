//
//  doAuth.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-08.
//


import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication

extension OAuth2Handlers {

	static func doAuth(_ request: HTTPRequest, _ response: HTTPResponse) {
		let response_type 	= request.param(name: "response_type") ?? ""
		let client_id 		= request.param(name: "client_id") ?? ""
//		let secret 			= request.param(name: "secret") ?? ""
		let redirecturl 	= request.param(name: "redirect_uri") ?? ""
		let state 			= request.param(name: "state") ?? ""

		let app = OAuth2Handlers.doAuthCheck(request, response)

		// CHECK INFO IS VALID
		if app.id.isEmpty {
			let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_request])
			response.completed(status: .badRequest)
			return
		}

		// CHECK AUTH
		let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
		var context: [String : Any] = [
			"application":app.name,
			"response_type":response_type,
			"client_id": client_id,
//			"secret": secret,
			"redirect_uri": redirecturl,
			"state": state,
			"csrfToken": request.session?.data["csrf"] as? String ?? ""
		]
		// add app config vars
		for i in Handlers.appExtras(request) { context[i.0] = i.1 }

		var template = "OAuthAuthorize.mustache" // -> grant
		if !contextAuthenticated {
			// login
			template = "OAuthLogin.mustache"
		}
		response.renderMustache(template: request.documentRoot + "/views/OAuth/\(template)", context: context)
		response.completed()
		return
	}
}
