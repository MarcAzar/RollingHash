import cyclichash, rabinkarphash, sequtils, random

template extendAndPrepend(hashFunction: untyped, L: int = 19): untyped =
  var pass: bool = true
  let n = 4
  var hf = hashFunction(n, L)
  let input = toSeq("XABCDY".items)
  let base = input[1 ..^ 2]
  pass = pass and base.len == n
  let extend = input[1 ..< input.len]
  let prepend = input[0 ..^ 2]
  for i in 0 ..< base.len:
    hf.eat(base[i])
  pass = pass and hf.hashValue == hf.trueHash(base)
  pass = pass and hf.hashPrepend(input[0]) == hf.trueHash(prepend)
  pass = pass and hf.hashExtend(input[input.len - 1]) == hf.trueHash(extend)
  pass

template aFunc(hashFunction: untyped, L: int = 7): untyped =
  let n = 3
  var pass: bool = true
  var hf = hashFunction(n, L)
  var s = newSeq[char]()
  var c: char
  for i in 0 ..< n:
    c = chr(rand(5) + 65)
    s.add(c)
    hf.eat(c)
  var o: char
  for i in 0 ..< 100_000:
    o = s[0]
    s.delete(0)
    c = chr(rand(5) + 65)
    s.add(c)
    hf.update(o, c)
    pass = pass and hf.trueHash(s) == hf.hashValue
  pass

template reverseUpdate(hashFunction: untyped, L: int = 7): untyped =
  let n = 3
  var pass: bool = true
  var hf = hashFunction(n, L)
  var s = newSeq[char]()
  var c: char
  for i in 0 ..< n:
    c = chr(rand(5) + 65)
    s.add(c)
    hf.eat(c)
  var o: char
  for i in 0 ..< 100_000:
    o = s[0]
    s.delete(0)
    c = chr(rand(5) + 65)
    s.add(c)
    hf.update(o, c)
    hf.reverseUpdate(o, c)
    hf.update(o, c)
    pass = pass and hf.trueHash(s) == hf.hashValue
  pass

template isRandom(hashFunction: untyped, L: int = 19): untyped  =
  let n = 5
  var pass: bool = true
  var data = newSeq[char]()
  for i in 0 ..< n:
    data.add(chr(i))
  var base = hashFunction(n, L)
  var x = base.trueHash(data)
  for i in 0 ..< 100:
    var hf = hashFunction(n, L)
    var y = hf.trueHash(data)
    pass = pass and y != x
  pass

when isMainModule:

  var ok: bool = true
  echo "Strating Cyclic Hash tests..."
  for L in 2..32:
    ok = ok and extendAndPrepend(newCyclicHash[uint32, char], L)
    ok = ok and afunc(newCyclicHash[uint32, char], L)
    ok = ok and reverseUpdate(newCyclicHash[uint32, char], L)
  if not ok:
    echo "Failed test group 32 bit Hash"
  else:
    echo "Passed test group 32 bit Hash"

  ok = true
  for L in 2..64:
    ok = ok and extendAndPrepend(newCyclicHash[uint64, char], L)
    ok = ok and afunc(newCyclicHash[uint64, char], L)
  if not ok:
    echo "Failed test group 64 bit Hash"
  else:
    echo "Passed test group 64 bit Hash"

  ok = true
  ok = ok and isRandom(newCyclicHash[uint64, char])
  ok = ok and isRandom(newCyclicHash[uint32, char])
  if not ok:
    echo "Failed test is Random"
  else:
    echo "Passed test is Random"

  echo "Starting Rabin Karp tests..."
  ok = true
  for L in 1..32:
    ok = ok and afunc(newRabinKarpHash[uint32, char])
  if not ok:
    echo "Failed is Function 32 bit Hash"
  else:
    echo "Passed is Function 32 bit Hash"
 
  ok = true
  for L in 1..64:
    ok = ok and afunc(newRabinKarpHash[uint64, char])
  if not ok:
    echo "Failed is Function 64 bit Hash"
  else:
    echo "Passed is Function 64 bit Hash"

  ok = true
  ok = ok and isRandom(newRabinKarpHash[uint32, char])
  ok = ok and isRandom(newRabinKarpHash[uint64, char])
  if not ok:
    echo "Failed is Random"
  else:
    echo "Passed is Random"
