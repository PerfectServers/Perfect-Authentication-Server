//
//  doAuthCheck.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-08.
//

import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication

extension OAuth2Handlers {

	static func doAuthCheck(_ request: HTTPRequest, _ response: HTTPResponse) -> Application {
		let response_type 		= request.param(name: "response_type") ?? ""
		let client_id 		= request.param(name: "client_id") ?? ""
//		let secret 			= request.param(name: "secret") ?? ""
		let redirecturl 	= request.param(name: "redirect_uri") ?? ""

		let app = Application()

		// https://tools.ietf.org/html/rfc6749#section-5.2
		if response_type != "code", response_type != "token" {
			print("Grant mismatch")
			let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_grant])
			response.completed(status: .badRequest)
			return app
		} else if client_id.isEmpty {
			print("ClientID empty")
			let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_client])
			response.completed(status: .badRequest)
			return app
		}
		do {
//			try app.find(["clientid": client_id, "clientsecret": secret])
			try app.find(["clientid": client_id])
			if app.id.isEmpty {
				print("Client mismatch")
				let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_client])
				response.completed(status: .badRequest)
				return app
			}
			var redirectMatch = false
			for val in app.redirecturls {
				if val == redirecturl {
					redirectMatch = true
				}
			}
			if redirectMatch == false {
				print("Redirect mismatch: \(redirecturl) vs \(app.redirecturls)")
				let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_request])
				response.completed(status: .badRequest)
				return app
			}
		} catch {
			print(error)
			let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_request])
			response.completed(status: .badRequest)
			return app
		}
		return app
	}
}
