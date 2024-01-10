printf 'Configuring SSH-Agent\n'
eval "$(ssh-agent -s)"

printf '\nAdding id to SSH-Agent\n'
#ssh-add ~/.ssh/own_repo
ssh -T github_own

printf '\nChecking git\n'
git status