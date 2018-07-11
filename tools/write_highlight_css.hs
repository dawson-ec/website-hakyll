-- Write all known Pandoc syntax styles to CSS files
import Skylighting

styles = [ ("kate", kate)
         , ("breezeDark", breezeDark)
         , ("pygments", pygments)
         , ("espresso", espresso)
         , ("tango", tango)
         , ("haddock", haddock)
         , ("monochrome", monochrome)
         , ("zenburn", zenburn)
         ]

writeCss (name, style) = writeFile cssFileName $ styleToCss style
    where cssFileName = name ++ ".css"

main = do
     mapM writeCss styles
