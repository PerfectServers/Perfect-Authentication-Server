//
//  OAuth2Login.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-08.
//

import PerfectHTTP
import PerfectSession
import PerfectCrypto
import PerfectSessionPostgreSQL
import LocalAuthentication

extension OAuth2Handlers {

	public static func login(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			var template = "/views/loginOAuth.mustache" // where it goes to after
			if let i = request.session?.userid, !i.isEmpty { response.redirect(path: "/") }
			var context: [String : Any] = ["title": configTitle]
			context["csrfToken"] = request.session?.data["csrf"] as? String ?? ""

			if let u = request.param(name: "username"), !(u as String).isEmpty,
				let p = request.param(name: "password"), !(p as String).isEmpty {
				do {
					let acc = try Account.login(u, p)
					request.session?.userid = acc.id
					context["msg_title"] = "Login Successful."
					context["msg_body"] = ""

					OAuth2Handlers.doAuth(request, response)
					return
					
				} catch {
					context["msg_title"] = "Login Error."
					context["msg_body"] = "Username or password incorrect"
					template = "/views/loginOAuth.mustache"
				}
			} else {
				context["msg_title"] = "Login Error."
				context["msg_body"] = "Username or password not supplied"
				template = "/views/loginOAuth.mustache"
			}

			response.renderMustache(template: request.documentRoot + template, context: context)
		}
	}

}
