IncludeFile "ghk.pbi"

If Not globalHK::init()
  MessageRequester("globalHK","Failed to install event handler.")
  End
EndIf

OpenWindow(0,0,0,330,105,"globalHK",#PB_Window_SystemMenu|#PB_Window_ScreenCentered)
StickyWindow(0,#True)

; hotkey #1
TextGadget(#PB_Any,10,14,70,25,"Hotkey #1:")
hotkey1 = ShortcutGadget(#PB_Any,80,10,100,25,0)
CocoaMessage(0,GadgetID(hotkey1),"setAlignment:",#NSCenterTextAlignment)
CocoaMessage(0,GadgetID(hotkey1),"setBezelStyle:",1)
button1bind = ButtonGadget(#PB_Any,180,12,80,25,"bind")
button1unbind = ButtonGadget(#PB_Any,250,12,80,25,"unbind")
DisableGadget(button1unbind,#True)

; hotkey #2
TextGadget(#PB_Any,10,44,70,25,"Hotkey #2:")
hotkey2 = ShortcutGadget(#PB_Any,80,40,100,25,0)
CocoaMessage(0,GadgetID(hotkey2),"setAlignment:",#NSCenterTextAlignment)
CocoaMessage(0,GadgetID(hotkey2),"setBezelStyle:",1)
button2bind = ButtonGadget(#PB_Any,180,42,80,25,"bind")
button2unbind = ButtonGadget(#PB_Any,250,42,80,25,"unbind")
DisableGadget(button2unbind,#True)

; hotkey #3
TextGadget(#PB_Any,10,74,70,25,"Hotkey #3:")
hotkey3 = ShortcutGadget(#PB_Any,80,70,100,25,0)
CocoaMessage(0,GadgetID(hotkey3),"setAlignment:",#NSCenterTextAlignment)
CocoaMessage(0,GadgetID(hotkey3),"setBezelStyle:",1)
button3bind = ButtonGadget(#PB_Any,180,72,80,25,"bind")
button3unbind = ButtonGadget(#PB_Any,250,72,80,25,"unbind")
DisableGadget(button3unbind,#True)

Repeat
  ev = WaitWindowEvent()
  Select ev
    Case #PB_Event_Gadget
      Select EventGadget()
        Case button1bind
          If Not globalHK::add(GetGadgetText(hotkey1),#PB_Event_FirstCustomValue + 1)
            MessageRequester("globalHK","Failed to bind this hotkey.")
          Else
            DisableGadget(button1bind,#True)
            DisableGadget(hotkey1,#True)
            DisableGadget(button1unbind,#False)
            SetActiveGadget(button1unbind)
          EndIf
        Case button2bind
          If Not globalHK::add(GetGadgetText(hotkey2),#PB_Event_FirstCustomValue + 2)
            MessageRequester("globalHK","Failed to bind this hotkey.")
          Else
            DisableGadget(button2bind,#True)
            DisableGadget(hotkey2,#True)
            DisableGadget(button2unbind,#False)
            SetActiveGadget(button2unbind)
          EndIf
        Case button3bind
          If Not globalHK::add(GetGadgetText(hotkey3),#PB_Event_FirstCustomValue + 3)
            MessageRequester("globalHK","Failed to bind this hotkey.")
          Else
            DisableGadget(button3bind,#True)
            DisableGadget(hotkey3,#True)
            DisableGadget(button3unbind,#False)
            SetActiveGadget(button3unbind)
          EndIf
        Case button1unbind
          If Not globalHK::remove(GetGadgetText(hotkey1),#PB_Event_FirstCustomValue + 1)
            MessageRequester("globalHK","Failed to unbind this hotkey.")
          Else
            DisableGadget(button1bind,#False)
            DisableGadget(hotkey1,#False)
            DisableGadget(button1unbind,#True)
            SetActiveGadget(button1bind)
          EndIf
        Case button2unbind
          If Not globalHK::remove(GetGadgetText(hotkey2),#PB_Event_FirstCustomValue + 2)
            MessageRequester("globalHK","Failed to unbind this hotkey.")
          Else
            DisableGadget(button2bind,#False)
            DisableGadget(hotkey2,#False)
            DisableGadget(button2unbind,#True)
            SetActiveGadget(button2bind)
          EndIf
        Case button3unbind
          If Not globalHK::remove(GetGadgetText(hotkey3),#PB_Event_FirstCustomValue + 3)
            MessageRequester("globalHK","Failed to unbind this hotkey.")
          Else
            DisableGadget(button3bind,#False)
            DisableGadget(hotkey3,#False)
            DisableGadget(button3unbind,#True)
            SetActiveGadget(button3bind)
          EndIf
      EndSelect
    Case #PB_Event_FirstCustomValue + 1
      MessageRequester("globalHK","You pressed shortcut #1!")
    Case #PB_Event_FirstCustomValue + 2
      MessageRequester("globalHK","You pressed shortcut #2!")
    Case #PB_Event_FirstCustomValue + 3
      MessageRequester("globalHK","You pressed shortcut #3!")
  EndSelect
Until ev = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; EnableUnicode
; EnableXP