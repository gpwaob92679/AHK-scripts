#SingleInstance Force

#Include <Chrome>


FormatSeconds(seconds) {
  seconds := Floor(seconds)
  time := 19700101  ; Midnight of an arbitrary date.
  time += seconds, seconds

  if (seconds >= 3600) {
    FormatTime, human_time, %time%, h:mm:ss
  } else {
    FormatTime, human_time, %time%, m:ss
  }
  return human_time
}


class VideoTimeGetter {
  page :=
  page_title :=

  GetCurrentVideoTime() {
    if (!WinActive("ahk_exe chrome.exe")) {
      return
    }

    WinGetActiveTitle, active_window_title
    active_page_title := SubStr(active_window_title, 1, InStr(active_window_title, " - Google Chrome") - 1)
    if (active_page_title != this.page_title) {
      active_page := Chrome.GetPageByTitle(active_page_title, "exact")
      if (active_page.Evaluate("document.getElementsByTagName('video').length").value > 0) {
        this._SetPage(active_page, active_page_title)
      } else {
        active_page.Disconnect()
      }
    }

    if (!this.page.Connected) {
      return
    }

    time := this.page.Evaluate("document.getElementsByTagName('video')[0].currentTime;").value
    return FormatSeconds(time)
  }

  _SetPage(page, page_title) {
    if (page == this.page && page_title == this.page_title) {
      return false
    }
    if (this.page is Chrome.Page) {
      this.page.Disconnect()
      this.page_title :=
    }
    this.page := page
    this.page_title := page_title
    return true
  }
}
video_time_getter := new VideoTimeGetter()


^!C::
video_time := video_time_getter.GetCurrentVideoTime()
if (video_time) {
  Clipboard := video_time
  page_title := video_time_getter.page_title
  ToolTip, %video_time%`n(Page: %page_title%)
  SetTimer, RemoveToolTip, -500
} else {
  ToolTip, Failed to copy current video time
  SetTimer, RemoveToolTip, -500
}
return


RemoveToolTip:
ToolTip
return
