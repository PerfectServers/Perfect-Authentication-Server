//
//  Routes.swift
//  Perfect-Local-Auth-template
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

import PerfectHTTPServer
import LocalAuthentication
import OAuth2

func mainRoutes() -> [[String: Any]] {

	var routes: [[String: Any]] = [[String: Any]]()
	// =========================================================================================
	// Special healthcheck
	// =========================================================================================
	routes.append(["method":"get", "uri":"/healthcheck", "handler":Handlers.healthcheck])
	routes.append(["method":"get", "uri":"/initialize", "handler":Handlers.initialize])
	routes.append(["method":"post", "uri":"/setup", "handler":Handlers.initializeSave])

	// =========================================================================================
	// add Static files
	// =========================================================================================
	routes.append(["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
	               "documentRoot":"./webroot",
	               "allowResponseFilters":true])

	// =========================================================================================
	// Handler for home page
	// =========================================================================================
	routes.append(["method":"get", "uri":"/", "handler":Handlers.main])

	// =========================================================================================
	// Login
	// =========================================================================================
	routes.append(["method":"get", "uri":"/login", "handler":Handlers.login]) // simply a serving of the login GET
	routes.append(["method":"post", "uri":"/login", "handler":LocalAuthWebHandlers.login])
	routes.append(["method":"get", "uri":"/logout", "handler":LocalAuthWebHandlers.logout])

	// =========================================================================================
	// Register
	// =========================================================================================
	routes.append(["method":"get", "uri":"/register", "handler":LocalAuthWebHandlers.register])
	routes.append(["method":"post", "uri":"/register", "handler":LocalAuthWebHandlers.registerPost])
	routes.append(["method":"get", "uri":"/verifyAccount/{passvalidation}", "handler":LocalAuthWebHandlers.registerVerify])
	routes.append(["method":"post", "uri":"/registrationCompletion", "handler":LocalAuthWebHandlers.registerCompletion])

	// =========================================================================================
	// JSON
	// =========================================================================================
	routes.append(["method":"get", "uri":"/api/v1/session", "handler":LocalAuthJSONHandlers.session])
	routes.append(["method":"get", "uri":"/api/v1/me", "handler":LocalAuthJSONHandlers.me])
	routes.append(["method":"get", "uri":"/api/v1/logout", "handler":LocalAuthJSONHandlers.logout])
	routes.append(["method":"post", "uri":"/api/v1/register", "handler":LocalAuthJSONHandlers.register])
	routes.append(["method":"post", "uri":"/api/v1/login", "handler":LocalAuthJSONHandlers.login])
	routes.append(["method":"post", "uri":"/api/v1/changepassword", "handler":LocalAuthJSONHandlers.changePassword])

	// =========================================================================================
	// OAuth2 Redirector (see https://github.com/OAuthSwift/OAuthSwift/wiki/API-with-only-HTTP-scheme-into-callback-URL)
	/*
	for 'oauth-swift' URL scheme : http://oauthswift.herokuapp.com/callback/{path?query} which redirect to oauth-swift://oauth-callback/{path?query}
	*/
	// =========================================================================================
	routes.append(["method":"get", "uri":"/api/v1/oauth/return/{provider}", "handler":Handlers.oAuthRedirecter])

	// =========================================================================================
	// Users
	// =========================================================================================
	routes.append(["method":"get", "uri":"/users", "handler":Handlers.userList])
	routes.append(["method":"get", "uri":"/users/create", "handler":Handlers.userMod])
	routes.append(["method":"get", "uri":"/users/{id}/edit", "handler":Handlers.userMod])
	routes.append(["method":"post", "uri":"/users/create", "handler":Handlers.userModAction])
	routes.append(["method":"post", "uri":"/users/{id}/edit", "handler":Handlers.userModAction])
	routes.append(["method":"delete", "uri":"/users/{id}/delete", "handler":Handlers.userDelete])

	routes.append(["method":"get", "uri":"/profile", "handler":Handlers.profile])
	routes.append(["method":"post", "uri":"/profile", "handler":Handlers.profile])


	// =========================================================================================
	// Applications
	// =========================================================================================
	routes.append(["method":"get", "uri":"/applications", "handler":Handlers.applicationList])
	routes.append(["method":"get", "uri":"/applications/create", "handler":Handlers.applicationMod])
	routes.append(["method":"get", "uri":"/applications/{id}/edit", "handler":Handlers.applicationMod])
	routes.append(["method":"post", "uri":"/applications/create", "handler":Handlers.applicationModAction])
	routes.append(["method":"post", "uri":"/applications/{id}/edit", "handler":Handlers.applicationModAction])
	routes.append(["method":"delete", "uri":"/applications/{id}/delete", "handler":Handlers.applicationDelete])



	// =========================================================================================
	// OAuth2 Triggers
	// =========================================================================================
	routes.append(["method":"get", "uri":"/to/facebook", "handler":Facebook.sendToProvider])
	routes.append(["method":"get", "uri":"/to/github", "handler":GitHub.sendToProvider])
	routes.append(["method":"get", "uri":"/to/google", "handler":Google.sendToProvider])
	routes.append(["method":"get", "uri":"/to/linkedin", "handler":Linkedin.sendToProvider])
	routes.append(["method":"get", "uri":"/to/slack", "handler":Slack.sendToProvider])
	routes.append(["method":"get", "uri":"/to/salesforce", "handler":SalesForce.sendToProvider])

	// =========================================================================================
	// OAuth2 Responses
	// =========================================================================================
	routes.append(["method":"get", "uri":"/auth/response/facebook", "handler":Facebook.authResponse])
	routes.append(["method":"get", "uri":"/auth/response/github", "handler":GitHub.authResponse])
	routes.append(["method":"get", "uri":"/auth/response/google", "handler":Google.authResponse])
	routes.append(["method":"get", "uri":"/auth/response/linkedin", "handler":Linkedin.authResponse])
	routes.append(["method":"get", "uri":"/auth/response/slack", "handler":Slack.authResponse])
	routes.append(["method":"get", "uri":"/auth/response/salesforce", "handler":SalesForce.authResponse])

	routes.append(["method":"get", "uri":"/oauth/convert", "handler":Handlers.oAuth2ConvertToUser])

	// =========================================================================================
	// OAuth2 Server
	// =========================================================================================
	routes.append(["method":"get", "uri":"/oauth/authenticate", "handler":OAuth2Handlers.authorize])
	routes.append(["method":"post", "uri":"/oauth/login", "handler":OAuth2Handlers.login])
	routes.append(["method":"post", "uri":"/oauth/grant", "handler":OAuth2Handlers.grant])
	routes.append(["method":"post", "uri":"/oauth/token", "handler":OAuth2Handlers.getToken]) // exchange token
	routes.append(["method":"get", "uri":"/oauth/profile", "handler":OAuth2Handlers.getProfile])


	return routes
}
