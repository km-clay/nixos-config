{ pkgs }:

let
  themeBuilder = import ./theme_builder.nix { inherit pkgs; };
in
pkgs.writeText "paperd.py" /* python */ ''
  import tomllib
  import sys
  import time
  import random
  from pathlib import Path
  from collections import deque
  import subprocess

  config = None

  with open(Path("~/.config/paperd/config.toml").expanduser(), "rb") as f:
            config = tomllib.load(f)

  interval = config["interval"]
  paper_dir = Path(config["wallpaper_dir"])
  transition = config.get("transition", {})
  transition_type = transition.get("type")
  transition_fps = transition.get("fps")
  transition_duration = transition.get("duration")
  transition_angle = transition.get("angle")
  transition_step = transition.get("step")

  exts = {".jpg", ".jpeg", ".png", ".webp"}
  images = deque([f for f in Path(paper_dir).iterdir() if f.suffix.lower() in exts])

  if len(images) == 0:
      print("No images found in the specified directory.")
      sys.exit(1)

  random.shuffle(images)
  used = []

  def next_image():
    if len(images) == 0:
      while used:
        images.append(used.pop())
      random.shuffle(images)

    image = images.popleft()
    used.append(image)
    return image

  def get_command(next_image):
      command = ["${pkgs.swww}/bin/swww", "img"]
      if transition_type:
          command.append("--transition-type")
          command.append(transition_type)
      if transition_fps:
          command.append("--transition-fps")
          command.append(str(transition_fps))
      if transition_duration:
          command.append("--transition-duration")
          command.append(str(transition_duration))
      if transition_angle:
          command.append("--transition-angle")
          command.append(str(transition_angle))
      if transition_step:
          command.append("--transition-step")
          command.append(str(transition_step))
      command.append(str(next_image))
      return command


  print(f"Found {len(images)} images. Starting wallpaper rotation every {interval} seconds.")
  current_time = int(time.time())

  image = next_image()
  command = get_command(image)
  subprocess.run(command)
  subprocess.run(["${pkgs.myPython}/bin/python3", "${themeBuilder}", str(image)])

  print(f"Setting wallpaper to {image} with transition {transition_type} (fps: {transition_fps}, duration: {transition_duration}, angle: {transition_angle}, step: {transition_step})")

  last_check = current_time % interval
  time.sleep(5)

  while True:
      current_time = int(time.time())
      if (current_time % interval) >= last_check:
          last_check = current_time % interval
          time.sleep(5)
          continue

      image = next_image()
      command = get_command(image)

      print(f"Setting wallpaper to {image} with transition {transition_type} (fps: {transition_fps}, duration: {transition_duration}, angle: {transition_angle}, step: {transition_step})")

      subprocess.run(command)
      subprocess.run(["${pkgs.myPython}/bin/python3", "${themeBuilder}", str(image)])
      last_check = current_time % interval
      time.sleep(5)
''
