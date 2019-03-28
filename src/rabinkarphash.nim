# Copyright (C) Marc Azar. All rights reserved.
# MIT License. Look at LICNESE.txt for more info
#
## A high performance Nim implementation of Rabin Karp algorithm. Can be used
## for content defined variable chunking.
##
import characterhash

type
  RabinKarpHash*[H: Units, C: char] = object
    hashValue*: H
    n: int
    wordSize: int
    hasher: CharacterHash[H, C]
    hashMask: H
    primeToN: H
    prime: H

proc newRabinKarpHash*[H, C](myN: int, myWordSize: int) : RabinKarpHash[H, C] {.inline.} =
  ## Creates a new Rabin Karp with a quasi-random[*]_ initial has value of
  ## size `myWordSize` in bits. 
  ## 
  ## Asserts that the bitsize of the required hash value is not smaller than
  ## the bitsize of `myWordSzie`
  ##
  ## .. [*] See Character Hash for more info
  assert(cast[uint](myWordSize) <= 8 * H.sizeof,
    "Can't create " & $myWordSize & " bit hash values")
  result = RabinKarpHash[H, C](
    hashValue: 0,
    n: myN,
    wordSize: myWordSize,
    hasher: hash[H, C](maskFnc[H](myWordSize)),
    hashMask: maskFnc[H](myWordSize),
    primeToN: 1,
    prime: 37
  )
  for i in 0 ..< myN:
    result.primeToN = result.primeToN * result.prime
    result.primeToN = result.primeToN and result.hashMask

proc reset*[H, C](y: var RabinKarpHAsh[H, C]) {.inline.}=
  ## Reset the hash values of rolling hash to `0`
  y.hashValue = 0

proc eat*[H, C](y: var RabinKarpHash[H, C], inChar: char) {.inline.} =
  ##
  y.hashValue = (y.prime * y.hashValue +
    y.hasher.hashValues[cast[int](inChar)]) and y.hashMask

proc update*[H, C](y: var RabinKarpHash[H, C], outChar, inChar: char) {.inline.}=
  ##
  y.hashValue = (y.prime * y.hashValue +
    y.hasher.hashValues[cast[int](inChar)] - y.primeToN *
      y.hasher.hashValues[cast[int](outChar)]) and y.hashMask

proc trueHash*[H, C](y: RabinKarpHash[H, C], c: seq[char]): H {.inline.}=
  ## Hash complete sequence of char without the need to update. This is a
  ## helper proceedure to test whether the update proceedure below yeilds
  ## correct results in unit testing
  ##
  var answer: H = 0
  for k in 0 ..< c.len:
    var x: H = 1
    for i in 0 ..< (c.len - 1 - k):
      x = (x * y.prime) and y.hashMask
    x = (x * y.hasher.hashValues[cast[int](c[k])]) and y.hashMask
    answer = (answer + x) and y.hashMask
  result = answer
