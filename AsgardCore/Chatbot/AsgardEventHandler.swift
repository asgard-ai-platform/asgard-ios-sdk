//
//  AsgardEventHandler.swift
//  AsgardCore
//
//  Created by INK on 2025/5/21.
//

internal import LDSwiftEventSource

class AsgardEventHandler: EventHandler {
    var onOpenedHandler: (() -> Void)?
    var onClosedHandler: (() -> Void)?
    var onMessageHandler: ((_ event: String, _ message: MessageEvent) -> Void)?
    var onErrorHandler: ((_ error: Error) -> Void)?

    func onOpened() {
        onOpenedHandler?()
    }

    func onClosed() {
        onClosedHandler?()
    }

    func onMessage(eventType: String, messageEvent: MessageEvent) {
        onMessageHandler?(eventType, messageEvent)
    }

    func onComment(comment: String) {
    }

    func onError(error: Error) {
        onErrorHandler?(error)
    }
}
