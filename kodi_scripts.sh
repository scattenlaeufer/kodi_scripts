# A colleciton of functions to trigger watching videos on kodi

server="192.168.178.40"
port="8080"
download_dir="/media/youtube"
kodi_dir="/storage/luke/youtube"

function kodi_buffer_play(){
	get_link "$@"
	buffer_video
	play_json
	play_video
}

function kodi_buffer_add_to_playlist(){
	get_link "$@"
	buffer_video
	add_to_playlist_json
	play_video
}

function kodi_play(){
	get_link "$@"
	get_video_link
	play_json
	play_video
}

function get_link(){
	if [ $# -eq 0 ]
	then
		link="$(xclip -o)"
	else
		link="$1"
	fi
}

function buffer_video() {
	file_name="$(youtube-dl --get-filename --format "bestvideo[height<=?1440]+bestaudio" --merge-output-format "mkv" --output "%(id)s.%(ext)s" --geo-bypass "$link")"
	video_path="$kodi_dir/$file_name"
	youtube-dl --format "bestvideo[height<=?1440]+bestaudio" --merge-output-format "mkv" --geo-bypass --output "$download_dir/$file_name" "$link"
}

function get_video_link(){
	link="$(xclip -o)"
	video_path="$(youtube-dl -g -f 'best' "$link" || echo "$link")"
}

function play_json(){
	json_query='{"jsonrpc":"2.0","id":"1","method":"Player.Open","params":{"item":{"file":"'"$video_path"'"}}}'
}

function add_to_playlist_json(){
	json_query='{"jsonrpc":"2.0","id":"1","method":"Playlist.Add","params":{"playlistid":1,"item":[{"file":"'"$video_path"'"}]}}'
}

function play_video() {
	curl -s --data-binary "$json_query" -H 'content-type: application/json;' http://$server:$port/jsonrpc
}
