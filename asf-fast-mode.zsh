#!/usr/bin/zsh

ASF_AUTH=${ASF_AUTH:-''}
ASF_BOT=${ASF_BOT:-''}
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

retries=0
while :; do

	# Find games with available card drops
	log "Checking for games with remaining card drops"
	cmd resume $ASF_BOT
	sleep 10 # Wait for updated card counts
	cmd pause $ASF_BOT
	appids=$(get bot/$ASF_BOT |
		jq -S ".Result.${ASF_BOT}.CardsFarmer.GamesToFarm|.[]|.AppID")
	if [[ -z $appids ]]; then
		# If we get no matches, retry later in case it's just an error
		(( retries++ < 3)) || break
		log "No games to idle. Retrying in 10 minutes..."
		sleep 600
		continue
	fi
	retries=0
	log "Found $(wc -l <<<$appids) games to idle"

	# Limit to 32 games at a time (the Steam network's limit)
	appids=$(head -n32 <<<$appids)

	# Idle games simultaneously for 30 minutes
	log "Idling $(wc -l <<<$appids) games for 30 minutes"
	cmd play $ASF_BOT ${(j.,.)${(f)appids}}
	sleep 1800

	# Pause for 1 minute
	log "Pausing for 1 minute"
	cmd reset
	sleep 60

	# Idle individually for 10 seconds
	while read -r appid; do
		log "Idling $appid for 10 seconds"
		cmd play $ASF_BOT $appid
		sleep 10
	done <<<$appids

done

log "Done!"
