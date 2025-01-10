structure BufferedFold:
sig
  type byte = Word8.word

  (* Fold over a sequence of bytes, B[start, stop). The sequence B is implicitly
   * given by the function `get_bytes` which populates a buffer. Doing
   * `val count = get_bytes{offset, buffer}` should fill the buffer with the
   * data `B[offset, offset+count)` and return a count of the number of bytes
   * written. The caller has control over the maximum size of the buffer by
   * specifying `capacity`.
   *
   * The folding function is `func` and we initialize the fold with the
   * accumulator value `init`.
   *)
  val loop:
    { get_bytes: {offset: int, buffer: byte array} -> int
    , capacity: int
    , start: int
    , stop: int
    , init: 'a
    , func: 'a * byte -> 'a
    }
    -> 'a
end =
struct

  type byte = Word8.word

  fun loop {get_bytes, capacity, start, stop, init, func} =
    let
      val buffer = ForkJoin.alloc capacity

      (* working at file[offset+i]
       * when i gets to j, we either stop or refill the buffer and continue
       * return when i = stop
       *)
      fun loop offset acc i j =
        if i < j then
          loop offset (func (acc, Array.sub (buffer, i))) (i + 1) j
        else if offset + i >= stop then
          acc
        else
          let
            val offset' = offset + i
            val j' = get_bytes {offset = offset', buffer = buffer}
          in
            loop offset' acc 0 j'
          end
    in
      (* Pass i=j=0 to immediately populate the buffer before continuting *)
      loop start init 0 0
    end

end
