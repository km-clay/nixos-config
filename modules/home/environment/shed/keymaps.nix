{ ... }:
{
  programs.shed = {
    functions = {
      _read_obj= /* bash */ ''
        _obj=""
        while read_key -v key; do
          if [[ "''${#_obj}" -ge 3 ]]; then return 1; fi
          case "$key" in
            i|a)
              if [ -n "$_obj" ]; then return 1; fi
              _obj="$key"
              ;;
            b|e)
              if [ -n "$_obj" ]; then return 1; fi
              _obj="$key"
              break
              ;;
            w|W)
              _obj="$_obj$key"
              break
              ;;
            f|F)
              read_key -v char
              _obj="$key$char"
              break
            ;;
            \(|\)|\[|\]|\{|\}|\"|\')
              if [ -z "$_obj" ]; then return 1; fi
              _obj="$_obj$key"
              break
              ;;
          esac
        done
      '';
      _surround_1 = /* bash */ ''
        local _obj
        _read_obj
        _get_surround_target
        _KEYS="v$_obj"
      '';
      _surround_2 = /* bash */ ''
        local start
        local end
        if [ "$_ANCHOR" -lt "$_CURSOR" ]; then
          start=$_ANCHOR
          end=$_CURSOR
        else
          start=$_CURSOR
          end=$_ANCHOR
        fi
        end=$((end + 1))

        delta=$((end - start))

        left="''${_BUFFER:0:$start}"
        mid="''${_BUFFER:$start:$delta}"
        right="''${_BUFFER:$end}"
        _BUFFER="$left$_sl$mid$_sr$right"
        _CURSOR=$start
      '';

      _get_surround_target = /* bash */ ''
        read_key -v _s_ch
        case "$_s_ch" in
          \(|\)) _sl='('; _sr=')' ;;
          \[|\]) _sl='['; _sr=']' ;;
          \{|\}) _sl='{'; _sr='}' ;;
          \<|\>) _sl='<'; _sr='>' ;;
          *) _sl="$_s_ch"; _sr="$_s_ch" ;;
        esac
      '';

      _surround_del = /* bash */ ''
        _get_surround_target
        local left_buf="''${_BUFFER:0:$_CURSOR}"
        local right_buf="''${_BUFFER:$left}"
        local left=""
        local right=""
        _scan_left $_sl "$left_buf"

        if [ "$?" -ne 0 ]; then
          _scan_right $_sl "$right_buf"

          [ "$?" -ne 0 ] && echo "No match found in left or right scan for char '$_sl' on $left_buf" 1>&2 && return 1
          left=$right
        fi

        mid_start=$((left + 1))
        right=""
        left_buf="''${_BUFFER:0:$left}"
        right_buf="''${_BUFFER:$mid_start}"
        _scan_right $_sr "$right_buf"

        [ "$?" -ne 0 ] && echo "No match found in right scan for char '$_sr'" 1>&2 && return 1

        mid_end=$((mid_start + right))
        right_start=$((mid_end + 1))
        new_left_buf="''${_BUFFER:0:$left}"
        new_mid_buf="''${_BUFFER:$mid_start:$right}"
        new_right_buf="''${_BUFFER:$right_start}"


        _BUFFER="$new_left_buf$new_mid_buf$new_right_buf"
      '';

      _scan_left = /* bash */ ''
        local needle="$1"
        local haystack="$2"
        local i=$((''${#haystack} - 1))


        while [ "$i" -ge 0 ]; do
          ch="''${haystack:$i:1}"
          if [ "$ch" = "$needle" ]; then
            left=$i
            return 0
          fi
          i=$((i - 1))
        done

        return 1
      '';

      _scan_right = /* bash */ ''
        local needle="$1"
        local haystack="$2"
        local i=0


        while [ "$i" -lt "''${#haystack}" ]; do
          ch="''${haystack:$i:1}"
          if [ "$ch" = "$needle" ]; then
            right="$i"
            return 0
          fi
          i=$((i + 1))
        done

        return 1
      '';

      _enum_chars = /* bash */ ''
        local i=0
        [ -z "$1" ] && return 1
        [ "''${#1}" -eq 1 ] && echo "0 $1" && return 0

        while [ "$i" -lt ''${#1} ]; do
          echo -n "$i ''${1:$i:1} "
          i=$((i + 1))
          [ $i -ge "''${#1}" ] && break
          echo -n " "
        done
        echo
      '';

      _enum_chars_rev = /* bash */ ''
        local i=$((''${#1} - 1))
        [ -z "$1" ] && return 1
        [ "''${#1}" -eq 1 ] && echo "0 $1" && return 0

        while [ "$i" -ge 0 ]; do
          echo -n "$i ''${1:$i:1} "
          i=$((i - 1))
          [ $i -lt 0 ] && break
          echo -n " "
        done
        echo
      '';

      _edit_line = /* bash */ ''
        tmp="$(mktemp)"
        echo -n "$_BUFFER" > "$tmp"
        $EDITOR "$tmp"
        _BUFFER="$(cat "$tmp")"
        rm "$tmp"
      '';
    };

    keymaps = [
      {
        modes = [ "n" ];
        keys = "<leader>e";
        command = ":!_edit_line<CR>";
      }
      {
        modes = [ "n" ];
        keys = "ys";
        command = ":!_surround_1<CR>:!_surround_2<CR>";
      }
      {
        modes = [ "n" ];
        keys = "ds";
        command = ":!_surround_del<CR>";
      }
    ];
  };
}
