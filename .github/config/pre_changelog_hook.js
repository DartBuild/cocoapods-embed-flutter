const path = require('path');
const fs = require('fs');
const semver = require('semver');
const core = require('@actions/core');
const childProcess = require("child_process");

exports.preVersionGeneration = (version) => {
  const { GITHUB_WORKSPACE } = process.env;
  core.info(`Computed version bump: ${version}`);

  const gem_info_file = path.join(GITHUB_WORKSPACE, 'lib/cocoapods-embed-flutter/gem_version.rb');
  const gem_info = `${fs.readFileSync(gem_info_file)}`;
  core.info(`Current gem info: ${gem_info}`);

  currentVersion = gem_info.match(/VERSION\s*=\s'(.*)'/)[1];
  core.info(`Current version: ${currentVersion}`);

  if (semver.lt(version, currentVersion)) { version = currentVersion; }
  core.info(`Final version: ${version}`);

  const new_gem_info = gem_info.replace(/VERSION\s*=\s*.*/g, `VERSION = '${version}'.freeze`);
  core.info(`Updated gem info: ${new_gem_info}`);
  fs.writeFileSync(gem_info_file, new_gem_info);

  const launchOption = {
    cwd: GITHUB_WORKSPACE,
    env: Object.assign({}, process.env, { 'LANG': 'en_US.UTF-8' })
  };

  childProcess.execSync('bundle config unset deployment', launchOption);
  childProcess.execSync('bundle install', launchOption);
  childProcess.execSync('bundle exec rake demo', launchOption);
  childProcess.execSync('bundle config deployment true', launchOption);
  return version;
}

exports.preTagGeneration = (tag) => { }