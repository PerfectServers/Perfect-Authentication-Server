//
//  configSave.swift
//  APIDocumentationServer
//
//  Created by Jonathan Guthrie on 2017-06-04.
//
//

import PerfectHTTP
import PerfectLogger

extension Handlers {

	static func configSave(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			var msg = ""

			if let title = request.param(name: "configTitle"), !title.isEmpty,
				let logo = request.param(name: "configLogo"), !logo.isEmpty,
				let srcset = request.param(name: "configLogoSrcSet"), !srcset.isEmpty {

				do {
					let cTitle = Config()
//					cTitle.name = "title"
//					cTitle.val = title
					try cTitle.upsert(cols: ["name","val"], params: ["title",title], conflictkeys: ["name"])
					configTitle = title

					let cLogo = Config()
//					cLogo.name = "logo"
//					cLogo.val = logo
					try cLogo.upsert(cols: ["name","val"], params: ["logo",logo], conflictkeys: ["name"])
					configLogo = logo

					let cLogoSrcSet = Config()
//					cLogoSrcSet.name = "logosrcset"
//					cLogoSrcSet.val = srcset
					try cLogoSrcSet.upsert(cols: ["name","val"], params: ["logosrcset",srcset], conflictkeys: ["name"])
					configLogoSrcSet = srcset

				} catch {
					msg = "Error saving Config Data: \(error)"
				}
				
			} else {
				msg = "Please enter all information."
			}

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true",
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

			response.render(template: "views/config", context: context)
		}
	}
	
}
