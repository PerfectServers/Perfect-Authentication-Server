//
//  ApplicationDelete.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-04.
//

import PerfectHTTP
import PerfectLogger
import PerfectLocalAuthentication


extension Handlers {

	static func applicationDelete(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			if (request.session?.userid ?? "").isEmpty { response.completed(status: .notAcceptable) }

			// Verify Admin
			Account.adminBounce(request, response)

			let obj = Application()

			if let id = request.urlVariables["id"] {
				try? obj.get(id)

				if obj.id.isEmpty {
					errorJSON(request, response, msg: "Invalid Application")
				} else {
					try? obj.delete()
				}
			}


			response.setHeader(.contentType, value: "application/json")
			var resp = [String: Any]()
			resp["error"] = "None"
			do {
				try response.setBody(json: resp)
			} catch {
				print("error setBody: \(error)")
			}
			response.completed()
			return
		}
	}
}

