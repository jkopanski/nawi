{- for Paths Parse{Field,Record} -}
{-# OPTIONS_GHC -Wno-orphans #-}
module Options
  ( file
  , dir
  , fileArgument
  , dirArgument
  , fileOption
  , dirOption
  ) where

-- optparse-applicative
import Options.Applicative qualified
  as OP

-- optparse-generic
import Options.Generic
  ( ParseField (..)
  , ParseFields (..)
  , ParseRecord (..)
  , getOnly
  )

-- path
import Path qualified

mapLeft :: (a -> c) -> Either a b -> Either c b
mapLeft f = \case
  Left a -> Left $ f a
  Right b -> Right b

file :: OP.ReadM (Path.SomeBase Path.File)
file = OP.eitherReader $ mapLeft displayException . Path.parseSomeFile

dir :: OP.ReadM (Path.SomeBase Path.Dir)
dir = OP.eitherReader $ mapLeft displayException . Path.parseSomeDir

fileArgument
  :: OP.Mod OP.ArgumentFields (Path.SomeBase Path.File)
  -> OP.Parser (Path.SomeBase Path.File)
fileArgument = OP.argument file

dirArgument
  :: OP.Mod OP.ArgumentFields (Path.SomeBase Path.Dir)
  -> OP.Parser (Path.SomeBase Path.Dir)
dirArgument = OP.argument dir

fileOption
  :: OP.Mod OP.OptionFields (Path.SomeBase Path.File)
  -> OP.Parser (Path.SomeBase Path.File)
fileOption = OP.option file

dirOption
  :: OP.Mod OP.OptionFields (Path.SomeBase Path.Dir)
  -> OP.Parser (Path.SomeBase Path.Dir)
dirOption = OP.option dir

instance ParseField (Path.SomeBase Path.File) where
  readField :: OP.ReadM (Path.SomeBase Path.File)
  readField = file

  metavar _ = "FILE"

instance ParseField (Path.SomeBase Path.Dir) where
  readField :: OP.ReadM (Path.SomeBase Path.Dir)
  readField = dir

  metavar _ = "DIR"

instance ParseFields (Path.SomeBase Path.File) where
  parseFields = parseField
instance ParseRecord (Path.SomeBase Path.File) where
  parseRecord = fmap getOnly parseRecord

instance ParseFields (Path.SomeBase Path.Dir) where
  parseFields = parseField
instance ParseRecord (Path.SomeBase Path.Dir) where
  parseRecord = fmap getOnly parseRecord
