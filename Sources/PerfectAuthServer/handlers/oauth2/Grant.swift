//
//  Grant.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-08.
//

import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication

extension OAuth2Handlers {

	static func grant(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let response_type 	= request.param(name: "response_type") ?? ""
			let client_id 		= request.param(name: "client_id") ?? ""
			let state 			= request.param(name: "state") ?? ""
			let redirecturl 	= request.param(name: "redirect_uri") ?? ""

			let app = OAuth2Handlers.doAuthCheck(request, response)

			// CHECK INFO IS VALID
			if app.id.isEmpty() {
				let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_request])
				response.completed(status: .badRequest)
				return
			}

			// now make grant, or tokens
			if response_type == "token" {

			} else {
				let code = OAuth2Codes(userid: (request.session?.userid ?? ""), clientid: client_id, expiration: 10)
//				response.status = .movedPermanently
//				response.redirect(path: "\(redirecturl)?code=\(code.code)&state=\(state)")
//				response.setHeader(.location, value: "\(redirecturl)?code=\(code.code)&state=\(state)")
				response.renderMustache(template: request.documentRoot + "/views/OAuth/OAuthRediect.mustache", context: ["metatags":"<meta http-equiv=\"refresh\" content=\"0; url=\(redirecturl)?code=\(code.code)&state=\(state)\" />","location":"\(redirecturl)?code=\(code.code)&state=\(state)"])
				response.completed()
			}
		}
	}

}

