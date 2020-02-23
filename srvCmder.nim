
when defined(cpu64):
  {.link: "resource/srvCmder64.res".}
else:
  {.link: "resource/srvCmder32.res".}

import wNim/[wApp, wEvent, wFrame, wIcon, wImage, wBitMap, wMenu]

import core/[core, srvListFrame, srvCtrlFrame]

type
  MenuID = enum
    idOpen = wIdUser, idExit
    idSrv, idSrvList, idSrvCtrl

proc buildSystrayMenu(self: wMenu) =
  let bmpSrvOn = Bitmap(Image(Icon("", 1)).scale(16, 16))
  let bmpSrvOff = Bitmap(Image(Icon("", 2)).scale(16, 16))
  getServices()
  getCtrlServices()
  for srv in core.srvCtrl.list:
    if w32s.menuRunning.contains(srv):
      self.append(idSrv, srv, "on", bmpSrvOn)
    if w32s.menuStopped.contains(srv):
      self.append(idSrv, srv, "off", bmpSrvOff)
  self.appendSeparator()
  self.append(idSrvCtrl, "Controled services", "")
  self.appendSeparator()
  self.append(idSrvList, "Open Services List", "")
  self.appendSeparator()
  self.append(idExit, "Quit", "Exit app")

proc main() =
  let app = App()
  let frame = Frame()
  frame.icon = Icon("", 0)
  frame.setTrayIcon(frame.icon)

  frame.idExit do ():
    frame.removeTrayIcon()
    frame.delete()

  frame.idSrvList do ():
    frame.srvList()

  frame.idSrvCtrl do ():
    frame.srvCtrl()

  frame.idSrv do (event: wEvent):
    let srv = event.getMenuItem.getLabel()
    let state = event.getMenuItem.getHelp()
    case state
    of "on":
      stopService(srv)
    of "off":
      startService(srv)

  frame.connect(wEvent_TrayRightDown) do ():
    let menu = Menu()
    buildSystrayMenu(menu)
    frame.popupMenu(menu)

  app.mainLoop()

when isMainModule:
  main()
