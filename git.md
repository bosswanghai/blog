# Git


### git 分支管理：

   [从0开始github](http://stormzhang.com/github/2016/06/19/learn-github-from-zero-summary/)
   
   [高级用法](http://backlogtool.com/git-guide/cn/stepup/stepup7_4.html)
   
* `查看分支`

```
git branch  查看当前分支
git branch -a 查看本地和远程所有分支

```

* `创建分支`

```
git branch branch_name  创建分支不切换
git checkout -b branch_name [from_branch_name] 创建分支并切换，后面的from_branch_name表示要从哪个分支生成新的分支，不写则是当前分支
git checkout commit_id -b branch_name


```

* `切换分支` git checkout branch_name

* `合并分支` 
git merge [分支名] 命令将指定分支合并到当前工作分支中

* `删除分支`
git branch -d [分支名]
如果分支还没有合入，则以上命令不好用，为了删除分支，需要使用-D参数

* `更新分支`
git pull   = git fetch + git merge
分支合并之前，最好使用 git pull 将 “master” 分支的代码更新到最新

* `推送分支`
git push  [远程仓库名] [分支名]

* git 代码提交：
git status / git diff查看情况(git add后，就不显示差异)

* `合并操作` git merge another_branch  
将另外一个分支合并到当前分支。如果有冲突，会有如下格式：

```
<<<<<<< HEAD

当前分支内容

==========

对端分支内容

>>>>>>>>>

```

* `变基操作` git rebase another_branch 
merge在tig上会显示多个合并轨迹，而rebase则只显示一条轨迹  
在rebase前，尽量不要push，如果push了，则在执行rebase操作后，只能执行push -f才可以提交成功。

git rebase -i old_commit 可以将多个提交合并为一个提交，或者对多个提交的commit注释进行操作。

* `代码暂存`   
  git stash  代码暂存  

  git stash list  查看暂存的文件  

  git stash pop = git stash apply(还原) + git stash drop [stash_id]（删除）

  git stash clear 删除所有的stash文件

```
两个分支master和branch，都在本地搭建的临时分支，如果修改了master中的文件，直接切换到branch分支，则
branch也会显示修改的内容，如果修改branch分支里的内容，提交的时候，则会连master中修改的文件一起提交。
解决办法： git stash，将当前的文件暂存。 回复时候，使用git stash pop

```

* `tag版本` git tag
  轻标签  
  
  git tag v0.1  创建 v0.1tag
  
  git log --decorate 显示包含标签资料的历史记录
  
  注解标签
  
  git tag -am "连猴子都懂的Git" banana
  
  删除标签
  
  git tag -d <tag_name>

* `比较差异`   
  git diff 默认比较当前目录和暂存区之间的差异
  git diff <commit1> <commit2> 比较两次提交之间的差异
  git diff --staged 比较暂存区和版本库之间的差异

* `回退`  
  git reset --hard (commit)
  
  ```
  head: the last success committed
  head~1 <==> head-1
  ```
  
* `修复`  
  git revert 
  修复错误，并**保留历史提交的版本**。如果revert head~1等跨越多个版本，则需要解决冲突后，git revert --contine,再commit提交就可以。
  
* `git cherry-pick`   
  分支A、B，当分支A需要将分支B的某一次提交合入到分支A中，则执行如下操作
  git checkout A
  git cherry-pick B-commit-id
  git add .
  git commit
  
* `查看文件是由谁提交的`

git blame file

### 补充点

`撤销操作`

单个文件 git checkout commit file

整个版本回退 git reset --hard commit

修复已提交的错误

git revert HEAD~1 

修复最后一次提交

git commit --amend

`名词解释`

`HEAD` 指向当前branch的最后一个分支  

```
⇒  cat .git/HEAD
ref: refs/heads/branch1

⇒  cat .git/refs/heads/branch1
255c72541e5b334b266ce9dcf29f735e7bd3a5e8
```


### 疑问点
MR 和 PR 在合并的时候默认会产生一个合并提交，但是如果在合并的时候勾选了“Fast-Forward 模式合并”，服务器会在合并的时候判断该 MR 或者 PR 是否符合“快进模式”合并，如果符合则会按照“快进模式”合并，不产生合并提交，如果是不符合“快进模式”合并的情况，则忽略该选项，依然以产生合并提交的方式合并。这个选项相当于 git merge 的 --ff 参数。


