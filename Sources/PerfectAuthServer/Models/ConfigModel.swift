//
//  ConfigModel.swift
//  PerfectLocalAuthPostgreSQLTemplate
//
//  Created by Jonathan Guthrie on 2017-06-14.
//

import PerfectLib
import StORM
import PostgresStORM
import PerfectCrypto

public class Config: PostgresStORM {
	public var name						= ""
	public var val						= ""

	public override init(){
		super.init()
	}

	public init(_ key: String) {
		super.init()
		try? get(key)
		// Note that we are setting the name
		// This is to increase code reuse
		name = key
	}

	public init(_ key: String, _ v: String, _ callback: (String)->() ) {
		super.init()
		try? get(key)
		if name.isEmpty {
			// Create
			name = key
			val = v
			try? create()
		}
		callback(val)
	}

	public static func getVal(_ key: String, _ def: String) -> String {
		let this = Config()
		do {
			try this.get(key)
		} catch {
			print(error)
		}
		if this.val.isEmpty {
			return def
		}
		return this.val
	}

	public static func runSetup() {
		do {
			let this = Config()
			try this.setup()
		} catch {
			print(error)
		}
	}

	override public func to(_ this: StORMRow) {
		name 	= StORMPatch.Extract.string(this.data, "name", "")!
		val		= StORMPatch.Extract.string(this.data, "val", "")!
	}

	public func rows() -> [Config] {
		var rows = [Config]()
		for i in 0..<self.results.rows.count {
			let row = Config()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

}



