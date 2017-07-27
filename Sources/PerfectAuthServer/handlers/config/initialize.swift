//
//  initialize.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-07-19.
//


import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension Handlers {

	static func initialize(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let users = Account()
			try? users.findAll()
			if users.rows().count > 0 {
				response.redirect(path: "/")
				response.completed()
				return
			}

			var context: [String : Any] = [String: Any]()

			// add app config vars
			for i in Handlers.appExtras(request) {
				context[i.0] = i.1
			}

			response.render(template: "views/initialsetup", context: context)
		}
	}

	static func initializeSave(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			
			let users = Account()
			try? users.findAll()
			if users.rows().count > 0 {
				response.redirect(path: "/")
				response.completed()
				return
			}

			let user = Account()
			var msg = ""



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

				user.usertype = .admin

				user.makeID()
				try? user.create()

			} else {
				print("Please enter the user's first and last name, as well as a valid email.")
				msg = "Please enter the user's first and last name, as well as a valid email."
				redirectRequest(request, response, msg: msg, template: "views/initialsetup")
			}

			response.redirect(path: "/")
			response.completed()
			return

		}
	}
}

