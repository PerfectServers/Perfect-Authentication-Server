//
//  ApplicationExtension.swift
//  PerfectLib
//
//  Created by Jonathan Guthrie on 2017-08-04.
//

import PerfectLocalAuthentication
import StORM

extension Application {
	public static func list() -> [[String: Any]] {
		var list = [[String: Any]]()
		let t = Application()
		let cursor = StORMCursor(limit: 9999999,offset: 0)
		try? t.select(
			columns: [],
			whereclause: "true",
			params: [],
			orderby: ["name"],
			cursor: cursor
		)


		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["name"] = row.name
			r["clientid"] = row.clientid
			list.append(r)
		}
		return list

	}
}

