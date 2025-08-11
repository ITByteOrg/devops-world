#!/usr/bin/env bash
# --------------------------------------------------------------------
# File: post-checkout.sh
#
# Description:
#   Git post-checkout hook triggered after a successful branch switch
#   or file checkout. Can be used to reinitialize context, emit logs,
#   or conditionally run post-checkout tasks (e.g., tooling refresh).
#
# Dependencies:
#   - shared-utils.sh: structured logging
#   - PostCheckoutActions.sh (optional): branch-specific logic
#
# Usage:
#   Place in .git/hooks/post-checkout (or symlink if using core.hooksPath)
# --------------------------------------------------------------------

# Initialize
GIT_ROOT="$(git rev-parse --show-toplevel)"
source "$GIT_ROOT/scripts/modules/shared-utils.sh"

# Extract arguments (passed by Git automatically)
PREV_HEAD="$1"
NEW_HEAD="$2"
IS_BRANCH_SWITCH="$3"

write_stdlog "Post-checkout hook triggered for ref $NEW_HEAD" info

# Optional: custom logic per branch
if [[ "$IS_BRANCH_SWITCH" == "1" ]]; then
  write_stdlog "Branch switch detected from $PREV_HEAD to $NEW_HEAD" success
  # Optional: source extra logic
  # source "$GIT_ROOT/scripts/modules/PostCheckoutActions.sh"
  # run_post_checkout_tasks "$NEW_HEAD"
else
  write_stdlog "File checkout occurred; no branch change." ok
fi

exit 0
