//
//  Authorize.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-04.
//

import SwiftMoment
import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication

/*
	localhost:8181/oauth/authenticate?client_id=S7oZBD42uusODflJ38jkug&secret=khP9KGFnMDy0na3Ai_keYQ&response_type=code&redirect_uri=http://localhost:8181/donkey
*/
extension OAuth2Handlers {
	static func authorize(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			OAuth2Handlers.doAuth(request, response)
		}
	}
}
