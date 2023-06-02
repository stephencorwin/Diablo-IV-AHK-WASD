#NoEnv
#Persistent
#SingleInstance, Force
#MaxHotkeysPerInterval, 500
SendMode Input
SetKeyDelay -1
SetControlDelay -1
SetTitleMatchMode, 3

; ====================================================================
; ============================== CONFIG ==============================
; ====================================================================

appName := "Diablo IV"        ; needs to match game window title exactly

; =========================== CALIBRATION ============================

yCorrection := -36            ; moves the coordinate (in pixels) of the center of the screen vertically (- up / + down), allows tweaking the skew of horizontal movement direction
xOffset := 400               ; horizontal coordinate of mouse click when moving left or right (it is located outside the screen, but game interprets it as clicking on the edge)
yOffset := 400               ; vertical coordinate of mouse click when moving up or down (it is located outside the screen, but game interprets it as clicking on the edge)
xStopOffset := 40             ; amount of pixels from the center of the screen (horizontally), where the click to stop the character occurs
yStopOffset := 30             ; amount of pixels from the center of the screen (vertically), where the click to stop the character occurs
timerTickTime := 20           ; time interval (in  milliseconds) between each scan of 'WASD' input
postClickDelay := 100         ; the length of pause (in milliseconds) after each click sent by the script; makes it less spammy, but also less responsive

; =========================== KEY BINDINGS ===========================

moveKey := "M"                ; key used to move the character (L, M, R)
abilityKeyBasic := "LButton"  ; key used for the basic abilityKey
abilityKeyCore := "RButton"   ; key used for the core ability
abilityKey1 := "q"            ; key used for ability 1
abilityKey2 := "e"            ; key used for ability 2
abilityKey3 := "PgDn"         ; key used for ability 3
abilityKey4 := "Shift"        ; key used for ability 4
holdKey := "\"                ; key used for holding position while using abilities

; =========================== ANTI-DETECTIONS ========================

movePrecision := 10           ; determines how much randomness to add to each click that is sent
stopMovePrecision := 10       ; determines how much randomness to add to each stop click that is sent
delayPrecision := 25          ; determines how much randomness to add to each click delay

; ====================================================================
; =========================== GLOBALS ================================
; ====================================================================

WinWaitActive, %appName%
Sleep 3000
SoundBeep
WinGetPos, xWin, yWin, wWin, hWin, A
xCenter := xWin + wWin / 2
yCenter := yWin + hWin / 2 + yCorrection

SetTimer, Main, %timerTickTime%
scriptPause := false
holdKeyToggled := false

; ====================================================================
; ====================================================================
; ====================================================================

#If WinActive(appName)

~End::
  if (scriptPause) {
    SoundBeep, 5000, 10
    SetTimer, Main, %timerTickTime%
  } else {
    SoundBeep, 1000, 10
    ControlClick, x%xCenter% y%yCenter%, A,, %moveKey%, 1, NA
    SetTimer, Main, Off
  }
  scriptPause := !scriptPause
return

~w up::
~a up::
~s up::
~d up::
  if (scriptPause) {
    return
  }

  if (isPressedAny()) {
    return
  }

  strButton := StrReplace(A_ThisHotkey, "~", "")
  strButton := StrReplace(strButton, " up", "")

  Coord := getStopCoord(strButton)
  xTarget := r(Coord.x, stopMovePrecision)
  yTarget := r(Coord.y, stopMovePrecision)

  ControlClick, x%xTarget% y%yTarget%, A,, %moveKey%, 1, NA
return

Main:
  if (!WinActive(appName)) {
    return
  }

  if (scriptPause) {
    return
  }

  ; hold position while using abilities
  if (isPressedAbility()) {
    if (!holdKeyToggled) {
      Send, {%holdKey% down}
      holdKeyToggled := true
    }
  } else {
    if (holdKeyToggled) {
      Send, {%holdKey% up}
      holdKeyToggled := false
    }
  }

  if (!isPressedAny()) {
    return
  }

  xTarget := r(horizontalDirEval(), movePrecision)
  yTarget := r(verticalDirEval(), movePrecision)

  ControlClick, x%xTarget% y%yTarget%, A,, %moveKey%, 1, NA
  Sleep, r(postClickDelay, delayPrecision)
return

; ====================================================================
; =========================== UTILS ==================================
; ====================================================================

getStopCoord(key) {
  Global
  Switch key {
    case "w":
      Coord := {x: xCenter, y: yCenter - yStopOffset}
    case "a":
      Coord := {x: xCenter - xStopOffset, y: yCenter}
    case "s":
      Coord := {x: xCenter, y: yCenter + yStopOffset}
    case "d":
      Coord := {x: xCenter + xStopOffset, y: yCenter}
  }
  return Coord
}

horizontalDirEval() {
  Global
  if (!(isPressed("a") or isPressed("d"))) {
    return xCenter
  }

  if (isPressed("a")) {
    return xCenter - xOffset
  }

  if (isPressed("d")) {
    return xCenter + xOffset
  }
}

verticalDirEval() {
  Global
  if (!(isPressed("w") or isPressed("s"))) {
    return yCenter
  }

  if (isPressed("w")) {
    return yCenter - yOffset
  }

  if (isPressed("s")) {
    return yCenter + yOffset
  }
}

isPressed(key) {
  return GetKeyState(key, "P")
}

isPressedAny() {
  return (isPressed("w") or isPressed("a") or isPressed("s") or isPressed("d"))
}

isPressedAbility() {
  Global
  return (isPressed(abilityKeyBasic) or isPressed(abilityKeyCore) or isPressed(abilityKey1) or isPressed(abilityKey2) or isPressed(3) or isPressed(abilityKey4))
}

r(num, precision) {
  val := 0
  Random, val, -precision, precision
  return num + val
}
