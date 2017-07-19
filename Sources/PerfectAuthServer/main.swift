//
//  main.swift
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

// Configuration of Session
SessionConfig.name = "perfectSession" // <-- change
SessionConfig.idle = 86400
SessionConfig.cookieDomain = "localhost" //<-- change
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = true
SessionConfig.CORS.enabled = true
SessionConfig.cookieSameSite = .lax

RequestLogFile.location = "./log.log"

let opts = initializeSchema(fname) // <-- loads base config like db and email configuration
httpPort = opts["httpPort"] as? Int ?? httpPort
baseURL = opts["baseURL"] as? String ?? baseURL

config() // for custom options
let sessionDriver = SessionPostgresDriver()
Utility.initializeObjects() // local setups

// Run local setup routines
Config.runSetup()

// Defaults
var configTitle = Config.getVal("title","Perfect Auth Server")
var configLogo = Config.getVal("logo","/images/perfect-logo-2-0.png")
var configLogoSrcSet = Config.getVal("logosrcset","/images/perfect-logo-2-0.png 1x, /images/perfect-logo-2-0.svg 2x")


// Configure Server
var confData: [String:[[String:Any]]] = [
	"servers": [
		[
			"name":"localhost",
			"port":httpPort,
			"routes":[],
			"filters":[]
		]
	]
]

// Load Filters
confData["servers"]?[0]["filters"] = filters()

// Load Routes
confData["servers"]?[0]["routes"] = mainRoutes()

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	 // fatal error launching one of the servers
	fatalError("\(error)")
}

