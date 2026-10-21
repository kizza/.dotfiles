# A lean Trello client over the REST API (https://developer.atlassian.com/cloud/trello/rest/).
#
# Credentials live in 1Password; `trello login` copies them into the macOS Keychain, because an agent's
# shell can't get 1Password's biometric approval but can read the Keychain.

keychain_service="trello-cli"
op_item="${TRELLO_OP_ITEM:-Trello CLI}" # its username is the API key, its credential the token

usage() {
  cat <<'EOF'
Usage: trello <command> [args]

  login                              Copy the API key and token from 1Password into the Keychain
  boards                             Your open boards
  lists <board>                      A board's open lists
  cards <board> [list]               Open cards on a board, or in one of its lists
  card <card>                        A card's details and comments
  comment <card> <text>              Add a comment to a card
  move <card> <list> [--board <b>]   Move a card to a list, on its own board or on <b>
  create <board> <list> <name> [description]
  api <METHOD> <path> [key=value...] Any other endpoint; prints the raw JSON

<board> and <card> take a trello.com URL, a shortlink or an id. <list> takes a list's name
(case-insensitive, unique substring) or its id.
EOF
}

login() {
  local key token
  key="$(op item get "$op_item" --fields username --reveal)"
  token="$(op item get "$op_item" --fields credential --reveal)"
  security add-generic-password -U -s "$keychain_service" -a key -w "$key"
  security add-generic-password -U -s "$keychain_service" -a token -w "$token"
  echo "Stored the Trello key and token in the Keychain."
}

credential() {
  security find-generic-password -s "$keychain_service" -a "$1" -w 2>/dev/null || {
    echo "No Trello credentials in the Keychain; run \`trello login\` in an interactive shell." >&2
    exit 1
  }
}

# api METHOD PATH [key=value...] — GET sends the pairs as a query, everything else as a form body.
api() {
  local method="$1" path="$2"
  shift 2

  local fields=()
  for pair in "$@"; do fields+=(--data-urlencode "$pair"); done

  local key token
  key="$(credential key)"
  token="$(credential token)"
  local authorization="OAuth oauth_consumer_key=\"$key\", oauth_token=\"$token\""

  local request=(-X "$method")
  [[ "$method" == GET ]] && request=(-G)

  # Trello explains a failure in the body ("invalid key", "invalid id"), so print it rather than the status.
  local response
  response="$(curl -sS --fail-with-body "${request[@]}" -H "Authorization: $authorization" \
    "https://api.trello.com/1$path" "${fields[@]}")" || {
    echo "Trello $method $path failed: $response" >&2
    exit 1
  }

  echo "$response"
}

# A URL's shortlink, or the argument unchanged when it is already a shortlink or an id.
identifier() {
  [[ "$1" =~ trello\.com/[bc]/([^/?#]+) ]] && { echo "${BASH_REMATCH[1]}"; return; }

  echo "$1"
}

# list_id BOARD LIST — a list id from its name, matched exactly then as a unique substring.
list_id() {
  local lists
  lists="$(api GET "/boards/$1/lists" fields=name filter=open)"

  jq -r --arg want "$2" '
    (map(select(.id == $want or (.name | ascii_downcase) == ($want | ascii_downcase)))) as $exact
    | (map(select(.name | ascii_downcase | contains($want | ascii_downcase)))) as $partial
    | if ($exact | length) == 1 then $exact[0].id
      elif ($partial | length) == 1 then $partial[0].id
      else empty end' <<<"$lists" | grep . || {
    echo "No single list matches \"$2\"; the lists are:" >&2
    jq -r '.[].name | "  " + .' <<<"$lists" >&2
    exit 1
  }
}

boards() {
  api GET /members/me/boards filter=open fields=name,shortLink,dateLastActivity |
    jq -r 'sort_by(.dateLastActivity) | reverse | .[] | "\(.shortLink)\t\(.name)"'
}

lists() {
  api GET "/boards/$(identifier "$1")/lists" filter=open fields=name |
    jq -r '.[] | "\(.id)\t\(.name)"'
}

cards() {
  local board
  board="$(identifier "$1")"

  if [[ $# -gt 1 ]]; then
    local list
    list="$(list_id "$board" "$2")"
    api GET "/lists/$list/cards" fields=name,shortLink,due |
      jq -r '.[] | "\(.shortLink)\t\(.name)\(if .due then "\tdue \(.due[:10])" else "" end)"'
    return
  fi

  api GET "/boards/$board/lists" filter=open cards=open card_fields=name,shortLink fields=name |
    jq -r '.[] | "## \(.name)", (.cards[] | "\(.shortLink)\t\(.name)"), ""'
}

card() {
  local card
  card="$(identifier "$1")"

  api GET "/cards/$card" fields=name,desc,url,due,dueComplete,labels list=true members=true member_fields=fullName |
    jq -r '"\(.name)\n\(.url)\nList: \(.list.name)",
      (if .due then "Due: \(.due[:10])\(if .dueComplete then " (complete)" else "" end)" else empty end),
      (if (.labels | length) > 0 then "Labels: \(.labels | map(.name // .color) | join(", "))" else empty end),
      (if (.members | length) > 0 then "Members: \(.members | map(.fullName) | join(", "))" else empty end),
      (if .desc != "" then "\n\(.desc)" else empty end)'

  api GET "/cards/$card/actions" filter=commentCard |
    jq -r 'if length > 0 then "\n## Comments" else empty end,
      (reverse | .[] | "\n\(.memberCreator.fullName), \(.date[:10]):\n\(.data.text)")'
}

comment() {
  api POST "/cards/$(identifier "$1")/actions/comments" text="$2" >/dev/null
  echo "Commented."
}

move() {
  local card board="" list
  card="$(identifier "$1")"
  # A write takes the board's full id, never the shortlink a URL carries.
  [[ "${3:-}" == --board ]] && board="$(api GET "/boards/$(identifier "$4")" fields=id | jq -r .id)"
  [[ -n "$board" ]] || board="$(api GET "/cards/$card" fields=idBoard | jq -r .idBoard)"
  list="$(list_id "$board" "$2")"

  api PUT "/cards/$card" idBoard="$board" idList="$list" pos=top |
    jq -r '"Moved \"\(.name)\"."'
}

create() {
  local list
  list="$(list_id "$(identifier "$1")" "$2")"

  api POST /cards idList="$list" name="$3" desc="${4:-}" pos=top |
    jq -r '"Created \(.shortUrl)"'
}

command="${1:-}"
[[ $# -gt 0 ]] && shift

case "$command" in
  login) login ;;
  boards) boards ;;
  lists) lists "$@" ;;
  cards) cards "$@" ;;
  card) card "$@" ;;
  comment) comment "$@" ;;
  move) move "$@" ;;
  create) create "$@" ;;
  api) api "$@" ;;
  *) usage ;;
esac
