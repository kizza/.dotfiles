function redb {
  SECONDS=0

  BACKUP_ID=$(ls tmp/db | tail -n 1 | sed 's/.dump//') rails db:anon:load && notify "Restored" "Database has been restored"

  minutes=$((SECONDS / 60))
  seconds=$((SECONDS % 60))
  donetick "Completed in ${minutes} minutes and ${seconds} seconds"
}

function branch_migrations() {
  since_master | egrep '^db/migrate'
}

function keep_up() {
  "$@"
  # if [[ $? -eq 1 ]]; then
    echo "Server crashed $?, restarting..."
    notify "Server crashed" "Restarting..."
    "$@"  # Re-run the original command
  # fi
}

function freshen_migrations() {
  MIGRATIONS=$(since_master | egrep '^db/migrate')
  if [ -z "$MIGRATIONS" ]; then
    echo "No migrations to freshen"
    return 0
  fi

  echo $MIGRATIONS | while read -r migration ; do
    # Wait a second, to ensure sequence of freshed migrations
    current_time=$(date +%s); while [[ $(date +%s) -eq $current_time ]]; do :; done
    freshen_migration "$migration"
  done
}

function rollback_branch() {
  MIGRATIONS=$(since_master | egrep '^db/migrate')
  if [ -z "$MIGRATIONS" ]; then
    echo "No migrations to rollback"
    return 0
  fi

  MIGRATIONS_COUNT=$(echo $MIGRATIONS | wc -l)
  REVERT_COUNT=$(($MIGRATIONS_COUNT + 1))
  VERSIONS=$(git ls-tree -r --name-status HEAD db/migrate | tail -$REVERT_COUNT)
  VERSION=$(echo $VERSIONS | head -1 | cut -d'_' -f 1 | cut -d/ -f3)
  # CURRENT_VERSION=$(rails runner 'ActiveRecord::Migrator.current_version')

  heading "Rolling back $MIGRATIONS_COUNT migrations"
  echo $MIGRATIONS
  rails db:migrate VERSION=$VERSION
  git discard db/structure.sql
  exitcode
}

function without_tenant() {
  rails runner 'ActsAsTenant.without_tenant { binding.pry }'
}
