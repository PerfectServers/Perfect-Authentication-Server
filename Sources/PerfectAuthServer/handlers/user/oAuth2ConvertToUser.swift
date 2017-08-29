//
//  oAuth2ConvertToUser.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-07-19.
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication
import OAuth2


extension Handlers {

	static func oAuth2ConvertToUser(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Account()
			guard let source = request.session?.data["loginType"] else {
				response.redirect(path: "/")
				response.completed()
				return
			}
			do {
				try user.find(["source": source, "remoteid": contextAccountID])
				if user.id.isEmpty {
					// no user, make one.
					user.makeID()
					user.usertype = .standard
					user.source = source as? String ?? "unknown"
					user.remoteid = contextAccountID // storing remote id so we can upgrade to user
					user.detail["firstname"] = request.session?.data["firstName"] as? String ?? ""
					user.detail["lastname"] = request.session?.data["lastName"] as? String ?? ""
					try user.create()
					request.session?.userid = user.id // storing new user id in session
				} else {
					// user exists, upgrade session to user.
					request.session?.userid = user.id
				}
			} catch {
				// no user
				print("something wrong finding user: \(error)")
				response.redirect(path: "/")
				response.completed()
				return
			}

			response.redirect(path: "/")
			response.completed()

		}
	}


	/// Helps with OAuth2 redirection for iOS apps
	public static func oAuthRedirecter(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			var str = [String]()
			for param in request.params() {
				str.append("\(param.0)=\(param.1)")
			}

			let provider = request.urlVariables["provider"] ?? ""

			print("REDIRECTING TO: \(LocalAuthConfig.OAuthAppNameScheme)/\(provider)?\(str.joined(separator: "&"))")
//			print("REDIRECTING TO: oauth-swift://oauth-callback/\(provider)?\(str.joined(separator: "&"))")
			response.status = .temporaryRedirect
			response.setHeader(.location, value: "\(LocalAuthConfig.OAuthAppNameScheme)/\(provider)?\(str.joined(separator: "&"))")
			response.completed()
		}
	}




}
