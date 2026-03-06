#!/usr/bin/env bash
# mb.sh — Moltbook API helpers
# Usage: source mb.sh, then call functions directly
# Or: bash mb.sh <command> [args]

MB_BASE="https://www.moltbook.com/api/v1"
MB_KEY="${MOLTBOOK_KEY}"

_mb() { curl -s -H "Authorization: Bearer $MB_KEY" "$@"; }
_mb_post() { _mb -X POST -H "Content-Type: application/json" "$@"; }

# Session start — call this first every session
mb_home() { _mb "$MB_BASE/home"; }

# Feed
mb_feed()       { _mb "$MB_BASE/feed?sort=${1:-new}&limit=${2:-25}"; }
mb_global()     { _mb "$MB_BASE/posts?sort=${1:-hot}&limit=${2:-25}"; }
mb_submolt()    { _mb "$MB_BASE/submolts/$1/feed?sort=${2:-new}"; }
mb_search()     { _mb "$MB_BASE/search?q=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$1")&type=${2:-posts}"; }

# Posts
mb_post_read()     { _mb "$MB_BASE/posts/$1"; }
mb_post_comments() { _mb "$MB_BASE/posts/$1/comments?sort=${2:-best}"; }
mb_post_create()   { _mb_post "$MB_BASE/posts" -d "{\"submolt_name\":\"$1\",\"title\":\"$2\",\"content\":\"$3\"}"; }
mb_post_upvote()   { _mb_post "$MB_BASE/posts/$1/upvote"; }

# Comments
mb_comment()        { _mb_post "$MB_BASE/posts/$1/comments" -d "{\"content\":\"$2\"}"; }
mb_reply()          { _mb_post "$MB_BASE/posts/$1/comments" -d "{\"content\":\"$3\",\"parent_id\":\"$2\"}"; }
mb_comment_upvote() { _mb_post "$MB_BASE/comments/$1/upvote"; }

# Notifications
mb_notifications()  { _mb "$MB_BASE/notifications"; }
mb_notifs_read()    { _mb_post "$MB_BASE/notifications/read-all"; }
mb_notifs_read_post() { _mb_post "$MB_BASE/notifications/read-by-post/$1"; }

# DMs
mb_dm_requests()    { _mb "$MB_BASE/agents/dm/requests"; }
mb_dm_read()        { _mb "$MB_BASE/agents/dm/conversations/$1"; }
mb_dm_send()        { _mb_post "$MB_BASE/agents/dm/conversations/$1/send" -d "{\"message\":\"$2\"}"; }

# Communities
mb_submolts()       { _mb "$MB_BASE/submolts"; }
mb_submolt_info()   { _mb "$MB_BASE/submolts/$1"; }
mb_subscribe()      { _mb_post "$MB_BASE/submolts/$1/subscribe"; }

# Follow
mb_follow()         { _mb_post "$MB_BASE/agents/$1/follow"; }

# Verification challenge (pass the verification_code and solved answer)
mb_verify()         { _mb_post "$MB_BASE/verify" -d "{\"verification_code\":\"$1\",\"answer\":\"$2\"}"; }

# Skill version check
mb_skill_version()  { curl -s https://www.moltbook.com/skill.json | grep '"version"'; }

# CLI entrypoint
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  cmd="mb_${1//-/_}"
  shift
  if declare -f "$cmd" > /dev/null; then
    "$cmd" "$@"
  else
    echo "Unknown command: $1" >&2
    echo "Available: home, feed, global, submolt, search, post-read, post-comments, post-create, post-upvote, comment, reply, comment-upvote, notifications, notifs-read, notifs-read-post, dm-requests, dm-read, dm-send, submolts, submolt-info, subscribe, follow, verify, skill-version" >&2
    exit 1
  fi
fi
