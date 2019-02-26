# Copyright (C) Marc Azar, All rights reserved.
# MIT License. Look at LICENSE.txt for more info
#
## Character Hashing based on given value type and input type. Uses Nim's
## `random` Module to generate initial randomized hash value, and has an option
## to be given seeds. For more info regarding the `random` please refer to 
## xoroshiro128+(xor/rotate/shift/rotate) library_
##
## .. _library:http://xoroshiro.di.unimi.it/
##
import random

type
  CharacterHash*[HashType = Natural, CharType = char] = object
    hashValues*: seq[HashType]

proc maskFnc*[HashType](bits: int): HashType {.inline.} =
  doAssert bits > 0
  doAssert bits <= HashType.sizeof * 8
  let x = cast[HashType](1) shl (bits - 1)
  result = x xor (x - 1)

proc hasher*[HashType, CharType](maxVal: HashType) : CharacterHash[HashType, CharType] {.raises: [IOError], inline.} =
  let numberOfChars = 1 shl (CharType.sizeof * 8)
  result.hashValues = newSeq[HashType](numberOfChars)

  if  HashType.sizeof <= 4:
    for k in 0 ..< numberOfChars:
      result.hashValues[k] = cast[HashType](rand(maxVal))

  elif HashType.sizeof == 8:
    let mx = maxVal shr 32
    var mx2: HashType = 0
    if mx == 0:
      mx2 = maxVal
    else:
      mx2 = high(int)
    
    for k in 0 ..< numberOfChars:
      result.hashValues[k] = cast[HashType](rand(mx2)) or (cast[HashType](rand(mx)) shl 32)
  
  else:
    raise newException(IOError, "unsupported hash value type")

proc hasher*[HashType, CharType](maxVal: int, seedOne, seedTwo: int): CharacterHash[HashType, CharType] {.raises: [IOError], inline.} =
  let numberOfChars = 1 shl (CharType.sizeof * 8)
  result.hashValues = newSeq[HashType](numberOfChars)
  
  if HashType.sizeof <= 4:
    for k in 0 ..< numberOfChars:
      result.hashValues[k] = cast[HashType](rand(maxVal))
    var r = initRand(seedOne)

  elif HashType.sizeof == 8:
    let mx = maxVal shr 32
    var mx2: HashType = 0
    if mx == 0:
      mx2 = maxVal
    else:
      mx2 = high(int)
    
    for k in 0 ..< numberOfChars:
      result.hashValues[k] = cast[HashType](rand(mx2)) or (cast[HashType](rand(mx)) shl 32)
    
    var rBase = initRand(seedOne)
    rBase = initRand(seedTwo)
    
  else:
    raise newException(IOError, "unsupported hash value tiype")