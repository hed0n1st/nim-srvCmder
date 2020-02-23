
import
  os,
  osproc,
  json,
  strutils,
  tables

import winim/com

type
  Win32_Service* = object
    list*: Table[int, seq[string]]
    running*: Table[int, seq[string]]
    menuRunning*: seq[string]
    stopped*: Table[int, seq[string]]
    menuStopped*: seq[string]

  ControledServices = object
    list*: seq[string]

  UpdateControledServices = enum
    addSrv, remSrv

var w32s*: Win32_Service
var srvCtrl*: ControledServices

let srvCtrlFile = joinPath(getAppDir(), "srvCmder.config")

proc getServices*() =
  let srvObj = GetObject(r"winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
  let srvQuery = srvObj.execQuery("Select * from Win32_Service")
  var l, r, s = 1
  w32s.menuRunning = @[]
  w32s.menuStopped = @[]
  w32s.running.clear
  w32s.stopped.clear
  for srv in srvQuery:
    var data: seq[string]
    data.add($srv.name)
    data.add($srv.displayname)
    data.add($srv.state)
    try:
      data.add($srv.description)
    except:
      data.add("No description.")

    case $srv.state
    of "Running":
      w32s.menuRunning.add($srv.name)
      w32s.running.add(r, data)
      inc r
    else:
      w32s.menuStopped.add($srv.name)
      w32s.stopped.add(s, data)
      inc s

    w32s.list.add(l, data)
    inc l

proc getCtrlServices*() =
  srvCtrl.list = @[]
  if srvCtrlFile.existsFile:
    for srv in srvCtrlFile.lines:
      srvCtrl.list.add(srv)

proc updateCtrlServicesFile(srv: string, mode: UpdateControledServices): bool =
  getCtrlServices()

  if mode == addSrv and not srvCtrl.list.contains(srv):
    let f = open(srvCtrlFile, fmAppend)
    defer: f.close()
    f.write(srv & "\n")
    result = true

  if mode == remSrv and srvCtrl.list.contains(srv):
    var data: File
    data = open(srvCtrlFile, fmRead)
    var newData: seq[string]
    for line in lines(data):
      if not line.contains(srv): newData.add(line)
    data.close()

    removeFile(srvCtrlFile)

    data = open(srvCtrlFile, fmWrite)
    for n in newData:
      data.write(n & "\n")
    data.close()
    result = true

proc addService*(srv: string): bool =
  updateCtrlServicesFile(srv, mode=addSrv)

proc remService*(srv: string): bool =
  updateCtrlServicesFile(srv, mode=remSrv)

proc isAdmin(): bool =
  let err = execCmd("reg query \"HKU\\S-1-5-19\"")
  case err
  of 0: result = true
  else: result = false

proc startService*(srv: string) =
  if isAdmin():
    discard execProcess(
      "net",
      args=["start", srv],
      options={poDaemon}
    )
  else:
    discard ShellExecuteW(
      0,
      newWideCString("runas"),
      newWideCString("net"),
      newWideCString("start " & srv),
      nil,
      SW_HIDE
    )

proc stopService*(srv: string) =
  if isAdmin():
    discard execProcess(
      "net",
      args=["stop", srv],
      options={poDaemon}
    )
  else:
    discard ShellExecuteW(
      0,
      newWideCString("runas"),
      newWideCString("net"),
      newWideCString("stop " & srv),
      nil,
      SW_HIDE
    )
