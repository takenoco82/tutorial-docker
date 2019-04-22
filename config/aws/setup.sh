#!/bin/bash
#
# AWS EC2 Amazon Linuxをセットアップする
#
# USAGE
#   sh {SCRIPT_FILENAME} -h
#
# REMARKS
#   https://qiita.com/2no553/items/e166c00790c3397acf2d
#   https://qiita.com/shinespark/items/a8019b7ca99e4a30d286
#

# bashのスイッチ
set -eux

#
# 関数定義
#
# タイムゾーンを変更する
function change_timezone() {
  # 変更前の設定確認
  echo $(date) >&2

  # ローカルタイムを Japan に変更
  sudo ln -sf /usr/share/zoneinfo/Japan /etc/localtime

  # ハードウェアクロックを Japan に変更
  sudo sed -i "s/\"UTC\"/\"Japan\"/g" /etc/sysconfig/clock

  # 変更後の設定確認
  echo $(date) >&2
}

# 文字コードを日本語に変更する
function change_locale() {
  sudo sed -i "s/en_US\.UTF-8/ja_JP\.UTF-8/g" /etc/sysconfig/i18n
}

# dockerをインストールする
function install_docker() {
  sudo yum update -y
  sudo yum install -y docker

  # docker サービスを起動する
  sudo service docker start

  # ec2-user を docker グループに追加する
  # NOTE: 一度 exit する必要がある
  sudo usermod -a -G docker $USER
}

# docker-composeをインストールする
function install_docker_compose() {
  set +x
  docker-compose --version &> /dev/null
  exit_status=$?
  set -x
  if [[ $exit_status -ne 0 ]]; then
      curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m) \
        -o docker-compose
      sudo mv docker-compose /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose
  fi
}

#
# メイン処理
#
change_timezone
change_locale
install_docker
install_docker_compose
