
import
  tables

import wNim/[wApp, wEvent, wFrame, wIcon, wPanel, wComboBox, wListCtrl, wMessageDialog]
import ../core/core

proc popListctrl(self: wListCtrl, data: Table[int, seq[string]]) =
  for data in data.pairs:
    var wd: seq[string] = data[1]
    var wid = self.appendItem(text=wd[0])
    self.setItem(wid, 1, text=wd[1])
    self.setItem(wid, 2, text=wd[2])
    self.setItem(wid, 3, text=wd[3])

proc srvList*(owner: wWindow) =
  let frame = Frame(title="Services Commander", style=wDefaultFrameStyle or wStayOnTop)
  frame.icon = Icon("", 0)
  frame.dpiAutoScale:
    frame.size = (800, 600)
    frame.minSize = (800, 600)
    frame.maxSize = (800, 600)
  let panel = Panel(frame)
  panel.margin = 5
  let combobox = ComboBox(panel, value="All",
                  choices=["All", "Running", "Stopped"],
                  style=wCbReadOnly
  )
  let listctrl = ListCtrl(panel, style=wLcReport or wLcNoSortHeader or wLcSingleSel or wBorderSunken)
  listctrl.insertColumn(0, text="Name", format=wListFormatLeft, width=200)
  listctrl.insertColumn(1, text="Display name", format=wListFormatLeft, width=200)
  listctrl.insertColumn(2, text="State", format=wListFormatLeft, width=100)
  listctrl.insertColumn(3, text="Description", format=wListFormatLeft)

  listctrl.popListCtrl(w32s.list)

  listctrl.setColumnWidth(3, -1)

  proc layout() =
    panel.autolayout """
      H:|[combobox(combobox.bestWidth)]|
      V:|-[combobox(25)]-[listctrl]-|
    """

  frame.wEvent_Show do ():
    layout()

  panel.wEvent_Size do ():
    layout()

  combobox.wEvent_ComboBox do ():
    let choice = combobox.getValue()
    listctrl.deleteAllItems()
    case choice
    of "All":
      listctrl.popListCtrl(w32s.list)
    of "Running":
      listctrl.popListCtrl(w32s.running)
    of "Stopped":
      listctrl.popListCtrl(w32s.stopped)

    listctrl.setColumnWidth(3, -1)

  listctrl.wEvent_ListItemRightClick do (event: wEvent):
    let srv = listctrl.getItemText(event.getIndex())
    let dlg = MessageDialog(frame, "Add " & srv & " as controled service?", "", wOkCancel or wIconQuestion)
    if dlg.showModal() != wIdOk:
      event.veto()
    else:
      if not addService(srv):
        MessageDialog(frame, "This service is already controled !", "", wOk or wIconExclamation or wStayOnTop).showModal()
        event.veto()

  frame.center()
  frame.show()
