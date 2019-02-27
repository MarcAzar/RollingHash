import cyclichash, sequtils

var hf = newCyclicHash[Natural, char](5, 19)
let input = "ABCDE"

hf.eat(input[0])
hf.eat(input[1])
hf.eat(input[2])
hf.eat(input[3])
echo "Hash value of ABCD is ", hf.hashValue

let charSeqFull = toSeq(input.items)
let charSeqPart = charSeqFull[0 ..< 4]

var trueAnswer = hf.hash(charSeqPart)
assert trueAnswer == hf.hashValue

hf.eat(input[4])
echo "Hash value of ABCDE is ", hf.hashValue

trueAnswer = hf.hash(charSeqFull)
assert trueAnswer == hf.hashValue
