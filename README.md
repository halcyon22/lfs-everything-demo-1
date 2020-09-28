# LFS Migration demo
This repo demonstrates the behavior of `git lfs migrate import --everything --include=...` with multiple branches.
## Step 1
Add a file to be migrated.
## Step 2
Modify the file to be migrated.
## Step 4
Run the migration.
## Results
* `.gitattributes` is rewritten into the initial commit. ✓
* `image-main.jpg` is in LFS in both commits in the main branch. ✓
* `.gitattributes` is not present on the branch. ✘
* `image-main.jpg` and `image-branch.jpg` on the branch are not migrated to LFS. ✘

The [git lfs migrate docs](https://github.com/git-lfs/git-lfs/blob/master/docs/man/git-lfs-migrate.1.ronn) seem to say that the `--everything` flag should cause branches to be migrated:
> The presence of flag --everything indicates that all local and remote references should be migrated.
