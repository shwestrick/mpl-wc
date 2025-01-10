mpl-wc: *.sml *.mlb lib
	mpl -output mpl-wc -default-type int64 -default-type word64 main.mlb

lib:
	smlpkg sync