import NeNeSandCore
import NeNeSandSave
import Testing

struct ArchiveTests {
  @Test
  func textRoundTripsTheProgress() {
    expectSame(Archive.Sheet(progress: .beginning, fireKnown: false, stoneKnown: false))
    let resume = Progression.Resume(
      amount: 40, rate: 3, oil: true, wood: true, lava: false, faucet: true)
    guard case .ready(let progress) = Progression.resuming(resume) else {
      #expect(Bool(false))
      return
    }
    expectSame(Archive.Sheet(progress: progress, fireKnown: true, stoneKnown: true))
    #expect(progress.purse.amount == 40)
    #expect(progress.purse.rate() == 3)
    #expect(progress.owns(.oil))
    #expect(progress.owns(.wood))
    #expect(!progress.owns(.lava))
    #expect(progress.ownsFaucet())
    #expect(progress.worth(.water) == 6)
  }

  @Test
  func brokenTextIsRejected() {
    let valid = Archive.text(
      Archive.Sheet(progress: .beginning, fireKnown: false, stoneKnown: false))
    let samples = [
      "",
      "nene-sand 1\n",
      valid.replacing("nene-sand 1", with: "nene-sand 2"),
      valid.replacing("stone 0", with: "stone 2"),
      valid.replacing("rate 1", with: "rate 0"),
      valid.replacing("amount 0", with: "amount 00"),
      valid.replacing("amount 0", with: "amount -1"),
      valid.replacing("amount 0\nrate 1", with: "rate 1\namount 0"),
      valid.replacing("\n", with: "\r\n"),
      String(valid.dropLast()),
      valid + "extra 1\n",
    ]
    for sample in samples {
      #expect(Archive.reading(sample) == .rejected)
    }
  }

  @Test
  func resumeRejectsABadPurse() {
    let negative = Progression.Resume(
      amount: -1, rate: 1, oil: false, wood: false, lava: false, faucet: false)
    #expect(Progression.resuming(negative) == .rejected)
    let zero = Progression.Resume(
      amount: 0, rate: 0, oil: false, wood: false, lava: false, faucet: false)
    #expect(Progression.resuming(zero) == .rejected)
  }

  @Test
  func restoredMarksStayAfterClear() {
    var board = Board(width: 2, height: 2)
    board.restore(fire: true, stone: true)
    board.stamp(x: 0, y: 0, grain: .sand)
    board.clear()
    #expect(board.fireKnown)
    #expect(board.stoneKnown)
    #expect(board.grain(x: 0, y: 0) == .empty)
  }

  private func expectSame(_ sheet: Archive.Sheet) {
    switch Archive.reading(Archive.text(sheet)) {
    case .rejected:
      #expect(Bool(false))
    case .ready(let again):
      #expect(again == sheet)
    }
  }
}
