
import Foundation
import AsyncHTTPClient
import NIO

let loop: EventLoopFuture<Void>
let linesLoop: EventLoopFuture<Void>
let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

class UnwrapError: Error { }

do {
    let file = try String(contentsOfFile: "./meta.data", encoding: .utf8)
    guard let numberOfLines = Double(try String(contentsOfFile: "./data.meta", encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)) else { throw UnwrapError() }

    var rows = file.split(separator: "\n")

    guard let infoString = rows.popLast() else { throw UnwrapError()}
    let info = String(infoString)

    let tokens = info.split(separator: " ")


    var total: Double = 0.0

    var errors: Double = 0.0

    var flag = false
    var previous = ""
    try tokens.map { String($0) }.forEach { token in 
        if flag {
            guard let tmp = Double(token) else { throw UnwrapError() }
            total = tmp
            flag = false
        }
        if token == "Found" {
            flag = true
        }
        if token == "serious" {
            guard let tmp = Double(previous) else { throw UnwrapError() }
            errors = tmp
        }
        previous = token
    }

    let score = 10.0 - ((5*errors + (total - errors)) / numberOfLines) * 10
    let stringScore = String(format: "%.2f", score)

    let color: String
    switch score {
    case  _ where score < 2:
        color = "red"
    case _ where score < 4:
        color = "orange"
    case _ where score < 6:
        color = "yellow"
    default:
        color = "green"
    }
    print("Linting Score: \(score) out of 10")

    let request = try HTTPClient.Request(url: "https://img.shields.io/badge/linting-\(stringScore)-\(color)?logo=swift&style=for-the-badge", method: .GET)
    loop = httpClient.execute(request: request)
        .map { response in 
            let body = response.body!
            FileManager().createFile(atPath: "./linting_badge.svg", contents: body.getData(at: 0, length: body.readableBytes))
            return
        }
} catch {
    print("Error parsing linting data")
    let request = try! HTTPClient.Request(url: "https://img.shields.io/badge/linting-no%20data-red?logo=swift&style=for-the-badge", method: .GET)
    loop = httpClient.execute(request: request)
        .map { response in 
            let body = response.body!
            FileManager().createFile(atPath: "./linting_badge.svg", contents: body.getData(at: 0, length: body.readableBytes))
            return
        }
}
do {
    let file = try String(contentsOfFile: "./codecov.summary", encoding: .utf8)
    var summary = file.split(separator:"\n")
    let _ = summary.popLast()
    guard let lines = summary.popLast() else { throw UnwrapError() }

    guard let beforeIndex = lines.firstIndex(of: ":"),
          let lastIndex = lines.firstIndex(of: "%")
     else { throw UnwrapError() }

    let firstIndex = lines.index(after: beforeIndex)
    let linesString = String(lines[firstIndex..<lastIndex])
    guard let linesPecentage = Double(linesString.trimmingCharacters(in: .whitespacesAndNewlines)) else { throw UnwrapError() }


    let linesColor: String
    switch linesPecentage {
    case _ where linesPecentage < 20:
        linesColor = "red"
    case _ where linesPecentage < 40:
        linesColor = "orange"
    case _ where linesPecentage < 60:
        linesColor = "yellow"
    default:
        linesColor = "green"
    }

    print("Coverage of \(linesPecentage)%")

    let lineRequest = try HTTPClient.Request(url: "https://img.shields.io/badge/coverage-\(linesPecentage)%25-\(linesColor)?logo=El%20Jueves&style=for-the-badge", method: .GET)
    linesLoop = httpClient.execute(request: lineRequest)
        .map { response in 
            let body = response.body!
            FileManager().createFile(atPath: "./lines_cov_badge.svg", contents: body.getData(at: 0, length: body.readableBytes))
            return
        }
} catch {
    print("Error parsing coverage data")
    let lineRequest = try! HTTPClient.Request(url: "https://img.shields.io/badge/coverage-no%20data-red?logo=El%20Jueves&style=for-the-badge", method: .GET)
    linesLoop = httpClient.execute(request: lineRequest)
        .map { response in 
            let body = response.body!
            FileManager().createFile(atPath: "./lines_cov_badge.svg", contents: body.getData(at: 0, length: body.readableBytes))
            return
        }
}

try! loop.wait()
print("Wrote linting svg")
try! linesLoop.wait()
print("Wrote coverage svg")

try! httpClient.syncShutdown()
