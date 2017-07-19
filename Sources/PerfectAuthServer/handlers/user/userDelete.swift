//
//  userDelete.swift
//  ServerMonitor
//
//  Created by Jonathan Guthrie on 2017-04-30.
//
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension Handlers {

	static func userDelete(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			if (request.session?.userid ?? "").isEmpty { response.completed(status: .notAcceptable) }

			let user = Account()

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				// cannot delete yourself
				if user.id == (request.session?.userid ?? "") {
					errorJSON(request, response, msg: "You cannot delete yourself.")
					return
				}
				let usersCount = Account()
				try? usersCount.findAll()
				if usersCount.results.cursorData.totalRecords <= 1 {
					errorJSON(request, response, msg: "You cannot delete yourself.")
					return
				}

				if user.id.isEmpty {
					errorJSON(request, response, msg: "Invalid User")
				} else {
					try? user.delete()
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
