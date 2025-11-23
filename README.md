# User Account Management System (Bash)

## Overview

This project is a robust, menu-driven Bash script designed to automate the management of Linux user accounts. It provides a Text User Interface (TUI) that allows System Administrators to perform Create, Read, Update, and Delete (CRUD) operations safely and efficiently without memorizing complex command-line flags.

## Features

- **Interactive Menu:** A persistent `while` loop provides a user-friendly menu until the user chooses to exit.
- **User Creation:** Supports adding users with GECOS (full name), default shell selection, and secure password setting via `chpasswd`.
- **User Modification:** Modular menu to update specific attributes:
  - Full Name (`chfn`)
  - Shell (`chsh`)
  - Password (`passwd`)
  - Group Membership (`usermod` / `gpasswd`)
- **Safe Deletion:** Verifies user existence before deletion and offers the option to remove the associated home directory (`userdel -r`).
- **Advanced Listing:** Uses `awk` to format `/etc/passwd` data into a clean, readable table.

## Technical Implementation

This script prioritizes **system stability** and **error handling**:

- **Strict Mode:** Utilizes `set -Eeuo pipefail` to ensure the script exits immediately upon encountering errors or undefined variables.
- **Root Privilege Check:** Automatically detects if the script is run without `sudo` and halts execution to prevent permission issues.
- **Input Validation:** Checks for empty strings and verifies user existence using `id -u` before attempting sensitive operations.

## Prerequisites

- Linux Operating System (Ubuntu/Debian/CentOS, etc.)
- Bash Shell
- Root/Sudo privileges

## Installation & Usage

1. **Clone the repository:**

```bash
git clone https://github.com/yourusername/your-repo-name.git
cd your-repo-name


2.  **Make the script executable:**

```bash
chmod +x project4_user_mgmt.sh

3. **Run with sudo:**

```bash
sudo ./project4_user_mgmt.sh

## Code Structure

The application is structured using modular functions and a central control loop:

- **menu()**: Contains the main `while` loop and `case` statement.
- **add_user()**: Handles user input and executes `useradd`.
- **delete_user()**: Handles verification and runs `userdel`.
- **modify_user()**: Provides a sub-menu for targeted updates.
- **list_users()**: Formats `/etc/passwd` entries for clean viewing.


