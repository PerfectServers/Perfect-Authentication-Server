//
//  UserExtension.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-07-28.
//

import PerfectLocalAuthentication
import PerfectHTTP

extension Account {
	public static func adminBounce(_ request: HTTPRequest, _ response: HTTPResponse) {
		let user = Account()
		do {
			try user.get(request.session?.userid ?? "")
			if !user.isAdmin() {
				response.redirect(path: "/")
			}
		} catch {
			print(error)
		}
	}
}
