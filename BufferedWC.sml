structure BufferedWC:
sig
  val wc: {filename: string} -> {num_lines: int, num_words: int, num_bytes: int}
end =
struct

  val capacity = CommandLineArgs.parseInt "buffer-capacity" 1000
  val grain = CommandLineArgs.parseInt "grain" 10000

  val newline = Word8.fromInt (Char.ord #"\n")
  val space = Word8.fromInt (Char.ord #" ")
  val tab = Word8.fromInt (Char.ord #"\t")
  fun is_newline byte = byte = newline
  fun is_space byte =
    byte = newline orelse byte = space orelse byte = tab
  fun is_space' byte = byte = space orelse byte = tab


  (* little state machine for a loop through the bytes *)
  fun process_next_byte ((nl, nw, prev_byte_is_space), byte) =
    if is_newline byte then (nl + 1, nw, true)
    else if is_space' byte then (nl, nw, true)
    else (nl, if prev_byte_is_space then nw + 1 else nw, false)


  fun wc {filename} =
    let
      val file = MPL.File.openFile filename
      val num_bytes = MPL.File.size file
      fun get_byte i = MPL.File.readWord8 file i
      fun get_bytes {offset, buffer} =
        let
          val count = Int.max
            (0, Int.min (Array.length buffer, num_bytes - offset))
          val buffer = ArraySlice.slice (buffer, 0, SOME count)
        in
          MPL.File.readWord8s file offset buffer;
          count
        end

      (* Main parallel loop: one big reduce *)

      val (nl, nw) =
        SeqBasis.reduce 1
          (fn ((nl1, nw1), (nl2, nw2)) => (nl1 + nl2, nw1 + nw2)) (0, 0)
          (0, Util.ceilDiv num_bytes grain)
          (fn i =>
             let
               val lo = i * grain
               val hi = Int.min (lo + grain, num_bytes)

               val (nl, nw, _) = BufferedFold.loop
                 { get_bytes = get_bytes
                 , capacity = capacity
                 , start = lo
                 , stop = hi
                 , init = (0, 0, lo = 0 orelse is_space (get_byte (lo - 1)))
                 , func = process_next_byte
                 }
             in
               (nl, nw)
             end)

    in
      MPL.File.closeFile file;
      {num_lines = nl, num_words = nw, num_bytes = num_bytes}
    end

end
