#!/usr/bin/zsh

die() { echo $@ >&2; exit 1; }

[ -n $ASFFM_STEAM_ID     ] || die 'Missing Steam ID (ASFFM_STEAM_ID env variable)'
[ -n $ASFFM_STEAM_LOGIN  ] || die 'Missing Steam login (ASFFM_STEAM_LOGIN env variable)'
[ -n $ASFFM_IPC_PASSWORD ] || ASFFM_IPC_PASSWORD=nXabeli8YZfqhl81

cat >/app/config/ASF.json <<ASF
{
	"s_SteamOwnerID": "${ASFFM_STEAM_ID}",
	"IPC": true,
	"IPCPassword": "${ASFFM_IPC_PASSWORD}"
}
ASF
cat >/app/config/bot.json <<BOT
{
	"Enabled": true,
	"SteamLogin": "${ASFFM_STEAM_LOGIN}",
	"OnlineStatus": 0,
	"IdleRefundableGames": false
}
BOT

asffm() {
	while [ ! -f /app/config/bot.bin ]; do sleep 1; done
	export ASF_BOT=bot
	export ASF_AUTH=$ASFFM_IPC_PASSWORD
	exec ./asf-fast-mode.zsh
}
asffm &

exec ./ArchiSteamFarm.sh --no-restart --process-required --system-required
