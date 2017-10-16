//
//  myData.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-11.
//


import PerfectHTTP
import PerfectLocalAuthentication
import PerfectLib


extension Handlers {

	static func myData(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			if let i = request.session?.userid, !i.isEmpty {
				let acc = Account()
				do {
					try acc.get(i)
					// Save if POST
					if request.method == .post {
						acc.detail["userdata"] = try request.postBodyString?.jsonDecode()
						try acc.save()
					}
					// Set and return data as JSON
					_ = try? response.setBody(json: [
						"userdata":acc.detail["userdata"] ?? [String:Any]()
						])
					response.completed()
					return
				} catch {
					LocalAuthHandlers.error(request, response, error: "AccountError", code: .badRequest)
					return
				}
			} else {
				LocalAuthHandlers.error(request, response, error: "NotLoggedIn", code: .badRequest)
				return
			}
		}
	}

}


