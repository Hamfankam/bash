#!/usr/bin/env bash
##!/usr/bin/bash -vx
#
#
# Declare important variables
export RESERVINGDNS_VERSION="0.2.0";
[[ -z $RESERVINGDNS_BASE_DIR ]] && export RESERVINGDNS_BASE_DIR=$(realpath $(dirname $0));

# Execute bootstrap script
source "$RESERVINGDNS_BASE_DIR/include/bootstrap.sh" || { echo "[FATAL ERROR] Bootstrap file not found or contains errors" && exit 1; };
cripto_chek_file

# Declare actions flags
ACTION_MAKE_UPDATE=0;
ACTION_MAKE_RUN=0;
ACTION_MAKE_DELETE=0;
ACTION_MAKE_CAREATA=0;
ACTION_MAKE_CAREATABLE=0;
ACTION_MAKE_INSERT_RCHAT=0;
ACTION_MAKE_DROPTABLE=0;
ACTION_SW_GATEWAY=0;
ACTION_SENDMS_RCHAT=0;
ACTION_SENDMS_MAIL=0;
ACTION_MAKE_FLUSH=0;
ACTION_GET_KEY=0;
ACTION_LKPASS_UPDATE=0;
ACTION_KEYS_CLEAN=0;
ACTION_KEYS_SHOW=0;
ACTION_DISABLE_NETWORK_LIMITS=0;
ACTION_SHOW_HELP=1;
ACTION_SHOW_VERSION=0;

# Check passed options and set actions flags
for arg in "$@"; do
  case $arg in
    '-u'|'--update')           ACTION_SHOW_HELP=0; ACTION_MAKE_UPDATE=1; ACTION_SHOW_STAT=1;;
	'-r'|'--run')              ACTION_SHOW_HELP=0; ACTION_MAKE_RUN=1; ACTION_SHOW_STAT=1;;
	'-del'|'--delete')         ACTION_SHOW_HELP=0; ACTION_MAKE_DELETE=1; ACTION_SHOW_STAT=1;;
	'-cta'|'--createa')        ACTION_SHOW_HELP=0; ACTION_MAKE_CAREATA=1; ACTION_SHOW_STAT=1;;
	'-crtbl'|'--creatable')    ACTION_SHOW_HELP=0; ACTION_MAKE_CAREATABLE=1; ACTION_SHOW_STAT=1;;
	'-crtblrc'|'--droptable')  ACTION_SHOW_HELP=0; ACTION_MAKE_INSERT_RCHAT=1; ACTION_SHOW_STAT=1;;
	'-drtbl'|'--droptable')    ACTION_SHOW_HELP=0; ACTION_MAKE_DROPTABLE=1; ACTION_SHOW_STAT=1;;
	'-gw'|'--gateway')         ACTION_SHOW_HELP=0; ACTION_SW_GATEWAY=1; ACTION_SHOW_STAT=1;;
	'-mr'|'--msgrcht')         ACTION_SHOW_HELP=0; ACTION_SENDMS_RCHAT=1; ACTION_SHOW_STAT=1;;
	'-mm'|'--msgmail')         ACTION_SHOW_HELP=0; ACTION_SENDMS_MAIL=1; ACTION_SHOW_STAT=1;;
    '-f'|'--flush')            ACTION_SHOW_HELP=0; ACTION_MAKE_FLUSH=1; ACTION_SHOW_STAT=1;;
    '-k'|'--get-key')          ACTION_SHOW_HELP=0; ACTION_GET_KEY=1;;
    '--lkpass-update')         ACTION_SHOW_HELP=0; ACTION_LKPASS_UPDATE=1;;
    '--keys-clean')            ACTION_SHOW_HELP=0; ACTION_KEYS_CLEAN=1;;
    '--keys-show')             ACTION_SHOW_HELP=0; ACTION_KEYS_SHOW=1;;
    '-s'|'--stat')             ACTION_SHOW_HELP=0; ACTION_MAKE_UPDATE=0; ACTION_SHOW_STAT=1;;
    '-l'|'--no-limit')         ACTION_DISABLE_NETWORK_LIMITS=1;;
    '-h'|'-H'|'--help')        ACTION_SHOW_HELP=1;;
    '-V'|'-v'|'--version')     ACTION_SHOW_HELP=0; ACTION_SHOW_VERSION=1;;
  esac;
done;

[[ -z $RESERVINGDNS_VERSION ]] && export RESERVINGDNS_VERSION='[unsetted]';

