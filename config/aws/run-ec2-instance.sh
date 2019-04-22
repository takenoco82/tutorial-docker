#!/bin/bash
#
# AWS EC2 インスタンスを作成する
#
# USAGE
#   sh {SCRIPT_FILENAME} -h
#
# REMARKS
#   https://qiita.com/predora005/items/a1527aa58066fab7e9ad
#

# bashのスイッチ
set -eu

#
# グローバル定数
#
# リージョン
readonly REGION=ap-northeast-1

#
# グローバル変数
#
# AMI
IMAGE_ID=ami-00a5245b4816c38e6
# インスタンスタイプ
INSTANCE_TYPE=t2.micro
# キーペア
KEY_NAME=aws
# サブネット
SUBNET_ID=subnet-09a64d0ed3113814f
# セキュリティグループ
SECURITY_GROUP_IDS=sg-0d5bfae9d9ac50dc3
# T2/T3 無制限
CPU_CREDITS=standard
# タグ
TAG_NAME=tutorial-docker
# aws ec2 run-instances の dry run オプション
DRY_RUN_OPTION=
# aws ec2 run-instances を実行の確認をするかどうか
FORCE_OPTION=0
# オプションの設定を対話式に行うかどうか
INTERACTIVE_OPTION=0

#
# 関数定義
#
function usage() {
  cat <<-EOS >&2
	Usage: sh $(basename "$0") [OPTIONS]

	  DESCRIPTION
	    AWS EC2 インスタンスを作成する

	  OPTIONS
	    -f    run without prompting for confirmation
	    -i    specify options interactively
	    -d    dry run
	    -h    this help
	EOS
}

# オプションを対話式に設定する
function set_options() {
  local interactive_option=$1

  if [[ $interactive_option -eq 0 ]]; then
    return
  fi

  read -p "Image ID of the AMI? [${IMAGE_ID}]: " answer && \
    [[ "$answer" == "" ]] || IMAGE_ID=$answer

  read -p "Instance type? [${INSTANCE_TYPE}]: " answer && \
    [[ "$answer" == "" ]] || INSTANCE_TYPE=$answer

  read -p "Name of the key pair? [${KEY_NAME}]: " answer && \
    [[ "$answer" == "" ]] || KEY_NAME=$answer

  read -p "ID of the subnet? [${SUBNET_ID}]: " answer && \
    [[ "$answer" == "" ]] || SUBNET_ID=$answer

  read -p "IDs of the security groups? [${SECURITY_GROUP_IDS}]: " answer && \
    [[ "$answer" == "" ]] || SECURITY_GROUP_IDS=$answer

  read -p "Credit option for CPU usage of the instance? [${CPU_CREDITS}]: " answer && \
    [[ "$answer" == "" ]] || CPU_CREDITS=$answer

  read -p "Name Tag of the instance? [${TAG_NAME}]: " answer && \
    [[ "$answer" == "" ]] || TAG_NAME=$answer
}

# インスタンスを作成するかどうか確認する
# 引数: FORCE_OPTION
function yes_or_no() {
  local force_option=$1

  if [[ $force_option -eq 1 ]]; then
    return 0
  fi

  while true; do
    read -p "Run EC2 instance? [Y/n]: " answer
    case $answer in
      Y|y) return 0 ;;
      N|n) return 1 ;;
      *) echo "Answer Yes or No.\n" ;;
    esac
  done
}

# インスタンスを作成する
# 引数: DRY_RUN_OPTION
function run_instance() {
  local dry_run_option=$1

  aws ec2 run-instances ${dry_run_option} \
    --region ${REGION} \
    --image-id ${IMAGE_ID} \
    --count 1 \
    --instance-type ${INSTANCE_TYPE} \
    --key-name ${KEY_NAME} \
    --subnet-id ${SUBNET_ID} \
    --security-group-ids ${SECURITY_GROUP_IDS} \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${TAG_NAME}}]" \
    --credit-specification CpuCredits=${CPU_CREDITS}
}

#
# 引数parse処理
#
function parse_args() {
  while getopts ":fidh" opt; do
    case $opt in
      f) FORCE_OPTION=1 ;;
      i) INTERACTIVE_OPTION=1 ;;
      d) DRY_RUN_OPTION=" --dry-run " ;;
      h) usage; exit 0 ;;
      *) usage; exit 1 ;;
    esac
  done

  shift $((OPTIND - 1))
}

#
# メイン処理
#
parse_args $@
set_options $INTERACTIVE_OPTION
yes_or_no $FORCE_OPTION || exit 1
run_instance "$DRY_RUN_OPTION"
