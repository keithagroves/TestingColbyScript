#!/bin/sh
#%author: Colby Schexnayder

# This script makes the following assumptions:
#
# 1. The local files have not been changed from Central,
#   ANY CHANGES MUST BE COMMITTED AND PUSHED IMMEDIATELY
#
# 2. Once a Repository is added to the RepoList it will
#    only be updated by this script push changes
#    from central to the Repo
#############################################
#BEGIN SCRIPT


#Step 1: pull from Central
echo "Pulling from Central"
git pull

#Step 2: Search through RepoList
while read in; do
    repoName=$(basename "$in" ".${in##*.}")
    
    #If the local Repo doesn't exist check github
    if [ ! -d "$repoName" ]
        then
        echo "$repoName is not in Central"
        echo "Checking github"
        git clone $in
#	git add ${repoName}
    else
        #If the repo exists locally check for external repo
        if git ls-remote --exit-code $in
        then
            #If the repo does exist generate .git
            echo "$repoName exists"
            echo "Generating .git"
            cd $repoName
            git clone --no-checkout $in
            cd $repoName
            mv ./.git ..
            cd ..
            rm -rf $repoName
            echo "Updating $repoName from Central"
            git add -A
            git commit -m "Updated from Central"
            git push
            cd ..
        else
            #If the external repo does not exist create it
            echo "Creating external Repo"
            cd $repoName
            git init
            git add .
            git commit -m "Created From Central"
            git branch -M main
            gh repo create "$repoName" --public --confirm
            git push -u origin main
            cd ..
        fi
    fi

    if [ -d "$repoName" ]
    then
        echo "Removing .git"
        cd $repoName
        rm -rf .git
        cd ..
    fi
done < RepoList.txt

#Step 3: Update Central
echo "Updating Central"
git add -A
git commit -m "Automatic Update"
git push
echo "Finished"
