<!-- markdownlint-configure-file {
  "MD013": {
    "code_blocks": false,
    "tables": false
  },
  "MD033": false,
  "MD041": false
} -->

<div align="center">

# mkc - magic keyboard connect

mkc is a **simple** cli tool that fixes the connection problem with Apples Magic Keyboard (when using it with multiple devices).

> :warning: **Important**: mkc searches for devices that have `Magic Keyboard` in their names.

[Getting started](##getting-started) •
[Installation](#installation)

</div>

## Getting started
It is important that your keyboard is switched off when starting mkc.

```sh
mkc             # automatically disconnects, unpairs and repairs the magic keyboard
```
When you are asked whether you want to start pairing, switch on your keyboard and type 'yes' (or 'y').

`mkc` should return a connection request window should be shown. Click connect and you are done.

## Installation

### *Step 1: Install mkc*
Right now, mkc is only installable via homebrew

To install mkc, run these commands in your terminal:

```sh
brew tap konrad-amtenbrink/tap
brew install mkc
```

### *Step 2: Add mkc to you shell*

To add mkc to you shell, run these commands in your terminal:

```sh
echo 'alias mkc="/usr/local/Cellar/mkc/0.1.1/bin/mkc"' >> ~/.zshrc
```
