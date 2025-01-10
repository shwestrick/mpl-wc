structure SimpleWC:
sig
  val wc: {filename: string} -> {num_lines: int, num_words: int, num_bytes: int}
end =
struct

  val grain = CommandLineArgs.parseInt "grain" 10000

  val newline = Word8.fromInt (Char.ord #"\n")
  val space = Word8.fromInt (Char.ord #" ")
  val tab = Word8.fromInt (Char.ord #"\t")
  fun is_newline byte = byte = newline
  fun is_space byte =
    byte = newline orelse byte = space orelse byte = tab

  fun wc {filename} =
    let
      val bytes = ReadFile.contentsBinSeq filename

      val (nl, nw) =
        SeqBasis.reduce grain
          (fn ((nl1, nw1), (nl2, nw2)) => (nl1 + nl2, nw1 + nw2)) (0, 0)
          (0, Seq.length bytes)
          (fn i =>
             let
               val b = Seq.nth bytes i
             in
               ( if is_newline b then 1 else 0
               , if
                   not (is_space b)
                   andalso (i = 0 orelse is_space (Seq.nth bytes (i - 1)))
                 then 1
                 else 0
               )
             end)
    in
      {num_lines = nl, num_words = nw, num_bytes = Seq.length bytes}
    end

end
