# Copyright (C) Marc Azar. All rights reserved.
# MIT License. Look at LICNESE.txt for more info
#
## A Nim implementation of Cyclic Polynomial Hash, aka BuzHash
##
## A Cyclic Polynomial hash is a type of Rolling hash which avoids
## multiplication by using circular shifts and xoring. For more information
## regarding Cyclic Polynomial hasing please refer to wiki's article on
## `Rolling Hash`_
##
## .. _Rolling Hash:https://en.wikipedia.org/wiki/Rolling_hash#Cyclic_polynomial
##
import characterhash

type
  CyclicHash*[HashType = Natural, CharType = char] = object
    hashValue*: HashType
    n: int
    wordSize: int
    hasher: CharacterHash[HashType, CharType]
    maskOne: HashType
    myR: int
    maskN: HashType

proc newCyclicHash*[HashType, CharType](myN: int, myWordSize: int) : CyclicHash[HashType, CharType] {.raises: [IOError], inline.} =
  ## Creates a new Cyclic Hash with a quasi-random[*]_ initial has value of
  ## size `myWordSize` in bits. 
  ## 
  ## Asserts that the bitsize of the required hash value is not smaller than
  ## the bitsize of `myWordSzie`
  ##
  ## .. [*] See Character Hash for more info
  if cmp(cast[uint](myWordSize), 8 * HashType.sizeof) > 0:
    raise newException(IOError,
                      "Can't create " & $myWordSize & " bit has values")
  result.hashValue = 0
  result.n = myN
  result.wordSize = myWordSize
  result.hasher = hasher[HashType, CharType](maskFnc[HashType](myWordSize))
  result.maskOne = maskFnc[HashType](myWordSize - 1)
  result.myR = myN mod myWordSize
  result.maskN = maskFnc[HashType](myWordSize - result.myR)

proc newCyclicHash*[HashType, CharType](myN: int, seedOne, seedTwo: int, myWordSize: int) : CyclicHash {.raises:[IOError], inline.} =
  ## Creates a new Cyclic Hash with a random[*]_ initial has value of size
  ## `myWordSize` in bits.
  ##
  ## Asserts that the bitsize of the required hash value is not smaller than
  ## the bitsize of `myWordSzie`
  ##
  ## .. [*] See Character Hash for more info
  if cmp(cast[uint](myWordSize), 8 * HashType.sizeof) > 0:
    raise newException(IOError,
                      "Can't create " & $myWordSize & " bit has values")
  result.hashValue = 0
  result.n = myN
  result.wordSize = myWordSize
  result.hasher = hasher[HashType, CharType](maskFnc(myWordSize), seedOne, seedTwo)
  result.maskOne = maskFnc(myWordSize - 1)
  result.myR = myN mod myWordSize
  result.maskN = maskFnc(myWordSize - result.myR)

template fastLeftShiftN[HashType, CharType](y: CyclicHash[HashType, CharType], x: var HashType) =
  x = ((x and y.maskN) shl y.myR) or (x shr (y.wordSize - y.myR))

template fastLeftShiftOne[HashType, CharType](y: CyclicHash[HashType, CharType], x: var HashType) =
  x = ((x and y.maskOne) shl 1) or (x shr (y.wordSize - 1))

template fastRightShiftOne[HashType, CharType](y: CyclicHash[HashType, CharType], x: var HashType) =
  x = (x shr 1) or ((x and 1) shl (y.wordSize - 1))

template getFastLeftShiftOne[HashType, CharType](y: CyclicHash[HashType, CharType], x: HashType): HashType =
  ((x and y.maskOne) shl 1) or (x shr (y.wordSize - 1))

template getFastRightShiftOne[HashType, CharType](y:CyclicHash[HashType, CharType], x: HashType) : HashType =
  (x shr 1) or ((x and 1) shl (y.wordSize - 1))

proc hash*[HashType, CharType](y: var CyclicHash[HashType, CharType], c: seq[char]): HashType {.inline.}=
  ## Hash complete sequence of char without the need to update. This is a
  ## helper proceedure to test whether the update proceedure below yeilds
  ## correct results in unit testing
  ##
  var answer: HashType = 0
  for k in 0 ..< c.len:
    y.fastLeftShiftOne(answer)
    answer = answer xor y.hasher.hashValues[ord(c[k])]
    result = answer
#[
proc hashZ*[HashType, CharType](y: var CyclicHash[HashType, CharType], outChar: CharType, n: int): HashType {.inline.}=
  var answer: HashType = y.hasher.hashValues[ord(outChar)]
  for k in 0 ..< n:
    y.fastLeftShiftOne(answer)
  result = answer
]#
proc update*[HashType, CharType](y: var CyclicHash[HashType, CharType], outChar: CharType, inChar: CharType) {.inline.}=
  ## Updates the rolling hash after shifting left and xoring hash value of
  ## `outChar` add `inChar`
  ##
  var z: HashType = y.hasher.hashValues[ord(outChar)]
  y.fastLeftShiftN(z)
  y.hashValue = y.getFastLeftShiftOne(y.hashValue) xor z xor y.hasher.hashValues[ord(inChar)]

proc reverseUpdate*[HashType, CharType](y: var CyclicHash[HashType, CharType], outChar: CharType, inChar: CharType) {.inline.}=
  # Cyclic Hash is reversible! We can undo a previous update by performing a
  # right shift. See `test_cyclichash` for an example.
  #
  var z: HashType = y.hasher.hashValues[ord(outChar)]
  y.fastLeftShiftN(z)
  y.hashValue = y.hashValue xor z xor y.hasher.hashValues[ord(inChar)]
  y.hashValue = y.getFastRightShiftOne(y.hashValue)

proc eat*[HashType, CharType](y: var CyclicHash[HashType, CharType], inChar: CharType) =
  ## Move rolling hash forward by shifting left and xoring the hash value of
  ## the new `inChar`
  ##
  y.fastLeftShiftOne(y.hashValue)
  y.hashValue = y.hashValue xor y.hasher.hashValues[ord(inChar)]

proc hashPrepend*[HashType, CharType](y: var CyclicHash[HashType, CharType], x: CharType): HashType {.inline.}=
  ## Prepends a rolling hash by adding a hashed `x` into the front of the
  ## rolling hash sequence
  ##
  var z: HashType = y.hasher.hashValues[ord(x)]
  y.fastLeftShiftN(z)
  result = z xor y.hashValue

proc hashExtend*[HashType, CharType](y: CyclicHash[HashType, CharType], x: CharType): HashType {.inline.}=
  ## Extends a rolling hash by adding a hashed `x` into the end of the rolling
  ## hash sequence
  ##
  result = y.getFastLeftShiftOne(y.hashValue) xor y.hasher.hashValues[ord(x)]

proc reset*(y: var CyclicHash) =
  ## Reset the hash values of rolling hash to `0`
  y.hashValue = 0
