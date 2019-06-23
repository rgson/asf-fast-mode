#!/usr/bin/zsh

ASF_AUTH=${ASF_AUTH:-''}
ASF_BOT=${ASF_BOT:-'bot'}
ASF_URL=${ASF_URL:-'http://localhost:1242'}

terminate() { exit 0; }
trap terminate INT TERM

log() { echo "[$(date -Is)] $@"; }

get() {
	curl -s -H "Authentication: $ASF_AUTH" $ASF_URL/Api/$1
	echo
}
post() {
	curl -H "Authentication: $ASF_AUTH" -X POST $ASF_URL/Api/$1 -d ''
	echo
}
cmd() {
	log CMD: $@
	post "command/${(j.%20.)@}"
}

# Start bot without automatically idling
cmd start $ASF_BOT
cmd pause $ASF_BOT
sleep 1 # TODO: handle 'not connected' error after start (delayed login?)

#while :; do

	# Find games with available card drops
	log "Checking for games with remaining card drops"
	appids=$(get bot/$ASF_BOT |
		jq -S ".Result.${ASF_BOT}.CardsFarmer.GamesToFarm|.[]|.AppID")
	log "Found $(wc -l <<<$appids) games to idle"

	# Limit to 32 games at a time (the Steam network's limit)
	appids=$(head -n32 <<<$appids)

	# Idle games simultaneously for 30 minutes
	log "Idling $(wc -l <<<$appids) games for 30 minutes"
	cmd play $ASF_BOT ${(j.,.)${(f)appids}}
	sleep 10 #1800

	# Pause for 1 minute
	log "Pausing for 1 minute"
	cmd play $ASF_BOT 1111 # Work-around, no manual-mode pause command
	sleep 10 # 60

	# Idle individually for 10 seconds
	while read -r appid; do
		log "Idling $appid for 10 seconds"
		cmd play $ASF_BOT $appid
		sleep 10
	done <<<$appids

#done
