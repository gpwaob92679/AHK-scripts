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


^!C::
WinGetActiveTitle, active_title
found_pos := RegExMatch(active_title, ".* - YouTube", youtube_page_title)
if (found_pos == 0) {  ; Current window isn't YouTube.
  return
}

youtube_page := Chrome.GetPageByTitle(youtube_page_title, "exact")
current_video_time := youtube_page.Evaluate("document.getElementsByTagName('video')[0].currentTime;").value
current_video_time := FormatSeconds(current_video_time)
youtube_page.Disconnect()

Clipboard := current_video_time
ToolTip, %current_video_time%
SetTimer, RemoveToolTip, -500
return


RemoveToolTip:
ToolTip
return
