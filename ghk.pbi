; pb-osx-globalhotkeys rev.4
; written by deseven
; based on Shardik code from
; http://forums.purebasic.com/english/viewtopic.php?p=402973#p402973
;
; https://github.com/deseven/pb-osx-globalhotkeys

DeclareModule globalHK
  Declare.b init()
  Declare.b add(hotkey.s,event.i,evWindow.i = #PB_Ignore,evObject.i = #PB_Ignore,evType.i = #PB_Ignore,evData.i = 0)
  Declare.b remove(hotkey.s,event.i = 0,removeAll.b = #False)
EndDeclareModule

Module globalHK
  
  ; imports
  ImportC ""
    GetApplicationEventTarget()
    RegisterEventHotKey(HotKeyCode.L,HotKeyModifiers.L,HotKeyID.Q,EventTargetRef.I,OptionBits.L,*EventHotKeyRef)
    UnregisterEventHotKey(EventHotKeyRef.I)
  EndImport
  
  ; constants & structures
  #kEventClassKeyboard = $6B657962     ; 'keyb'
  #kEventHotKeyPressed = 5
  #kEventParamDirectObject = $2D2D2D2D ; '----'
  #typeEventHotKeyID = $686B6964       ; 'hkid'
  #cmdKeyBit = 8
  #shiftKeyBit = 9
  #alphaLockBit = 10
  #optionKeyBit = 11
  #controlKeyBit = 12
  #rightShiftKeyBit = 13
  #rightOptionKeyBit = 14
  #rightControlKeyBit = 15
  #cmdKey = 1 << #cmdKeyBit
  #shiftKey = 1 << #shiftKeyBit
  #alphaLock = 1 << #alphaLockBit
  #optionKey = 1 << #optionKeyBit
  #controlKey = 1 << #controlKeyBit
  #rightShiftKey = 1 << #rightShiftKeyBit
  #rightOptionKey = 1 << #rightOptionKeyBit
  #rightControlKey = 1 << #rightControlKeyBit
  
  Structure EventTypeSpec
    EventClass.L
    EventKind.L
  EndStructure
  
  Structure EventHotKeyID
    Signature.L
    ID.L
  EndStructure
  
  Structure globalHotkey
    hotkey.s
    event.i
    evWindow.i
    evObject.i
    evType.i
    evData.i
    hotkeyID.EventHotKeyID
    hotkeyRef.i
  EndStructure
  
  ; keys mapping
  Global NewMap carbonKeys.i()
  carbonKeys("A") = $00
  carbonKeys("S") = $01
  carbonKeys("D") = $02
  carbonKeys("F") = $03
  carbonKeys("H") = $04
  carbonKeys("G") = $05
  carbonKeys("Z") = $06
  carbonKeys("X") = $07
  carbonKeys("C") = $08
  carbonKeys("V") = $09
  carbonKeys("B") = $0B
  carbonKeys("Q") = $0C
  carbonKeys("W") = $0D
  carbonKeys("E") = $0E
  carbonKeys("R") = $0F
  carbonKeys("Y") = $10
  carbonKeys("T") = $11
  carbonKeys("1") = $12 : carbonKeys("!") = $12
  carbonKeys("2") = $13 : carbonKeys("@") = $13
  carbonKeys("3") = $14 : carbonKeys("#") = $14
  carbonKeys("4") = $15 : carbonKeys("$") = $15
  carbonKeys("6") = $16 : carbonKeys("^") = $16
  carbonKeys("5") = $17 : carbonKeys("%") = $17
  carbonKeys("=") = $18 : carbonKeys("+") = $18
  carbonKeys("9") = $19 : carbonKeys("(") = $19
  carbonKeys("7") = $1A : carbonKeys("&") = $1A
  carbonKeys("-") = $1B : carbonKeys("_") = $1B
  carbonKeys("8") = $1C : carbonKeys("*") = $1C
  carbonKeys("0") = $1D : carbonKeys(")") = $1D
  carbonKeys("]") = $1E : carbonKeys("}") = $1E
  carbonKeys("O") = $1F : carbonKeys(")") = $1F
  carbonKeys("U") = $20
  carbonKeys("[") = $21 : carbonKeys("{") = $21
  carbonKeys("I") = $22
  carbonKeys("P") = $23
  carbonKeys("L") = $25
  carbonKeys("J") = $26
  carbonKeys("'") = $27 : carbonKeys(#DQUOTE$) = $27
  carbonKeys("K") = $28
  carbonKeys(";") = $29 : carbonKeys(":") = $29
  carbonKeys("\") = $2A : carbonKeys("|") = $2A
  carbonKeys(",") = $2B : carbonKeys("<") = $2B
  carbonKeys("/") = $2C : carbonKeys("?") = $2C
  carbonKeys("N") = $2D
  carbonKeys("M") = $2E
  carbonKeys(".") = $2F : carbonKeys(">") = $2F
  carbonKeys("`") = $32 : carbonKeys("~") = $32
  carbonKeys("Return") = $24
  carbonKeys("Tab") = $30
  carbonKeys("Space") = $31
  carbonKeys("Esc") = $35
  carbonKeys("CAPS") = $39
  carbonKeys("F1") = $7A
  carbonKeys("F2") = $78
  carbonKeys("F3") = $63
  carbonKeys("F4") = $76
  carbonKeys("F5") = $60
  carbonKeys("F6") = $61
  carbonKeys("F7") = $62
  carbonKeys("F8") = $64
  carbonKeys("F9") = $65
  carbonKeys("F10") = $6D
  carbonKeys("F11") = $67
  carbonKeys("F12") = $6F
  carbonKeys("F13") = $69
  carbonKeys("F14") = $6B
  carbonKeys("F15") = $71
  carbonKeys("F16") = $6A
  carbonKeys("F17") = $40
  carbonKeys("F18") = $4F
  carbonKeys("F19") = $50
  carbonKeys("F20") = $5A
  carbonKeys("Home") = $73
  carbonKeys("End") = $77
  carbonKeys("PgUp") = $74
  carbonKeys("PgDown") = $79
  carbonKeys("§") = $0A : carbonKeys("±") = $0A
  carbonKeys("Del") = $33
  
  ; hotkeys list and other stuff
  Global NewList globalHotkeys.globalHotkey()
  Global Dim eventTypes.EventTypeSpec(0)
  eventTypes(0)\EventClass = #kEventClassKeyboard
  eventTypes(0)\EventKind = #kEventHotKeyPressed
  Global initOK = #False
  Global freeID.i = 1
  
  ; procedures
  ProcedureC globalHotkeyHandler(NextHandlerRef.i,EventRef.i,*UserData)
    Protected HotKey.q,signature.i,id.i
    If GetEventParameter_(EventRef,#kEventParamDirectObject,#typeEventHotKeyID,0,SizeOf(EventHotKeyID),0,@HotKey) = 0
      signature = PeekL(HotKey)
      id = PeekL(HotKey + 4)
      ForEach globalHotkeys()
        If globalHotkeys()\hotkeyID\ID = id And globalHotkeys()\hotkeyID\Signature = signature
          ;Debug "id is " + id + ", signature is " + signature
          PostEvent(globalHotkeys()\event,globalHotkeys()\evWindow,globalHotkeys()\evObject,globalHotkeys()\evType,globalHotkeys()\evData)
          Break
        EndIf
      Next
    EndIf
  EndProcedure
  
  Procedure.b init()
    If InstallEventHandler_(GetApplicationEventTarget(),@globalHotkeyHandler(),1,@eventTypes(), 0, 0) = 0
      initOK = #True
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.b add(hotkey.s,event.i,evWindow.i = #PB_Ignore,evObject.i = #PB_Ignore,evType.i = #PB_Ignore,evData.i = 0)
    Protected modifiers.i,key.s,num.s
    If Not initOK : ProcedureReturn #False : EndIf
    If Len(hotkey) > 1
      For i = 1 To Len(hotkey)
        Select Mid(hotkey,i,1)
          Case "⌃"
            modifiers + #controlKey
          Case "⌥"
            modifiers + #optionKey
          Case "⇧"
            modifiers + #shiftKey
          Case "⌘"
            modifiers + #cmdKey
          Case "⎋"
            key = "Esc"
          Case "↩"
            key = "Return"
          Default
            key + Mid(hotkey,i,1)
        EndSelect
      Next
      If Len(key) And FindMapElement(carbonKeys(),key)
        AddElement(globalHotkeys())
        globalHotkeys()\hotkey = hotkey
        globalHotkeys()\hotkeyID\ID = freeID
        freeID + 1
        globalHotkeys()\hotkeyID\Signature = Val("$68303030") + globalHotkeys()\hotkeyID\ID
        globalHotkeys()\event = event
        globalHotkeys()\evWindow = evWindow
        globalHotkeys()\evObject = evObject
        globalHotkeys()\evType = evType
        globalHotkeys()\evData = evData
        If RegisterEventHotKey(carbonKeys(),modifiers,@globalHotkeys()\hotkeyID,GetApplicationEventTarget(),0,@globalHotkeys()\hotkeyRef) = 0
          ProcedureReturn #True
        Else
          DeleteElement(globalHotkeys())
        EndIf
      EndIf
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.b remove(hotkey.s,event.i = 0,removeAll.b = #False)
    If Not initOK : ProcedureReturn #False : EndIf
    ForEach globalHotkeys()
      If globalHotkeys()\hotkey = hotkey Or globalHotkeys()\event = event Or removeAll
        If UnregisterEventHotKey(globalHotkeys()\hotkeyRef) = 0
          DeleteElement(globalHotkeys())
        Else
          ProcedureReturn #False
        EndIf
      EndIf
    Next
    ProcedureReturn #True
  EndProcedure
EndModule
; IDE Options = PureBasic 5.42 LTS (MacOS X - x64)
; Folding = --
; EnableUnicode
; EnableXP