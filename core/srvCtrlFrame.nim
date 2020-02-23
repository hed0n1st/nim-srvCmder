
import wNim/[wApp, wEvent, wFrame, wIcon, wPanel, wListBox, wButton, wMessageDialog]
import ../core/core

proc popListbox(self: wListBox) =
  self.clear()
  getCtrlServices()
  for srv in srvCtrl.list:
    self.append(srv)

proc srvCtrl*(owner: wWindow) =
  let frame = Frame(title="Services Commander", style=wDefaultFrameStyle or wStayOnTop)
  frame.icon = Icon("", 0)
  frame.dpiAutoScale:
    frame.size = (400, 300)
    frame.minSize = (400, 300)
    frame.maxSize = (400, 300)
  let panel = Panel(frame)
  panel.margin = 6
  let listbox = ListBox(panel, style=wLbSingle or wLbNeededScroll or wBorderSunken)
  let button = Button(panel, label="Remove ...")
  button.disable()

  listbox.popListbox()

  proc layout() =
    panel.autolayout """
      H:|-[button]-|
      H:|-[listbox]-|
      V:|-[listbox]-[button(25)]-|
    """

  var srv: string

  listbox.wEvent_Listbox do (event: wEvent):
    srv = listbox.getText(listbox.getSelection())
    button.label = "Remove " & srv
    button.enable()

  button.wEvent_Button do ():
    if remService(srv):
      MessageDialog(frame, srv & " has been deleted", "", wOk or wIconInformation or wStayOnTop).showModal()
    listbox.popListbox()
    button.label = "Remove ..."
    button.disable()

  frame.wEvent_Show do ():
    layout()

  panel.wEvent_Size do ():
    layout()

  frame.center()
  frame.show()
