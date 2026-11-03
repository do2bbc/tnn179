#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
tmp=$(mktemp -d)
trap 'rm -f "$tmp/test.c" "$tmp/test"; rmdir "$tmp"' EXIT HUP INT TERM
cat > "$tmp/test.c" <<'EOF'
#include <assert.h>
#include <string.h>
struct connection {
  char name[17];
  unsigned char sentinel[16];
  char nickname[64];
};
static void copy_name(struct connection *cp, const char *user)
{
EOF
awk '
  /^  if \(\*cp->nickname\)/ { active = 1 }
  active { print }
  active && /cp->name\[sizeof\(cp->name\) - 1\] = 0;/ {
    found = 1
    exit
  }
  END { if (!found) exit 1 }
' src/l1irc.c >> "$tmp/test.c"
cat >> "$tmp/test.c" <<'EOF'
}
int main(void)
{
  struct connection cp;
  char user[128];
  memset(&cp, 0, sizeof(cp));
  memset(cp.sentinel, 0xa5, sizeof(cp.sentinel));
  memset(user, 'u', sizeof(user) - 1);
  user[sizeof(user) - 1] = 0;
  for (int nick = 0; nick < 2; ++nick) {
    if (nick) {
      memset(cp.nickname, 'n', sizeof(cp.nickname) - 1);
      cp.nickname[sizeof(cp.nickname) - 1] = 0;
    }
    copy_name(&cp, user);
    assert(strlen(cp.name) == sizeof(cp.name) - 1);
    for (unsigned i = 0; i < sizeof(cp.name) - 1; ++i)
      assert(cp.name[i] == (nick ? 'n' : 'u'));
    for (unsigned i = 0; i < sizeof(cp.sentinel); ++i)
      assert(cp.sentinel[i] == 0xa5);
  }
  return 0;
}
EOF
${CC:-cc} -std=c11 -Wall -Wextra -Werror -fsanitize=address,undefined \
  "$tmp/test.c" -o "$tmp/test"
"$tmp/test"
