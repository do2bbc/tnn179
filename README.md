# tnn179afu61

## Portable Windows CB test build

The `Windows portable CB test package` GitHub workflow builds on pull
requests, `v*` tags, manual dispatch and published releases. On publication
it attaches the portable ZIP and SHA-256 checksum to that release. Build,
ABI, regression and Wine diagnostic checks must pass before upload.
Artifacts are explicitly XP-unverified; actual XP/hardware testing is still
required. Publishing a release does not certify Windows XP compatibility.

To reproduce the release package from a committed revision on Linux:

```sh
xvfb-run -a sh tests/package-win32.sh /absolute/path/to/output
```

Dependencies: MinGW-w64 i686 GCC/G++, native GCC, make, zip/unzip, Perl,
Wine with 32-bit support, and Xvfb. The script packages only `git archive
HEAD`, enables the CB/HOSTMYCALL options in that source snapshot, includes
the exact source and license, and never copies local node settings/state.

The Win32 port can be cross-compiled with MinGW-w64 in a separate source
copy (do not mix Linux and Windows object files):

```sh
make -f tnn32.mak all PREFIX=i686-w64-mingw32-
```

No system-header modifications or `hardpatch` step are required. The result
is a 32-bit console executable targeting Windows API/subsystem 5.1 and
MSVCRT, with compiler runtimes linked statically. This targets Windows XP,
but a Wine smoke test is **not** certification on real XP.

Use the neutral files in [os/win32/portable](os/win32/portable) for a
portable package, not the historical saved node state. The offline example
has no active ports or peers and uses public test passwords. Change both
passwords and the node identity before enabling an interface. The CB build
requires `DISABLECALLCHECK` in `include/allmodif.h`; `HOSTMYCALL` is also
enabled in the Pi-equivalent CB configuration. The Win32 banner identifies
this setting as `(CB)` while retaining the upstream version lineage.

Include `alas.txt` and the complete matching source when distributing the
package. See the portable README for available interfaces and hardware-test
limitations. Linux kernel AX.25 and ISA-card drivers are not included.
The obsolete `pfhadd` target points to DOS/Linux parallel-port I/O code and
is excluded from the Windows utilities.

Run `sh tests/irc-name.sh` to check the bounded IRC login name copy, including
both USER-before-NICK and NICK-before-USER, under ASan/UBSan.
After a Windows build, run `sh tests/win32-build.sh` to check signed TNN types,
the 32-bit ABI, the XP subsystem version and system-only DLL dependencies.
These checks do not replace execution on the intended Windows version.

The Windows package writes bounded, content-free `tnn-runtime.log` and
`tnn-crash.log` files in its start directory; see the portable README for
rotation, privacy and limitations. No automatic uploads or restarts occur.
The existing legacy debug/startup logs are separate and may contain data.
The isolated diagnostic harness can be built with:

```sh
i686-w64-mingw32-gcc -DWIN32 -D_WIN32_WINNT=0x0501 -DWINVER=0x0501 \
  -Iinclude -Ios/win32 -Ios/linux -Isrc -static \
  -Wl,--subsystem,console:5.01 tests/win32-diagnostics.c \
  os/win32/diagnostics.c -o diagnostics-test.exe
```

In an empty test directory, run the harness with `clean`, `error`, `unclean`,
`heartbeat` (61 seconds), `signal` or `exception`. The last two deliberately
terminate the harness, not a running node. Check diagnostic file contents
and `.previous.log` rotation. Keep the matching executable and source for
interpreting exception addresses; a text report is not a stack trace.

## Hostmode monitor

With `M A` (or `M IUSCF`), the hostmode monitor forwards complete NET/ROM
headers, including ConReq, ConAck, DiscReq, DiscAck and InfoAck packets
without application payload. TNT can decode these with `:layer3 on`.
Header-only monitoring without `F` remains unchanged.

Run the focused monitor regression test with:

```sh
sh tests/monitor-hostmode.sh
```
