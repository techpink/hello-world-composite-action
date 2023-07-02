#!/usr/bin/env bash
set -e

function main {
  local -r patcher_env_folder=${INPUT_ENV_FOLDER}

  chmod +x /tmp/patcher
  cd ${patcher_env_folder}
  /tmp/patcher update --non-interactive --update-strategy next-breaking --no-color | tee /tmp/patcher-output.txt

  csplit -k /tmp/patcher-output.txt -f patcher '/^manual_steps_you_must_follow/' || true

  EOF=$(dd if=/dev/urandom bs=15 count=1 status=none | base64)
  echo "patcher_action_updates<<$EOF" >> "${GITHUB_OUTPUT}"
  echo "$( tail -n +2 patcher00 )" >> "${GITHUB_OUTPUT}"
  echo "$EOF" >> "${GITHUB_OUTPUT}"
  rm patcher00
  
  [[ -f patcher01 ]] || echo '\nNo manual steps are required\n' >> patcher01
  echo "patcher_action_manual_steps<<$EOF" >> "${GITHUB_OUTPUT}"
  echo "$( tail -n +2 patcher01 )" >> "${GITHUB_OUTPUT}"
  echo "$EOF" >> "${GITHUB_OUTPUT}"
  rm patcher01  
}

main "$@"
