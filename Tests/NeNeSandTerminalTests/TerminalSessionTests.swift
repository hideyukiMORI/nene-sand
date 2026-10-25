import Glibc
import Testing

@testable import NeNeSandTerminal

struct TerminalSessionTests {
  @Test
  func writeAllFinishesWhenThePipeAcceptsOnlyAPrefix() {
    var ends = [Int32](repeating: -1, count: 2)
    #expect(pipe(&ends) == 0)
    let readEnd = ends[0]
    let writeEnd = ends[1]
    let flags = fcntl(writeEnd, F_GETFL)
    _ = fcntl(writeEnd, F_SETFL, flags | O_NONBLOCK)
    let payload = Array(repeating: UInt8(ascii: "k"), count: 200_000)
    let child = fork()
    #expect(child >= 0)
    if child == 0 {
      close(writeEnd)
      var got = 0
      var buffer = [UInt8](repeating: 0, count: 1024)
      while got < payload.count {
        var waiting = pollfd(fd: readEnd, events: Int16(POLLIN), revents: 0)
        if poll(&waiting, 1, 2000) <= 0 {
          _exit(3)
        }
        let count = read(readEnd, &buffer, buffer.count)
        if count <= 0 {
          _exit(2)
        }
        got += count
      }
      _exit(0)
    }
    close(readEnd)
    TerminalSession.writeAll(payload, to: writeEnd)
    close(writeEnd)
    var status: Int32 = 0
    _ = waitpid(child, &status, 0)
    #expect(status == 0)
  }
}
