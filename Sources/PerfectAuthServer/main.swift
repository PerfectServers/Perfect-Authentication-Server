//
//  main.swift
//  Perfect Auth Server
//
//  Created by Jonathan Guthrie on 2017-07-27.
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
import PerfectHTTP
import PerfectHTTPServer
import PerfectRequestLogger
import PerfectSession
import PerfectSessionPostgreSQL
import PerfectCrypto
import LocalAuthentication

let _ = PerfectCrypto.isInitialized

#if os(Linux)
let fileRoot = "/perfect-deployed/apidocumentationserver/" // <-- change
var httpPort = 8100
let fname = "./config/ApplicationConfigurationLinux.json"
#else
let fileRoot = ""
var httpPort = 8181
let fname = "./config/ApplicationConfiguration.json"
#endif

var baseURL = ""
var sslCertPath = ""
var sslKeyPath = ""


// =======================================================================
// Configuration of Session
// =======================================================================
SessionConfig.name = "perfectSession" // <-- change
SessionConfig.idle = 86400
SessionConfig.cookieDomain = "localhost" //<-- change
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = true
SessionConfig.CORS.enabled = true
SessionConfig.cookieSameSite = .lax


// =======================================================================
// Logfile
// =======================================================================
RequestLogFile.location = "./log.log"



let opts = initializeSchema(fname) // <-- loads base config like db and email configuration
httpPort = opts["httpPort"] as? Int ?? httpPort
baseURL = opts["baseURL"] as? String ?? baseURL



// =======================================================================
// Load DB access
// We cn also now init the session driver
// =======================================================================
config()
let sessionDriver = SessionPostgresDriver()
Utility.initializeObjects()




// =======================================================================
// Run local setup routines
// =======================================================================
Config.runSetup()



// =======================================================================
// Defaults
// =======================================================================
var configTitle = Config.getVal("title","Perfect Auth Server")
var configLogo = Config.getVal("logo","/images/perfect-logo-2-0.png")
var configLogoSrcSet = Config.getVal("logosrcset","/images/perfect-logo-2-0.png 1x, /images/perfect-logo-2-0.svg 2x")





// =======================================================================
// Configure Server
// =======================================================================
var confData: [String:[[String:Any]]] = [
	"servers": [
		[
			"name":"mainServer",
			"port":httpPort,
			"routes":[],
			"filters":[]
		]
	]
]



// =======================================================================
// Load Filters
// =======================================================================
confData["servers"]?[0]["filters"] = filters()





// =======================================================================
// Load Routes
// =======================================================================
confData["servers"]?[0]["routes"] = mainRoutes()




// =======================================================================
// TLS Config
// =======================================================================
if !sslKeyPath.isEmpty, !sslCertPath.isEmpty {
	confData["servers"]?[0]["tlsConfig"] = [
		"certPath": sslCertPath,
		"verifyMode": "peer",
		"keyPath": sslKeyPath
		]

	// Redirect from Port 80 to 443
//	confData["servers"]?.append([
//		"name":"redirectServer",
//		"port":80,
//		"routes":[
//			["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
//			 "base":"\(baseURL)"]
//		]
//	])
}


// =======================================================================
// Server start
// =======================================================================
do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	 // fatal error launching one of the servers
	fatalError("\(error)")
}

