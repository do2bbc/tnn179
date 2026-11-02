# tnn179afu61

## Hostmode monitor

With `M A` (or `M IUSCF`), the hostmode monitor forwards complete NET/ROM
headers, including ConReq, ConAck, DiscReq, DiscAck and InfoAck packets
without application payload. TNT can decode these with `:layer3 on`.
Header-only monitoring without `F` remains unchanged.

Run the focused monitor regression test with:

```sh
sh tests/monitor-hostmode.sh
```
