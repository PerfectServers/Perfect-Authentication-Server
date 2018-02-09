//
//  getToken.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-08.
//

import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication

extension OAuth2Handlers {
	// Post request
	static func getToken(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let grant_type 		= request.param(name: "grant_type") ?? ""
			let code 			= request.param(name: "code") ?? ""
			let client_id 		= request.param(name: "client_id") ?? ""
			let redirecturl 	= request.param(name: "redirect_uri") ?? ""

//			grant_type must be authorization_code
//			code must match and not be expired
//			client_id must not be empty and match what is in the code record
//			redirect_uri must be in allowed list

			// MUST nuke code record after success

			if grant_type != "authorization_code" {
				// reject
				print("grant_type != authorization_code")
				let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_request])
				response.completed(status: .badRequest)
				return
			}

			// load code
			let codeRecord = OAuth2Codes()
			let app = Application()
			do {
				try codeRecord.get(code)

				// make sure code has not expired
				if !codeRecord.isCurrent() {
					print("!codeRecord.isCurrent")
					throw OAuth2ErrorCodes.invalid_request
				}

				// chck client id is correct
				if codeRecord.clientid != client_id {
					print("codeRecord.clientid != client_id")
					throw OAuth2ErrorCodes.invalid_request
				}
				try app.find(["clientid":client_id])
				if app.id.isEmpty {
					print("app.id.isEmpty")
					throw OAuth2ErrorCodes.invalid_request
				}
				var redirectMatch = false
				for val in app.redirecturls {
					if val == redirecturl {
						redirectMatch = true
					}
				}
				if redirectMatch == false {
					print("redirectMatch == false")
					let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_request])
					response.completed(status: .badRequest)
					return
				}
			} catch {
				print("general fail")
				let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.invalid_request])
				response.completed(status: .badRequest)
				return
			}

			let userid = codeRecord.userid
//				request.session?.userid ?? ""
//			print(request.session?.userid)
			if userid.isEmpty {
				print("userid.isEmpty")
				let _ = try? response.setBody(json: ["error":OAuth2ErrorCodes.unauthorized_client])
				response.completed(status: .badRequest)
				return
			}
			// All checks have passed.
			// Create token, kill code.

			// create the token
			let token = AccessToken(userid: userid, clientid: client_id, expiration: oAuth2TokenExpiry)
			// save token, kill code
			do {
				try token.create()
				try codeRecord.delete()
			} catch {
				print("Error deleting code record: \(error)")
			}

			let resp: [String: Any] = [
				"access_token": token.accesstoken,
				"token_type": "bearer",
				"expires_in": oAuth2TokenExpiry,
				"refresh_token": token.refreshtoken
			]

			do {
				try response.setBody(json: resp)
				response.completed()
			} catch {
				print("ERROR RESPONDING TO ACCESS TOKEN: \(error)")
				response.completed()
			}
		}
	}

}

