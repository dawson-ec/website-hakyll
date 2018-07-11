# Tools

Extra bits and bobs that are useful but not required:

## write_highlight_css.hs

A Haskell script to write out all known Pandoc syntax highlighting
themes to their own css file. Run it with:

    stack exec runhaskell write_highlight_css.hs

and it will write new css files in the current directory.
