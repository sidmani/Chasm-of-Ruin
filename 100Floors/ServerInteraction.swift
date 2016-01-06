//
//  ServerInteraction.swift
//  100Floors
//
//  Created by Sid Mani on 1/4/16.
//
//

    let socket = SocketIOClient(socketURL: "http://localhost:9092", options: [.Log(true), .ForcePolling(true)])
    func run() {
    socket.on("connect") {data, ack in
    print("socket connected")
    }
    
    socket.on("currentAmount") {data, ack in
    if let cur = data[0] as? Double {
    socket.emitWithAck("canUpdate", cur)(timeoutAfter: 0) {data in
    socket.emit("update", ["amount": cur + 2.50])
    }
    
    ack.with("Got your currentAmount", "dude")
    }
    }
    
    socket.connect()
    }
