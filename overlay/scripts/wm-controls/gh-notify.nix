{ writeShedBin }:
writeShedBin "gh-notify" ''
  set -euo pipefail
  state="''${XDG_STATE_HOME:-$HOME/.local/state}/gh-notify"

  mkdir -p "$state"
  seen="$state/seen"
  touch "$seen"

  gh api '/notifications' \
  --jq '.[]
    | select(
      .repository.owner.login == "km-clay"
      or (.reason | IN("mention","review_requested","assign","team_mention"))
    ) | [.id, .updated_at, .reason, .repository.full_name, .subject.type, .subject.title] | @tsv' \
  | while IFS=$'\t' read -r id updated reason repo type title; do
    key="$id:$updated"
    grep -qxF "$key" "$seen" && continue
    notify-send -a GitHub -i github "$repo - $reason" "$type: $title" || continue
    printf '%s\n' "$key" >> "$seen"
  done
''
