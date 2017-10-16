//
//  OAuth2SessionFilter.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-15.
//

import PerfectHTTP
import PerfectSession
import PerfectSessionPostgreSQL
import PerfectLogger
import PerfectLocalAuthentication

public class OAuth2SessionPostgresFilter {
	public var driver = PostgresSessions()
//	public init() {
//		driver.setup()
//	}
}
extension OAuth2SessionPostgresFilter: HTTPRequestFilter {

	public func filter(request: HTTPRequest, response: HTTPResponse, callback: (HTTPRequestFilterResult) -> ()) {
//		print("in oath2session filter request")
		if request.path != SessionConfig.healthCheckRoute {
			var createSession = true
			var session = PerfectSession()

			if let token = request.getCookie(name: SessionConfig.name) {
				// From Cookie
				session = driver.resume(token: token)
			} else if let bearer = request.header(.authorization), !bearer.isEmpty {
				// From Bearer Token
				let b = bearer.chompLeft("Bearer ")
				//print("looking for token \(b)")
				session = driver.resume(token: b)

				// For OAuth2 Filters, add alternative load here.
				if session.token.isEmpty {
//					print("For OAuth2 Filters, add alternative load here")
					let accessToken = AccessToken()
					try? accessToken.get(b)
					//print("access token: \(accessToken.accesstoken)")
					if !accessToken.accesstoken.isEmpty, accessToken.isCurrent() {
						session._isOAuth2 = true
						session.token = accessToken.accesstoken
						session.userid = accessToken.userid
						createSession = false
					}
				}


			} else if let s = request.param(name: "session"), !s.isEmpty {
				// From Session Link
				session = driver.resume(token: s)
			}

			if !session.token.isEmpty, !session._isOAuth2 {
				//				var session = driver.resume(token: token)
				if session.isValid(request) {
					session._state = "resume"
					request.session = session
					createSession = false
				} else {
					driver.destroy(request, response)
				}
			} else if session._isOAuth2 {
				session._state = "resume"
				request.session = session
			}
			if createSession, !session._isOAuth2 {
				//start new session
				request.session = driver.start(request)
			}

			if !session._isOAuth2 {
				// Now process CSRF
				if request.session?._state != "new" || request.method == .post {
					//print("Check CSRF Request: \(CSRFFilter.filter(request))")
					if !CSRFFilter.filter(request) {

						switch SessionConfig.CSRF.failAction {
						case .fail:
							response.status = .notAcceptable
							callback(.halt(request, response))
							return
						case .log:
							LogFile.info("CSRF FAIL")

						default:
							print("CSRF FAIL (console notification only)")
						}
					}
				}

				CORSheaders.make(request, response)
			}
		}
		callback(HTTPRequestFilterResult.continue(request, response))
	}

	/// Wrapper enabling PerfectHTTP 2.1 filter support
	public static func filterAPIRequest(data: [String:Any]) throws -> HTTPRequestFilter {
		return OAuth2SessionPostgresFilter()
	}

}