# Actions declarations
[[ "$ACTION_SHOW_HELP" -eq 1 ]] && {
  self=$(basename "$(test -L "$0" && readlink "$0" || echo "$0")");
  installed="$(ui_style 'installed' 'green')";
  not_installed="$(ui_style 'not installed' 'red bold')";
  curl_inst="$not_installed"    && { system_application_exists 'curl'  && curl_inst="$installed"; };
  wget_inst="$not_installed"    && { system_application_exists 'wget'  && wget_inst="$installed"; };
  psql_inst="$not_installed"    && { system_application_exists 'psql'  && psql_inst="$installed"; };
  openssl_inst="$not_installed"    && { system_application_exists 'openssl'  && openssl_inst="$installed"; };
  sed_inst="$not_installed"    && { system_application_exists 'sed'  && sed_inst="$installed"; };
  xmlstarlet_inst="$not_installed"    && { system_application_exists 'xmlstarlet'  && xmlstarlet_inst="$installed"; };
  mail_inst="$not_installed"    && { system_application_exists 'mail'  && mail_inst="$installed"; };
echo -e "

  $(ui_style 'Reserving DNS Arkan' 'green') ($(ui_style 'https://arkan.ru/' 'yellow underline')), version "$(ui_style "$RESERVINGDNS_VERSION" 'yellow')"

$(ui_style 'Optional depends by:' 'yellow')
  $(ui_style 'sed' 'yellow')         ($sed_inst)
  $(ui_style 'curl' 'yellow')        ($curl_inst)
  $(ui_style 'wget' 'yellow')        ($wget_inst)
  $(ui_style 'psql' 'yellow')        ($psql_inst)
  $(ui_style 'openssl' 'yellow')     ($openssl_inst)
  $(ui_style 'mailutils' 'yellow')   ($mail_inst)
  $(ui_style 'xmlstarlet' 'yellow')  ($xmlstarlet_inst)

$(ui_style 'Usage:' 'yellow')
  $self [options]

$(ui_style 'Options:' 'yellow')
  $(ui_style '-u, --update' 'green')             $(ui_style 'Update Token 3h' 'yellow')
  $(ui_style '-r, --run' 'green')                $(ui_style 'Run logic script' 'yellow')
  $(ui_style '-del, --delete' 'green')           $(ui_style 'Delete DNS A record' 'yellow') ($(ui_style 'Use for Delete DNS A record!' 'red bold'))
  $(ui_style '-cta, --createa' 'green')          $(ui_style 'Create DNS A record' 'yellow')
  $(ui_style '-crtbl, --creatable' 'green')      $(ui_style 'Create Table db PGsql' 'yellow')
  $(ui_style '-crtblrc, --creatablerc' 'green')  $(ui_style 'Create Table db PGsql and Tocket RocketChat' 'yellow')
  $(ui_style '-drtbl, --droptable' 'green')      $(ui_style 'Drop Table db PGsql' 'yellow')
  $(ui_style '-gw, --gateway' 'green')           $(ui_style 'Изменение основного шлюза' 'yellow')
  $(ui_style '-mr, --msgrcht' 'green')           $(ui_style 'Отправка сообщения в RocketChat' 'yellow')
  $(ui_style '-mm, --msgmail' 'green')           $(ui_style 'Отправка сообщения на mail' 'yellow')
  $(ui_style '-f, --flush' 'green')              Remove all downloaded mirror files
  $(ui_style '-k, --get-key' 'green')            $(ui_style 'Get free key' 'yellow') ($(ui_style 'Use for educational or informational purposes only!' 'red bold'))
      $(ui_style '--lkpass-update' 'green')      Update LK user password
      $(ui_style '--keys-clean' 'green')         Test all stored keys and remove invalid
      $(ui_style '--keys-show' 'green')          Show all stored valid keys
  $(ui_style '-C, --color' 'green')              Force enable color output
  $(ui_style '-c, --no-color' 'green')           Force disable color output
  $(ui_style '-s, --stat' 'green')               Show statistics
  $(ui_style '-l, --no-limit' 'green')           Disable any download limits
  $(ui_style '-d, --debug' 'green')              Display debug messages
  $(ui_style '-h, --help' 'green')               Display this help message
  $(ui_style '-v, --version' 'green')            Display script version
  
";
};

[[ "$ACTION_SHOW_VERSION" -eq 1 ]] && {
  echo -e "
Reserving DNS Arkan Script, version $RESERVINGDNS_VERSION
Copyright 2023 plugin.an@arkan.ru
";
};

