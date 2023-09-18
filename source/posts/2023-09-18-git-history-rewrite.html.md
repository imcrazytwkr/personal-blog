---
title: Rewriting GIT history
date: 2023-09-18
tags: git, shell
---

Yesterday I have been migrating some repositories from self-hosted Gitea instance to cloud BitBucket and stumbled upon a couple of them that got `.gitignore` files added fairly recently and all the vendor files committed into. This resulted in pretty bad repository bloat that can be fairly easy to fix. In this post I am going to explain how I did just that and why I chose some specific options.

All of the aforementioned repositories practiced [Trunk-based development](https://www.atlassian.com/continuous-delivery/continuous-integration/trunk-based-development) which made my job easier as I pretty much only had to rewrite the history of the main branch. Throughout this whole article old trunks are assumed to be `master` branches and new trunks (post-rewrite) are to end up in `main` branches. `cleanup` branch will be used in these examples as a temporary branch we do our actual work on.

## Initial setup

To start with, we must derive a new branch from the first commit of the old `master` branch, add `.gitignore` and amend commit:

```bash
git checkout master
git checkout -b main "$(git rev-list HEAD | tail -n 1)"

vim .gitignore
git commit --amend
```

**Fair warning:** at this point you should not remove any files because in the next step we are going to do some rebasing and the process will break at first if you remove some file that has been updated in any of more recent commits.

As I have mentioned in the warning paragraph earlier, now we are going to checkout a temporary branch from the most recent commit of the old `master` and rebase it onto out new `main` branch:

```bash
git checkout master
git checkout -b cleanup

git rebase main
```

## Rewriting branch history

Next part is a bit tricky because we are going to be actually doing some destructive stuff on the cleanup branch. At first we are going to iterate over repository state of every commit using `git filter-branch` and remaking out commits:

```bash
git filter-branch --tree-filter 'git rm --cached -rf .; git add .; git clean -d -X -f'
```

Unlike rebase operation, tree filter checkouts complete state of every commit one by one into a separate folder and recreates all the git diffs. That means that if we remove, for example, `node_modules` in the first commit, recreating second one will not break. If rebase had been used here, it would have erred because it expects for all files updated in future commits to be present and we cannot guarantee that.

After rewrite is complete, you should inspect commits on the new branch visually. If everything seems okay (empty commits are okay, we will fix this in the next step), we can safely proceed with removing backed up `cleanup` branch. `filter-branch` creates them automatically and doesn't always work correctly when we have an old one even if you supply the force flag `-f` so it is safer and more convenient to do tidy things first.

```bash
git for-each-ref --format='%(refname)' refs/original/ | xargs -n 1 git update-ref -d
```

**Note:** `xargs -n 1` is not an equivalent of piping previous stdout to `head -n 1`. It controls how many arguments are passed onto the supplied command on each iteration. `update-ref` expects to receive only one reference and forcing multiple ones into it isn't going to work.

## Removing empty commits

Next step is optional and is only needed if you end up with empty commits in the history of `cleanup` branch. You can use this script to list empty commits:

```bash
#!/bin/sh

git rev-list HEAD | while read -r hash; do
  [ -z "$(git diff-tree --root --no-commit-id --name-status "$hash")" ] && echo "$hash"
done
```

This small script iterates through commits of the  current branch, gets FS tree diff listing and outputs hashes of empty commits. Here's an explanation of extra flags passed to `git diff-tree` along with explanations on why I'm using them:

- `--root` flag  makes diff-tree list changes even for the initial commit. Without it, the first commit is going to be mistaken for blank by this script.
- `--no-commit-id` skips printing commit's hash to stdout. Without it, `diff-tree` has inconsistent behavior when it comes to displaying blank commits: on some versions of git it does not print anything while on the others it prints only the commit hash.
- `--name-status` is not important because the only thin it does is speeding up the operation by limiting stdout output and skipping extra meta processing (GIT also keeps file permissions inside the repo). Depending on how long your repo history is and how fast of an SSD you have, there may not be any noticeable difference but there's also no reason not to add it.

If like me, you do end up with some empty commits, these two commands will remove those from your history and tidy the branch up:

```bash
git filter-branch --commit-filter 'git_commit_non_empty_tree "$@"'
git for-each-ref --format='%(refname)' refs/original/ | xargs -n 1 git update-ref -d
```

## Final steps

The only thing left to do now is to fast-forward `main` branch with shiny new commits from `cleanup` and remove now redundant branch:

```bash
git checkout main
git merge cleanup --ff-only
git branch -d cleanup
```

I'm using `--ff-only` instead of regular `--ff` here as a precaution. `--ff-only` aborts merge and exits git process with a non-zero code if it finds any problems along the way. This, to me, is an indicator that something went wrong in earlier stages and that I should retrace my steps and fix the reason for fast-forward to fail. If you do not want to go an extra mile, feel free to use regular `--ff` instead which will create a merge commit where you can fix any problems straight away at the expense of extra commits on the `main` branch.

## Bonus section: when you need to rewrite commit authors

During my migration I have stumbled upon a problem: some commit authors no longer had access to the email addresses they used to have and that was not ideal. I checked with project maintainers and they told me that commit timestamps aren't that important as long as history itself does not change. This was great because I was only aware of one reliable method of changing authors and it rewrites timestamps to the current one. Here is how I did it:

```bash
git rebase -r --root --exec 'git commit --amend --no-edit --author="$(remap_autor "$(git show --format="%aE" | head -n 1)")"'
```

`remap_author` in this case is a custom script that accepts current committer's old email and returns new author string in the `New Name <new_email@example.com>` format. It is usually fairly trivial to implement one and the actual implementation depends on how you keep user mappings and how much data you have.

The rest of the command is fairly self-explanatory so if you have any kind of questions, [contact me](/about/), and I will update this post to clarify it in details or write a whole other blog post if the explanation ends up being too long.

Thank you for reading this post from start to finish! If you have any experience rebuilding more complex repositories, feel free to reach me out too: I would be glad to update this post with more info.
