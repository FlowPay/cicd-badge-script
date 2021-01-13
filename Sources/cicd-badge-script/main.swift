
import Foundation
import AsyncHTTPClient

var file = try! String(contentsOfFile: "./meta.data", encoding: .utf8)
let numberOfLines = Double(try! String(contentsOfFile: "./data.meta", encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines))!

var rows = file.split(separator: "\n")

let info = String(rows.popLast()!)

var tokens = info.split(separator: " ")


var total: Double = 0.0

var errors: Double = 0.0

var flag = false
var previous = ""
tokens.map { String($0) }.forEach { token in 
    if flag {
        total = Double(token)!   
        flag = false
    }
    if token == "Found" {
        flag = true
    }
    if token == "serious" {
        errors = Double(previous)!
    }
    previous = token
}

print(total)
print(errors)
print(numberOfLines)
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
print(color)

let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
let request = try! HTTPClient.Request(url: "https://img.shields.io/badge/linting-\(stringScore)-\(color)?logo=swift&style=for-the-badge", method: .GET)
let loop = httpClient.execute(request: request)
    .map { response in 
        let body = response.body!
        FileManager().createFile(atPath: "./linting_badge.svg", contents: body.getData(at: 0, length: body.readableBytes))
        return
    }

file = try! String(contentsOfFile: "./codecov.summary", encoding: .utf8)
var summary = file.split(separator:"\n")
let functions = summary.popLast()!
let lines = summary.popLast()!

print(lines)
print(functions)

print(lines.index(after: lines.firstIndex(of: ":")!))
print(lines.firstIndex(of: "%")!)

let linesPecentage = Double(String(lines[lines.index(after: lines.firstIndex(of: ":")!)..<lines.firstIndex(of: "%")!]).trimmingCharacters(in: .whitespacesAndNewlines))!

let functionPercentage = Double(String(functions[functions.index(after: functions.firstIndex(of: ":")!)..<functions.firstIndex(of: "%")!]).trimmingCharacters(in: .whitespacesAndNewlines))!

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

let lineRequest = try! HTTPClient.Request(url: "https://img.shields.io/badge/lines%20cov-\(linesPecentage)%25-\(linesColor)?logo=codersRank&style=for-the-badge", method: .GET)
let linesLoop = httpClient.execute(request: lineRequest)
    .map { response in 
        let body = response.body!
        FileManager().createFile(atPath: "./lines_cov_badge.svg", contents: body.getData(at: 0, length: body.readableBytes))
        return
    }

let functionColor: String
switch functionPercentage {
case _ where functionPercentage < 20:
    functionColor = "red"
case _ where functionPercentage < 40:
    functionColor = "orange"
case _ where functionPercentage < 60:
    functionColor = "yellow"
default:
    functionColor = "green"
}

let functionRequest = try! HTTPClient.Request(url: "https://img.shields.io/badge/function%20cov-\(functionColor)%25-\(functionPercentage)?logo=codersRank&style=for-the-badge", method: .GET)
let functionLoop = httpClient.execute(request: lineRequest)
    .map { response in 
        let body = response.body!
        FileManager().createFile(atPath: "./function_cov_badge.svg", contents: body.getData(at: 0, length: body.readableBytes))
        return
    }

try! loop.wait()
try! linesLoop.wait()
try! functionLoop.wait()

try! httpClient.syncShutdown()
