import cyclichash, os, times

type
  H = int
  C = char

proc hashALot(n: int, L: int, ttimes: Natural, sizeOfTest: Natural, recorder: var seq[Natural]) =
  for t in 0 ..< ttimes:
    var hf = newCyclicHash[H, C](n, L)
    for k in 0 ..< n:
      hf.eat(char(k))
    for k in n ..< sizeOfTest:
      hf.update(char((k-n) mod 256), char(k mod 256))
    recorder[t] = hf.hashValue

proc synthetic =
  let L = 19
  var recorder = newSeq[Natural](1)
  let sizeOfTest = 100_000_000
  var startTime, endTime: float
  
  echo("Time in seconds to compute ", sizeOfTest, " hashes of size ", L)
  for n in 1 .. 13:
    startTime = cpuTime()
    hashALot(n, L+n, 1, sizeOfTest, recorder)
    endTime = cpuTime()
    echo(endTime - startTime)

when isMainModule:
  synthetic()