[[ "$ACTION_MAKE_FLUSH" -eq 1 ]] && {
  ui_message 'debug' 'Execute "flush" action';
  [ -d "$NOD32MIRROR_MIRROR_DIR" ] && {
    find "$NOD32MIRROR_MIRROR_DIR" -type f \(\
      -name '*.nup' \
      -o -name '._*' \
      -o -name '*.ver' \
      -o -name "$NOD32MIRROR_TIMESTAMP_FILE_NAME" \
      -o -name "$NOD32MIRROR_VERSION_FILE_NAME" \)\
      -delete;
    find "$NOD32MIRROR_MIRROR_DIR" -type d \(\
      -name 'pcu' \
      -o -name 'v[0-9]*' \)\
      -exec rm -Rf "{}" +;
    ui_message 'notice' 'Mirror flushed';
  };
};

[[ "$ACTION_GET_KEY" -eq 1 ]] && {
  ui_message 'debug' 'Execute "get key" action';
  echo -e "\n$(ui_style 'Use for educational or informational purposes only!' 'red bold')\n";
  nod32keys_get_valid_key || {
    ui_message 'fatal' 'Cannot get valid free key' && exit 1;
  }
};

[[ "$ACTION_DISABLE_NETWORK_LIMITS" -eq 1 ]] && {
  ui_message 'debug' 'Execute "dissable network limits" action';
  ui_message 'debug' 'Download limits DISABLED';
  export RESERVINGDNS_DOWNLOAD_SPEED_LIMIT=0;
  export RESERVINGDNS_DOWNLOAD_DELAY=0;
};

[[ "$ACTION_LKPASS_UPDATE" -eq 1 ]] && {
  ui_message 'debug' 'Execute "LK password update" action';
  cripto_in 'debug' "$passpsk" "aVGiMAuxqkTT-CMV4mOzqz5tJdfHeoE4Ti9uTthAsPA"
  psql_update 'debug' 'token' 'client_secret' "$varc_in";
};

[[ "$ACTION_KEYS_CLEAN" -eq 1 ]] && {
  ui_message 'debug' 'Execute "keys clean" action';
  nod32keys_remove_invalid_keys;
};

[[ "$ACTION_KEYS_SHOW" -eq 1 ]] && {
  ui_message 'debug' 'Execute "keys show" action';
  nod32keys_get_all_keys 'valid';
};

[[ "$ACTION_MAKE_UPDATE" -eq 1 ]] && {
  ui_message 'debug' 'Execute "reserving_DNS" action';
  # if [[ -z $NOD32MIRROR_MIRROR_DIR ]]; then
    # ui_message 'fatal' 'Empty directory path for mirroring files. Please, check configuration file' && exit 1;
  # fi;
  ui_message 'info' "Проверка токина, тип: access: $(ui_style "scope= dns-master" 'yellow')";
  psql_select 'debug' 'token' 'client_secret_3h'
  cripto_out 'debug' "$passpsk" "$psqlvar"
  dnsapi_commit 'debug' "arkan.su" "$varc_out"
  if [ "$(echo $message_commit | egrep -i '<status>' | cut -d' ' -f1)" == "<status>fail</status>" ]; then
	ui_message 'info' "Отсутствует токен, тип: access: $(ui_style "scope= dns-master" 'yellow')";
	psql_select 'debug' 'token' 'client_id'
	client_id=$psqlvar
	psql_select 'debug' 'token' 'lc_user_name'
	lc_user_name=$psqlvar
	psql_select 'debug' 'token' 'lc_user_hashed_pass'
	cripto_out 'debug' "$passpsk" "$psqlvar"
	lc_user_hashed_pass=$varc_out
	psql_select 'debug' 'token' 'client_secret'
	cripto_out 'debug' "$passpsk" "$psqlvar"
	client_secret=$varc_out
	dnsapi_send_cs3ht 'debug' "$client_id" "$lc_user_name" "$lc_user_hashed_pass" "$client_secret"
	cripto_in 'debug' "$passpsk" "$client_secret_3h_token"
	psql_update 'debug' 'token' 'client_secret_3h' "$varc_in"
  fi
	psql_select 'debug' 'token' 'client_secret_3h'
	cripto_out 'debug' "$passpsk" "$psqlvar"
	dnsapi_commit 'debug' "arkan.su" "$varc_out"
};

