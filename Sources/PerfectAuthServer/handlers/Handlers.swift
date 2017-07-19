//
//  Handlers.swift
//  Perfect-App-Template
//
//  Created by Jonathan Guthrie on 2017-02-20.
//	Copyright (C) 2017 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import StORM
import LocalAuthentication

class Handlers {

	// Basic "main" handler - simply outputs "Hello, world!"
	static func main(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			var context: [String : Any] = ["title": "Perfect Authentication Server"]
			if let i = request.session?.userid, !i.isEmpty { context["authenticated"] = true }

			// add app config vars
			for i in Handlers.extras(request) { context[i.0] = i.1 }
			for i in Handlers.appExtras(request) { context[i.0] = i.1 }

			response.render(template: "views/index", context: context)
		}
	}

//	public static func login(data: [String:Any]) throws -> RequestHandler {
//		return {
//			request, response in
//			var context: [String : Any] = ["title": "Perfect Authentication Server"]
//			if let i = request.session?.userid, !i.isEmpty { context["authenticated"] = true }
//
//			// add app config vars
//			for i in Handlers.extras(request) { context[i.0] = i.1 }
//			for i in Handlers.appExtras(request) { context[i.0] = i.1 }
//
//			response.render(template: "views/login", context: context)
//		}
//	}




}
