module Main where

import Prelude hiding (on)

-- optparse-generic
import Options.Generic
  ( ParseRecord
  , Unwrapped
  , Wrapped
  , type (:::)
  , type (<?>)
  )
import Options.Generic qualified as Opt

-- haskell-gi
import Data.GI.Base

-- gi-gtk
import GI.Gtk qualified as Gtk

data Options w = Options
  { debug :: w ::: Bool <?> "Start in GTK interactive debugging"
  }
  deriving stock (Generic)

instance ParseRecord (Options Wrapped)
deriving instance Show (Options Unwrapped)

-- | An example of a signal callback accessing the ?self parameter
-- (that is, the object raising the callback). See
-- https://github.com/haskell-gi/haskell-gi/issues/346
-- for why this is necessary when dealing with even controllers in gtk4.
pressedCB :: (?self :: Gtk.GestureClick) => Int32 -> Double -> Double -> IO ()
pressedCB nPress x y = do
  button <- #getCurrentButton ?self
  putStrLn $
    "Button pressed: "
      <> show nPress
      <> " "
      <> show x
      <> " "
      <> show y
      <> " button: "
      <> show button

activate :: Bool -> Gtk.Application -> IO ()
activate debug app = do
  box <- new Gtk.Box [#orientation := Gtk.OrientationVertical]

  adjustment <-
    new
      Gtk.Adjustment
      [ #value := 50
      , #lower := 0
      , #upper := 100
      , #stepIncrement := 1
      ]
  slider <- new Gtk.Scale [#adjustment := adjustment, #drawValue := True]
  #append box slider
  spinButton <- new Gtk.SpinButton [#adjustment := adjustment]
  #append box spinButton

  controller <- new Gtk.GestureClick [After #pressed pressedCB]
  #addController slider controller

  window <-
    new
      Gtk.ApplicationWindow
      [ #application := app
      , #title := "Hello"
      , #child := box
      ]
  #show window

  Gtk.windowSetInteractiveDebugging debug

main :: IO ()
main = do
  (opts, _help) <-
    Opt.unwrapWithHelp "MadNat widgets"

  app <-
    new
      Gtk.Application
      [ #applicationId := "haskell-gi.Gtk4.test"
      , On #activate (activate (debug opts) ?self)
      ]

  void $ #run app Nothing
