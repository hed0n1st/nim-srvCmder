# nim-srvCmder

Requires the fantastic wNim

```
nimble install wNim
```

srvCmder can be run as admin, because :

```
execProcess(
  "net",
  args=[...],
  options={...}
)
```

UAC will ask permission if run without privileges

This application resides in systray and is accessible via right-click.
