{ super, root, host }:

# We need to fold all of these into a single attribute set
import ./commands { inherit super root;  } //
import ./nix { inherit super host root; } //
import ./misc { inherit super; } //
import ./wm-controls { inherit super; }