[[ "$ACTION_MAKE_RUN" -eq 1 ]] && {
  while true
  do
	logic_isp_to_gw
	ui_message 'info' "sleep 300"
	sleep 300
  done
  # if logic_wordcounts ; then
	# echo "Word Counts r0";
  # else
	# echo "Word Counts r1";
  # fi;
  ######################################################
  # if logic_hping_test "$RESERVINGDNS_TEST_URI" '3'; then
	# if logic_hc_valid_test "$RESERVINGDNS_TEST_URI"; then
		# echo "$http_code r0";
	# else
		# echo "$http_code r1";
	# fi;
  # fi
};

[[ "$ACTION_MAKE_DELETE" -eq 1 ]] && {
  dnszone=$2
  dnsnamel3=$3
  readip=$4
  ui_message 'debug' 'Action Delete DNS A record';
  psql_select 'debug' 'token' 'client_secret_3h'
  cripto_out 'debug' "$passpsk" "$psqlvar"
  dnsapi_delete 'debug' "$dnszone" "$varc_out" "$dnsnamel3" "$readip"
  dnsapi_commit 'debug' "$dnszone" "$varc_out"
};

[[ "$ACTION_MAKE_CAREATA" -eq 1 ]] && {
  dnszone=$2
  dnsnamel3=$3
  readip=$4
  [ "$#" -eq 1 ] && {
    dnszone=arkan.su
    dnsnamel3=test
    readip=84.204.102.210
  };
  ui_message 'debug' 'Action CAREAT DNS A record';
  psql_select 'debug' 'token' 'client_secret_3h';
  cripto_out 'debug' "$passpsk" "$psqlvar";
  dnsapi_creadanameip 'debug' "$dnszone" "$varc_out" "$dnsnamel3" "$readip";
  dnsapi_commit 'debug' "$dnszone" "$varc_out";
};

[[ "$ACTION_MAKE_CAREATABLE" -eq 1 ]] && {
  [ "$#" -eq 1 ] && {
    ui_message 'debug' "Не достаточно ключей для выполнения запроса" && exit 1;
  };
  psql_create 'debug' "$2";
};

[[ "$ACTION_MAKE_INSERT_RCHAT" -eq 1 ]] && {
  [ "$#" -eq 1 ] && {
    ui_message 'debug' "Не достаточно ключей для выполнения запроса" && exit 1;
  };
  cripto_in 'debug' "$passpsk" "$4";
  psql_isert_into_rchat 'debug' "$2" "$3" "$varc_in";
};

[[ "$ACTION_MAKE_DROPTABLE" -eq 1 ]] && {
  [ "$#" -eq 1 ] && {
    ui_message 'debug' "Не достаточно ключей для выполнения запроса" && exit 1;
  };
  psql_delete_table 'debug' "$2";
};

[[ "$ACTION_SHOW_STAT" -eq 1 ]] && {
  mirror_dir="$NOD32MIRROR_MIRROR_DIR";
  [ -d "$mirror_dir" ] && {
    files_count=$(find "$mirror_dir" -type f -iname '*.nup' | wc -l);
    [[ ! "$files_count" == "" ]] && {
      ui_message 'info' "Total updates (*.nup) files count: $(ui_style "$files_count file(s)" 'yellow')";
    };
    updates_files_size=$(find "$mirror_dir" -type f -name '*.nup' -ls | awk '{total += $7} END {printf("%.1fM", (total/1024/1024))}');
    [[ ! "$updates_files_size" == "" ]] && {
      ui_message 'info' "Total updates (*.nup) files size: $(ui_style $updates_files_size 'yellow')";
    };
    mirror_dir_size=$(fs_get_directory_size "$mirror_dir");
    [[ ! "$mirror_dir_size" == "0" ]] && {
      ui_message 'info' "Mirror directory size is $(ui_style $mirror_dir_size 'yellow')";
    };
  };
};

[[ "ACTION_SENDMS_MAIL" -eq 1 ]] && {
  sendmessage_mail 'debug' "$2" "$3" "$4" "$5";
};

[[ "$ACTION_SENDMS_RCHAT" -eq 1 ]] && {
  sendmessage_rchat "$2" "$3";
};

[[ "$ACTION_SW_GATEWAY" -eq 1 ]] && {
  gwip=$2
  [ "$#" -eq 1 ] && {
	gwip=GATEWAY
  };
  gw_switch 'debug' "$gwip"
};

[ -d "$(fs_get_temp_directory)" ] && fs_remove_temp_directory;
