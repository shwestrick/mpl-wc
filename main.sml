val filename = List.hd (CommandLineArgs.positional ())
               handle _ => Util.die "missing input filename"

val impl = CommandLineArgs.parseString "impl" "buffered"

val wc =
  case impl of
    "buffered" => BufferedWC.wc
  | "simple" => SimpleWC.wc
  | _ =>
      Util.die
        ("unknown -impl " ^ impl ^ "\nvalid options are: buffered simple")

val {num_lines, num_words, num_bytes} = wc {filename = filename}

val _ = print
  (Int.toString num_lines ^ " " ^ Int.toString num_words ^ " "
   ^ Int.toString num_bytes ^ " " ^ filename ^ "\n")
