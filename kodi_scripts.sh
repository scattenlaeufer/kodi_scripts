# A colleciton of functions to trigger watching videos on kodi

server="192.168.178.40"
port="8080"
download_dir="/media/youtube"

function kodi_buffer_play(){
	get_link "$@"
	buffer_video
	play_video
}

function kodi_play(){
	get_link "$@"
	get_video_link
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
	video_path="$download_dir/$(youtube-dl --get-filename --format "bestvideo[height<=?1440]+bestaudio/best" --geo-bypass "$link")"
	youtube-dl --format "bestvideo[height<=?1440]+bestaudio/best" --geo-bypass --output "$video_path" "$link"
}

function get_video_link(){
	link="$(xclip -o)"
	video_path="$(youtube-dl -g -f 'best' "$link" || echo "$link")"
}

function play_video() {
  curl -s --data-binary\
    '{"jsonrpc":"2.0","id":"1","method":"Player.Open","params":{"item":{"file":"'"$video_path"'"}}}'\
    -H 'content-type: application/json;' http://$server:$port/jsonrpc

}
