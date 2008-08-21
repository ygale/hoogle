
module Hackage where

import Util


processHackage exclude = do
    depends "temp/hackage/hackage.tar" [] $ do
        createDirectoryIfMissing True "temp/hackage"
        system_ "wget http://hackage.haskell.org/packages/archive/00-index.tar.gz -O temp/hackage/hackage.tar.gz"
        system_ $ "gunzip --force temp/hackage/hackage.tar.gz"
        system_ $ "tar -xf temp/hackage/hackage.tar -C temp/hackage"

    xs <- mapM package . filter (`notElem` exclude) =<< lsDirectories "temp/hackage"
    writeFile "temp/hackage/hoogle.txt" $ unlines $ hackagePrefix ++ concat xs
    copyFile "temp/hackage/hoogle.txt" "result/hackage.txt"


package name = do
    vers <- lsDirectories $ "temp/hackage/" ++ name
    let ver = showVersion $ maximum $ map readVersion vers
    cabal <- readCabal' $ "temp/hackage/" ++ name ++ "/" ++ ver ++ "/" ++ name ++ ".cabal"
    
    return $ [""] ++
             doc (cabalField True "synopsis" cabal ++ [""] ++ cabalField True "description" cabal) ++
             ["@package " ++ name, "@version " ++ ver
             ,"@hackage http://hackage.haskell.org/cgi-bin/hackage-scripts/package/" ++ name]


doc = map rtrim . zipWith (++) ("-- | " : repeat "--   ") . lines . haddock . unlines


hackagePrefix =
    ["-- Hoogle documentation, generated by Hoogle"
    ,"-- From http://hackage.haskell.org/"
    ,"-- See Hoogle, http://www.haskell.org/hoogle/"
    ]


-- Fix up some of the haddock documentation bits
-- Currently not done, do we want to try getting Haddock to do this?
-- Is there some code in Haddock that can be libraried off, or stolen?
haddock :: String -> String
haddock x = x
