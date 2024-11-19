{ pkgs }:

pkgs.writeShellApplication {
  name = "mntstack";
  runtimeInputs = [];
  text = ''
    set -e

    # File to store the stack
    STACK_FILE="/tmp/mntstack.txt"

    validate_entry() {
      local entry_dev entry_mntpoint
      IFS=' ' read -r entry_dev entry_mntpoint <<< "$1"
      echo "$entry_dev" > /dev/null # Don't ask
      [ -n "$(findmnt -no SOURCE,TARGET "$entry_mntpoint" | cut -d' ' -f1-)" ]
    }

    # Function to push a path onto the stack
    push_path() {
      local device="$1"
      local mount_point="$2"
      local bind_flag="$3"

        if [ ! -f "$STACK_FILE" ]; then
          touch "$STACK_FILE"
        fi

        # Validate the paths
        if [[ ! -e "$device" || ! -d "$mount_point" ]]; then
          echo "Error: Invalid device or mount point."
          exit 1
        fi

        # Check if the device is a normal directory
        if [[ -d "$device" && "$bind_flag" != "--bind" ]]; then
          echo "Error: Cannot mount a normal directory without --bind flag."
          exit 1
        fi

        # Check for duplicate entries
        if grep -q "^$device $mount_point\$" "$STACK_FILE"; then
          echo "Error: Duplicate entry detected."
          exit 1
        fi

        # Mount the device to the mount point
        if [[ "$bind_flag" == "--bind" ]]; then
          sudo mount --bind "$device" "$mount_point"
        else
          sudo mount "$device" "$mount_point"
        fi

        # Append the path to the stack file
        echo "$device $mount_point" >> "$STACK_FILE"
        echo "Pushed and mounted: $device $mount_point"
      }

    # Function to pop a path from the stack
    pop_path() {


        if [[ ! -f "$STACK_FILE" || ''${#stack[@]} -eq 0 ]]; then
            echo "Warning: Stack is empty. Nothing to pop."
            exit 0
        fi

        mapfile -t stack < "$STACK_FILE"

        # Get the last entry
        last_path="''${stack[-1]}"
        if ! validate_entry "$last_path"; then
          echo -e "Warning: Invalid stack entry \"''${stack[-1]}\""
          sed -i '$d' "$STACK_FILE"
          return 0
        fi

        IFS=' ' read -r device mount_point <<< "$last_path"

        # Unmount the device
        sudo umount "$mount_point"
        sed -i '$d' "$STACK_FILE"

        echo "Popped and unmounted: $device"
    }

    # Function to list the current stack
    list_stack() {
      # Check if the stack file exists
      if [[ ! -f "$STACK_FILE" ]]; then
        echo "Stack is empty."
        exit 0
      fi

      # Read the stack file into an array
      mapfile -t stack < "$STACK_FILE"

      # Check if the stack is empty
      if [[ ''${#stack[@]} -eq 0 ]]; then
        echo "Stack is empty."
        exit 0
      fi

      # Display the stack elements
      for ((i=0; i<''${#stack[@]}; i++)); do
          IFS=' ' read -r device mount_point <<< "''${stack[i]}"
          echo "$((i+1)). $mount_point -> $device"
      done
    }

      pop_num=1
      all=false
      bind=false
      pos_args=()

    # Early check for help
    if [[ "$1" == "help" ]]; then
      echo "Usage: $0 {push|pop|list} [--bind] [<device> <mount_point>]"
      echo "Flags:"
      echo "pop -c,--count: specify a number of mounts to pop"
      echo "pop -a,--all: pop the entire stack"
      echo "push <dir> <mount_point> -b,--bind: use --bind when mounting"
      exit 0
    fi

    # Process flags
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -a|--all)
          all=true
          shift
          ;;
        -c|--count)
          if [[ "$2" =~ ^-?[0-9]+$ ]]; then
            pop_num="$2"
            shift 2
          else
            echo "Invalid count: please give an integer like -c 5"
            exit 1
          fi
          ;;
        -b|--bind)
          bind=true
          shift
          ;;
        *)
          pos_args+=("$1")
          shift
          ;;
      esac
    done

    # Main command processing
    case "''${pos_args[0]}" in
      push)
        if [[ ''${#pos_args[@]} -lt 3 || ''${#pos_args[@]} -gt 4 ]]; then
          echo "Usage: $0 push [--bind] <device> <mount_point>"
          exit 1
        fi
        push_path "''${pos_args[1]}" "''${pos_args[2]}" "$([[ $bind == true ]] && echo "--bind")"
        ;;
      pop)
        if [[ ''${#pos_args[@]} -ne 1 ]]; then
          echo "Usage: $0 pop"
          exit 1
        fi
        if [[ ! -f "$STACK_FILE" ]]; then
          echo "Stack file does not exist. Nothing to pop."
        fi
        if [[ $all == false ]]; then
          mapfile -t stack < "$STACK_FILE"
          while [[ $pop_num -gt 0 ]]; do
            pop_path || break
            mapfile -t stack < "$STACK_FILE"
            ((pop_num--))
          done
        else
          mapfile -t stack < "$STACK_FILE"
          while [[ ''${#stack[@]} -gt 0 ]]; do
            if ! pop_path; then
              break
            fi
            mapfile -t stack < "$STACK_FILE"
          done
        fi
        ;;
      list)
        if [[ ''${#pos_args[@]} -ne 1 ]]; then
          echo "Usage: $0 list"
          exit 1
        fi
        list_stack
        ;;
      *)
        echo "Usage: $0 {push|pop|list} [--bind] [<device> <mount_point>]"
        exit 1
        ;;
    esac
  '';
}
