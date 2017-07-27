//
//  Config.swift
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

import PerfectLib
import JSONConfig
import PerfectSession
import PerfectSessionPostgreSQL
import LocalAuthentication
import OAuth2
import StORM
import PostgresStORM

struct AppCredentials {
	var clientid = ""
	var clientsecret = ""
}

func config() {
	#if os(Linux)
		let fname = "./config/ApplicationConfigurationLinux.json"
	#else
		let fname = "./config/ApplicationConfiguration.json"
	#endif

	if let configData = JSONConfig(name: fname) {
		if let dict = configData.getValues() {

			// Required Values
			httpPort = dict["httpport"] as? Int ?? httpPort

			// Optional Values
			if let i = dict["databasedebug"] {
				if (i as? String ?? "") == "true" {
					StORMdebug = true
				}
			}

			if let i = dict["sslCertPath"] {
				if !(i as? String ?? "").isEmpty {
					sslCertPath = i as? String ?? ""
				}
			}
			if let i = dict["sslKeyPath"] {
				if !(i as? String ?? "").isEmpty {
					sslKeyPath = i as? String ?? ""
				}
			}

			if let i = dict["baseDomain"] {
				if !(i as? String ?? "").isEmpty {
					SessionConfig.cookieDomain = i as? String ?? SessionConfig.cookieDomain
				}
			}

			// For ORM
			PostgresConnector.host        = dict["postgreshost"] as? String ?? "localhost"
			PostgresConnector.username    = dict["postgresuser"] as? String ?? ""
			PostgresConnector.password    = dict["postgrespwd"] as? String ?? ""
			PostgresConnector.database    = dict["postgresdbname"] as? String ?? ""
			PostgresConnector.port        = dict["postgresport"] as? Int ?? 5432

			// For Sessions
			PostgresSessionConnector.host = PostgresConnector.host
			PostgresSessionConnector.port = PostgresConnector.port
			PostgresSessionConnector.username = PostgresConnector.username
			PostgresSessionConnector.password = PostgresConnector.password
			PostgresSessionConnector.database = PostgresConnector.database
			PostgresSessionConnector.table = "sessions"

			// Outbound email config
			SMTPConfig.mailserver         = dict["mailserver"] as? String ?? ""
			SMTPConfig.mailuser			  = dict["mailuser"] as? String ?? ""
			SMTPConfig.mailpass			  = dict["mailpass"] as? String ?? ""
			SMTPConfig.mailfromaddress    = dict["mailfromaddress"] as? String ?? ""
			SMTPConfig.mailfromname       = dict["mailfromname"] as? String ?? ""

			// OAuth2 Config
			if let i = dict["facebookAppID"] { FacebookConfig.appid = i as? String ?? "" }
			if let i = dict["facebookSecret"] { FacebookConfig.secret = i as? String ?? "" }
			if let i = dict["facebookEndpointAfterAuth"] { FacebookConfig.endpointAfterAuth = i as? String ?? "" }
			if let i = dict["facebookRedirectAfterAuth"] { FacebookConfig.redirectAfterAuth = i as? String ?? "" }

			if let i = dict["githubKey"] { GitHubConfig.appid = i as? String ?? "" }
			if let i = dict["githubSecret"] { GitHubConfig.secret = i as? String ?? "" }
			if let i = dict["githubEndpointAfterAuth"] { GitHubConfig.endpointAfterAuth = i as? String ?? "" }
			if let i = dict["githubRedirectAfterAuth"] { GitHubConfig.redirectAfterAuth = i as? String ?? "" }

			if let i = dict["googleKey"] { GoogleConfig.appid = i as? String ?? "" }
			if let i = dict["googleSecret"] { GoogleConfig.secret = i as? String ?? "" }
			if let i = dict["googleEndpointAfterAuth"] { GoogleConfig.endpointAfterAuth = i as? String ?? "" }
			if let i = dict["googleRedirectAfterAuth"] { GoogleConfig.redirectAfterAuth = i as? String ?? "" }

			if let i = dict["linkedinKey"] { LinkedinConfig.appid = i as? String ?? "" }
			if let i = dict["linkedinSecret"] { LinkedinConfig.secret = i as? String ?? "" }
			if let i = dict["linkedinEndpointAfterAuth"] { LinkedinConfig.endpointAfterAuth = i as? String ?? "" }
			if let i = dict["linkedinRedirectAfterAuth"] { LinkedinConfig.redirectAfterAuth = i as? String ?? "" }

			if let i = dict["slackKey"] { SlackConfig.appid = i as? String ?? "" }
			if let i = dict["slackSecret"] { SlackConfig.secret = i as? String ?? "" }
			if let i = dict["slackEndpointAfterAuth"] { SlackConfig.endpointAfterAuth = i as? String ?? "" }
			if let i = dict["slackRedirectAfterAuth"] { SlackConfig.redirectAfterAuth = i as? String ?? "" }

			if let i = dict["salesforceKey"] { SalesForceConfig.appid = i as? String ?? "" }
			if let i = dict["salesforceSecret"] { SalesForceConfig.secret = i as? String ?? "" }
			if let i = dict["salesforceEndpointAfterAuth"] { SalesForceConfig.endpointAfterAuth = i as? String ?? "" }
			if let i = dict["salesforceRedirectAfterAuth"] { SalesForceConfig.redirectAfterAuth = i as? String ?? "" }

		}
	} else {
		print("Unable to get Configuration")
	}

}
