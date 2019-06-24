# ASF Fast Mode

A faster way to farm Steam Trading Cards with [ArchiSteamFarm].

ASF Fast Mode is an [ArchiSteamFarm]-based implementation of the
["fast mode"][FastMode] farming algorithm used by e.g. [CardIdleRemastered] and
[IdleMasterExtended]. The goal is to offer equally efficient cards farming
using ASF, for those who prefer ASF (or its superior Linux compatibility) over
the other alternatives.

## Usage

1. [Install and configure ASF][ASF-Setup] (or use the [Docker][ASF-Docker]
   image). At least one bot must be configured, IPC must be enabled and an IPC
   password must be set.
2. Start ASF.
3. Start **ASF Fast Mode** with the appropriate environmental variables set.

### Example

This example runs ASF Fast Mode against an ASF Docker container.

```sh
# Configure ASF
mkdir -p ~/.asf
cat >~/.asf/ASF.json <<ASF
{
  "s_SteamOwnerID": "12345678901234567",
  "IPC": true,
  "IPCPassword": "MyIPCPassword"
}
ASF
cat >~/.asf/MyBot.json <<BOT
{
  "Enabled": true,
  "SteamLogin": "MySteamLogin",
  "OnlineStatus": 0,
  "IdleRefundableGames": false
}
BOT
cat >~/.asf/IPC.config <<IPC
{"Kestrel":{"Endpoints":{"HTTP":{"Url":"http://*:1242"}}}}
IPC

# Start ASF in a Docker container
docker run -it --rm -u $(id -u):$(id -g) \
  -p 127.0.0.1:1242:1242 -p '[::1]:1242:1242' \
  -v $HOME/.asf:/app/config \
  --name asf justarchi/archisteamfarm:master

# Start ASF Fast Mode
ASF_BOT=MyBot ASF_AUTH=MyIPCPassword ./asf-fast-mode.zsh
```

### Prerequisites

ASF Fast Mode is implemented as a `zsh` shell script and thus requires [zsh].
It is easily installed on all mainstream Linux distros.


[ArchiSteamFarm]: https://github.com/JustArchiNET/ArchiSteamFarm
[FastMode]: https://steamcommunity.com/groups/idlemastery/discussions/0/1485487749771924917/#c1485487749771945429
[CardIdleRemastered]: https://github.com/AlexanderSharykin/CardIdleRemastered
[IdleMasterExtended]: https://github.com/JonasNilson/idle_master_extended/releases
[ASF-Setup]: https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Setting-up
[ASF-Docker]: https://github.com/JustArchiNET/ArchiSteamFarm/wiki/Docker
[zsh]: https://en.wikipedia.org/wiki/Z_shell
