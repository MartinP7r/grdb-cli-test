import ArgumentParser
import Foundation
import GRDB
import Path

struct Player: Encodable, PersistableRecord {
    var id: Int
    var team: Team
}

struct Team: Encodable {
    var id: Int
    var name: String
}

class AsyncStreamer {
    public let stream: AsyncStream<Player>
    private let continuation: AsyncStream<Player>.Continuation

    init() {
        let (stream, continuation) = AsyncStream.makeStream(of: Player.self)
        self.stream = stream
        self.continuation = continuation
    }

    func start() {
        for idx in 1...200_000 {
            let player = Player(id: idx, team: .init(id: idx, name: "Team \(idx)"))
            continuation.yield(player)
        }
    }
}

@main
struct GrdbCliTest: AsyncParsableCommand {
    mutating func run() async throws {
        try await start()
        print("end")
    }

    private static let streamer = AsyncStreamer()

    func start() async throws {
        let path = Path.applicationSupport / "database" / "grdb.sqlite"
        print("db path", path.string)
        let dbQueue = try DatabaseQueue(path: path.string)

        try await dbQueue.write { db in
            try db.create(table: "player") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("team", .text).notNull()
            }
        }
        Task {
            var players = [Player]()
            for await player in Self.streamer.stream {
                players.append(player)
                if players.count >= 20_000 {
                    print("saving")
                    let playersForSaving = players
                    players.removeAll()

                    // --- 
                    // This will break within the first couple of thousand saves
                    // comment out and the program finishes without issues
                    try await dbQueue.write { [playersForSaving] db in
                        for p in playersForSaving {
                            print("saved \(p.id)")
                            try p.save(db)
                        }
                    }
                    // ---
                }
            }
        }
        Self.streamer.start()
    }
}
