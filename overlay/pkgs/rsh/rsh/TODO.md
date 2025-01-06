## Stuff that needs to be done

* rework variable substitution; the logic is too flimsy in it's current state. It currently works with raw strings rather than tokens which makes the logic brittle and largely incompatible with large swathes of the code-base. The hacky implementation of "$@" is a good example of this.

* Implement behavior for shell opt flags
