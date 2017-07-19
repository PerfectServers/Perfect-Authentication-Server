//
//  ConfigModel.swift
//  PerfectLocalAuthPostgreSQLTemplate
//
//  Created by Jonathan Guthrie on 2017-06-14.
//

import StORM
import PostgresStORM

public class Config: PostgresStORM {
	public var name						= ""
	public var val						= ""

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
		name				= this.data["name"] as? String			?? ""
		val					= this.data["val"] as? String			?? ""
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



