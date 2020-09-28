#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Usage: $0 <test repo URL>"
    exit 1
fi
REPO_URL=$1

IMAGE_BASE_URL='http://lorempixel.com/100/100/cats'

git clone ${REPO_URL} lfs-everything-demo
(
	cd lfs-everything-demo

	COMMIT_COUNT=$(git rev-list --all --count)
	if [[ ${COMMIT_COUNT} -gt 1 ]]; then
		echo "Too many commits: ${COMMIT_COUNT}"
		exit
	fi

	cat <<- 'EOF' > README.md
	# LFS Migration demo
	This repo demonstrates the behavior of `git lfs migrate import --everything --include=...` with multiple branches.
	## Step 1
	Add a file to be migrated.
	EOF

	curl -s ${IMAGE_BASE_URL}/1/ --output image-main.jpg
	git add image-main.jpg
	git commit -am "adds image-main.jpg"

	cat <<- 'EOF' >> README.md
	## Step 2
	Modify the file to be migrated.
	EOF

	curl -s ${IMAGE_BASE_URL}/2/ --output image-main.jpg
	git commit -am "modifies image-main.jpg"
	git push

	git checkout -b test-branch
	git push --set-upstream origin test-branch

	cat <<- 'EOF' >> README.md
	## Step 3
	Add a file to be migrated on a branch.
	EOF

	curl -s ${IMAGE_BASE_URL}/3/ --output image-branch.jpg
	git add image-branch.jpg
	git commit -am "adds image-branch.jpg"
	git push

	git checkout -

	cat <<- 'EOF' >> README.md
	## Step 4
	Run the migration.
	EOF
	git commit -am "adds step 4 to README"
	git push

	git lfs migrate import --everything --verbose --include="*.jp*g"
	git push --force

	cat <<- 'EOF' >> README.md
	## Results
	* `.gitattributes` is rewritten into the initial commit. ✓
	* `image-main.jpg` is in LFS in both commits in the main branch. ✓
	* `.gitattributes` is not present on the branch. ✘
	* `image-main.jpg` and `image-branch.jpg` on the branch are not migrated to LFS. ✘

	The [git lfs migrate docs](https://github.com/git-lfs/git-lfs/blob/master/docs/man/git-lfs-migrate.1.ronn) seem to say that the `--everything` flag should cause branches to be migrated:
	> The presence of flag --everything indicates that all local and remote references should be migrated.
	EOF

	git commit -am "adds results info to README"
	git push
)
