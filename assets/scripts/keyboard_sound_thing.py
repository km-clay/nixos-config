import evdev, random, subprocess, os, threading, socket

active_class = ""

def watch_hyprland():
    global active_class
    sig = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
    sock_path = f"{os.environ['XDG_RUNTIME_DIR']}/hypr/{sig}/.socket2.sock"
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    s.connect(sock_path)
    for line in s.makefile():
        if line.startswith("activewindow>>"):
            active_class = line.split(">>")[1].split(",")[0]

threading.Thread(target=watch_hyprland, daemon=True).start()

dev = None

def is_target_window():
    return active_class == "kitty" or active_class == "neovide" or active_class == "discord" or active_class == "vesktop" or active_class == "firefox"

for path in evdev.list_devices():
  d = evdev.InputDevice(path)
  if 'keyd virtual keyboard' in d.name:
      dev = d
      break
  d.close()

if dev != None:
    for event in dev.read_loop():
        if event.type == 1 and event.value == 1 and is_target_window():
            if event.code == 28:
                subprocess.Popen(['pw-play', '/home/pagedmov/.sysflake/assets/sound/msg_finish.wav'])
            elif event.code == 14:
                subprocess.Popen(['pw-cat', '--playback', '--volume=0.5', '/home/pagedmov/.sysflake/assets/sound/low_hp.wav'])
            elif event.code == 1:
                subprocess.Popen(['pw-play', '/home/pagedmov/.sysflake/assets/sound/menu_close.wav'])
            else:
                pitch = random.randint(-50,50)
                subprocess.Popen(['play', '-q', '/home/pagedmov/.sysflake/assets/sound/msg.wav', 'pitch', str(pitch)])
