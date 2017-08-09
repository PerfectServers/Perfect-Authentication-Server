//
//  OAuth2Codes.swift
//  PerfectAuthServer
//
//  Created by Jonathan Guthrie on 2017-08-08.
//

import StORM
import PostgresStORM
import Foundation
import SwiftRandom
import SwiftMoment

public class OAuth2Codes: PostgresStORM {
	public var code				= ""
	public var expires			= 0
	public var clientid			= ""
	public var userid			= ""

	var _rand = URandom()

	public static func setup(_ str: String = "") {
		do {
			let obj = OAuth2Codes()
			try obj.setup(str)

			// Migrations
			//			let _ = try obj.sql("ALTER TABLE application ADD COLUMN redirecturls text", params: [])

		} catch {
			// nothing
		}
	}


	public override init(){}

	public init(userid u: String, clientid c: String, expiration: Int, scope s: [String] = [String]()) {
		super.init()
		code = _rand.secureToken
		clientid = c
		userid = u
		expires = Int(moment().epoch()) + (expiration * 1000)
		try? create()
	}

	public func isCurrent() -> Bool {
		if Int(moment().epoch()) > expires { return false }
		return true
	}

	override public func to(_ this: StORMRow) {
		code     		= this.data["code"] as? String		?? ""
		expires			= this.data["expires"] as? Int		?? 0
		userid			= this.data["userid"] as? String	?? ""
		clientid		= this.data["clientid"] as? String	?? ""
	}

	public func rows() -> [OAuth2Codes] {
		var rows = [OAuth2Codes]()
		for i in 0..<self.results.rows.count {
			let row = OAuth2Codes()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

}
