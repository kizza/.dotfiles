# export CLOUDSDK_ROOT_DIR="/path/to/google/cloud/sdk/"
# export APPENGINE_HOME="${CLOUDSDK_ROOT_DIR}/platform/appengine-java-sdk"
# export GAE_SDK_ROOT="${CLOUDSDK_ROOT_DIR}/platform/google_appengine"
export APPENGINE_HOME="/Applications/GoogleAppEngineLauncher.app/Contents/Resources/GoogleAppEngine-default.bundle/Contents/Resources/google_appengine"

# The next line enables Java libraries for Google Cloud SDK
export CLASSPATH="${APPENGINE_HOME}/lib":${CLASSPATH}

# The next line enables Python libraries for Google Cloud SDK
# export PYTHONPATH=${GAE_SDK_ROOT}:${PYTHONPATH}
export RWORKFLOW="/Users/keiran.oleary/Keiran/routine-workflow"
# export PYTHONPATH=${APPENGINE_HOME}:${RWORKFLOW}:${RWORKFLOW}/tests:${PYTHONPATH}

# export PYTHONPATH="${RWORKFLOW}:${RWORKFLOW}/tests:${PYTHONPATH}"

# NVM
export NVM_DIR="/Users/keiran.oleary/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Auto load nvmrc files
autoload -U add-zsh-hook
load-nvmrc() {
  if [[ -f .nvmrc && -r .nvmrc ]]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc
