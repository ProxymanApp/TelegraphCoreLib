//
//  HTTPMessage.swift
//  Telegraph
//
//  Created by Yvo van Beek on 1/30/17.
//  Copyright © 2017 Building42. All rights reserved.
//

import Foundation

open class HTTPMessage {
  public var version: HTTPVersion
  public var headers: HTTPHeaders
  public var body: Data

  internal var firstLine: String { return "" }
  internal var stripBody = false

  /// Creates a new HTTPMessage.
  public init(version: HTTPVersion = .default, headers: HTTPHeaders = HTTPHeaders.empty, body: Data = Data()) {
    self.version = version
    self.headers = headers
    self.body = body
  }

  /// Performs last minute changes to the message, just before writing it to the stream.
  open func prepareForWrite() {
    // Set the keep alive connection header
    if headers.connection == nil {
      headers.connection = keepAlive ? "keep-alive" : "close"
    }
  }
}

// MARK: Helper methods

public extension HTTPMessage {
  /// Returns a boolean indicating if the connection should be kept open.
  var keepAlive: Bool {
    guard let connection = headers.connection else { return version.minor != 0 }
    return connection.caseInsensitiveCompare("close") != .orderedSame
  }

  /// Returns a boolean indicating if this message carries an instruction to upgrade.
  var isConnectionUpgrade: Bool {
    return headers.connection?.caseInsensitiveCompare("upgrade") == .orderedSame
  }
}

// MARK: Proxyman

public extension HTTPMessage {

    func httpMessageData() -> Data {
        var head = Data()
        head.reserveCapacity(100)

        // Write the first line
        head.append(firstLine.utf8Data)
        head.append(.crlf)

        // Set content lent if it's absent
        // Otherwise the client doesn't know when the response is done
        if headers.contentLength == nil && !body.isEmpty {
            headers.contentLength = body.count
        }
        
        // Write the headers
        headers.orderHeaders.forEach { key, value in
            head.append("\(key): \(value)".utf8Data)
            head.append(.crlf)
        }

        // Signal the end of the headers with another crlf
        head.append(.crlf)

        // Start body
        head.append(body)
        return head
    }

    func httpMessageDataForBreakpoint() -> Data {
        var head = Data()

        // Write the first line
        head.append(firstLine.utf8Data)
        head.append(.crlf)

        // Remove the content-length because the user can edit the Body of the HTTP Message
        headers.contentLength = nil

        // Write the headers
        headers.orderHeaders.forEach { key, value in
            head.append("\(key): \(value)".utf8Data)
            head.append(.crlf)
        }

        // Signal the end of the headers with another crlf
        head.append(.crlf)

        // Start body
        head.append(body)
        return head
    }
}
