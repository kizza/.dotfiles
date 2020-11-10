# Watch files and execute cmd on change
watch () {
  if [[ ! $(gem list filewatcher -i) == "true" ]]; then  # Install filewatcher if not present
    gem install filewatcher
  fi

  glob="$1"
  cmd="$2"

  # Easy globbing (eg. "js" => "./**/*.js")
  if [[ ${#glob} == 2 ]]; then
    glob="./**/*.$glob"
  fi

  # Easy js testing eg. watch js
  if [[ $glob == *".js" ]]; then
    if [ -z "$2"  ]; then
      cmd="npm test"
    fi
  fi

  # Easy ruby testing eg. watch path/to/file_spec.rb
  if [[ $1 == *".rb" ]]; then
    glob="./**/*.rb"

    if [ -z "$2"  ]; then
      cmd="bin/rake test $1"
      if [[ $1 == *"_spec.rb" ]]; then
        cmd="bin/rspec $1"
      fi
    fi
    echo "$cmd"
  fi

  echo "Will run \"$cmd\" when $glob changes..."
  filewatcher "$glob" "$cmd"
}

