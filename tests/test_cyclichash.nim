import cyclichash, sequtils, random

type
  H = int64
  C = char

proc extendAndPrepend =
  let n = 4
  let L = 19
  var hf = newCyclicHash[H, C](n, L)
  let input = toSeq("XABCDY".items)
  let base = input[1 ..^ 2]
  doAssert base.len == n
  let extend = input[1 ..< input.len]
  let prepend = input[0 ..^ 2]
  for i in 0 ..< base.len:
    hf.eat(base[i])
  doAssert hf.hashValue == hf.trueHash(base)
  doAssert hf.hashPrepend(input[0]) == hf.trueHash(prepend)
  doAssert hf.hashExtend(input[input.len - 1]) == hf.trueHash(extend)

proc aFunc =
  let L = 7
  let n = 3
  var hf = newCyclicHash[H, C](n, L)
  
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

    doAssert hf.trueHash(s) == hf.hashValue

proc reverseUpdate =
  let L = 7
  let n = 3
  var hf = newCyclicHash[H, C](n, L)
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

    doAssert hf.trueHash(s) == hf.hashValue

proc isRandom =
  let n = 5
  let L = 19
  var data = newSeq[char]()
  for i in 0 ..< n:
    data.add(chr(i))

  var base = newCyclicHash[H, C](n, L)
  var x = base.trueHash(data)
  for i in 0 ..< 100:
    var hf = newCyclicHash[H, C](n, L)
    var y = hf.trueHash(data)
    
    doAssert y != x

when isMainModule:
  try:
    extendAndPrepend()
    echo "Passed extend and prepend test"
  except:
    echo "Failed extend and prepend test"
  
  try:
    afunc()
    echo "Passed is a function test"
  except:
    echo "Failed is a function test"

  try:
    reverseUpdate()
    echo "Passed reverse update test"
  except:
    echo "Failed reverse update test"

  try:
    isRandom()
    echo "Passed randomized test"
  except:
    echo "Failed randomized test"
