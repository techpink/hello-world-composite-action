#!/usr/bin/env bash
set -e

# clean multiline text to be passed to Github API
function clean_multiline_text {
  local -r input="$1"
  local output
  output="${input//'%'/'%25'}"
  output="${output//$'\n'/'%0A'}"
  output="${output//$'\r'/'%0D'}"
  echo "${output}"
}

function main {
  local -r patcher_env_folder=${INPUT_ENV_FOLDER}

  chmod +x /tmp/patcher
  cd ${patcher_env_folder}
  /tmp/patcher update --non-interactive --update-strategy next-breaking --no-color | tee /tmp/patcher-output.txt

  csplit -k /tmp/patcher-output.txt -f patcher '/^manual_steps_you_must_follow/' || true

  local patcher_action_updates
  patcher_action_updates=$(clean_multiline_text "$( tail -n +2 patcher00 )")
  echo "patcher_action_updates=${patcher_action_updates}" >> "${GITHUB_OUTPUT}"
  rm patcher00
  
  [[ -f patcher01 ]] || echo '\nNo manual steps are required\n' >> patcher01
  local patcher_action_manual_steps
  patcher_action_manual_steps=$(clean_multiline_text "$( tail -n +2 patcher01 )")
  echo "patcher_action_manual_steps=${patcher_action_manual_steps}" >> "${GITHUB_OUTPUT}"
  rm patcher01  
}

main "$@"
