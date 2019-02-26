import cyclichash, times, os

proc hashALot(n: int, L: int, ttimes: Natural, sizeOfTest: Natural, recorder: var seq[Natural]): float =
  let tic = cpuTime()
  for times in 0 ..< ttimes:
    var hf = newCyclicHash[Natural, char](n, L)
    for k in 0 ..< n:
      hf.eat(chr(k))
    for k in n ..< sizeOfTest:
      hf.update(chr(k-n), chr(k))
    recorder[times] = hf.hashValue
  result = (cpuTime() - tic)/ttimes.float

proc synthetic =
  let L = 19
  var recorder = newSeq[Natural]()
  let sizeOfTest = 100_000_000
  for n in 1 .. 13:
    echo hashALot(n, L+n, 1, sizeOfTest, recorder)
  echo "#L = ", L, " char-length = ", sizeOfTest

synthetic()
