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
import Foundation
import PerfectCrypto
import PerfectCloudFormation

struct AppCredentials {
	var clientid = ""
	var clientsecret = ""
}

extension Config {

	fileprivate static func dictOrDefault(_ dict: [String : Any], dictName: String, def: String) -> String {
		return dict[dictName] as? String ?? def
	}
	fileprivate static func dictOrDefault(_ dict: [String : Any], dictName: String, def: Int) -> Int {
		return dict[dictName] as? Int ?? def
	}

	public static func load() {
		#if os(Linux)
			let fname = "./config/ApplicationConfigurationLinux.json"
		#else
			let fname = "./config/ApplicationConfiguration.json"
		#endif

		if let configData = JSONConfig(name: fname) {
			if let dict = configData.getValues() {

				// ====================================================================================
				// HTTP port
				// Not loaded from database
				// ====================================================================================
				httpPort = dict["httpport"] as? Int ?? httpPort


				// ====================================================================================
				// For ORM
				// Not loaded from database
				// ====================================================================================
				
				if let pgsql = CloudFormation.listRDSInstances(type: .postgres)
						.sorted(by: { $0.resourceName < $1.resourceName }).first {
					PostgresConnector.host = pgsql.hostName
					PostgresConnector.port = pgsql.hostPort
					PostgresConnector.username = pgsql.userName
					PostgresConnector.password = pgsql.password
				} else {
					PostgresConnector.host		= dictOrDefault(dict, dictName: "postgreshost", def: "localhost")
					PostgresConnector.username	= dictOrDefault(dict, dictName: "postgresuser", def: "perfect")
					PostgresConnector.password	= dictOrDefault(dict, dictName: "postgrespwd", def: "perfect")
					PostgresConnector.port		= dictOrDefault(dict, dictName: "postgresuser", def: 5432)
				}
				PostgresConnector.database	= dict["postgresdbname"] as? String ?? "authserver"


				// ====================================================================================
				// Make sure database exists - or create it
				// ====================================================================================
				let thisConfig = Config()
				let result = try? thisConfig.sql("SELECT 1 FROM pg_database WHERE datname = $1", params: [PostgresConnector.database])
				if result?.numFields() == nil {
					// Creating database
					print("Creating Database now: \(PostgresConnector.database)")
					let tempdb = PostgresConnector.database
					PostgresConnector.database = "postgres"
					do {
						let _ = try thisConfig.sql("CREATE DATABASE \(tempdb) OWNER \(PostgresConnector.username)", params: [])
					} catch {
						fatalError("\(error.localizedDescription)")
					}
					PostgresConnector.database = tempdb
				}


				// ====================================================================================
				// For Sessions
				// Not loaded from database
				// ====================================================================================
				PostgresSessionConnector.host = PostgresConnector.host
				PostgresSessionConnector.port = PostgresConnector.port
				PostgresSessionConnector.username = PostgresConnector.username
				PostgresSessionConnector.password = PostgresConnector.password
				PostgresSessionConnector.database = PostgresConnector.database
				PostgresSessionConnector.table = "sessions"


				
				// ====================================================================================
				// Make sure Config exists
				// ====================================================================================
				try? thisConfig.setup()




				// ====================================================================================
				// Database debug
				// ====================================================================================
				let _ = Config("databasedebug", dict["databasedebug"] as? String ?? "", {
					value in
					if value == "true" {
						StORMdebug = true
					} else {
						StORMdebug = false
					}
				})



				// ====================================================================================
				// SSL State
				// ====================================================================================
				let _ = Config("sslCertPath", dict["sslCertPath"] as? String ?? "", {
					value in
					sslCertPath = value
				})
				let _ = Config("sslKeyPath", dict["sslKeyPath"] as? String ?? "", {
					value in
					sslKeyPath = value
				})



				// ====================================================================================
				// Outbound email config
				// ====================================================================================
				let _ = Config("mailserver", dict["mailserver"] as? String ?? "", {
					value in
					SMTPConfig.mailserver = value
				})
				let _ = Config("mailuser", dict["mailuser"] as? String ?? "", {
					value in
					SMTPConfig.mailuser = value
				})

				let origValue = dict["mailpass"] as? String ?? ""
				var encrypted = ""
				let cipher = Cipher.aes_256_cbc
				let salt = "All good things come to those who wait..."

				// Encryption
				if !origValue.isEmpty {
					encrypted = origValue.encrypt(cipher, password: SMTPConfig.mailuser, salt: salt) ?? ""
				}
				let _ = Config("mailpass", encrypted, {
					value in
					if !value.isEmpty {
						// Decryption
						let decrypted = value.decrypt(cipher, password: SMTPConfig.mailuser, salt: salt) ?? ""
						SMTPConfig.mailpass = decrypted
					}
				})




				let _ = Config("mailfromaddress", dict["mailfromaddress"] as? String ?? "", {
					value in
					SMTPConfig.mailfromaddress = value
				})
				let _ = Config("mailfromname", dict["mailfromname"] as? String ?? "", {
					value in
					SMTPConfig.mailfromname = value
				})



				// ====================================================================================
				// URL's
				// ====================================================================================
				let _ = Config("baseDomain", dict["baseDomain"] as? String ?? "", {
					value in
					SessionConfig.cookieDomain = value
				})

				let _ = Config("baseURL", dict["baseURL"] as? String ?? "", {
					value in
					baseURL = value

					FacebookConfig.endpointAfterAuth = "\(value)/auth/response/facebook"
					FacebookConfig.redirectAfterAuth = "\(value)/oauth/convert"

					GoogleConfig.endpointAfterAuth = "\(value)/auth/response/google"
					GoogleConfig.redirectAfterAuth = "\(value)/oauth/convert"

					LinkedinConfig.endpointAfterAuth = "\(value)/auth/response/linkedin"
					LinkedinConfig.redirectAfterAuth = "\(value)/oauth/convert"
				})

				// ====================================================================================
				// OAuth2 Config
				// ====================================================================================
				// Facebook
				let _ = Config("facebookAppID", dict["facebookAppID"] as? String ?? "", {
					value in
					FacebookConfig.appid = value
				})
				let _ = Config("facebookSecret", dict["facebookSecret"] as? String ?? "", {
					value in
					FacebookConfig.secret = value
				})

				// Google
				let _ = Config("googleKey", dict["googleKey"] as? String ?? "", {
					value in
					GoogleConfig.appid = value
				})
				let _ = Config("googleSecret", dict["googleSecret"] as? String ?? "", {
					value in
					GoogleConfig.secret = value
				})

				// Linkedin
				let _ = Config("linkedinKey", dict["linkedinKey"] as? String ?? "", {
					value in
					LinkedinConfig.appid = value
				})
				let _ = Config("linkedinSecret", dict["linkedinSecret"] as? String ?? "", {
					value in
					LinkedinConfig.secret = value
				})


				// ====================================================================================
				// END
				// ====================================================================================
			}
		} else {
			print("Unable to get Configuration")
		}

	}
}
