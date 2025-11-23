#!/usr/bin/env bash
# SOFE3200 Project 4 — User Account Management Script
# Provides a simple TUI (text UI) for add/del/modify/list users with basic safety.
#
# NOTE: Run with sudo.
#
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || { echo "Please run as root (sudo)." >&2; exit 1; }

read_secret(){
  # prompt silently
  local prompt="$1"
  local varname="$2"
  read -r -s -p "$prompt" val || val=""
  echo
  printf -v "$varname" '%s' "$val"
}

pause(){ read -r -p "Press Enter to continue..." _ || true; }

add_user(){
  read -r -p "Username: " username
  read -r -p "Full name (GECOS): " fullname
  read -r -p "Default shell [/bin/bash]: " shell; shell="${shell:-/bin/bash}"
  read -r -p "Additional groups (comma-separated, optional): " groups
  read_secret "Password (leave blank to set later): " password

  [[ -n "$username" ]] || { echo "Username is required."; return 1; }

  local args=(-m -s "$shell" -c "$fullname")
  if [[ -n "$groups" ]]; then args+=(-G "$groups"); fi

  if id -u "$username" >/dev/null 2>&1; then
    echo "User '$username' already exists."
    return 1
  fi

  useradd "${args[@]}" "$username"
  echo "Created user $username"
  if [[ -n "$password" ]]; then
    echo "${username}:${password}" | chpasswd
    echo "Password set."
  else
    echo "No password set. Use 'passwd ${username}' when ready."
  fi
}

delete_user(){
  read -r -p "Username to delete: " username
  [[ -n "$username" ]] || { echo "Username is required."; return 1; }
  if ! id -u "$username" >/dev/null 2>&1; then
    echo "No such user: $username"; return 1
  fi
  read -r -p "Also remove home directory? [y/N]: " yn
  if [[ "${yn,,}" == "y" ]]; then
    userdel -r "$username"
  else
    userdel "$username"
  fi
  echo "Deleted user $username"
}

modify_user(){
  read -r -p "Username to modify: " username
  [[ -n "$username" ]] || { echo "Username is required."; return 1; }
  if ! id -u "$username" >/dev/null 2>&1; then
    echo "No such user: $username"; return 1
  fi

  echo "1) Change full name"
  echo "2) Change shell"
  echo "3) Change password"
  echo "4) Add to groups"
  echo "5) Remove from groups"
  read -r -p "Choose: " choice

  case "$choice" in
    1)
      read -r -p "New full name: " fullname
      chfn -f "$fullname" "$username"
      echo "Updated."
      ;;
    2)
      read -r -p "New shell [/bin/bash]: " shell; shell="${shell:-/bin/bash}"
      chsh -s "$shell" "$username"
      echo "Updated."
      ;;
    3)
      passwd "$username"
      ;;
    4)
      read -r -p "Comma-separated groups to add: " gs
      usermod -a -G "$gs" "$username"
      echo "Updated."
      ;;
    5)
      read -r -p "Comma-separated groups to remove: " gs
      IFS=',' read -ra arr <<< "$gs"
      for g in "${arr[@]}"; do gpasswd -d "$username" "$g" || true; done
      echo "Updated."
      ;;
    *)
      echo "Invalid choice";;
  esac
}

list_users(){
  echo "System users (name:uid:gid:full name:shell)"
  getent passwd | awk -F: '{printf "%-20s %-8s %-8s %-30s %-20s\n",$1,$3,$4,$5,$7}'
}

menu(){
  while :; do
    clear || true
    cat <<'MENU'
User Account Management
=======================
1) Add user
2) Delete user
3) Modify user
4) List users
5) Quit
MENU
    read -r -p "Select: " sel
    case "$sel" in
      1) add_user; pause;;
      2) delete_user; pause;;
      3) modify_user; pause;;
      4) list_users; pause;;
      5) exit 0;;
      *) echo "Invalid option"; pause;;
    esac
  done
}

menu
