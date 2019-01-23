
export LC_ALL=en_US.UTF-8

alias l="ls -Glh"
alias cdp="cd ~/Desktop/vetgrid/consensus_te"

tab(){
	column -t $1 | less
}

make_fams(){
	grep '^>' $1 | tr -d '>' | tr '\n' ',' | sed 's/.$//'
}

mount_dir(){
	sshfs -o defer_permissions,volname=NAME USER@SERVER:/path/on/machine ~/Desktop/mountpoint/
}


unmount_dir(){
	umount ~/Desktop/mountpoint
}

samflags(){
	samtools view $1 | cut -f2 | sort | uniq -c
}

samview(){
	samtools view -h $1 | less -S
}

add_symlinks(){
	for f in $(git status --porcelain | grep '^??' | sed 's/^?? //'); do
	    test -L "$f" && echo $f >> .gitignore; # add symlinks
	    test -d "$f" && echo $f\* >> .gitignore; # add new directories as well
	done
}

export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1


PATH="~/sw:${PATH}"
export PATH
