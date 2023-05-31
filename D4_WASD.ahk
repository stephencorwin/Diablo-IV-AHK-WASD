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

;appName := "Path of Exile"   ; needs to match game window title exactly
;appName := "Diablo III"
appName := "Diablo IV"
;appName := "League of Legends (TM) Client"

; ====================================================================

yCorrection := -36            ; moves the coordinate (in pixels) of the center of the screen vertically (- up / + down), allows tweaking the skew of horizontal movement direction
xOffset := 10000              ; horizontal coordinate of mouse click when moving left or right (it is located outside the screen, but game interprets it as clicking on the edge)
yOffset := 10000              ; vertical coordinate of mouse click when moving up or down (it is located outside the screen, but game interprets it as clicking on the edge)
xStopOffset := 40             ; amount of pixels from the center of the screen (horizontally), where the click to stop the character occurs
yStopOffset := 30             ; amount of pixels from the center of the screen (vertically), where the click to stop the character occurs
timerTickTime := 20           ; time interval (in  milliseconds) between each scan of 'WASD' input
postClickDelay := 100         ; the length of pause (in milliseconds) after each click sent by the script; makes it less spammy, but also less responsive
moveKey := "L"                ; key used to move the character (L, M, R)

; ====================================================================

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
  Sleep, r(postClickDelay, delayPrecision)
return

Main:
  if (!WinActive(appName)) {
    return
  }

  if (scriptPause) {
    return
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

r(num, precision) {
  val := 0
  Random, val, -precision, precision
  return num + val
}
