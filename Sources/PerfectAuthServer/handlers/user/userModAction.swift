//
//  userModAction.swift
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
	
	static func userModAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Account()
			var msg = ""

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid User", template: "views/user")
				}
			}


			if let firstname = request.param(name: "firstname"), !firstname.isEmpty,
				let lastname = request.param(name: "lastname"), !lastname.isEmpty,
				let email = request.param(name: "email"), !email.isEmpty,
				let username = request.param(name: "username"), !username.isEmpty{
				user.username = username
				user.detail["firstname"] = firstname
				user.detail["lastname"] = lastname
				user.email = email


				if let pwd = request.param(name: "pw"), !pwd.isEmpty {
					user.makePassword(pwd)
				}

				switch request.param(name: "usertype") ?? "" {
					case "standard":
						user.usertype = .standard
					case "admin":
						user.usertype = .admin
					case "inactive":
						user.usertype = .inactive
					default:
						user.usertype = .provisional
				}

				if user.id.isEmpty {
					user.makeID()
					try? user.create()
				} else {
					try? user.save()
				}

			} else {
				msg = "Please enter the user's first and last name, as well as a valid email."
				redirectRequest(request, response, msg: msg, template: "views/users", additional: [
					"usermod?":"true",
					])
			}


			let users = Account.listUsers()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true",
				"users": users,
				"msg": msg
			]
			if contextAuthenticated {
				for i in Handlers.extras(request) {
					context[i.0] = i.1
				}
			}
			// add app config vars
			for i in Handlers.appExtras(request) {
				context[i.0] = i.1
			}

			response.render(template: "views/users", context: context)
		}
	}
}
