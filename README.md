# XD

<!-- vscode-markdown-toc -->
* 1. [Kickoff note](#Kickoffnote)
* 2. [Usage](#Usage)
* 3. [Installation](#Installation)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='Kickoffnote'></a>Kickoff note

XD does many things and does them moderately well – yes, no, XD is not the 'Unix way.' However, it does what you probably wanted to do anyway, so why not...

##  2. <a name='Usage'></a>Usage

With XD life becomes easy...

```sh
# ls -lha
xd
```

```sh
# mkdir -p new_dir/inside_dir
# cd new_dir/inside_dir
xd new_dir/inside_dir
```

```sh
# tar zcf existing_dir.tar.gz existing_dir
xd existing_dir.tar.gz
```

```sh
# tar zcf archive.tar.gz existing_dir
xd archive.tar.gz existing_dir
```

```sh
# tar zcf archive.tar.gz existing_dir
xd archive.tar.gz existing_dir
```

```sh
# tar zxf archive.tar.gz
xd archive.tag.gz
```

```sh
# mkdir -p new_dir
# tar zxf archive.tar.gz -C new_dir
xd archive.tag.gz new_dir
```

```sh
# vim file.txt
xd file.txt
```

##  3. <a name='Installation'></a>Installation

```sh
git clone --branch=release https://gitlab.com/mariusz-kowalski/xd.git $HOME/.local/share/xd
```

Add this line to your shell rc file: ($HOME/.zshrc $HOME/.bashrc)

```sh
source $HOME/.local/share/xd/xd.sh
```
