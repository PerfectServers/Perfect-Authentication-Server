//
//  getProfile.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-09.
//

import Foundation
import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication

extension OAuth2Handlers {
	// GET request
	static func getProfile(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let user = Account()
			if var bearer = request.header(.authorization), !bearer.isEmpty, bearer.hasPrefix("Bearer ") {
				// From Bearer Token
				bearer.removeFirst("Bearer ".count)
				let accessTokenRecord = AccessToken()
				try? accessTokenRecord.get(bearer)
				if !accessTokenRecord.isCurrent() {
					response.completed(status: .unauthorized)
				}
				try? user.get(accessTokenRecord.userid)
				if user.id.isEmpty {
					response.completed(status: .unauthorized)
				}
			} else {
				response.completed(status: .unauthorized)
			}

			let resp: [String: Any] = [
				"firstname": user.detail["firstname"] as? String ?? "",
				"lastname": user.detail["lastname"] as? String ?? ""
			]

			do {
				try response.setBody(json: resp)
				response.completed()
			} catch {
				print("ERROR RESPONDING TO PROFILE REQUEST: \(error)")
				response.completed()
			}
		}
	}

}


